Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 790646B00BC
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:01:32 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 28/36] autonuma: page_autonuma
Date: Wed, 22 Aug 2012 16:59:12 +0200
Message-Id: <1345647560-30387-29-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Move the AutoNUMA per page information from the "struct page" to a
separate page_autonuma data structure allocated in the memsection
(with sparsemem) or in the pgdat (with flatmem).

This is done to avoid growing the size of "struct page". The
page_autonuma data is only allocated if the kernel is booted on real
NUMA hardware and noautonuma is not passed as a parameter to the
kernel.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma.h       |   18 +++-
 include/linux/autonuma_types.h |   55 +++++++++
 include/linux/mm_types.h       |   26 ----
 include/linux/mmzone.h         |   24 +++-
 include/linux/page_autonuma.h  |   53 +++++++++
 init/main.c                    |    2 +
 mm/Makefile                    |    2 +-
 mm/autonuma.c                  |  102 +++++++++++------
 mm/huge_memory.c               |   13 ++-
 mm/page_alloc.c                |   21 +---
 mm/page_autonuma.c             |  246 ++++++++++++++++++++++++++++++++++++++++
 mm/sparse.c                    |  126 +++++++++++++++++++-
 12 files changed, 588 insertions(+), 100 deletions(-)
 create mode 100644 include/linux/page_autonuma.h
 create mode 100644 mm/page_autonuma.c

diff --git a/include/linux/autonuma.h b/include/linux/autonuma.h
index 85ca5eb..1d87ecc 100644
--- a/include/linux/autonuma.h
+++ b/include/linux/autonuma.h
@@ -7,15 +7,26 @@
 
 extern void autonuma_enter(struct mm_struct *mm);
 extern void autonuma_exit(struct mm_struct *mm);
-extern void __autonuma_migrate_page_remove(struct page *page);
+extern void __autonuma_migrate_page_remove(struct page *,
+					   struct page_autonuma *);
 extern void autonuma_migrate_split_huge_page(struct page *page,
 					     struct page *page_tail);
 extern void autonuma_setup_new_exec(struct task_struct *p);
+extern struct page_autonuma *lookup_page_autonuma(struct page *page);
 
 static inline void autonuma_migrate_page_remove(struct page *page)
 {
-	if (ACCESS_ONCE(page->autonuma_migrate_nid) >= 0)
-		__autonuma_migrate_page_remove(page);
+	struct page_autonuma *page_autonuma = lookup_page_autonuma(page);
+	if (ACCESS_ONCE(page_autonuma->autonuma_migrate_nid) >= 0)
+		__autonuma_migrate_page_remove(page, page_autonuma);
+}
+
+static inline void autonuma_free_page(struct page *page)
+{
+	if (autonuma_possible()) {
+		autonuma_migrate_page_remove(page);
+		lookup_page_autonuma(page)->autonuma_last_nid = -1;
+	}
 }
 
 #define autonuma_printk(format, args...) \
@@ -29,6 +40,7 @@ static inline void autonuma_migrate_page_remove(struct page *page) {}
 static inline void autonuma_migrate_split_huge_page(struct page *page,
 						    struct page *page_tail) {}
 static inline void autonuma_setup_new_exec(struct task_struct *p) {}
+static inline void autonuma_free_page(struct page *page) {}
 
 #endif /* CONFIG_AUTONUMA */
 
diff --git a/include/linux/autonuma_types.h b/include/linux/autonuma_types.h
index 9673ce8..525c31f 100644
--- a/include/linux/autonuma_types.h
+++ b/include/linux/autonuma_types.h
@@ -78,6 +78,61 @@ struct task_autonuma {
 	/* do not add more variables here, the above array size is dynamic */
 };
 
+/*
+ * Per page (or per-pageblock) structure dynamically allocated only if
+ * autonuma is possible.
+ */
+struct page_autonuma {
+	/*
+	 * To modify autonuma_last_nid locklessly, the architecture
+	 * needs to have SMP atomic granularity < sizeof(long). Not
+	 * all architectures have this, notably some ancient Alphas
+	 * (but none of them should run in NUMA
+	 * systems). Architectures without this granularity require
+	 * autonuma_last_nid to be a long.
+	 */
+#ifdef CONFIG_64BIT
+	/*
+	 * If autonuma_migrate_nid is >= 0, it means the page_autonuma
+	 * structure is linked into one of the NUMA node's migrate
+	 * lists. Which list is determined by the NUMA node the page
+	 * belongs to. If autonuma_migrate_nid is -1, the
+	 * page_autonuma structure is not linked into any NUMA node's
+	 * migrate list.
+	 */
+	int autonuma_migrate_nid;
+	/*
+	 * autonuma_last_nid records the NUMA node that accessed the
+	 * page during the last NUMA hinting page fault. If a
+	 * different node accesses the page next, AutoNUMA will not
+	 * migrate the page. This tries to avoid page thrashing by
+	 * requiring that a page be accessed by the same node twice in
+	 * a row before it is queued for migration.
+	 */
+	int autonuma_last_nid;
+#else
+#if MAX_NUMNODES > 32767
+#error "too many nodes"
+#endif
+	short autonuma_migrate_nid;
+	short autonuma_last_nid;
+#endif
+	/*
+	 * This is the list node that links the page (referenced by
+	 * the page_autonuma structure) in the
+	 * &NODE_DATA(dst_nid)->autonuma_migrate_head[page_nid] lru.
+	 */
+	struct list_head autonuma_migrate_node;
+
+	/*
+	 * To find the page starting from the autonuma_migrate_node we
+	 * need a backlink.
+	 *
+	 * FIXME: drop it;
+	 */
+	struct page *page;
+};
+
 extern int alloc_task_autonuma(struct task_struct *tsk,
 			       struct task_struct *orig,
 			       int node);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3f10fef..c80101c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -152,32 +152,6 @@ struct page {
 		struct page *first_page;	/* Compound tail pages */
 	};
 
