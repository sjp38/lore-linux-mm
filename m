Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 082CA6B006C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:51:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 03:16:54 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 46CC2E002D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:23:08 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39LpGIn3735824
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:21:16 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39LpIOj031115
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 21:51:19 GMT
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 13/15] mm: Implement the worker function for memory
 region compaction
Date: Wed, 10 Apr 2013 03:18:45 +0530
Message-ID: <20130409214843.4500.3852.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We are going to invoke the memory compaction algorithms for region-evacuation
from worker threads, instead of dedicating a separate kthread to it. So
add the worker infrastructure to perform this.

In the worker, we calculate the cost of migration/compaction for a given
region - if we need to migrate less than 32 pages, then we go ahead, else we
deem the effort to be too costly and abort the compaction.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mm.h     |   20 ++++++++++++++++++++
 include/linux/mmzone.h |   21 +++++++++++++++++++++
 mm/page_alloc.c        |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index cb0d898..e380eeb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -755,6 +755,26 @@ static inline void set_next_region_in_freelist(struct free_list *free_list)
 	}
 }
 
+static inline int is_mem_pwr_work_in_progress(struct mem_power_ctrl *mpc)
+{
+	if (mpc->work_status == MEM_PWR_WORK_IN_PROGRESS)
+		return 1;
+	return 0;
+}
+
+static inline void set_mem_pwr_work_in_progress(struct mem_power_ctrl *mpc)
+{
+	mpc->work_status = MEM_PWR_WORK_IN_PROGRESS;
+	smp_mb();
+}
+
+static inline void set_mem_pwr_work_complete(struct mem_power_ctrl *mpc)
+{
+	mpc->work_status = MEM_PWR_WORK_COMPLETE;
+	mpc->region = NULL;
+	smp_mb();
+}
+
 #ifdef SECTION_IN_PAGE_FLAGS
 static inline void set_page_section(struct page *page, unsigned long section)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6e209e9..fdadd2a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -17,6 +17,7 @@
 #include <linux/pageblock-flags.h>
 #include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
+#include <linux/workqueue.h>
 #include <asm/page.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -337,6 +338,24 @@ enum zone_type {
 
 #ifndef __GENERATING_BOUNDS_H
 
+/*
+ * In order to evacuate a memory region, if the no. of pages to be migrated
+ * via compaction is more than this number, the effort is considered too
+ * costly and should be aborted.
+ */
+#define MAX_NR_MEM_PWR_MIGRATE_PAGES	32
+
+enum {
+	MEM_PWR_WORK_COMPLETE = 0,
+	MEM_PWR_WORK_IN_PROGRESS
+};
+
+struct mem_power_ctrl {
+	struct work_struct work;
+	struct zone_mem_region *region;
+	int work_status;
+};
+
 struct zone_mem_region {
 	unsigned long start_pfn;
 	unsigned long end_pfn;
@@ -405,6 +424,8 @@ struct zone {
 	struct zone_mem_region	zone_regions[MAX_NR_ZONE_REGIONS];
 	int 			nr_zone_regions;
 
+	struct mem_power_ctrl	mem_power_ctrl;
+
 #ifndef CONFIG_SPARSEMEM
 	/*
 	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40a3aa6..db7b892 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5002,6 +5002,35 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
 }
 
+static void mem_power_mgmt_fn(struct work_struct *work)
+{
+	struct mem_power_ctrl *mpc;
+	struct zone_mem_region *region;
+	unsigned long pages_in_use;
+	struct zone *zone;
+
+	mpc = container_of(work, struct mem_power_ctrl, work);
+
+	if (!mpc->region)
+		return; /* No work to do */
+
+	zone = container_of(mpc, struct zone, mem_power_ctrl);
+	region = mpc->region;
+
+	if (region == zone->zone_regions)
+		return; /* No point compacting region 0. */
+
+	pages_in_use = region->present_pages - region->nr_free;
+
+	if (pages_in_use > 0 &&
+			(pages_in_use <= MAX_NR_MEM_PWR_MIGRATE_PAGES)) {
+
+		evacuate_mem_region(zone, region);
+	}
+
+	set_mem_pwr_work_complete(mpc);
+}
+
 static void __meminit init_node_memory_regions(struct pglist_data *pgdat)
 {
 	int nid = pgdat->node_id;
@@ -5094,6 +5123,10 @@ static void __meminit init_zone_memory_regions(struct pglist_data *pgdat)
 
 		zone_init_free_lists_late(z);
 
+		INIT_WORK(&z->mem_power_ctrl.work, mem_power_mgmt_fn);
+		z->mem_power_ctrl.region = NULL;
+		set_mem_pwr_work_complete(&z->mem_power_ctrl);
+
 		/*
 		 * Revisit the last visited node memory region, in case it
 		 * spans multiple zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
