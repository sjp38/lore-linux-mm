Subject: Re: [itcompilesshipitPATCH] -ac22-riel vm improvement?
References: <Pine.LNX.4.21.0006192052001.7938-100000@duckman.distro.conectiva>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Rik van Riel's message of "Mon, 19 Jun 2000 20:57:51 -0300 (BRST)"
Date: 20 Jun 2000 02:11:02 +0200
Message-ID: <yttzoohnre1.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "rik" == Rik van Riel <riel@conectiva.com.br> writes:

Hi

rik> the following patch should implement the following things,
rik> but due to lack of a test machine at home and enormous
rik> peer pressure by the #humboltluitjes folks to send this
rik> out _before_ dinner, I can't tell for sure...

rik> - shrink_mmap() deadlock prevention
rik> - uses bdflush/kflushd to sync the dirty buffers in an
rik>   efficient way (only stalls when we really can't keep up)
rik> - uses the memory_pressure() stuff to make sure we don't do
rik>   too much work
rik> - reintroduces the zone->free_pages > zone->pages_high patch

rik> Since all of this patch does no more than simple code reuse of
rik> other parts of the kernel, it should be good enough to give it
rik> a try and tell me if it works :)

Rik forgot the patch to try_to_free_buffers that accept the -1
argument, here it is.


Later, Juan.

> Hi quintela,

> this patch adds an option to try_to_free_buffers where file IO is
> skipped alltogether...

> cheers,


--- fs/buffer.c.orig	Thu Jun  8 12:57:35 2000
+++ fs/buffer.c	Thu Jun  8 12:59:44 2000
@@ -2234,6 +2234,11 @@
  * NOTE: There are quite a number of ways that threads of control can
  *       obtain a reference to a buffer head within a page.  So we must
  *	 lock out all of these paths to cleanly toss the page.
+ *
+ * Different values for wait:
+ * -1:  don't do IO to free the buffers associated with page
+ *  0:  start asynchronous IO to free the buffers
+ *  1:  wait until the buffers have been freed
  */
 int try_to_free_buffers(struct page * page, int wait)
 {
@@ -2286,7 +2291,7 @@
 	spin_unlock(&free_list[index].lock);
 	write_unlock(&hash_table_lock);
 	spin_unlock(&lru_list_lock);	
-	if (sync_page_buffers(bh, wait))
+	if (wait >= 0 && sync_page_buffers(bh, wait))
 		goto again;
 	return 0;
 }




-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
