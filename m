Date: Thu, 9 Dec 2004 00:33:15 +0100
From: Miquel van Smoorenburg <miquels@cistron.nl>
Subject: Re: PATCH: mark_page_accessed() for read()s on non-page boundaries
Message-ID: <20041208233314.GA13529@cistron.nl>
References: <20041207213819.GA32537@cistron.nl> <20041207135205.783860cf.akpm@osdl.org> <1102457139l.23999l.3l@stargazer.cistron.net> <20041207142805.2b7517b7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041207142805.2b7517b7.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

According to Andrew Morton:
> It'll probably need to handle the "Maximally shrunk" case too.  But I've
> locally merged some readahead rework from Steve Pratt and Ram Pai, and it
> looks like the changes will be simpler in that case:

It looks like I can just set ra->prev_page unconditionally...

I redid the patch against 2.6.10-rc3 and ran some tests:

- Boot kernel with mem=128M

- create a testfile of size 8 MB on a partition. Unmount/mount.

- then generate about 10 MB/sec streaming writes

	for i in `seq 1 1000`
	do
		dd if=/dev/zero of=junkfile.$i bs=1M count=10
		sync
		cat junkfile.$i > /dev/null
		sleep 1
	done

- use an application that reads 128 bytes 64000 times from a
  random offset in the 64 MB testfile.

1. Linux 2.6.10-rc3 vanilla, no streaming writes:

# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.22s system 5% cpu 4.456 total

2. Linux 2.6.10-rc3 vanilla, streaming writes:

# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.16s system 2% cpu 7.667 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.37s system 1% cpu 23.294 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.02s user 0.99s system 1% cpu 1:11.52 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.21s system 2% cpu 10.273 total

3. Linux 2.6.10-rc3 with read-page-access.patch , streaming writes:

# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.02s user 0.21s system 3% cpu 7.634 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.04s user 0.22s system 2% cpu 9.588 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.02s user 0.12s system 24% cpu 0.563 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.13s system 98% cpu 0.163 total

As expected, with the read-page-access.patch, the kernel keeps
the 8 MB testfile cached as expected, while without it,
it doesn't.

So this is useful for workloads where one smallish (wrt RAM) file
is read randomly over and over again (like heavily used database
indexes), while other I/O is going on. Plain 2.6 caches those files
poorly, if the app uses plain read().

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=



PATCH: mark_page_accessed() for read()s on non-page boundaries

When reading a (partial) page from disk using read(), the kernel only
marks the page as "accessed" if the read started at a page boundary.
This means that files that are accessed randomly at non-page boundaries
(usually database style files) will not be cached properly.

The patch below uses the readahead state instead. If a page is read(),
it is marked as "accessed" if the previous read() was for a different
page, whatever the offset in the page.

Signed-Off-By: Miquel van Smoorenburg <miquels@cistron.nl>


diff -ruN linux-2.6.10-rc3.orig/mm/filemap.c linux-2.6.10-rc3/mm/filemap.c
--- linux-2.6.10-rc3.orig/mm/filemap.c	2004-12-08 16:05:17.000000000 +0100
+++ linux-2.6.10-rc3/mm/filemap.c	2004-12-08 16:50:17.000000000 +0100
@@ -689,6 +689,7 @@
 {
 	struct inode *inode = mapping->host;
 	unsigned long index, end_index, offset;
+	unsigned long prev_page;
 	loff_t isize;
 	struct page *cached_page;
 	int error;
@@ -719,6 +720,8 @@
 		}
 		nr = nr - offset;
 
+		prev_page = ra.next_size ? ra.prev_page : -1UL;
+
 		cond_resched();
 		page_cache_readahead(mapping, &ra, filp, index);
 
@@ -726,10 +729,13 @@
 		page = find_get_page(mapping, index);
 		if (unlikely(page == NULL)) {
 			handle_ra_miss(mapping, &ra, index);
+			prev_page = -1UL;
 			goto no_cached_page;
 		}
-		if (!PageUptodate(page))
+		if (!PageUptodate(page)) {
+			prev_page = -1UL;
 			goto page_not_up_to_date;
+		}
 page_ok:
 
 		/* If users can be writing to this page using arbitrary
@@ -740,9 +746,10 @@
 			flush_dcache_page(page);
 
 		/*
-		 * Mark the page accessed if we read the beginning.
+		 * When (part of) the same page is read multiple times
+		 * in succession, only mark it as accessed the first time.
 		 */
-		if (!offset)
+		if (prev_page != index)
 			mark_page_accessed(page);
 
 		/*
diff -ruN linux-2.6.10-rc3.orig/mm/readahead.c linux-2.6.10-rc3/mm/readahead.c
--- linux-2.6.10-rc3.orig/mm/readahead.c	2004-10-18 23:53:11.000000000 +0200
+++ linux-2.6.10-rc3/mm/readahead.c	2004-12-08 16:07:40.000000000 +0100
@@ -364,6 +364,7 @@
 		if (ra->next_size != 0)
 			goto out;
 	}
+	ra->prev_page = offset;
 
 	if (ra->next_size == -1UL)
 		goto out;	/* Maximally shrunk */
@@ -382,13 +383,10 @@
 		 */
 		first_access=1;
 		ra->next_size = max / 2;
-		ra->prev_page = offset;
 		ra->currnt_wnd_hit++;
 		goto do_io;
 	}
 
-	ra->prev_page = offset;
-
 	if (offset >= ra->start && offset <= (ra->start + ra->size)) {
 		/*
 		 * A readahead hit.  Either inside the window, or one
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