-#ifdef CONFIG_AUTONUMA
-	/*
-	 * FIXME: move to pgdat section along with the memcg and allocate
-	 * at runtime only in presence of a numa system.
-	 */
-	/*
-	 * To modify autonuma_last_nid lockless the architecture,
-	 * needs SMP atomic granularity < sizeof(long), not all archs
-	 * have that, notably some ancient alpha (but none of those
-	 * should run in NUMA systems). Archs without that requires
-	 * autonuma_last_nid to be a long.
-	 */
-#ifdef CONFIG_64BIT
-	int autonuma_migrate_nid;
-	int autonuma_last_nid;
-#else
-#if MAX_NUMNODES > 32767
-#error "too many nodes"
-#endif
-	/* FIXME: remember to check the updates are atomic */
-	short autonuma_migrate_nid;
-	short autonuma_last_nid;
-#endif
-	struct list_head autonuma_migrate_node;
-#endif
-
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a5920f8..853e236 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -710,12 +710,9 @@ typedef struct pglist_data {
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
 #ifdef CONFIG_AUTONUMA
-	/*
-	 * lock serializing all lists with heads in the
-	 * autonuma_migrate_head[] array, and the
-	 * autonuma_nr_migrate_pages field.
-	 */
-	spinlock_t autonuma_lock;
+#if !defined(CONFIG_SPARSEMEM)
+	struct page_autonuma *node_page_autonuma;
+#endif
 	/*
 	 * All pages from node "page_nid" to be migrated to this node,
 	 * will be queued into the list
@@ -726,6 +723,12 @@ typedef struct pglist_data {
 	unsigned long autonuma_nr_migrate_pages;
 	/* waitqueue for this node knuma_migrated daemon */
 	wait_queue_head_t autonuma_knuma_migrated_wait;
+	/*
+	 * lock serializing all lists with heads in the
+	 * autonuma_migrate_head[] array, and the
+	 * autonuma_nr_migrate_pages field.
+	 */
+	spinlock_t autonuma_lock;
 #endif
 } pg_data_t;
 
@@ -1088,6 +1091,15 @@ struct mem_section {
 	 * section. (see memcontrol.h/page_cgroup.h about this.)
 	 */
 	struct page_cgroup *page_cgroup;
+#endif
+#ifdef CONFIG_AUTONUMA
+	/*
+	 * If !SPARSEMEM, pgdat doesn't have page_autonuma pointer. We use
+	 * section.
+	 */
+	struct page_autonuma *section_page_autonuma;
+#endif
+#if defined(CONFIG_MEMCG) ^ defined(CONFIG_AUTONUMA)
 	unsigned long pad;
 #endif
 };
diff --git a/include/linux/page_autonuma.h b/include/linux/page_autonuma.h
new file mode 100644
index 0000000..9763e61
--- /dev/null
+++ b/include/linux/page_autonuma.h
@@ -0,0 +1,53 @@
+#ifndef _LINUX_PAGE_AUTONUMA_H
+#define _LINUX_PAGE_AUTONUMA_H
+
+#if defined(CONFIG_AUTONUMA) && !defined(CONFIG_SPARSEMEM)
+extern void __init page_autonuma_init_flatmem(void);
+#else
+static inline void __init page_autonuma_init_flatmem(void) {}
+#endif
+
+#ifdef CONFIG_AUTONUMA
+
+#include <linux/autonuma_flags.h>
+
+extern void __meminit page_autonuma_map_init(struct page *page,
+					     struct page_autonuma *page_autonuma,
+					     int nr_pages);
+
+#ifdef CONFIG_SPARSEMEM
+#define PAGE_AUTONUMA_SIZE (sizeof(struct page_autonuma))
+#define SECTION_PAGE_AUTONUMA_SIZE (PAGE_AUTONUMA_SIZE *	\
+				    PAGES_PER_SECTION)
+#endif
+
+extern void __meminit pgdat_autonuma_init(struct pglist_data *);
+
+#else /* CONFIG_AUTONUMA */
+
+#ifdef CONFIG_SPARSEMEM
+struct page_autonuma;
+#define PAGE_AUTONUMA_SIZE 0
+#define SECTION_PAGE_AUTONUMA_SIZE 0
+
+#define autonuma_possible() false
+
+#endif /* CONFIG_SPARSEMEM */
+
+static inline void pgdat_autonuma_init(struct pglist_data *pgdat) {}
+
+#endif /* CONFIG_AUTONUMA */
+
+#ifdef CONFIG_SPARSEMEM
+extern struct page_autonuma * __meminit __kmalloc_section_page_autonuma(int nid,
+									unsigned long nr_pages);
+extern void __kfree_section_page_autonuma(struct page_autonuma *page_autonuma,
+					  unsigned long nr_pages);
+extern void __init sparse_early_page_autonuma_alloc_node(struct page_autonuma **page_autonuma_map,
+							 unsigned long pnum_begin,
+							 unsigned long pnum_end,
+							 unsigned long map_count,
+							 int nodeid);
+#endif
+
+#endif /* _LINUX_PAGE_AUTONUMA_H */
diff --git a/init/main.c b/init/main.c
index b286730..586764f 100644
--- a/init/main.c
+++ b/init/main.c
@@ -69,6 +69,7 @@
 #include <linux/slab.h>
 #include <linux/perf_event.h>
 #include <linux/file.h>
