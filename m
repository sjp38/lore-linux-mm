Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 799DB6B00A2
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:48 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 12/33] autonuma: Migrate On Fault per NUMA node data
Date: Thu,  4 Oct 2012 01:50:54 +0200
Message-Id: <1349308275-2174-13-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This defines the per node data used by Migrate On Fault in order to
rate limit the migration. The rate limiting is applied independently
to each destination node.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mmzone.h |   11 +++++++++++
 mm/page_alloc.c        |    6 ++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2daa54f..f793541 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -709,6 +709,17 @@ typedef struct pglist_data {
 	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
+#ifdef CONFIG_AUTONUMA
+	/*
+	 * Lock serializing the per destination node AutoNUMA memory
+	 * migration rate limiting data.
+	 */
+	spinlock_t autonuma_migrate_lock;
+	/* Rate limiting time interval */
+	unsigned long autonuma_migrate_last_jiffies;
+	/* Number of pages migrated during the rate limiting time interval */
+	unsigned long autonuma_migrate_nr_pages;
+#endif
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a9b18bc..ef69743 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -58,6 +58,7 @@
 #include <linux/prefetch.h>
 #include <linux/migrate.h>
 #include <linux/page-debug-flags.h>
+#include <linux/autonuma.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -4398,6 +4399,11 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	int ret;
 
 	pgdat_resize_init(pgdat);
+#ifdef CONFIG_AUTONUMA
+	spin_lock_init(&pgdat->autonuma_migrate_lock);
+	pgdat->autonuma_migrate_nr_pages = 0;
+	pgdat->autonuma_migrate_last_jiffies = jiffies;
+#endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat_page_cgroup_init(pgdat);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
