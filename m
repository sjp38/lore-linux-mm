Message-Id: <200107280144.DAA25730@mailb.telia.com>
Content-Type: text/plain;
  charset="iso-8859-15"
From: Roger Larsson <roger.larsson@norran.net>
Subject: [PATCH] MAX_READAHEAD gives doubled throuput
Date: Sat, 28 Jul 2001 03:40:49 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi all,

Got wondering why simultaneous streaming is so much slower than normal...

Are there any reasons nowadays why we should not attempt to read ahead more 
than 31 pages at once?

31 pages equals 0.1 MB, it is read from the HD in 4 ms => very close to the 
average access times. Resulting in a maximum of half the possible speed.

With this patch copy and diff throughput are increased from 14 respective 11 
MB/s to 27 and 28 !!!

I enable the profiling as well... (one printk warning fixed)

/RogerL

*******************************************
Patch prepared by: roger.larsson@norran.net

--- linux/mm/filemap.c.orig	Fri Jul 27 21:31:41 2001
+++ linux/mm/filemap.c	Sat Jul 28 03:01:05 2001
@@ -744,10 +744,8 @@
 	return NULL;
 }
 
-#if 0
 #define PROFILE_READAHEAD
 #define DEBUG_READAHEAD
-#endif
 
 /*
  * Read-ahead profiling information
@@ -791,13 +789,13 @@
 		}
 
 		printk("Readahead average:  max=%ld, len=%ld, win=%ld, async=%ld%%\n",
-			total_ramax/total_reada,
-			total_ralen/total_reada,
-			total_rawin/total_reada,
-			(total_async*100)/total_reada);
+		       total_ramax/total_reada,
+		       total_ralen/total_reada,
+		       total_rawin/total_reada,
+		       (total_async*100)/total_reada);
 #ifdef DEBUG_READAHEAD
-		printk("Readahead snapshot: max=%ld, len=%ld, win=%ld, raend=%Ld\n",
-			filp->f_ramax, filp->f_ralen, filp->f_rawin, filp->f_raend);
+		printk("Readahead snapshot: max=%ld, len=%ld, win=%ld, raend=%ld\n",
+		       filp->f_ramax, filp->f_ralen, filp->f_rawin, filp->f_raend);
 #endif
 
 		total_reada	= 0;
--- linux/include/linux/blkdev.h.orig	Fri Jul 27 21:36:37 2001
+++ linux/include/linux/blkdev.h	Sat Jul 28 02:51:10 2001
@@ -184,7 +184,7 @@
 #define PageAlignSize(size) (((size) + PAGE_SIZE -1) & PAGE_MASK)
 
 /* read-ahead in pages.. */
-#define MAX_READAHEAD	31
+#define MAX_READAHEAD	511
 #define MIN_READAHEAD	3
 
 #define blkdev_entry_to_request(entry) list_entry((entry), struct request, 
queue)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
