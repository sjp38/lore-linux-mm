Date: Fri, 19 Jan 2007 19:10:33 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070120031033.17491.53781.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070120031007.17491.33355.sendpatchset@schroedinger.engr.sgi.com>
References: <20070120031007.17491.33355.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 5/5] Throttle vm writeout per cpuset
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Paul Menage <menage@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Throttle VM writeout in a cpuset aware way

This bases the vm throttling from the reclaim path on the dirty ratio
of the cpuset. Note that a cpuset is only effective if shrink_zone is called
from direct reclaim.

kswapd has a cpuset context that includes the whole machine. VM throttling
will only work during synchrononous reclaim and not  from kswapd.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc5/include/linux/writeback.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/writeback.h	2007-01-15 21:37:05.209897874 -0600
+++ linux-2.6.20-rc5/include/linux/writeback.h	2007-01-15 21:37:33.283671963 -0600
@@ -85,7 +85,7 @@ static inline void wait_on_inode(struct 
 int wakeup_pdflush(long nr_pages, nodemask_t *nodes);
 void laptop_io_completion(void);
 void laptop_sync_completion(void);
-void throttle_vm_writeout(void);
+void throttle_vm_writeout(nodemask_t *);
 
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
Index: linux-2.6.20-rc5/mm/page-writeback.c
===================================================================
--- linux-2.6.20-rc5.orig/mm/page-writeback.c	2007-01-15 21:35:28.013794159 -0600
+++ linux-2.6.20-rc5/mm/page-writeback.c	2007-01-15 21:37:33.302228293 -0600
@@ -349,12 +349,12 @@ void balance_dirty_pages_ratelimited_nr(
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
-void throttle_vm_writeout(void)
+void throttle_vm_writeout(nodemask_t *nodes)
 {
 	struct dirty_limits dl;
 
         for ( ; ; ) {
-		get_dirty_limits(&dl, NULL, &node_online_map);
+		get_dirty_limits(&dl, NULL, nodes);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
Index: linux-2.6.20-rc5/mm/vmscan.c
===================================================================
--- linux-2.6.20-rc5.orig/mm/vmscan.c	2007-01-15 21:37:26.605346439 -0600
+++ linux-2.6.20-rc5/mm/vmscan.c	2007-01-15 21:37:33.316878027 -0600
@@ -949,7 +949,7 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
-	throttle_vm_writeout();
+	throttle_vm_writeout(&cpuset_current_mems_allowed);
 
 	atomic_dec(&zone->reclaim_in_progress);
 	return nr_reclaimed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
