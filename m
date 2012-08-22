Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 5C50E6B0069
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:00 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 12/36] autonuma: knuma_migrated per NUMA node queues
Date: Wed, 22 Aug 2012 16:58:56 +0200
Message-Id: <1345647560-30387-13-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This defines the knuma_migrated queues. There is one knuma_migrated
per NUMA node with active CPUs. Pages are added to these queues
through the NUMA hinting page fault (memory follow CPU algorithm with
false sharing evaluation). The daemons are then woken up with a
certain hysteresis to migrate the memory in a round robin fashion from
all remote nodes to the daemon's local node.

The head that belongs to the local node that knuma_migrated runs on,
for now must be empty and it's not being used.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mmzone.h |   18 ++++++++++++++++++
 mm/page_alloc.c        |   11 +++++++++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2daa54f..a5920f8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -709,6 +709,24 @@ typedef struct pglist_data {
 	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
+#ifdef CONFIG_AUTONUMA
+	/*
+	 * lock serializing all lists with heads in the
+	 * autonuma_migrate_head[] array, and the
+	 * autonuma_nr_migrate_pages field.
+	 */
+	spinlock_t autonuma_lock;
+	/*
+	 * All pages from node "page_nid" to be migrated to this node,
+	 * will be queued into the list
+	 * autonuma_migrate_head[page_nid].
+	 */
+	struct list_head autonuma_migrate_head[MAX_NUMNODES];
+	/* number of pages from other nodes queued for migration to this node */
+	unsigned long autonuma_nr_migrate_pages;
+	/* waitqueue for this node knuma_migrated daemon */
+	wait_queue_head_t autonuma_knuma_migrated_wait;
+#endif
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a6337b3..8c9cad5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -58,6 +58,7 @@
 #include <linux/prefetch.h>
 #include <linux/migrate.h>
 #include <linux/page-debug-flags.h>
+#include <linux/autonuma.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -4391,8 +4392,18 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	int nid = pgdat->node_id;
 	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 	int ret;
+#ifdef CONFIG_AUTONUMA
+	int node_iter;
+#endif
 
 	pgdat_resize_init(pgdat);
+#ifdef CONFIG_AUTONUMA
+	spin_lock_init(&pgdat->autonuma_lock);
+	init_waitqueue_head(&pgdat->autonuma_knuma_migrated_wait);
+	pgdat->autonuma_nr_migrate_pages = 0;
+	for_each_node(node_iter)
+		INIT_LIST_HEAD(&pgdat->autonuma_migrate_head[node_iter]);
+#endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat_page_cgroup_init(pgdat);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
