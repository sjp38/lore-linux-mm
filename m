Date: Wed, 22 Dec 1999 23:00:40 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [patch] mmap<->write deadlock fix, plus bug in block_write_zero_range
In-Reply-To: <Pine.LNX.3.96.991222103000.22064A-100000@kanga.kvack.org>
Message-ID: <Pine.BSO.4.10.9912222254540.25860-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 1999, Benjamin C.R. LaHaise wrote:
> On Wed, 22 Dec 1999, Chuck Lever wrote:
> > On Wed, 22 Dec 1999, Benjamin C.R. LaHaise wrote:
> > i've tried this before several times.  i could never get the system to
> > perform as well under benchmark load using find_page_nolock as when using
> > find_get_page. the throughput difference was about 5%, if i recall.  i
> > haven't explained this to myself yet.
>
> Here's my hypothesis about why find_page_nolock vs find_get_page makes a
> difference: using find_page_nolock means that we'll never do a
> run_task_queue(&tq_disk); to get our async readahead requests run.  So, in
> theory, doing that in filemap_nopage will restore performance.  Isn't
> there a way that the choice of when to run tq_disk could be made a bit
> less arbitrary?

this patch appears to have negligible effect on benchmark throughput
measurements, whereas, without the run_task_queue, throughput drops.

btw, i notice that a "read_cache_page" function has appeared that looks
similar to "page_cache_read" -- is there necessity for both?

--- linux-2.3.34-ref/mm/filemap.c	Wed Dec 22 21:23:03 1999
+++ linux/mm/filemap.c	Wed Dec 22 22:53:19 1999
@@ -1325,9 +1325,13 @@
 	 */
 	hash = page_hash(&inode->i_data, pgoff);
 retry_find:
-	page = __find_get_page(&inode->i_data, pgoff, hash);
+	spin_lock(&pagecache_lock);
+	page = __find_page_nolock(&inode->i_data, pgoff, *hash);
 	if (!page)
 		goto no_cached_page;
+	get_page(page);
+	spin_unlock(&pagecache_lock);
+	run_task_queue(&tq_disk);
 
 	/*
 	 * Ok, found a page in the page cache, now we need to check
@@ -1358,6 +1362,8 @@
 	return old_page;
 
 no_cached_page:
+	spin_unlock(&pagecache_lock);
+
 	/*
 	 * If the requested offset is within our file, try to read a whole 
 	 * cluster of pages at once.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
