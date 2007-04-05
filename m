Message-Id: <20070405174319.860268120@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
Date: Thu, 05 Apr 2007 19:42:18 +0200
From: root@programming.kicks-ass.net
Subject: [PATCH 09/12] mm: remove throttle_vm_writeback
Content-Disposition: inline; filename=remove-throttle_vm_writeout.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

rely on accurate dirty page accounting to provide enough push back

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

Index: linux-2.6-mm/include/linux/writeback.h
===================================================================
--- linux-2.6-mm.orig/include/linux/writeback.h	2007-04-05 13:23:51.000000000 +0200
+++ linux-2.6-mm/include/linux/writeback.h	2007-04-05 13:24:11.000000000 +0200
@@ -84,7 +84,6 @@ static inline void wait_on_inode(struct 
 int wakeup_pdflush(long nr_pages);
 void laptop_io_completion(void);
 void laptop_sync_completion(void);
-void throttle_vm_writeout(gfp_t gfp_mask);
 
 extern struct timer_list laptop_mode_wb_timer;
 static inline int laptop_spinned_down(void)
Index: linux-2.6-mm/mm/page-writeback.c
===================================================================
--- linux-2.6-mm.orig/mm/page-writeback.c	2007-04-05 13:23:51.000000000 +0200
+++ linux-2.6-mm/mm/page-writeback.c	2007-04-05 13:24:38.000000000 +0200
@@ -437,37 +437,6 @@ void balance_dirty_pages_ratelimited_nr(
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
-void throttle_vm_writeout(gfp_t gfp_mask)
-{
-	long background_thresh;
-	long dirty_thresh;
-
-	if ((gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO)) {
-		/*
-		 * The caller might hold locks which can prevent IO completion
-		 * or progress in the filesystem.  So we cannot just sit here
-		 * waiting for IO to complete.
-		 */
-		congestion_wait(WRITE, HZ/10);
-		return;
-	}
-
-        for ( ; ; ) {
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
-
-                /*
-                 * Boost the allowable dirty threshold a bit for page
-                 * allocators so they don't get DoS'ed by heavy writers
-                 */
-                dirty_thresh += dirty_thresh / 10;      /* wheeee... */
-
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
-                congestion_wait(WRITE, HZ/10);
-        }
-}
-
 /*
  * writeback at least _min_pages, and keep writing until the amount of dirty
  * memory is less than the background threshold, or until we're all clean.
Index: linux-2.6-mm/mm/vmscan.c
===================================================================
--- linux-2.6-mm.orig/mm/vmscan.c	2007-04-03 12:17:57.000000000 +0200
+++ linux-2.6-mm/mm/vmscan.c	2007-04-05 13:24:03.000000000 +0200
@@ -1047,8 +1047,6 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
-	throttle_vm_writeout(sc->gfp_mask);
-
 	atomic_dec(&zone->reclaim_in_progress);
 	return nr_reclaimed;
 }

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
