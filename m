Subject: shrink_mmap() change in ac-21
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 19 Jun 2000 22:14:52 +0200
Message-ID: <87r99t8m2r.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alan@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi, Alan and others!

The shrink_mmap() change in your latest prepatch (ac12) doesn't look
very healthy. Removing the test for the wrong zone we effectively
discard lots of wrong pages before we get to the right one. That is
effectively flushing the page cache and we have unbalanced system.

For example, check the "vmstat 1" output below, done while I was
reading a big file from the disk. At some point in time, the page
cache shrunk to almost half of its size (75MB -> 42MB).

The reason is balancing of the DMA zone (which is much smaller on a
128MB machine than the NORMAL zone!). shrink_mmap() now happily evicts
wrong pages from the memory and continues doing so until it finally
frees enough pages from the DMA zone. That, of course, hurts caching
as the page cache gets shrunk a lot without a good reason.


   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 0  1  0    988   5556    172  78708   0   0  3811     0  342   859   0   6  93
 0  1  0   1040   9712    176  74640   0 168  3043    42  309   801   0   6  93
 0  1  0   1084   7272    184  76800   0 408  2659   102  317   762   0   7  93
 0  1  0   1084   8704__  212  75308   0   0  2730     0  285   782   0   7  93
 3  0  0   1084  42400  \ 192  42780   0   0  2447     0  270   703   0   8  91
 0  1  0   1084  30092  | 204  54684   0   0  2979     0  299   767   1   4  95
                         \
                           here! :)

The incriminating change is:


Index: 24001.28/mm/filemap.c
--- 24001.28/mm/filemap.c Wed, 14 Jun 2000 01:44:09 +0200 zcalusic (linux/F/b/16_filemap.c 1.6.1.3.2.4.1.1.2.2.2.1.1.21.1.1.3.2.3.1.4.1 644)
+++ 24001.31(w)/mm/filemap.c Sun, 18 Jun 2000 21:23:47 +0200 zcalusic (linux/F/b/16_filemap.c 1.6.1.3.2.4.1.1.2.2.2.1.1.21.1.1.3.2.3.1.4.2 644)
@@ -361,16 +361,6 @@
 			}
 		}
 
-		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high) {
-			/* the page from the wrong zone doesn't count */
-			count++;
-			goto unlock_continue;
-		}
-
 		/* Take the pagecache_lock spinlock held to avoid
 		   other tasks to notice the page while we are looking at its
 		   page count. If it's a pagecache-page we'll free it

Regards,
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
