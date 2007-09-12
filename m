Message-ID: <46E743B0.6070308@google.com>
Date: Tue, 11 Sep 2007 18:41:04 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [PATCH 5/6] cpuset write vm writeout
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
In-Reply-To: <46E741B1.4030100@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Throttle VM writeout in a cpuset aware way

This bases the vm throttling from the reclaim path on the dirty ratio
of the cpuset. Note that a cpuset is only effective if shrink_zone is called
from direct reclaim.

kswapd has a cpuset context that includes the whole machine. VM throttling
will only work during synchrononous reclaim and not  from kswapd.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Ethan Solomita <solo@google.com>

---

Patch against 2.6.23-rc4-mm1

diff -uprN -X 0/Documentation/dontdiff 4/include/linux/writeback.h 5/include/linux/writeback.h
--- 4/include/linux/writeback.h	2007-09-11 14:49:47.000000000 -0700
+++ 5/include/linux/writeback.h	2007-09-11 14:50:52.000000000 -0700
@@ -94,7 +94,7 @@ static inline void inode_sync_wait(struc
 int wakeup_pdflush(long nr_pages, nodemask_t *nodes);
 void laptop_io_completion(void);
 void laptop_sync_completion(void);
-void throttle_vm_writeout(gfp_t gfp_mask);
+void throttle_vm_writeout(nodemask_t *nodes,gfp_t gfp_mask);
 
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
diff -uprN -X 0/Documentation/dontdiff 4/mm/page-writeback.c 5/mm/page-writeback.c
--- 4/mm/page-writeback.c	2007-09-11 14:49:47.000000000 -0700
+++ 5/mm/page-writeback.c	2007-09-11 14:50:52.000000000 -0700
@@ -386,7 +386,7 @@ void balance_dirty_pages_ratelimited_nr(
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
-void throttle_vm_writeout(gfp_t gfp_mask)
+void throttle_vm_writeout(nodemask_t *nodes, gfp_t gfp_mask)
 {
 	struct dirty_limits dl;
 
@@ -401,7 +401,7 @@ void throttle_vm_writeout(gfp_t gfp_mask
 	}
 
 	for ( ; ; ) {
-		get_dirty_limits(&dl, NULL, &node_online_map);
+		get_dirty_limits(&dl, NULL, nodes);
 
 		/*
 		 * Boost the allowable dirty threshold a bit for page
diff -uprN -X 0/Documentation/dontdiff 4/mm/vmscan.c 5/mm/vmscan.c
--- 4/mm/vmscan.c	2007-09-11 14:50:41.000000000 -0700
+++ 5/mm/vmscan.c	2007-09-11 14:50:52.000000000 -0700
@@ -1185,7 +1185,7 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
-	throttle_vm_writeout(sc->gfp_mask);
+	throttle_vm_writeout(&cpuset_current_mems_allowed, sc->gfp_mask);
 
 	atomic_dec(&zone->reclaim_in_progress);
 	return nr_reclaimed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