+#include <linux/page_autonuma.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -456,6 +457,7 @@ static void __init mm_init(void)
 	 * bigger than MAX_ORDER unless SPARSEMEM.
 	 */
 	page_cgroup_init_flatmem();
+	page_autonuma_init_flatmem();
 	mem_init();
 	kmem_cache_init();
 	percpu_init_late();
diff --git a/mm/Makefile b/mm/Makefile
index 0fd3165..5a4fa30 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -34,7 +34,7 @@ obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
-obj-$(CONFIG_AUTONUMA) 	+= autonuma.o
+obj-$(CONFIG_AUTONUMA) 	+= autonuma.o page_autonuma.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
diff --git a/mm/autonuma.c b/mm/autonuma.c
index a505ec3..7967507 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -76,11 +76,18 @@ void autonuma_migrate_split_huge_page(struct page *page,
 				      struct page *page_tail)
 {
 	int nid, last_nid;
+	struct page_autonuma *page_autonuma, *page_tail_autonuma;
 
-	nid = page->autonuma_migrate_nid;
+	if (!autonuma_possible())
+		return;
+
+	page_autonuma = lookup_page_autonuma(page);
+	page_tail_autonuma = lookup_page_autonuma(page_tail);
+
+	nid = page_autonuma->autonuma_migrate_nid;
 	VM_BUG_ON(nid >= MAX_NUMNODES);
 	VM_BUG_ON(nid < -1);
-	VM_BUG_ON(page_tail->autonuma_migrate_nid != -1);
+	VM_BUG_ON(page_tail_autonuma->autonuma_migrate_nid != -1);
 	if (nid >= 0) {
 		VM_BUG_ON(page_to_nid(page) != page_to_nid(page_tail));
 
@@ -94,44 +101,46 @@ void autonuma_migrate_split_huge_page(struct page *page,
 		 */
 		compound_lock(page_tail);
 		autonuma_migrate_lock(nid);
-		list_add_tail(&page_tail->autonuma_migrate_node,
-			      &page->autonuma_migrate_node);
+		list_add_tail(&page_tail_autonuma->autonuma_migrate_node,
+			      &page_autonuma->autonuma_migrate_node);
 		autonuma_migrate_unlock(nid);
 
-		page_tail->autonuma_migrate_nid = nid;
+		page_tail_autonuma->autonuma_migrate_nid = nid;
 		compound_unlock(page_tail);
 	}
 
-	last_nid = ACCESS_ONCE(page->autonuma_last_nid);
+	last_nid = ACCESS_ONCE(page_autonuma->autonuma_last_nid);
 	if (last_nid >= 0)
-		page_tail->autonuma_last_nid = last_nid;
+		page_tail_autonuma->autonuma_last_nid = last_nid;
 }
 
-void __autonuma_migrate_page_remove(struct page *page)
+void __autonuma_migrate_page_remove(struct page *page,
+				    struct page_autonuma *page_autonuma)
 {
 	unsigned long flags;
 	int nid;
 
 	flags = compound_lock_irqsave(page);
 
-	nid = page->autonuma_migrate_nid;
+	nid = page_autonuma->autonuma_migrate_nid;
 	VM_BUG_ON(nid >= MAX_NUMNODES);
 	VM_BUG_ON(nid < -1);
 	if (nid >= 0) {
 		int numpages = hpage_nr_pages(page);
 		autonuma_migrate_lock(nid);
-		list_del(&page->autonuma_migrate_node);
+		list_del(&page_autonuma->autonuma_migrate_node);
 		NODE_DATA(nid)->autonuma_nr_migrate_pages -= numpages;
 		autonuma_migrate_unlock(nid);
 
-		page->autonuma_migrate_nid = -1;
+		page_autonuma->autonuma_migrate_nid = -1;
 	}
 
 	compound_unlock_irqrestore(page, flags);
 }
 
-static void __autonuma_migrate_page_add(struct page *page, int dst_nid,
-					int page_nid)
+static void __autonuma_migrate_page_add(struct page *page,
+					struct page_autonuma *page_autonuma,
+					int dst_nid, int page_nid)
 {
 	unsigned long flags;
 	int nid;
@@ -157,25 +166,25 @@ static void __autonuma_migrate_page_add(struct page *page, int dst_nid,
 	flags = compound_lock_irqsave(page);
 
 	numpages = hpage_nr_pages(page);
-	nid = page->autonuma_migrate_nid;
+	nid = page_autonuma->autonuma_migrate_nid;
 	VM_BUG_ON(nid >= MAX_NUMNODES);
 	VM_BUG_ON(nid < -1);
 	if (nid >= 0) {
 		autonuma_migrate_lock(nid);
-		list_del(&page->autonuma_migrate_node);
+		list_del(&page_autonuma->autonuma_migrate_node);
 		NODE_DATA(nid)->autonuma_nr_migrate_pages -= numpages;
 		autonuma_migrate_unlock(nid);
 	}
 
 	autonuma_migrate_lock(dst_nid);
-	list_add(&page->autonuma_migrate_node,
+	list_add(&page_autonuma->autonuma_migrate_node,
 		 &NODE_DATA(dst_nid)->autonuma_migrate_head[page_nid]);
 	NODE_DATA(dst_nid)->autonuma_nr_migrate_pages += numpages;
 	nr_migrate_pages = NODE_DATA(dst_nid)->autonuma_nr_migrate_pages;
 
 	autonuma_migrate_unlock(dst_nid);
 
-	page->autonuma_migrate_nid = dst_nid;
+	page_autonuma->autonuma_migrate_nid = dst_nid;
 
 	compound_unlock_irqrestore(page, flags);
 
@@ -191,9 +200,13 @@ static void __autonuma_migrate_page_add(struct page *page, int dst_nid,
 static void autonuma_migrate_page_add(struct page *page, int dst_nid,
 				      int page_nid)
 {
-	int migrate_nid = ACCESS_ONCE(page->autonuma_migrate_nid);
+	int migrate_nid;
+	struct page_autonuma *page_autonuma = lookup_page_autonuma(page);
+
+	migrate_nid = ACCESS_ONCE(page_autonuma->autonuma_migrate_nid);
 	if (migrate_nid != dst_nid)
-		__autonuma_migrate_page_add(page, dst_nid, page_nid);
+		__autonuma_migrate_page_add(page, page_autonuma,
+					    dst_nid, page_nid);
 }
 
 static bool autonuma_balance_pgdat(struct pglist_data *pgdat,
@@ -284,23 +297,26 @@ static void numa_hinting_fault_cpu_follow_memory(struct task_struct *p,
 static inline bool last_nid_set(struct page *page, int this_nid)
 {
 	bool ret = true;
-	int autonuma_last_nid = ACCESS_ONCE(page->autonuma_last_nid);
+	struct page_autonuma *page_autonuma = lookup_page_autonuma(page);
+	int autonuma_last_nid = ACCESS_ONCE(page_autonuma->autonuma_last_nid);
 	VM_BUG_ON(this_nid < 0);
 	VM_BUG_ON(this_nid >= MAX_NUMNODES);
 	if (autonuma_last_nid >= 0 && autonuma_last_nid != this_nid) {
-		int migrate_nid = ACCESS_ONCE(page->autonuma_migrate_nid);
+		int migrate_nid;
+		migrate_nid = ACCESS_ONCE(page_autonuma->autonuma_migrate_nid);
 		if (migrate_nid >= 0)
-			__autonuma_migrate_page_remove(page);
+			__autonuma_migrate_page_remove(page, page_autonuma);
 		ret = false;
 	}
 	if (autonuma_last_nid != this_nid)
-		ACCESS_ONCE(page->autonuma_last_nid) = this_nid;
+		ACCESS_ONCE(page_autonuma->autonuma_last_nid) = this_nid;
 	return ret;
 }
 
 static int __page_migrate_nid(struct page *page, int page_nid)
 {
-	int migrate_nid = ACCESS_ONCE(page->autonuma_migrate_nid);
+	struct page_autonuma *page_autonuma = lookup_page_autonuma(page);
+	int migrate_nid = ACCESS_ONCE(page_autonuma->autonuma_migrate_nid);
 	if (migrate_nid < 0)
 		migrate_nid = page_nid;
 	return migrate_nid;
@@ -895,6 +911,7 @@ static int isolate_migratepages(struct list_head *migratepages,
 		struct zone *zone;
 		struct page *page;
 		struct lruvec *lruvec;
+		struct page_autonuma *page_autonuma;
 
 		cond_resched();
 		/*
@@ -926,16 +943,17 @@ static int isolate_migratepages(struct list_head *migratepages,
 			autonuma_migrate_unlock_irq(pgdat->node_id);
 			continue;
 		}
-		page = list_entry(heads[nid].prev,
-				  struct page,
-				  autonuma_migrate_node);
+		page_autonuma = list_entry(heads[nid].prev,
+					   struct page_autonuma,
+					   autonuma_migrate_node);
+		page = page_autonuma->page;
 		if (unlikely(!get_page_unless_zero(page))) {
 			/*
 			 * Is getting freed and will remove self from the
 			 * autonuma list shortly, skip it for now.
 			 */
-			list_del(&page->autonuma_migrate_node);
-			list_add(&page->autonuma_migrate_node,
+			list_del(&page_autonuma->autonuma_migrate_node);
+			list_add(&page_autonuma->autonuma_migrate_node,
 				 &heads[nid]);
 			autonuma_migrate_unlock_irq(pgdat->node_id);
 			autonuma_printk("autonuma migrate page is free\n");
@@ -944,7 +962,7 @@ static int isolate_migratepages(struct list_head *migratepages,
 		autonuma_migrate_unlock_irq(pgdat->node_id);
 		if (!PageLRU(page)) {
 			autonuma_printk("autonuma migrate page not in LRU\n");
-			__autonuma_migrate_page_remove(page);
+			__autonuma_migrate_page_remove(page, page_autonuma);
 			put_page(page);
 			continue;
 		}
@@ -956,13 +974,14 @@ static int isolate_migratepages(struct list_head *migratepages,
 			/* FIXME: remove split_huge_page */
 			if (unlikely(split_huge_page(page))) {
 				autonuma_printk("autonuma migrate THP free\n");
-				__autonuma_migrate_page_remove(page);
+				__autonuma_migrate_page_remove(page,
+							       page_autonuma);
 				put_page(page);
 				continue;
 			}
 		}
 
-		__autonuma_migrate_page_remove(page);
+		__autonuma_migrate_page_remove(page, page_autonuma);
 
 		zone = page_zone(page);
 		spin_lock_irq(&zone->lru_lock);
@@ -1007,11 +1026,16 @@ static struct page *alloc_migrate_dst_page(struct page *page,
 {
 	int nid = (int) data;
 	struct page *newpage;
+	struct page_autonuma *page_autonuma, *newpage_autonuma;
 	newpage = alloc_pages_exact_node(nid,
 					 GFP_HIGHUSER_MOVABLE | GFP_THISNODE,
 					 0);
-	if (newpage)
-		newpage->autonuma_last_nid = page->autonuma_last_nid;
+	if (newpage) {
+		page_autonuma = lookup_page_autonuma(page);
+		newpage_autonuma = lookup_page_autonuma(newpage);
+		newpage_autonuma->autonuma_last_nid =
+			page_autonuma->autonuma_last_nid;
+	}
 	return newpage;
 }
 
@@ -1446,7 +1470,8 @@ static int __init noautonuma_setup(char *str)
 	}
 	return 1;
 }
-__setup("noautonuma", noautonuma_setup);
+/* early so sparse.c also can see it */
+early_param("noautonuma", noautonuma_setup);
 
 static bool autonuma_init_checks_failed(void)
 {
@@ -1470,7 +1495,12 @@ static int __init autonuma_init(void)
 
 	VM_BUG_ON(num_possible_nodes() < 1);
 	if (num_possible_nodes() <= 1 || !autonuma_possible()) {
-		clear_bit(AUTONUMA_POSSIBLE_FLAG, &autonuma_flags);
+		/* should have been already initialized by page_autonuma */
+		if (autonuma_possible()) {
+			WARN_ON(1);
+			/* try to fixup if it wasn't ok */
+			clear_bit(AUTONUMA_POSSIBLE_FLAG, &autonuma_flags);
+		}
 		return -EINVAL;
 	} else if (autonuma_init_checks_failed()) {
 		printk("autonuma disengaged: init checks failed\n");
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 067cba1..579e52b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1849,7 +1849,12 @@ static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
 	bool mknuma = false;
 #ifdef CONFIG_AUTONUMA
 	int autonuma_last_nid = -1;
+	struct page_autonuma *src_page_an, *page_an = NULL;
+
+	if (autonuma_possible())
+		page_an = lookup_page_autonuma(page);
 #endif
+
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR; _pte++) {
 		pte_t pteval = *_pte;
 		struct page *src_page;
@@ -1861,12 +1866,12 @@ static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			src_page = pte_page(pteval);
 #ifdef CONFIG_AUTONUMA
 			/* pick the first one, better than nothing */
-			if (autonuma_last_nid < 0) {
+			if (autonuma_possible() && autonuma_last_nid < 0) {
+				src_page_an = lookup_page_autonuma(src_page);
 				autonuma_last_nid =
-					ACCESS_ONCE(src_page->
-						    autonuma_last_nid);
+					ACCESS_ONCE(src_page_an->autonuma_last_nid);
 				if (autonuma_last_nid >= 0)
-					ACCESS_ONCE(page->autonuma_last_nid) =
+					ACCESS_ONCE(page_an->autonuma_last_nid) =
 						autonuma_last_nid;
 			}
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 49e2916..74b73fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -59,6 +59,7 @@
 #include <linux/migrate.h>
 #include <linux/page-debug-flags.h>
 #include <linux/autonuma.h>
+#include <linux/page_autonuma.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -619,10 +620,7 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 		return 1;
 	}
-	autonuma_migrate_page_remove(page);
-#ifdef CONFIG_AUTONUMA
-	page->autonuma_last_nid = -1;
-#endif
+	autonuma_free_page(page);
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;
@@ -3792,10 +3790,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);
-#ifdef CONFIG_AUTONUMA
-		page->autonuma_last_nid = -1;
-		page->autonuma_migrate_nid = -1;
-#endif
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
 		if (!is_highmem_idx(zone))
@@ -4396,21 +4390,12 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	int nid = pgdat->node_id;
 	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 	int ret;
-#ifdef CONFIG_AUTONUMA
-	int node_iter;
-#endif
 
 	pgdat_resize_init(pgdat);
-#ifdef CONFIG_AUTONUMA
-	spin_lock_init(&pgdat->autonuma_lock);
-	init_waitqueue_head(&pgdat->autonuma_knuma_migrated_wait);
-	pgdat->autonuma_nr_migrate_pages = 0;
-	for_each_node(node_iter)
-		INIT_LIST_HEAD(&pgdat->autonuma_migrate_head[node_iter]);
-#endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat_page_cgroup_init(pgdat);
+	pgdat_autonuma_init(pgdat);
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
diff --git a/mm/page_autonuma.c b/mm/page_autonuma.c
new file mode 100644
index 0000000..46d616c
--- /dev/null
+++ b/mm/page_autonuma.c
@@ -0,0 +1,246 @@
+#include <linux/mm.h>
+#include <linux/memory.h>
+#include <linux/autonuma.h>
+#include <linux/page_autonuma.h>
+#include <linux/bootmem.h>
+
+void __meminit page_autonuma_map_init(struct page *page,
+				      struct page_autonuma *page_autonuma,
+				      int nr_pages)
+{
+	struct page *end;
+	for (end = page + nr_pages; page < end; page++, page_autonuma++) {
+		page_autonuma->autonuma_last_nid = -1;
+		page_autonuma->autonuma_migrate_nid = -1;
+		page_autonuma->page = page;
+	}
+}
+
+static void __meminit __pgdat_autonuma_init(struct pglist_data *pgdat)
+{
+	int node_iter;
+
+	spin_lock_init(&pgdat->autonuma_lock);
+	init_waitqueue_head(&pgdat->autonuma_knuma_migrated_wait);
+	pgdat->autonuma_nr_migrate_pages = 0;
+
+	/* initialize autonuma_possible() */
+	if (num_possible_nodes() <= 1)
+		clear_bit(AUTONUMA_POSSIBLE_FLAG, &autonuma_flags);
+
+	/* noautonuma early param may also clear AUTONUMA_POSSIBLE_FLAG */
+	if (autonuma_possible())
+		for_each_node(node_iter)
+			INIT_LIST_HEAD(&pgdat->autonuma_migrate_head[node_iter]);
+}
+
+#if !defined(CONFIG_SPARSEMEM)
+
+static unsigned long total_usage;
+
+void __meminit pgdat_autonuma_init(struct pglist_data *pgdat)
+{
+	__pgdat_autonuma_init(pgdat);
+	pgdat->node_page_autonuma = NULL;
+}
+
+struct page_autonuma *lookup_page_autonuma(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long offset;
+	struct page_autonuma *base;
+
+	base = NODE_DATA(page_to_nid(page))->node_page_autonuma;
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * The sanity checks the page allocator does upon freeing a
+	 * page can reach here before the page_autonuma arrays are
+	 * allocated when feeding a range of pages to the allocator
+	 * for the first time during bootup or memory hotplug.
+	 */
+	if (unlikely(!base))
+		return NULL;
+#endif
+	offset = pfn - NODE_DATA(page_to_nid(page))->node_start_pfn;
+	return base + offset;
+}
+
+static int __init alloc_node_page_autonuma(int nid)
+{
+	struct page_autonuma *base;
+	unsigned long table_size;
+	unsigned long nr_pages;
+
+	nr_pages = NODE_DATA(nid)->node_spanned_pages;
+	if (!nr_pages)
+		return 0;
+
+	table_size = sizeof(struct page_autonuma) * nr_pages;
+
+	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
+			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	if (!base)
+		return -ENOMEM;
+	NODE_DATA(nid)->node_page_autonuma = base;
+	total_usage += table_size;
+	page_autonuma_map_init(NODE_DATA(nid)->node_mem_map, base, nr_pages);
+	return 0;
+}
+
+void __init page_autonuma_init_flatmem(void)
+{
+
+	int nid, fail;
+
+	/* __pgdat_autonuma_init initialized autonuma_possible() */
+	if (!autonuma_possible())
+		return;
+
+	for_each_online_node(nid)  {
+		fail = alloc_node_page_autonuma(nid);
+		if (fail)
+			goto fail;
+	}
+	printk(KERN_INFO "allocated %lu KBytes of page_autonuma\n",
+	       total_usage >> 10);
+	printk(KERN_INFO "please try the 'noautonuma' option if you"
+	" don't want to allocate page_autonuma memory\n");
+	return;
+fail:
+	printk(KERN_CRIT "allocation of page_autonuma failed.\n");
+	printk(KERN_CRIT "please try the 'noautonuma' boot option\n");
+	panic("Out of memory");
+}
+
+#else /* CONFIG_SPARSEMEM */
+
+struct page_autonuma *lookup_page_autonuma(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	struct mem_section *section = __pfn_to_section(pfn);
+
+	/* if it's not a power of two we may be wasting memory */
+	BUILD_BUG_ON(SECTION_PAGE_AUTONUMA_SIZE &
+		     (SECTION_PAGE_AUTONUMA_SIZE-1));
+
+	/* memsection must be a power of two */
+	BUILD_BUG_ON(sizeof(struct mem_section) &
+		     (sizeof(struct mem_section)-1));
+
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * The sanity checks the page allocator does upon freeing a
+	 * page can reach here before the page_autonuma arrays are
+	 * allocated when feeding a range of pages to the allocator
+	 * for the first time during bootup or memory hotplug.
+	 */
+	if (!section->section_page_autonuma)
+		return NULL;
+#endif
+	return section->section_page_autonuma + pfn;
+}
+
+void __meminit pgdat_autonuma_init(struct pglist_data *pgdat)
+{
+	__pgdat_autonuma_init(pgdat);
+}
+
+struct page_autonuma * __meminit __kmalloc_section_page_autonuma(int nid,
+								 unsigned long nr_pages)
+{
+	struct page_autonuma *ret;
+	struct page *page;
+	unsigned long memmap_size = PAGE_AUTONUMA_SIZE * nr_pages;
+
+	page = alloc_pages_node(nid, GFP_KERNEL|__GFP_NOWARN,
+				get_order(memmap_size));
+	if (page)
+		goto got_map_page_autonuma;
+
+	ret = vmalloc(memmap_size);
+	if (ret)
+		goto out;
+
+	return NULL;
+got_map_page_autonuma:
+	ret = (struct page_autonuma *)pfn_to_kaddr(page_to_pfn(page));
+out:
+	return ret;
+}
+
+void __kfree_section_page_autonuma(struct page_autonuma *page_autonuma,
+				   unsigned long nr_pages)
+{
+	if (is_vmalloc_addr(page_autonuma))
+		vfree(page_autonuma);
+	else
+		free_pages((unsigned long)page_autonuma,
+			   get_order(PAGE_AUTONUMA_SIZE * nr_pages));
+}
+
+static struct page_autonuma __init *sparse_page_autonuma_map_populate(unsigned long pnum,
+								      int nid)
+{
+	struct page_autonuma *map;
+	unsigned long size;
+
+	map = alloc_remap(nid, SECTION_PAGE_AUTONUMA_SIZE);
+	if (map)
+		return map;
+
+	size = PAGE_ALIGN(SECTION_PAGE_AUTONUMA_SIZE);
+	map = __alloc_bootmem_node_high(NODE_DATA(nid), size,
+					PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	return map;
+}
+
+void __init sparse_early_page_autonuma_alloc_node(struct page_autonuma **page_autonuma_map,
+						  unsigned long pnum_begin,
+						  unsigned long pnum_end,
+						  unsigned long map_count,
+						  int nodeid)
+{
+	void *map;
+	unsigned long pnum;
+	unsigned long size = SECTION_PAGE_AUTONUMA_SIZE;
+
+	map = alloc_remap(nodeid, size * map_count);
+	if (map) {
+		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
+			if (!present_section_nr(pnum))
+				continue;
+			page_autonuma_map[pnum] = map;
+			map += size;
+		}
+		return;
+	}
+
+	size = PAGE_ALIGN(size);
+	map = __alloc_bootmem_node_high(NODE_DATA(nodeid), size * map_count,
+					PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	if (map) {
+		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
+			if (!present_section_nr(pnum))
+				continue;
+			page_autonuma_map[pnum] = map;
+			map += size;
+		}
+		return;
+	}
+
+	/* fallback */
+	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
+		struct mem_section *ms;
+
+		if (!present_section_nr(pnum))
+			continue;
+		page_autonuma_map[pnum] = sparse_page_autonuma_map_populate(pnum, nodeid);
+		if (page_autonuma_map[pnum])
+			continue;
+		ms = __nr_to_section(pnum);
+		printk(KERN_ERR "%s: sparsemem page_autonuma map backing failed "
+		       "some memory will not be available.\n", __func__);
+	}
+}
+
+#endif /* CONFIG_SPARSEMEM */
diff --git a/mm/sparse.c b/mm/sparse.c
index fac95f2..5b8d018 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -9,6 +9,7 @@
 #include <linux/export.h>
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
+#include <linux/page_autonuma.h>
 #include "internal.h"
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
@@ -230,7 +231,8 @@ struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pn
 
 static int __meminit sparse_init_one_section(struct mem_section *ms,
 		unsigned long pnum, struct page *mem_map,
-		unsigned long *pageblock_bitmap)
+		unsigned long *pageblock_bitmap,
+		struct page_autonuma *page_autonuma)
 {
 	if (!present_section(ms))
 		return -EINVAL;
@@ -239,6 +241,14 @@ static int __meminit sparse_init_one_section(struct mem_section *ms,
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
 							SECTION_HAS_MEM_MAP;
  	ms->pageblock_flags = pageblock_bitmap;
+#ifdef CONFIG_AUTONUMA
+	if (page_autonuma) {
+		ms->section_page_autonuma = page_autonuma - section_nr_to_pfn(pnum);
+		page_autonuma_map_init(mem_map, page_autonuma, PAGES_PER_SECTION);
+	}
+#else
+	BUG_ON(page_autonuma);
+#endif
 
 	return 1;
 }
@@ -480,6 +490,9 @@ void __init sparse_init(void)
 	int size2;
 	struct page **map_map;
 #endif
+	struct page_autonuma **uninitialized_var(page_autonuma_map);
+	struct page_autonuma *page_autonuma;
+	int size3;
 
 	/* Setup pageblock_order for HUGETLB_PAGE_SIZE_VARIABLE */
 	set_pageblock_order();
@@ -577,6 +590,63 @@ void __init sparse_init(void)
 					 map_count, nodeid_begin);
 #endif
 
+	/* __pgdat_autonuma_init initialized autonuma_possible() */
+	if (autonuma_possible()) {
+		unsigned long total_page_autonuma;
+		unsigned long page_autonuma_count;
+
+		size3 = sizeof(struct page_autonuma *) * NR_MEM_SECTIONS;
+		page_autonuma_map = alloc_bootmem(size3);
+		if (!page_autonuma_map)
+			panic("can not allocate page_autonuma_map\n");
+
+		for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
+			struct mem_section *ms;
+
+			if (!present_section_nr(pnum))
+				continue;
+			ms = __nr_to_section(pnum);
+			nodeid_begin = sparse_early_nid(ms);
+			pnum_begin = pnum;
+			break;
+		}
+		total_page_autonuma = 0;
+		page_autonuma_count = 1;
+		for (pnum = pnum_begin + 1; pnum < NR_MEM_SECTIONS; pnum++) {
+			struct mem_section *ms;
+			int nodeid;
+
+			if (!present_section_nr(pnum))
+				continue;
+			ms = __nr_to_section(pnum);
+			nodeid = sparse_early_nid(ms);
+			if (nodeid == nodeid_begin) {
+				page_autonuma_count++;
+				continue;
+			}
+			/* ok, we need to take cake of from pnum_begin to pnum - 1*/
+			sparse_early_page_autonuma_alloc_node(page_autonuma_map,
+							      pnum_begin,
+							      NR_MEM_SECTIONS,
+							      page_autonuma_count,
+							      nodeid_begin);
+			total_page_autonuma += SECTION_PAGE_AUTONUMA_SIZE * page_autonuma_count;
+			/* new start, update count etc*/
+			nodeid_begin = nodeid;
+			pnum_begin = pnum;
+			page_autonuma_count = 1;
+		}
+		/* ok, last chunk */
+		sparse_early_page_autonuma_alloc_node(page_autonuma_map, pnum_begin,
+						      NR_MEM_SECTIONS,
+						      page_autonuma_count, nodeid_begin);
+		total_page_autonuma += SECTION_PAGE_AUTONUMA_SIZE * page_autonuma_count;
+		printk("allocated %lu KBytes of page_autonuma\n",
+		       total_page_autonuma >> 10);
+		printk(KERN_INFO "please try the 'noautonuma' option if you"
+		       " don't want to allocate page_autonuma memory\n");
+	}
+
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
 		if (!present_section_nr(pnum))
 			continue;
@@ -585,6 +655,13 @@ void __init sparse_init(void)
 		if (!usemap)
 			continue;
 
+		if (autonuma_possible()) {
+			page_autonuma = page_autonuma_map[pnum];
+			if (!page_autonuma)
+				continue;
+		} else
+			page_autonuma = NULL;
+
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 		map = map_map[pnum];
 #else
@@ -594,11 +671,13 @@ void __init sparse_init(void)
 			continue;
 
 		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
-								usemap);
+					usemap, page_autonuma);
 	}
 
 	vmemmap_populate_print_last();
 
+	if (autonuma_possible())
+		free_bootmem(__pa(page_autonuma_map), size3);
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	free_bootmem(__pa(map_map), size2);
 #endif
@@ -685,7 +764,8 @@ static void free_map_bootmem(struct page *page, unsigned long nr_pages)
 }
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
-static void free_section_usemap(struct page *memmap, unsigned long *usemap)
+static void free_section_usemap(struct page *memmap, unsigned long *usemap,
+				struct page_autonuma *page_autonuma)
 {
 	struct page *usemap_page;
 	unsigned long nr_pages;
@@ -699,8 +779,14 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 	 */
 	if (PageSlab(usemap_page)) {
 		kfree(usemap);
-		if (memmap)
+		if (memmap) {
 			__kfree_section_memmap(memmap, PAGES_PER_SECTION);
+			if (autonuma_possible())
+				__kfree_section_page_autonuma(page_autonuma,
+							      PAGES_PER_SECTION);
+			else
+				BUG_ON(page_autonuma);
+		}
 		return;
 	}
 
@@ -717,6 +803,13 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 			>> PAGE_SHIFT;
 
 		free_map_bootmem(memmap_page, nr_pages);
+
+		if (autonuma_possible()) {
+			struct page *page_autonuma_page;
+			page_autonuma_page = virt_to_page(page_autonuma);
+			free_map_bootmem(page_autonuma_page, nr_pages);
+		} else
+			BUG_ON(page_autonuma);
 	}
 }
 
@@ -732,6 +825,7 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	struct mem_section *ms;
 	struct page *memmap;
+	struct page_autonuma *page_autonuma;
 	unsigned long *usemap;
 	unsigned long flags;
 	int ret;
@@ -751,6 +845,16 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 		__kfree_section_memmap(memmap, nr_pages);
 		return -ENOMEM;
 	}
+	if (autonuma_possible()) {
+		page_autonuma = __kmalloc_section_page_autonuma(pgdat->node_id,
+								nr_pages);
+		if (!page_autonuma) {
+			kfree(usemap);
+			__kfree_section_memmap(memmap, nr_pages);
+			return -ENOMEM;
+		}
+	} else
+		page_autonuma = NULL;
 
 	pgdat_resize_lock(pgdat, &flags);
 
@@ -762,11 +866,16 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
-	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
+	ret = sparse_init_one_section(ms, section_nr, memmap, usemap,
+				      page_autonuma);
 
 out:
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret <= 0) {
+		if (autonuma_possible())
+			__kfree_section_page_autonuma(page_autonuma, nr_pages);
+		else
+			BUG_ON(page_autonuma);
 		kfree(usemap);
 		__kfree_section_memmap(memmap, nr_pages);
 	}
@@ -777,6 +886,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 {
 	struct page *memmap = NULL;
 	unsigned long *usemap = NULL;
+	struct page_autonuma *page_autonuma = NULL;
 
 	if (ms->section_mem_map) {
 		usemap = ms->pageblock_flags;
@@ -784,8 +894,12 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 						__section_nr(ms));
 		ms->section_mem_map = 0;
 		ms->pageblock_flags = NULL;
+
+#ifdef CONFIG_AUTONUMA
+		page_autonuma = ms->section_page_autonuma;
+#endif
 	}
 
-	free_section_usemap(memmap, usemap);
+	free_section_usemap(memmap, usemap, page_autonuma);
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
