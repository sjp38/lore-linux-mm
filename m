Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id A2E856B0044
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:51:14 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 03:16:47 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 4FA5E394005C
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:21:09 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39Lp5Pl7537128
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:21:05 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39Lp7pC012123
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:51:08 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 12/15] mm: Add infrastructure to evacuate memory
 regions using compaction
Date: Wed, 10 Apr 2013 03:18:35 +0530
Message-ID: <20130409214832.4500.17236.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To enhance memory power-savings, we need to be able to completely evacuate
lightly allocated regions, and move those used pages to lower regions,
which would help consolidate all the allocations to a minimum no. of regions.
This can be done using some of the memory compaction and reclaim algorithms.
Develop such an infrastructure to evacuate memory regions completely.

The traditional compaction algorithm uses a pfn walker to get free pages
for compaction. But this would be way too costly for us. We do a pfn walk
only to isolate the used pages, but to get free pages, we just depend on the
fast buddy allocator itself. But we are careful to abort when the buddy
allocator starts giving free pages in this region itself or higher regions
(because in that case, if we proceed, it would be defeating the purpose of
the entire effort).

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/compaction.h     |    7 ++++
 include/linux/gfp.h            |    2 +
 include/linux/migrate.h        |    3 +-
 include/trace/events/migrate.h |    3 +-
 mm/compaction.c                |   72 ++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c                |    5 +--
 6 files changed, 87 insertions(+), 5 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 091d72e..6be2b08 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -26,6 +26,7 @@ extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
+extern int evacuate_mem_region(struct zone *z, struct zone_mem_region *zmr);
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
@@ -102,6 +103,12 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
+static inline int evacuate_mem_region(struct zone *z,
+				      struct zone_mem_region *zmr)
+{
+	return 0;
+}
+
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0f615eb..dd5430f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -351,6 +351,8 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
+int rmqueue_bulk(struct zone *zone, unsigned int order, unsigned long count,
+		 struct list_head *list, int migratetype, int cold);
 void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
 void free_pages_exact(void *virt, size_t size);
 /* This is different from alloc_pages_exact_node !!! */
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a405d3dc..e006be9 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -30,7 +30,8 @@ enum migrate_reason {
 	MR_SYSCALL,		/* also applies to cpusets */
 	MR_MEMPOLICY_MBIND,
 	MR_NUMA_MISPLACED,
-	MR_CMA
+	MR_CMA,
+	MR_PWR_MGMT
 };
 
 #ifdef CONFIG_MIGRATION
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index ec2a6cc..e6892c0 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -15,7 +15,8 @@
 	{MR_MEMORY_HOTPLUG,	"memory_hotplug"},		\
 	{MR_SYSCALL,		"syscall_or_cpuset"},		\
 	{MR_MEMPOLICY_MBIND,	"mempolicy_mbind"},		\
-	{MR_CMA,		"cma"}
+	{MR_CMA,		"cma"},				\
+	{MR_PWR_MGMT,		"power_management"}
 
 TRACE_EVENT(mm_migrate_pages,
 
diff --git a/mm/compaction.c b/mm/compaction.c
index ff9cf23..a76ad90 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1162,6 +1162,78 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	return rc;
 }
 
+static struct page *power_mgmt_alloc(struct page *migratepage,
+				     unsigned long data, int **result)
+{
+	struct compact_control *cc = (struct compact_control *)data;
+	struct page *freepage;
+
+	/*
+	 * Try to allocate pages from lower memory regions. If it fails,
+	 * abort.
+	 */
+	if (list_empty(&cc->freepages)) {
+		struct zone *z = page_zone(migratepage);
+
+		rmqueue_bulk(z, 0, cc->nr_migratepages, &cc->freepages,
+			     MIGRATE_MOVABLE, 1);
+
+		if (list_empty(&cc->freepages))
+			return NULL;
+	}
+
+	freepage = list_entry(cc->freepages.next, struct page, lru);
+
+	if (page_zone_region_id(freepage) >= page_zone_region_id(migratepage))
+		return NULL; /* Freepage is not from lower region, so abort */
+
+	list_del(&freepage->lru);
+	cc->nr_freepages--;
+
+	return freepage;
+}
+
+static unsigned long power_mgmt_release_freepages(unsigned long info)
+{
+	struct compact_control *cc = (struct compact_control *)info;
+
+	return release_freepages(&cc->freepages);
+}
+
+int evacuate_mem_region(struct zone *z, struct zone_mem_region *zmr)
+{
+	unsigned long start_pfn = zmr->start_pfn;
+	unsigned long end_pfn = zmr->end_pfn;
+
+	struct compact_control cc = {
+		.nr_migratepages = 0,
+		.order = -1,
+		.zone = page_zone(pfn_to_page(start_pfn)),
+		.sync = false,  /* Async migration */
+		.ignore_skip_hint = true,
+	};
+
+	struct aggression_control ac = {
+		.isolate_unevictable = false,
+		.prep_all = false,
+		.reclaim_clean = true,
+		.max_tries = 1,
+		.reason = MR_PWR_MGMT,
+	};
+
+	struct free_page_control fc = {
+		.free_page_alloc = power_mgmt_alloc,
+		.alloc_data = (unsigned long)&cc,
+		.release_freepages = power_mgmt_release_freepages,
+		.free_data = (unsigned long)&cc,
+	};
+
+	INIT_LIST_HEAD(&cc.migratepages);
+	INIT_LIST_HEAD(&cc.freepages);
+
+	return compact_range(&cc, &ac, &fc, start_pfn, end_pfn);
+}
+
 
 /* Compact all zones within a node */
 static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f31ca94..40a3aa6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1445,9 +1445,8 @@ retry_reserve:
  * a single hold of the lock, for efficiency.  Add them to the supplied list.
  * Returns the number of new pages which were placed at *list.
  */
-static int rmqueue_bulk(struct zone *zone, unsigned int order,
-			unsigned long count, struct list_head *list,
-			int migratetype, int cold)
+int rmqueue_bulk(struct zone *zone, unsigned int order, unsigned long count,
+		 struct list_head *list, int migratetype, int cold)
 {
 	int mt = migratetype, i;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
