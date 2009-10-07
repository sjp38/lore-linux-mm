Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0692E6B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 04:25:10 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n978P6fE028440
	for <linux-mm@kvack.org>; Wed, 7 Oct 2009 01:25:06 -0700
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by wpaz13.hot.corp.google.com with ESMTP id n978OUOq015461
	for <linux-mm@kvack.org>; Wed, 7 Oct 2009 01:25:03 -0700
Received: by pxi14 with SMTP id 14so5239417pxi.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2009 01:25:03 -0700 (PDT)
Date: Wed, 7 Oct 2009 01:24:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: clear node in N_HIGH_MEMORY and stop kswapd when all
 memory is offlined
In-Reply-To: <20091006031924.22576.35018.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910070043140.16136@chino.kir.corp.google.com>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain> <20091006031924.22576.35018.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Lee Schermerhorn wrote:

> [PATCH 11/11] hugetlb:  offload [un]registration of sysfs attr to worker thread
> 
> Against:  2.6.31-mmotm-090925-1435
> 
> New in V6
> 
> V7:  + remove redundant check for memory{ful|less} node from 
>        node_hugetlb_work().  Rely on [added] return from
>        hugetlb_register_node() to differentiate between transitions
>        to/from memoryless state.
> 

That doesn't work because the memory hotplug code doesn't clear the 
N_HIGH_MEMORY bit for status_change_nid on MEM_OFFLINE, so 
hugetlb_register_node() will always return true under such conditions.

The following should fix it.  Christoph?



mm: clear node in N_HIGH_MEMORY and stop kswapd when all memory is offlined

When memory is hot-removed, its node must be cleared in N_HIGH_MEMORY if
there are no present pages left.

In such a situation, kswapd must also be stopped since it has nothing
left to do.

Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/swap.h |    1 +
 mm/memory_hotplug.c  |    4 ++++
 mm/vmscan.c          |   28 ++++++++++++++++++++++------
 3 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -273,6 +273,7 @@ extern int scan_unevictable_register_node(struct node *node);
 extern void scan_unevictable_unregister_node(struct node *node);
 
 extern int kswapd_run(int nid);
+extern void kswapd_stop(int nid);
 
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -838,6 +838,10 @@ repeat:
 
 	setup_per_zone_wmarks();
 	calculate_zone_inactive_ratio(zone);
+	if (!node_present_pages(node)) {
+		node_clear_state(node, N_HIGH_MEMORY);
+		kswapd_stop(node);
+	}
 
 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2163,6 +2163,7 @@ static int kswapd(void *p)
 	order = 0;
 	for ( ; ; ) {
 		unsigned long new_order;
+		int ret;
 
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 		new_order = pgdat->kswapd_max_order;
@@ -2174,19 +2175,23 @@ static int kswapd(void *p)
 			 */
 			order = new_order;
 		} else {
-			if (!freezing(current))
+			if (!freezing(current) && !kthread_should_stop())
 				schedule();
 
 			order = pgdat->kswapd_max_order;
 		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
-		if (!try_to_freeze()) {
-			/* We can speed up thawing tasks if we don't call
-			 * balance_pgdat after returning from the refrigerator
-			 */
+		ret = try_to_freeze();
+		if (kthread_should_stop())
+			break;
+
+		/*
+		 * We can speed up thawing tasks if we don't call balance_pgdat
+		 * after returning from the refrigerator
+		 */
+		if (!ret)
 			balance_pgdat(pgdat, order);
-		}
 	}
 	return 0;
 }
@@ -2441,6 +2446,17 @@ int kswapd_run(int nid)
 	return ret;
 }
 
+/*
+ * Called by memory hotplug when all memory in a node is offlined.
+ */
+void kswapd_stop(int nid)
+{
+	struct task_struct *kswapd = NODE_DATA(nid)->kswapd;
+
+	if (kswapd)
+		kthread_stop(kswapd);
+}
+
 static int __init kswapd_init(void)
 {
 	int nid;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
