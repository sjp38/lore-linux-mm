Message-ID: <39654CCC.9DE5000E@uow.edu.au>
Date: Fri, 07 Jul 2000 13:21:48 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: new latency report
References: <3965371A.6F72A3FF@norran.net>
Content-Type: multipart/mixed; boundary="------------0E34CBC9C170CD1E38A3D01D"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-audio-dev@ginette.musique.umontreal.ca" <linux-audio-dev@ginette.musique.umontreal.ca>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------0E34CBC9C170CD1E38A3D01D
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Roger Larsson wrote:
> 
> Hi,
> 
> The attached output shows that when we hit swap - there are
> code lines with latency problems :-(
> [the actual code tested is test3-pre2 with my latency modifications
>  (improvement and profiling) but has one modification relative
> test3-pre4
>  kswapd in the tested version always sleeps => problems accounted
>  to the process causing it]

I'm losing sleep over kswapd.

> see the 293ms in generic_make_request...

Try adding the attached patch to your existing tree.  It fixes a lot of stuff.  sys_close() and sys_exit() still need attention.

> and the 704ms used to busy loop in modprobe...
> (SB16 non PnP)

Don't worry about it.

> These are worse then the previously found aux_write_dev :-(

Or this.
--------------0E34CBC9C170CD1E38A3D01D
Content-Type: text/plain; charset=us-ascii;
 name="low-latency.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="low-latency.patch"

--- linux-2.4.0-test3-pre4/mm/filemap.c	Thu Jul  6 20:23:47 2000
+++ linux-akpm/mm/filemap.c	Fri Jul  7 01:39:02 2000
@@ -160,6 +160,8 @@
 	start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 
 repeat:
+	if (current->need_resched)
+		schedule();		/* LOWLATENCY sys_unlink() */
 	head = &mapping->pages;
 	spin_lock(&pagecache_lock);
 	curr = head->next;
@@ -450,6 +452,10 @@
 
 		page_cache_get(page);
 		spin_unlock(&pagecache_lock);
+
+		if (current->need_resched)
+			schedule();		/* LOWLATENCY sys_sync() */
+
 		lock_page(page);
 
 		/* The buffers could have been free'd while we waited for the page lock */
@@ -1081,6 +1087,9 @@
 		 * "pos" here (the actor routine has to update the user buffer
 		 * pointers and the remaining count).
 		 */
+		if (current->need_resched)
+			schedule();		/* LOWLATENCY sys_read() */
+
 		nr = actor(desc, page, offset, nr);
 		offset += nr;
 		index += offset >> PAGE_CACHE_SHIFT;
@@ -1533,6 +1542,8 @@
 	 * vma/file is guaranteed to exist in the unmap/sync cases because
 	 * mmap_sem is held.
 	 */
+	if (current->need_resched)
+		schedule();		/* LOWLATENCY sys_msync() */
 	return page->mapping->a_ops->writepage(file, page);
 }
 
@@ -2486,6 +2497,9 @@
 	while (count) {
 		unsigned long bytes, index, offset;
 		char *kaddr;
+
+		if (current->need_resched)
+			schedule();		/* LOWLATENCY sys_write() */
 
 		/*
 		 * Try to find the page in the cache. If it isn't there,


--------------0E34CBC9C170CD1E38A3D01D--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
