Subject: [patch] improve streaming I/O [bug in shrink_mmap()]
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 12 Jun 2000 23:46:09 +0200
Message-ID: <87ln0abmji.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alan@redhat.com
Cc: Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi!

This simple one-liner solves a long standing problem in Linux VM.
While searching for a discardable page in shrink_mmap() Linux was too
easily failing and subsequently falling back to swapping. The problem
was that shrink_mmap() counted pages from the wrong zone, and in case
of balancing a relatively smaller zone (e.g. DMA zone on a 128MB
computer) "count" would be mistakenly spent dealing with pages from
the wrong zone. The net effect of all this was spurious swapping that
hurt performance greatly.

I tested this patch very thoroughly here and it doesn't reveal any bad
behavior. I think that applying the patch is the first and most
important step towards more fast and balanced kernel. Stay tuned for
more improvements.

Benchmarking reveals a nice improvement for the streaming I/O
applications:

    -------Sequential Output-------- ---Sequential Input-- --Random--
    -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
 MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU

*** ac-16:

400 17380 74.4 13887 14.9  6203  6.8 14452 46.4 15743 12.3 129.9  1.0
400 15134 65.3 15085 15.9  5872  6.5 13281 40.8 18943 14.4 124.4  1.0

*** ac-16 with patch applied:

400 17426 75.8 17919 18.6  6518  7.7 16294 50.0 21038 16.8 132.0  0.8
400 16915 73.3 17502 17.9  6515  7.2 16499 51.4 21148 15.7 131.0  1.4
               ^^^^^       ^^^^                 ^^^^^

Index: 24001.23/mm/filemap.c
--- 24001.23/mm/filemap.c Mon, 12 Jun 2000 21:03:48 +0200 zcalusic (linux/F/b/16_filemap.c 1.6.1.3.2.4.1.1.2.2.2.1.1.21.1.1.3.2.3.1.3.1.2.1 644)
+++ 24001.24/mm/filemap.c Mon, 12 Jun 2000 21:51:53 +0200 zcalusic (linux/F/b/16_filemap.c 1.6.1.3.2.4.1.1.2.2.2.1.1.21.1.1.3.2.3.1.3.1.2.2 644)
@@ -365,8 +365,11 @@
 		 * Page is from a zone we don't care about.
 		 * Don't drop page cache entries in vain.
 		 */
-		if (page->zone->free_pages > page->zone->pages_high)
+		if (page->zone->free_pages > page->zone->pages_high) {
+			/* the page from the wrong zone doesn't count */
+			count++;
 			goto unlock_continue;
+		}
 
 		/* Take the pagecache_lock spinlock held to avoid
 		   other tasks to notice the page while we are looking at its

Regards,
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
