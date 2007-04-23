Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l3NNWtcu008493
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:32:55 -0700
Received: from smtp.corp.google.com (spacemonkey1.corp.google.com [192.168.120.115])
	by zps77.corp.google.com with ESMTP id l3NNWjmh017749
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:32:45 -0700
Received: from [10.253.168.165] (m682a36d0.tmodns.net [208.54.42.104])
	(authenticated bits=0)
	by smtp.corp.google.com (8.13.8/8.13.8) with ESMTP id l3NNWixL021596
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:32:44 -0700
Message-ID: <462D421A.3070309@google.com>
Date: Mon, 23 Apr 2007 16:32:42 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [RFC 5/7] cpuset write vm writeout
References: <462D3F4C.2040007@google.com>
In-Reply-To: <462D3F4C.2040007@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
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

diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff 4/include/linux/writeback.h 5/include/linux/writeback.h
--- 4/include/linux/writeback.h	2007-04-23 14:37:31.000000000 -0700
+++ 5/include/linux/writeback.h	2007-04-23 14:37:51.000000000 -0700
@@ -85,7 +85,7 @@ static inline void wait_on_inode(struct 
 int wakeup_pdflush(long nr_pages, nodemask_t *nodes);
 void laptop_io_completion(void);
 void laptop_sync_completion(void);
-void throttle_vm_writeout(gfp_t gfp_mask);
+void throttle_vm_writeout(nodemask_t *nodes,gfp_t gfp_mask);
 
 extern struct timer_list laptop_mode_wb_timer;
 static inline int laptop_spinned_down(void)
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff 4/mm/page-writeback.c 5/mm/page-writeback.c
--- 4/mm/page-writeback.c	2007-04-23 15:12:27.000000000 -0700
+++ 5/mm/page-writeback.c	2007-04-23 15:13:15.000000000 -0700
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
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff 4/mm/vmscan.c 5/mm/vmscan.c
--- 4/mm/vmscan.c	2007-04-23 14:37:32.000000000 -0700
+++ 5/mm/vmscan.c	2007-04-23 14:37:51.000000000 -0700
@@ -1055,7 +1055,7 @@ static unsigned long shrink_zone(int pri
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
