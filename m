Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D31476B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 19:52:23 -0500 (EST)
Message-ID: <512C0746.6020408@ubuntu.com>
Date: Mon, 25 Feb 2013 19:52:22 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Something amiss with IO throttling
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

There seems to be something wrong with IO throttling in recent
kernels.  I have noticed two problems recently:

1)  I noticed that the man page for readahead() states that it blocks
until the data has been read, which is incorrect.  The whole point of
the call is that it initiates background read(ahead), in the hopes
that it will finish before the data is actually read, just like
posix_fadvise(POSIX_FADV_WILLNEED).  Testing however, indicates that
indeed, both readahead() and fadvise with POSIX_FADV_WILLNEED does
appear to be blocking at least for most of the time it takes to read a
large file.  In my case I'm reading a 400mb file after dropping cache
and having 2+gb of free ram, and the readahead/fadvise blocks for
nearly the 5 seconds it takes to read that.

I made sure that the queue is not getting full by increasing
max_sectors_kb to 4096, and nr_requests to 4096 and verifying that the
file is in a single contiguous extent using ext4 extents, so no need
to read indirect blocks ( which was the cause of readahead() blocking
I ran into a few years ago ).

2)  I have been trying to figure out why restoring a level 0 dump is
only getting half or less the throughput it should.  Inspection of
blktrace data seemed to show that there were a fair number of seeks
back and forth between the file data, which was largely contiguous
thanks to the ext4 multiblock allocator, and metadata ( inodes,
directories, bitmaps ).  Even after implementing POSIX_FADV_NOREUSE in
the hopes that this would allow the file data to migrate out first and
the metadata to remain cached until later so these seeks could be
avoided, there was little to no improvement.  Prior to my recent pair
of patches implementing NOREUSE and fixing DONTNEED, using DONTNEED
and/or sync_file_range(SYNC_FILE_RANGE_WRITE) actually made things
*worse*, indicating that they too were being unnecessarily throttled.

I noticed that during the restore, write queues are not full, dirty
pages are nowhere near dirty_max_ratio, and pages in Writeback are
only 1-3 MB, yet the restore process is being throttled.  I also
disabled dirty_writeback_centisecs.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQEcBAEBAgAGBQJRLAdGAAoJEJrBOlT6nu75954IAMaYCgimvT7ftDb8a4QGdYaD
mvXIErscjEoZeke/CufYuckKyziYkhjD3yrZmBBPpM3+EZQJHynVb/c9bh0IB64C
P/1uxOW5Si6q5u/qchIA7kZo4PHfyNjSNehtLG3urK7/8XvSMxZbE1tTX5BSKjCJ
edpwpYXie6HiKCKRnbiYGSD8wnFDOvygE+KRQ37DoYyP+UVaPTiWwOc9RFGKgAgX
ET14fHHD72t7BXtpAsErMwRJhE1Aw8L23mP20O4yN2rY3maIMuQzv1wFeRzUDLqn
TE6+4OAZRFkJpBjHXr3RUme7jq300a8YsbaHGCjx0XA0N1uxjLVxQRLc2blGOso=
=eNWA
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
