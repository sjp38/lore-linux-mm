Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B1F336B009B
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:25:54 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so315298pbc.17
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:25:54 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:55:48 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 01253394004E
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:55:31 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNPhK038666402
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:55:43 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNPj4k023929
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:55:46 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 35/40] mm: Add infrastructure to evacuate memory
 regions using compaction
Date: Thu, 26 Sep 2013 04:51:39 +0530
Message-ID: <20130925232136.26184.28161.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To enhance memory power-savings, we need to be able to completely evacuate
lightly allocated regions, and move those used pages to lower regions,
which would help consolidate all the allocations to a minimum no. of regions.
This can be done using some of the memory compaction and reclaim algorithms.
Develop such an infrastructure to evacuate memory regions completely.

The traditional compaction algorithm uses a pfn walker to get free pages
for compaction. But this would be way too costly for us. So we do a pfn walk
only to isolate the used pages, but to get free pages, we just depend on the
fast buddy allocator itself. But we are careful to abort the compaction run
when the buddy allocator starts giving free pages in this region itself or
higher regions (because in that case, if we proceed, it would be defeating
the purpose of the entire effort).

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/compaction.h     |    7 +++
 include/linux/gfp.h            |    2 +
 include/linux/migrate.h        |    3 +
 include/linux/mm.h             |    1 
 include/trace/events/migrate.h |    3 +
 mm/compaction.c                |   99 ++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c                |   23 +++++++--
 7 files changed, 130 insertions(+), 8 deletions(-)

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
index 9b4dd49..dab3c78 100644
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
index 8d3c57f..5ab1d48 100644
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4286a75..f49acb0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -470,6 +470,7 @@ void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
 int split_free_page(struct page *page);
+void __split_free_page(struct page *page, unsigned int order);
 
 /*
  * Compound pages have a destructor function.  Provide a
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
index c775066..9449b7f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1168,6 +1168,105 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
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
+		unsigned int i, count, order = 0;
+		struct page *page, *tmp;
+		LIST_HEAD(list);
+
+		/* Get a bunch of order-0 pages from the buddy freelists */
+		count = rmqueue_bulk(z, order, cc->nr_migratepages, &list,
+				     MIGRATE_MOVABLE, 1);
+
+		cc->nr_freepages = count * (1ULL << order);
+
+		if (list_empty(&list))
+			return NULL;
+
+		list_for_each_entry_safe(page, tmp, &list, lru) {
+			__split_free_page(page, order);
+
+			list_move_tail(&page->lru, &cc->freepages);
+
+			/*
+			 * Now add all the order-0 subdivisions of this page
+			 * to the freelist as well.
+			 */
+			for (i = 1; i < (1ULL << order); i++) {
+				page++;
+				list_add(&page->lru, &cc->freepages);
+			}
+
+		}
+
+		VM_BUG_ON(!list_empty(&list));
+
+		/* Now map all the order-0 pages on the freelist. */
+		map_pages(&cc->freepages);
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
index 70c3d7a..4571d30 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1793,9 +1793,8 @@ retry:
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
 
@@ -2111,6 +2110,20 @@ static int __isolate_free_page(struct page *page, unsigned int order)
 	return 1UL << order;
 }
 
+
+/*
+ * The page is already free and isolated (removed) from the buddy system.
+ * Set up the refcounts appropriately. Note that we can't use page_order()
+ * here, since the buddy system would have invoked rmv_page_order() before
+ * giving the page.
+ */
+void __split_free_page(struct page *page, unsigned int order)
+{
+	/* Split into individual pages */
+	set_page_refcounted(page);
+	split_page(page, order);
+}
+
 /*
  * Similar to split_page except the page is already free. As this is only
  * being used for migration, the migratetype of the block also changes.
@@ -2132,9 +2145,7 @@ int split_free_page(struct page *page)
 	if (!nr_pages)
 		return 0;
 
-	/* Split into individual pages */
-	set_page_refcounted(page);
-	split_page(page, order);
+	__split_free_page(page, order);
 	return nr_pages;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
