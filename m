Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C70EC800CA
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 03:12:45 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so9287092pdj.7
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 00:12:45 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id pl6si20335779pdb.123.2014.11.24.00.12.41
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 00:12:42 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 1/8] mm/page_ext: resurrect struct page extending code for debugging
Date: Mon, 24 Nov 2014 17:15:19 +0900
Message-Id: <1416816926-7756-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

When we debug something, we'd like to insert some information to
every page. For this purpose, we sometimes modify struct page itself.
But, this has drawbacks. First, it requires re-compile. This makes us
hesitate to use the powerful debug feature so development process is
slowed down. And, second, sometimes it is impossible to rebuild the kernel
due to third party module dependency. At third, system behaviour would be
largely different after re-compile, because it changes size of struct
page greatly and this structure is accessed by every part of kernel.
Keeping this as it is would be better to reproduce errornous situation.

This feature is intended to overcome above mentioned problems. This feature
allocates memory for extended data per page in certain place rather than
the struct page itself. This memory can be accessed by the accessor
functions provided by this code. During the boot process, it checks whether
allocation of huge chunk of memory is needed or not. If not, it avoids
allocating memory at all. With this advantage, we can include this feature
into the kernel in default and can avoid rebuild and solve related problems.

Until now, memcg uses this technique. But, now, memcg decides to embed
their variable to struct page itself and it's code to extend struct page
has been removed. I'd like to use this code to develop debug feature,
so this patch resurrect it.

To help these things to work well, this patch introduces two callbacks
for clients. One is the need callback which is mandatory if user wants
to avoid useless memory allocation at boot-time. The other is optional,
init callback, which is used to do proper initialization after memory
is allocated. Detailed explanation about purpose of these functions is
in code comment. Please refer it.

Others are completely same with previous extension code in memcg.

v3:
 minor fix for readable code

