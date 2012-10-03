Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 659E86B00B2
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:47 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 29/33] autonuma: page_autonuma
Date: Thu,  4 Oct 2012 01:51:11 +0200
Message-Id: <1349308275-2174-30-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Move the autonuma_last_nid from the "struct page" to a separate
page_autonuma data structure allocated in the memsection (with
sparsemem) or in the pgdat (with flatmem).

This is done to avoid growing the size of "struct page". The
page_autonuma data is only allocated if the kernel is booted on real
NUMA hardware and noautonuma is not passed as a parameter to the
kernel.

An alternative would be to takeover 16 bits from the page->flags: but:

1) 32bit are already used (in fact 32bit archs are considering to
   adding another 32bit too to avoid losing common code features), 16
   bits would be used by the last_nid, and several bits are used by
   per-node (readonly) zone/node information, so we would be left with
   just an handful of spare PG_ bits if we stole 16 for the last_nid.

2) We cannot exclude we'll want to add more bits of information in the
   future (and more than 16 wouldn't fit on page->flags). Changing the
   format or layout of the page_autonuma structure is trivial,
   compared to altering the format of the page->flags. So
   page_autonuma is much more hackable than page->flags.

3) page->flags can be modified from under us with locked ops
   (lock_page and all page flags operations). Normally we never change
   more than 1 bit at once on it. So the way page->flags could be
   updated is through cmpxchg. That's slow and tricky code would need
   to be written for it (potentially to drop late in case of point 2
   above). Allocating those 2 bytes separately to me looks a lot
   cleaner even if it takes 0.048% of memory (but only when booting on
   NUMA hardware).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma.h       |    8 ++
 include/linux/autonuma_types.h |   19 +++
 include/linux/mm_types.h       |   11 --
 include/linux/mmzone.h         |   12 ++
 include/linux/page_autonuma.h  |   50 +++++++++
 init/main.c                    |    2 +
 mm/Makefile                    |    2 +-
 mm/autonuma.c                  |   37 +++++--
 mm/huge_memory.c               |   13 ++-
 mm/page_alloc.c                |   14 +--
 mm/page_autonuma.c             |  237 ++++++++++++++++++++++++++++++++++++++++
 mm/sparse.c                    |  126 ++++++++++++++++++++-
 12 files changed, 490 insertions(+), 41 deletions(-)
 create mode 100644 include/linux/page_autonuma.h
 create mode 100644 mm/page_autonuma.c

diff --git a/include/linux/autonuma.h b/include/linux/autonuma.h
index 02d4875..274c616 100644
--- a/include/linux/autonuma.h
+++ b/include/linux/autonuma.h
@@ -10,6 +10,13 @@ extern void autonuma_exit(struct mm_struct *mm);
 extern void autonuma_migrate_split_huge_page(struct page *page,
 					     struct page *page_tail);
 extern void autonuma_setup_new_exec(struct task_struct *p);
