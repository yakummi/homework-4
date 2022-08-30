-- количество исполнителей в каждом жанре

SELECT name_genre, COUNT(artist_id) as count_artists
FROM genres 
	JOIN artists_genres USING(genre_id)
GROUP BY name_genre;

-- количество треков, вошедших в альбомы 2019-2020 годов;

SELECT name_album, release_year, COUNT(name_composition) AS count_trek
FROM albums 
	JOIN compositions USING(album_id)
WHERE release_year BETWEEN '2019-01-01' AND '2020-12-31'
GROUP BY name_album, release_year;

--средняя продолжительность треков по каждому альбому;

SELECT name_album, ROUND(AVG(duration), 2) AS avg_duration_trek
FROM albums 
	JOIN compositions USING(album_id)
GROUP BY name_album;

--все исполнители, которые не выпустили альбомы в 2020 году;

SELECT DISTINCT name_artist
FROM artists 
	JOIN artists_albums USING(artist_id)
	JOIN albums USING(album_id)
WHERE artist_id  NOT IN (SELECT artist_id
							  FROM artists_albums
							  		INNER JOIN albums USING(album_id)
							  WHERE TO_CHAR(albums.release_year, 'YYYY') LIKE '%2020%')
GROUP BY name_artist;

--названия сборников, в которых присутствует конкретный исполнитель (выберите сами);

SELECT DISTINCT (name_digest, name_artist)
FROM digests 
	JOIN compositions_digests USING(digest_id)
	JOIN compositions USING(composition_id)
	JOIN albums USING(album_id)
	JOIN artists_albums USING(album_id)
	JOIN artists USING(artist_id)
WHERE name_artist LIKE 'Noize%'
GROUP BY name_digest, name_artist;

--название альбомов, в которых присутствуют исполнители более 1 жанра;
	
SELECT name_album, name_artist, COUNT(name_genre) AS count_genre
FROM albums
	JOIN artists_albums USING(album_id)
	JOIN artists USING(artist_id)
	JOIN artists_genres USING(artist_id)
	JOIN genres USING(genre_id)
GROUP BY name_album, name_artist
HAVING COUNT(name_genre) > 1;

--наименование треков, которые не входят в сборники;

SELECT DISTINCT name_composition
FROM compositions 
	JOIN compositions_digests USING(composition_id)
WHERE compositions_digests.digest_id is Null
GROUP BY name_composition;

--исполнителя(-ей), написавшего самый короткий по продолжительности трек (теоретически таких треков может быть несколько);

SELECT DISTINCT (name_artist, duration)
FROM artists 
	INNER JOIN artists_albums USING(artist_id)
	INNER JOIN albums USING(album_id)
	INNER JOIN compositions USING(album_id)
WHERE duration = (SELECT MIN(duration)
				  FROM compositions)
GROUP BY name_artist, duration;

--название альбомов, содержащих наименьшее количество треков.

SELECT name_album, COUNT(name_composition) AS count_trek
FROM albums
	INNER JOIN compositions USING (album_id)
GROUP BY name_album
HAVING COUNT(name_composition) = (SELECT COUNT(name_composition) AS c
								  FROM albums
									  INNER JOIN compositions USING(album_id)
								  GROUP BY name_album
								  ORDER BY c
								  LIMIT 1);
