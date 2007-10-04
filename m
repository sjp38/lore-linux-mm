Subject: [PATCH] remove throttle_vm_writeout()
Message-Id: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 04 Oct 2007 14:25:22 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: wfg@mail.ustc.edu.cn, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This in preparation for the writable mmap patches for fuse.  I know it
conflicts with

  writeback-remove-unnecessary-wait-in-throttle_vm_writeout.patch

but if this function is to be removed, it doesn't make much sense to
fix it first ;)
---

From: Miklos Szeredi <mszeredi@suse.cz>

By relying on the global diry limits, this can cause a deadlock when
devices are stacked.

If the stacking is done through a fuse filesystem, the __GFP_FS,
__GFP_IO tests won't help: the process doing the allocation doesn't
have any special flag.

So why exactly does this function exist?

Direct reclaim does not _increase_ the number of dirty pages in the
system, so rate limiting it seems somewhat pointless.

There are two cases:

1) File backed pages -> file

  dirty + writeback count remains constant

2) Anonymous pages -> swap

  writeback count increases, dirty balancing will hold back file
  writeback in favor of swap

So the real question is: does case 2 need rate limiting, or is it OK
to let the device queue fill with swap pages as fast as possible?

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/include/linux/writeback.h
===================================================================
--- linux.orig/include/linux/writeback.h	2007-10-02 16:55:03.000000000 +0200
+++ linux/include/linux/writeback.h	2007-10-04 13:40:33.000000000 +0200
@@ -94,7 +94,6 @@ static inline void inode_sync_wait(struc
 int wakeup_pdflush(long nr_pages);
 void laptop_io_completion(void);
 void laptop_sync_completion(void);
-void throttle_vm_writeout(gfp_t gfp_mask);
 
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2007-10-02 16:55:03.000000000 +0200
+++ linux/mm/page-writeback.c	2007-10-04 13:40:33.000000000 +0200
@@ -497,37 +497,6 @@ void balance_dirty_pages_ratelimited_nr(
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
Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2007-10-02 16:55:03.000000000 +0200
+++ linux/mm/vmscan.c	2007-10-04 13:40:33.000000000 +0200
@@ -1184,7 +1184,6 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
-	throttle_vm_writeout(sc->gfp_mask);
 	return nr_reclaimed;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
