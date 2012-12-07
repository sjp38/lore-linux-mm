Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id C541C6B00A9
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:52 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 32/49] mm: numa: Structures for Migrate On Fault per NUMA migration rate limiting
Date: Fri,  7 Dec 2012 10:23:35 +0000
Message-Id: <1354875832-9700-33-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Andrea Arcangeli <aarcange@redhat.com>

This defines the per-node data used by Migrate On Fault in order to
rate limit the migration. The rate limiting is applied independently
to each destination node.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |   13 +++++++++++++
 mm/page_alloc.c        |    5 +++++
 2 files changed, 18 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a23923b..1ed16e5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -717,6 +717,19 @@ typedef struct pglist_data {
 	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
+#ifdef CONFIG_BALANCE_NUMA
+	/*
+	 * Lock serializing the per destination node AutoNUMA memory
+	 * migration rate limiting data.
+	 */
+	spinlock_t balancenuma_migrate_lock;
+
+	/* Rate limiting time interval */
+	unsigned long balancenuma_migrate_next_window;
+
+	/* Number of pages migrated during the rate limiting time interval */
+	unsigned long balancenuma_migrate_nr_pages;
+#endif
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5953dc2..df58654 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4449,6 +4449,11 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	int ret;
 
 	pgdat_resize_init(pgdat);
+#ifdef CONFIG_BALANCE_NUMA
+	spin_lock_init(&pgdat->balancenuma_migrate_lock);
+	pgdat->balancenuma_migrate_nr_pages = 0;
+	pgdat->balancenuma_migrate_next_window = jiffies;
+#endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat_page_cgroup_init(pgdat);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
