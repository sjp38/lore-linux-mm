Message-ID: <465FB9A5.8070806@google.com>
Date: Thu, 31 May 2007 23:16:05 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [corrected][RFC 5/7] cpuset write vm writeout
References: <465FB6CF.4090801@google.com>
In-Reply-To: <465FB6CF.4090801@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@google.com>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Throttle VM writeout in a cpuset aware way

This bases the vm throttling from the reclaim path on the dirty ratio
of the cpuset. Note that a cpuset is only effective if shrink_zone is called
from direct reclaim.

kswapd has a cpuset context that includes the whole machine. VM throttling
will only work during synchrononous reclaim and not  from kswapd.

Originally by Christoph Lameter <clameter@sgi.com>

Signed-off-by: Ethan Solomita <solo@google.com>

---

diff -uprN -X 0/Documentation/dontdiff 4/include/linux/writeback.h 5/include/linux/writeback.h
--- 4/include/linux/writeback.h	2007-05-30 11:36:14.000000000 -0700
+++ 5/include/linux/writeback.h	2007-05-30 11:37:01.000000000 -0700
@@ -89,7 +89,7 @@ static inline void wait_on_inode(struct 
 int wakeup_pdflush(long nr_pages, nodemask_t *nodes);
 void laptop_io_completion(void);
 void laptop_sync_completion(void);
-void throttle_vm_writeout(gfp_t gfp_mask);
+void throttle_vm_writeout(nodemask_t *nodes,gfp_t gfp_mask);
 
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
diff -uprN -X 0/Documentation/dontdiff 4/mm/page-writeback.c 5/mm/page-writeback.c
--- 4/mm/page-writeback.c	2007-05-30 11:36:15.000000000 -0700
+++ 5/mm/page-writeback.c	2007-05-30 11:37:01.000000000 -0700
@@ -384,7 +384,7 @@ void balance_dirty_pages_ratelimited_nr(
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
-void throttle_vm_writeout(gfp_t gfp_mask)
+void throttle_vm_writeout(nodemask_t *nodes, gfp_t gfp_mask)
 {
 	struct dirty_limits dl;
 
@@ -399,7 +399,7 @@ void throttle_vm_writeout(gfp_t gfp_mask
 	}
 
 	for ( ; ; ) {
-		get_dirty_limits(&dl, NULL, &node_online_map);
+		get_dirty_limits(&dl, NULL, nodes);
 
 		/*
 		 * Boost the allowable dirty threshold a bit for page
diff -uprN -X 0/Documentation/dontdiff 4/mm/vmscan.c 5/mm/vmscan.c
--- 4/mm/vmscan.c	2007-05-30 11:36:17.000000000 -0700
+++ 5/mm/vmscan.c	2007-05-30 11:37:01.000000000 -0700
@@ -1079,7 +1079,7 @@ static unsigned long shrink_zone(int pri
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