v2:
 describe overall design at the top of the page extension code.
 add more description on commit message.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h   |   12 ++
 include/linux/page_ext.h |   59 +++++++
 init/main.c              |    7 +
 mm/Kconfig.debug         |    9 ++
 mm/Makefile              |    1 +
 mm/page_alloc.c          |    2 +
 mm/page_ext.c            |  386 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 476 insertions(+)
 create mode 100644 include/linux/page_ext.h
 create mode 100644 mm/page_ext.c

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3879d76..2f0856d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -722,6 +722,9 @@ typedef struct pglist_data {
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
 	struct page *node_mem_map;
+#ifdef CONFIG_PAGE_EXTENSION
+	struct page_ext *node_page_ext;
+#endif
 #endif
 #ifndef CONFIG_NO_BOOTMEM
 	struct bootmem_data *bdata;
@@ -1075,6 +1078,7 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
 
 struct page;
+struct page_ext;
 struct mem_section {
 	/*
 	 * This is, logically, a pointer to an array of struct
@@ -1092,6 +1096,14 @@ struct mem_section {
 
 	/* See declaration of similar field in struct zone */
 	unsigned long *pageblock_flags;
+#ifdef CONFIG_PAGE_EXTENSION
+	/*
+	 * If !SPARSEMEM, pgdat doesn't have page_ext pointer. We use
+	 * section. (see page_ext.h about this.)
+	 */
+	struct page_ext *page_ext;
+	unsigned long pad;
+#endif
 	/*
 	 * WARNING: mem_section must be a power-of-2 in size for the
 	 * calculation and use of SECTION_ROOT_MASK to make sense.
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
new file mode 100644
index 0000000..2ccc8b4
--- /dev/null
+++ b/include/linux/page_ext.h
@@ -0,0 +1,59 @@
+#ifndef __LINUX_PAGE_EXT_H
+#define __LINUX_PAGE_EXT_H
+
+struct pglist_data;
+struct page_ext_operations {
+	bool (*need)(void);
+	void (*init)(void);
+};
+
+#ifdef CONFIG_PAGE_EXTENSION
+
+/*
+ * Page Extension can be considered as an extended mem_map.
+ * A page_ext page is associated with every page descriptor. The
+ * page_ext helps us add more information about the page.
+ * All page_ext are allocated at boot or memory hotplug event,
+ * then the page_ext for pfn always exists.
+ */
+struct page_ext {
+	unsigned long flags;
+};
+
+extern void pgdat_page_ext_init(struct pglist_data *pgdat);
+
+#ifdef CONFIG_SPARSEMEM
+static inline void page_ext_init_flatmem(void)
+{
+}
+extern void page_ext_init(void);
+#else
+extern void page_ext_init_flatmem(void);
+static inline void page_ext_init(void)
+{
+}
+#endif
+
+struct page_ext *lookup_page_ext(struct page *page);
+
+#else /* !CONFIG_PAGE_EXTENSION */
+struct page_ext;
+
+static inline void pgdat_page_ext_init(struct pglist_data *pgdat)
+{
+}
+
+static inline struct page_ext *lookup_page_ext(struct page *page)
+{
+	return NULL;
+}
+
+static inline void page_ext_init(void)
+{
+}
+
+static inline void page_ext_init_flatmem(void)
+{
+}
+#endif /* CONFIG_PAGE_EXTENSION */
+#endif /* __LINUX_PAGE_EXT_H */
diff --git a/init/main.c b/init/main.c
index 235aafb..c60a246 100644
--- a/init/main.c
+++ b/init/main.c
@@ -51,6 +51,7 @@
 #include <linux/mempolicy.h>
 #include <linux/key.h>
 #include <linux/buffer_head.h>
+#include <linux/page_ext.h>
 #include <linux/debug_locks.h>
 #include <linux/debugobjects.h>
 #include <linux/lockdep.h>
@@ -484,6 +485,11 @@ void __init __weak thread_info_cache_init(void)
  */
 static void __init mm_init(void)
 {
+	/*
+	 * page_ext requires contiguous pages,
+	 * bigger than MAX_ORDER unless SPARSEMEM.
+	 */
+	page_ext_init_flatmem();
 	mem_init();
 	kmem_cache_init();
 	percpu_init_late();
@@ -621,6 +627,7 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
+	page_ext_init();
 	debug_objects_mem_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 4b24432..1ba81c7 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -1,3 +1,12 @@
+config PAGE_EXTENSION
+	bool "Extend memmap on extra space for more information on page"
+	---help---
+	  Extend memmap on extra space for more information on page. This
+	  could be used for debugging features that need to insert extra
+	  field for every page. This extension enables us to save memory
+	  by not allocating this extra memory according to boottime
+	  configuration.
+
 config DEBUG_PAGEALLOC
 	bool "Debug page memory allocations"
 	depends on DEBUG_KERNEL
diff --git a/mm/Makefile b/mm/Makefile
index 9c4371d..0b7a784 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -71,3 +71,4 @@ obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
 obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
+obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c0dbede..c91f449 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -48,6 +48,7 @@
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
+#include <linux/page_ext.h>
 #include <linux/debugobjects.h>
 #include <linux/kmemleak.h>
 #include <linux/compaction.h>
@@ -4857,6 +4858,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 #endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
+	pgdat_page_ext_init(pgdat);
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
diff --git a/mm/page_ext.c b/mm/page_ext.c
new file mode 100644
index 0000000..8b3a97a
--- /dev/null
+++ b/mm/page_ext.c
@@ -0,0 +1,386 @@
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/bootmem.h>
+#include <linux/page_ext.h>
+#include <linux/memory.h>
+#include <linux/vmalloc.h>
+#include <linux/kmemleak.h>
+
+/*
+ * struct page extension
+ *
+ * This is the feature to manage memory for extended data per page.
+ *
+ * Until now, we must modify struct page itself to store extra data per page.
+ * This requires rebuilding the kernel and it is really time consuming process.
+ * And, sometimes, rebuild is impossible due to third party module dependency.
+ * At last, enlarging struct page could cause un-wanted system behaviour change.
+ *
+ * This feature is intended to overcome above mentioned problems. This feature
+ * allocates memory for extended data per page in certain place rather than
+ * the struct page itself. This memory can be accessed by the accessor
+ * functions provided by this code. During the boot process, it checks whether
+ * allocation of huge chunk of memory is needed or not. If not, it avoids
+ * allocating memory at all. With this advantage, we can include this feature
+ * into the kernel in default and can avoid rebuild and solve related problems.
+ *
+ * To help these things to work well, there are two callbacks for clients. One
+ * is the need callback which is mandatory if user wants to avoid useless
+ * memory allocation at boot-time. The other is optional, init callback, which
+ * is used to do proper initialization after memory is allocated.
+ *
+ * The need callback is used to decide whether extended memory allocation is
+ * needed or not. Sometimes users want to deactivate some features in this
+ * boot and extra memory would be unneccessary. In this case, to avoid
+ * allocating huge chunk of memory, each clients represent their need of
+ * extra memory through the need callback. If one of the need callbacks
+ * returns true, it means that someone needs extra memory so that
+ * page extension core should allocates memory for page extension. If
+ * none of need callbacks return true, memory isn't needed at all in this boot
+ * and page extension core can skip to allocate memory. As result,
+ * none of memory is wasted.
+ *
+ * The init callback is used to do proper initialization after page extension
+ * is completely initialized. In sparse memory system, extra memory is
+ * allocated some time later than memmap is allocated. In other words, lifetime
+ * of memory for page extension isn't same with memmap for struct page.
+ * Therefore, clients can't store extra data until page extension is
+ * initialized, even if pages are allocated and used freely. This could
+ * cause inadequate state of extra data per page, so, to prevent it, client
+ * can utilize this callback to initialize the state of it correctly.
+ */
+
+static struct page_ext_operations *page_ext_ops[] = {
+};
+
+static unsigned long total_usage;
+
+static bool __init invoke_need_callbacks(void)
+{
+	int i;
+	int entries = ARRAY_SIZE(page_ext_ops);
+
+	for (i = 0; i < entries; i++) {
+		if (page_ext_ops[i]->need && page_ext_ops[i]->need())
+			return true;
+	}
+
+	return false;
+}
+
+static void __init invoke_init_callbacks(void)
+{
+	int i;
+	int entries = ARRAY_SIZE(page_ext_ops);
+
+	for (i = 0; i < entries; i++) {
+		if (page_ext_ops[i]->init)
+			page_ext_ops[i]->init();
+	}
+}
+
+#if !defined(CONFIG_SPARSEMEM)
+
+
+void __meminit pgdat_page_ext_init(struct pglist_data *pgdat)
+{
+	pgdat->node_page_ext = NULL;
+}
+
+struct page_ext *lookup_page_ext(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long offset;
+	struct page_ext *base;
+
+	base = NODE_DATA(page_to_nid(page))->node_page_ext;
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * The sanity checks the page allocator does upon freeing a
+	 * page can reach here before the page_ext arrays are
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
+static int __init alloc_node_page_ext(int nid)
+{
+	struct page_ext *base;
+	unsigned long table_size;
+	unsigned long nr_pages;
+
+	nr_pages = NODE_DATA(nid)->node_spanned_pages;
+	if (!nr_pages)
+		return 0;
+
+	table_size = sizeof(struct page_ext) * nr_pages;
+
+	base = memblock_virt_alloc_try_nid_nopanic(
+			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
+			BOOTMEM_ALLOC_ACCESSIBLE, nid);
+	if (!base)
+		return -ENOMEM;
+	NODE_DATA(nid)->node_page_ext = base;
+	total_usage += table_size;
+	return 0;
+}
+
+void __init page_ext_init_flatmem(void)
+{
+
+	int nid, fail;
+
+	if (!invoke_need_callbacks())
+		return;
+
+	for_each_online_node(nid)  {
+		fail = alloc_node_page_ext(nid);
+		if (fail)
+			goto fail;
+	}
+	pr_info("allocated %ld bytes of page_ext\n", total_usage);
+	invoke_init_callbacks();
+	return;
+
+fail:
+	pr_crit("allocation of page_ext failed.\n");
+	panic("Out of memory");
+}
+
+#else /* CONFIG_FLAT_NODE_MEM_MAP */
+
+struct page_ext *lookup_page_ext(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	struct mem_section *section = __pfn_to_section(pfn);
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * The sanity checks the page allocator does upon freeing a
+	 * page can reach here before the page_ext arrays are
+	 * allocated when feeding a range of pages to the allocator
+	 * for the first time during bootup or memory hotplug.
+	 */
+	if (!section->page_ext)
+		return NULL;
+#endif
+	return section->page_ext + pfn;
+}
+
+static void *__meminit alloc_page_ext(size_t size, int nid)
+{
+	gfp_t flags = GFP_KERNEL | __GFP_ZERO | __GFP_NOWARN;
+	void *addr = NULL;
+
+	addr = alloc_pages_exact_nid(nid, size, flags);
+	if (addr) {
+		kmemleak_alloc(addr, size, 1, flags);
+		return addr;
+	}
+
+	if (node_state(nid, N_HIGH_MEMORY))
+		addr = vzalloc_node(size, nid);
+	else
+		addr = vzalloc(size);
+
+	return addr;
+}
+
+static int __meminit init_section_page_ext(unsigned long pfn, int nid)
+{
+	struct mem_section *section;
+	struct page_ext *base;
+	unsigned long table_size;
+
+	section = __pfn_to_section(pfn);
+
+	if (section->page_ext)
+		return 0;
+
+	table_size = sizeof(struct page_ext) * PAGES_PER_SECTION;
+	base = alloc_page_ext(table_size, nid);
+
+	/*
+	 * The value stored in section->page_ext is (base - pfn)
+	 * and it does not point to the memory block allocated above,
+	 * causing kmemleak false positives.
+	 */
+	kmemleak_not_leak(base);
+
+	if (!base) {
+		pr_err("page ext allocation failure\n");
+		return -ENOMEM;
+	}
+
+	/*
+	 * The passed "pfn" may not be aligned to SECTION.  For the calculation
+	 * we need to apply a mask.
+	 */
+	pfn &= PAGE_SECTION_MASK;
+	section->page_ext = base - pfn;
+	total_usage += table_size;
+	return 0;
+}
+#ifdef CONFIG_MEMORY_HOTPLUG
+static void free_page_ext(void *addr)
+{
+	if (is_vmalloc_addr(addr)) {
+		vfree(addr);
+	} else {
+		struct page *page = virt_to_page(addr);
+		size_t table_size;
+
+		table_size = sizeof(struct page_ext) * PAGES_PER_SECTION;
+
+		BUG_ON(PageReserved(page));
+		free_pages_exact(addr, table_size);
+	}
+}
+
+static void __free_page_ext(unsigned long pfn)
+{
+	struct mem_section *ms;
+	struct page_ext *base;
+
+	ms = __pfn_to_section(pfn);
+	if (!ms || !ms->page_ext)
+		return;
+	base = ms->page_ext + pfn;
+	free_page_ext(base);
+	ms->page_ext = NULL;
+}
+
+static int __meminit online_page_ext(unsigned long start_pfn,
+				unsigned long nr_pages,
+				int nid)
+{
+	unsigned long start, end, pfn;
+	int fail = 0;
+
+	start = SECTION_ALIGN_DOWN(start_pfn);
+	end = SECTION_ALIGN_UP(start_pfn + nr_pages);
+
+	if (nid == -1) {
+		/*
+		 * In this case, "nid" already exists and contains valid memory.
+		 * "start_pfn" passed to us is a pfn which is an arg for
+		 * online__pages(), and start_pfn should exist.
+		 */
+		nid = pfn_to_nid(start_pfn);
+		VM_BUG_ON(!node_state(nid, N_ONLINE));
+	}
+
+	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
+		if (!pfn_present(pfn))
+			continue;
+		fail = init_section_page_ext(pfn, nid);
+	}
+	if (!fail)
+		return 0;
+
+	/* rollback */
+	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)
+		__free_page_ext(pfn);
+
+	return -ENOMEM;
+}
+
+static int __meminit offline_page_ext(unsigned long start_pfn,
+				unsigned long nr_pages, int nid)
+{
+	unsigned long start, end, pfn;
+
+	start = SECTION_ALIGN_DOWN(start_pfn);
+	end = SECTION_ALIGN_UP(start_pfn + nr_pages);
+
+	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)
+		__free_page_ext(pfn);
+	return 0;
+
+}
+
+static int __meminit page_ext_callback(struct notifier_block *self,
+			       unsigned long action, void *arg)
+{
+	struct memory_notify *mn = arg;
+	int ret = 0;
+
+	switch (action) {
+	case MEM_GOING_ONLINE:
+		ret = online_page_ext(mn->start_pfn,
+				   mn->nr_pages, mn->status_change_nid);
+		break;
+	case MEM_OFFLINE:
+		offline_page_ext(mn->start_pfn,
+				mn->nr_pages, mn->status_change_nid);
+		break;
+	case MEM_CANCEL_ONLINE:
+		offline_page_ext(mn->start_pfn,
+				mn->nr_pages, mn->status_change_nid);
+		break;
+	case MEM_GOING_OFFLINE:
+		break;
+	case MEM_ONLINE:
+	case MEM_CANCEL_OFFLINE:
+		break;
+	}
+
+	return notifier_from_errno(ret);
+}
+
+#endif
+
+void __init page_ext_init(void)
+{
+	unsigned long pfn;
+	int nid;
+
+	if (!invoke_need_callbacks())
+		return;
+
+	for_each_node_state(nid, N_MEMORY) {
+		unsigned long start_pfn, end_pfn;
+
+		start_pfn = node_start_pfn(nid);
+		end_pfn = node_end_pfn(nid);
+		/*
+		 * start_pfn and end_pfn may not be aligned to SECTION and the
+		 * page->flags of out of node pages are not initialized.  So we
+		 * scan [start_pfn, the biggest section's pfn < end_pfn) here.
+		 */
+		for (pfn = start_pfn; pfn < end_pfn;
+			pfn = ALIGN(pfn + 1, PAGES_PER_SECTION)) {
+
+			if (!pfn_valid(pfn))
+				continue;
+			/*
+			 * Nodes's pfns can be overlapping.
+			 * We know some arch can have a nodes layout such as
+			 * -------------pfn-------------->
+			 * N0 | N1 | N2 | N0 | N1 | N2|....
+			 */
+			if (pfn_to_nid(pfn) != nid)
+				continue;
+			if (init_section_page_ext(pfn, nid))
+				goto oom;
+		}
+	}
+	hotplug_memory_notifier(page_ext_callback, 0);
+	pr_info("allocated %ld bytes of page_ext\n", total_usage);
+	invoke_init_callbacks();
+	return;
+
+oom:
+	panic("Out of memory");
+}
+
+void __meminit pgdat_page_ext_init(struct pglist_data *pgdat)
+{
+}
+
+#endif
+
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