+extern struct page_autonuma *lookup_page_autonuma(struct page *page);
+
+static inline void autonuma_free_page(struct page *page)
+{
+	if (autonuma_possible())
+		lookup_page_autonuma(page)->autonuma_last_nid = -1;
+}
 
 #define autonuma_printk(format, args...) \
 	if (autonuma_debug()) printk(format, ##args)
@@ -21,6 +28,7 @@ static inline void autonuma_exit(struct mm_struct *mm) {}
 static inline void autonuma_migrate_split_huge_page(struct page *page,
 						    struct page *page_tail) {}
 static inline void autonuma_setup_new_exec(struct task_struct *p) {}
+static inline void autonuma_free_page(struct page *page) {}
 
 #endif /* CONFIG_AUTONUMA */
 
diff --git a/include/linux/autonuma_types.h b/include/linux/autonuma_types.h
index 9673ce8..d0c6403 100644
--- a/include/linux/autonuma_types.h
+++ b/include/linux/autonuma_types.h
@@ -78,6 +78,25 @@ struct task_autonuma {
 	/* do not add more variables here, the above array size is dynamic */
 };
 
+/*
+ * Per page (or per-pageblock) structure dynamically allocated only if
+ * autonuma is possible.
+ */
+struct page_autonuma {
+	/*
+	 * autonuma_last_nid records the NUMA node that accessed the
+	 * page during the last NUMA hinting page fault. If a
+	 * different node accesses the page next, AutoNUMA will not
+	 * migrate the page. This tries to avoid page thrashing by
+	 * requiring that a page be accessed by the same node twice in
+	 * a row before it is queued for migration.
+	 */
+#if MAX_NUMNODES > 32767
+#error "too many nodes"
+#endif
+	short autonuma_last_nid;
+};
+
 extern int alloc_task_autonuma(struct task_struct *tsk,
 			       struct task_struct *orig,
 			       int node);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 9e8398a..c80101c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -152,17 +152,6 @@ struct page {
 		struct page *first_page;	/* Compound tail pages */
 	};
 
-#ifdef CONFIG_AUTONUMA
-	/*
-	 * FIXME: move to pgdat section along with the memcg and allocate
-	 * at runtime only in presence of a numa system.
-	 */
-#if MAX_NUMNODES > 32767
-#error "too many nodes"
-#endif
-	short autonuma_last_nid;
-#endif
-
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f793541..db68389 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -710,6 +710,9 @@ typedef struct pglist_data {
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
 #ifdef CONFIG_AUTONUMA
+#if !defined(CONFIG_SPARSEMEM)
+	struct page_autonuma *node_page_autonuma;
+#endif
 	/*
 	 * Lock serializing the per destination node AutoNUMA memory
 	 * migration rate limiting data.
@@ -1081,6 +1084,15 @@ struct mem_section {
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
index 0000000..6da6c51
--- /dev/null
+++ b/include/linux/page_autonuma.h
@@ -0,0 +1,50 @@
+#ifndef _LINUX_PAGE_AUTONUMA_H
+#define _LINUX_PAGE_AUTONUMA_H
+
+#include <linux/autonuma_flags.h>
+
+#if defined(CONFIG_AUTONUMA) && !defined(CONFIG_SPARSEMEM)
+extern void __init page_autonuma_init_flatmem(void);
+#else
+static inline void __init page_autonuma_init_flatmem(void) {}
+#endif
+
+#ifdef CONFIG_AUTONUMA
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
index 1b2530c..b5c5ff6 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -55,10 +55,19 @@ void autonuma_migrate_split_huge_page(struct page *page,
 				      struct page *page_tail)
 {
 	int last_nid;
+	struct page_autonuma *page_autonuma, *page_tail_autonuma;
 
-	last_nid = ACCESS_ONCE(page->autonuma_last_nid);
+	if (!autonuma_possible())
+		return;
+
+	page_autonuma = lookup_page_autonuma(page);
+	page_tail_autonuma = lookup_page_autonuma(page_tail);
+
+	VM_BUG_ON(page_tail_autonuma->autonuma_last_nid != -1);
+
+	last_nid = ACCESS_ONCE(page_autonuma->autonuma_last_nid);
 	if (last_nid >= 0)
-		page_tail->autonuma_last_nid = last_nid;
+		page_tail_autonuma->autonuma_last_nid = last_nid;
 }
 
 static int sync_isolate_migratepages(struct list_head *migratepages,
@@ -176,13 +185,18 @@ static struct page *alloc_migrate_dst_page(struct page *page,
 {
 	int nid = (int) data;
 	struct page *newpage;
+	struct page_autonuma *page_autonuma, *newpage_autonuma;
 	newpage = alloc_pages_exact_node(nid,
 					 (GFP_HIGHUSER_MOVABLE | GFP_THISNODE |
 					  __GFP_NOMEMALLOC | __GFP_NORETRY |
 					  __GFP_NOWARN | __GFP_NO_KSWAPD) &
 					 ~GFP_IOFS, 0);
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
 
@@ -291,13 +305,14 @@ static void numa_hinting_fault_cpu_follow_memory(struct task_struct *p,
 static inline bool last_nid_set(struct page *page, int this_nid)
 {
 	bool ret = true;
-	int autonuma_last_nid = ACCESS_ONCE(page->autonuma_last_nid);
+	struct page_autonuma *page_autonuma = lookup_page_autonuma(page);
+	int autonuma_last_nid = ACCESS_ONCE(page_autonuma->autonuma_last_nid);
 	VM_BUG_ON(this_nid < 0);
 	VM_BUG_ON(this_nid >= MAX_NUMNODES);
 	if (autonuma_last_nid != this_nid) {
 		if (autonuma_last_nid >= 0)
 			ret = false;
-		ACCESS_ONCE(page->autonuma_last_nid) = this_nid;
+		ACCESS_ONCE(page_autonuma->autonuma_last_nid) = this_nid;
 	}
 	return ret;
 }
@@ -1185,7 +1200,8 @@ static int __init noautonuma_setup(char *str)
 	}
 	return 1;
 }
-__setup("noautonuma", noautonuma_setup);
+/* early so sparse.c also can see it */
+early_param("noautonuma", noautonuma_setup);
 
 static bool autonuma_init_checks_failed(void)
 {
@@ -1209,7 +1225,12 @@ static int __init autonuma_init(void)
 
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
index 757c1cc..86db742 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1850,7 +1850,12 @@ static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
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
@@ -1862,12 +1867,12 @@ static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
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
index e096742..8e6493a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -59,6 +59,7 @@
 #include <linux/migrate.h>
 #include <linux/page-debug-flags.h>
 #include <linux/autonuma.h>
+#include <linux/page_autonuma.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -619,9 +620,7 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 		return 1;
 	}
-#ifdef CONFIG_AUTONUMA
-	page->autonuma_last_nid = -1;
-#endif
+	autonuma_free_page(page);
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;
@@ -3797,9 +3796,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);
-#ifdef CONFIG_AUTONUMA
-		page->autonuma_last_nid = -1;
-#endif
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
 		if (!is_highmem_idx(zone))
@@ -4402,14 +4398,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	int ret;
 
 	pgdat_resize_init(pgdat);
-#ifdef CONFIG_AUTONUMA
-	spin_lock_init(&pgdat->autonuma_migrate_lock);
-	pgdat->autonuma_migrate_nr_pages = 0;
-	pgdat->autonuma_migrate_last_jiffies = jiffies;
-#endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat_page_cgroup_init(pgdat);
+	pgdat_autonuma_init(pgdat);
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
diff --git a/mm/page_autonuma.c b/mm/page_autonuma.c
new file mode 100644
index 0000000..d400d7f
--- /dev/null
+++ b/mm/page_autonuma.c
@@ -0,0 +1,237 @@
+#include <linux/mm.h>
+#include <linux/memory.h>
+#include <linux/autonuma.h>
+#include <linux/page_autonuma.h>
+#include <linux/bootmem.h>
+#include <linux/vmalloc.h>
+
+void __meminit page_autonuma_map_init(struct page *page,
+				      struct page_autonuma *page_autonuma,
+				      int nr_pages)
+{
+	struct page *end;
+	for (end = page + nr_pages; page < end; page++, page_autonuma++)
+		page_autonuma->autonuma_last_nid = -1;
+}
+
+static void __meminit __pgdat_autonuma_init(struct pglist_data *pgdat)
+{
+	spin_lock_init(&pgdat->autonuma_migrate_lock);
+	pgdat->autonuma_migrate_nr_pages = 0;
+	pgdat->autonuma_migrate_last_jiffies = jiffies;
+
+	/* initialize autonuma_possible() */
+	if (num_possible_nodes() <= 1)
+		clear_bit(AUTONUMA_POSSIBLE_FLAG, &autonuma_flags);
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
