Received: from localhost (riel@localhost)
	by brutus.conectiva.com.br (8.11.1/8.11.1) with ESMTP id eB4D7X729367
	for <linux-mm@kvack.org>; Mon, 4 Dec 2000 11:07:33 -0200
Date: Mon, 4 Dec 2000 11:07:33 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: vm_pageout_scan badness (fwd)
Message-ID: <Pine.LNX.4.21.0012041106590.29258-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

below you'll find a nice analysis of some *very* interesting
artifacts caching and read-ahead can have when interfering
with each other ...

Rik
---------- Forwarded message ----------
Date: Sun, 3 Dec 2000 16:53:49 -0800 (PST)
From: Matt Dillon <dillon@earth.backplane.com>
To: News History File User <newsuser@free-pr0n.netscum.dk>
Cc: hackers@FreeBSD.ORG, usenet@tdk.net
Subject: Re: vm_pageout_scan badness

    ok, since I got about 6 requests in four hours to be Cc'd, I'm 
    throwing this back onto the list.  Sorry for the double-response that
    some people are going to get!

    I am going to include some additional thoughts in the front, then break
    to my originally private email response.

    I ran a couple of tests with MAP_NOSYNC to make sure that the
    fragmentation issue is real.  It definitely is.  If you create a
    file by ftruncate()ing it to a large size, then mmap() it SHARED +
    NOSYNC, then modify the file via the mmap, massive fragmentation occurs
    on the file.  This is easily demonstrated by issuing a sequential read
    on the file and noting that the system is not able to do any clustering
    whatsoever and gets a measily 0.6MB/sec of throughput (on a disk
    that can do 12-15MB/sec).  (and the disk seeks wildly during the read).

    When you create a large file and fill it with zero's, THEN mmap() it
    SHARED + NOSYNC and write to it randomly via the mmap(), the file 
    remains laid on disk optimally.  However, I noticed something interesting!
    When I dd if=file of=/dev/null bs=32k the file the first time after
    randomly writing it and then fsync()ing it, I only get 4MB/sec of
    throughput.  If I dd the file a second time I get around 8MB/sec.  If
    I dd it the third time I get the platter speed - 12-15MB/sec.  The issue
    here has to do with the fact that the file is partially cached in the
    first two dd runs.

    The partially cached file shortcuts the I/O clustering code, preventing
    it from issueing read aheads once it hits a buffer that is already
    in the cache.  So if you have a spattering of cached blocks and then
    read a file sequentially, you actually get lower throughput then if
    you don't have *any* cached blocks and then read the file sequentially.
    Verrry interesting!  I think it may be beneficial to the clustering code
    to issue the full read-ahead even if some of the blocks in the middle
    are already cached.  The clustering code only operates when sequential
    operation is detected, so I don't think it can make things worse.

    large file == at least 2 x main memory.


    -- original response --

    Ok, lets concentrate on your hishave, artclean, artctrl, and overview
    numbers.

:-rw-rw-r--  1 news  news  436206889 Dec  3 05:22 history
:-rw-rw-r--  1 news  news         67 Dec  3 05:22 history.dir
:-rw-rw-r--  1 news  news   81000000 Dec  1 01:55 history.hash
:-rw-rw-r--  1 news  news   54000000 Nov 30 22:49 history.index
:
:More observations that may or may not mean anything -- before rebooting,
:I timed the `fsync' commands on the 108MB and 72MB history files, as

    note: the fsync command will not flush MAP_NOSYNC pages.

:The time taken to do the `fsync' was around one minute for the two
:history files.  And around 1 second for the BerkeleyDB file...

    This is an indication of file fragmentation, probably due to holes
    in the history file being filled via the mmap() instead of filled via
    write().

    In order for MAP_NOSYNC to be reasonable, you have to fix the code
    that extends a file via ftruncate()s to write() zero's into the 
    extended portion.

:data getting flushed to disk, then it seems like someone's priorities
:are a bit, well, wrong.  The way I see it, by giving the MAP_NOSYNC
:flag, I'm sort of asking for preferential treatment, kinda like mlock,
:even though that's not available to me as `news' user.

     The pages are treated the way any VM page is treated... they'll
     be cached based on use.  I don't think this is the problem.

    Ok, lets look at a summary of your timing results:
    
    hishave		overv		artclean	artctrl

    38857(26474)	112176(6077)	12264(6930)	2297(308)
    22114(28196)	136855(6402)	12757(7295)	1257(322)
    13614(24312)	156723(6071)	13232(6800)	324(244)
    9944(25198)		164223(6620)	13441(7753)	255(160)
    2777(50732)		24979(3788)	29821(4017)	131(51)
    31975(11904)	21593(3320)	25148(3567)	5935(340)

    Specifically, look at the last one where it blew up on you.  hishave
    and artctrl are much worse, overview and artclean are about the same.

    This is an indication of excessive seeking on the history disk.  I
    believe that this seeking may be due to file fragmentation.

    There is an easy way to test file fragmentation.  Kill off everything
    and do a 'dd if=history of=/dev/null bs=32k'.  Do the same for 
    history.hash and history.index.  Look at the iostat on the history
    drive.  Specifically, do an 'iostat 1' and look at the KB/t (kilobytes
    per transfer).  You should see 32-64KB/t.  If you see 8K/t the file
    is severely fragmented.  Go through the entire history file(s) w/ dd...
    the fragmentation may occur near the end.

    If the file turns out to be fragmented, the only way to fix it is to 
    fix the code that extends the file.  Instead of ftruncate()ing the file
    and then appending to it via the mmap(), you should modify the
    ftruncate() code to fill in the hole with write()'s before returning,
    so the modifications via mmap() are modifying pages that already have
    file-backing store rather then filling in holes.

    Then rewrite the history file (e.g. 'cp'), and restart innd.

						    -Matt




To Unsubscribe: send mail to majordomo@FreeBSD.org
with "unsubscribe freebsd-hackers" in the body of the message

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
