Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id C64096B0070
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 03:11:41 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id w10so4795260pde.33
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 00:11:41 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id hg4si6777096pbc.83.2014.11.21.00.11.37
        for <linux-mm@kvack.org>;
        Fri, 21 Nov 2014 00:11:38 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 6/7] mm/page_owner: keep track of page owners
Date: Fri, 21 Nov 2014 17:14:05 +0900
Message-Id: <1416557646-21755-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1416557646-21755-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416557646-21755-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This is the page owner tracking code which is introduced
so far ago. It is resident on Andrew's tree, though, nobody
tried to upstream so it remain as is. Our company uses this feature
actively to debug memory leak or to find a memory hogger so
I decide to upstream this feature.

This functionality help us to know who allocates the page.
When allocating a page, we store some information about
allocation in extra memory. Later, if we need to know
status of all pages, we can get and analyze it from this stored
information.

In previous version of this feature, extra memory is statically defined
in struct page, but, in this version, extra memory is allocated outside
of struct page. It enables us to turn on/off this feature at boottime
without considerable memory waste.

Although we already have tracepoint for tracing page allocation/free,
using it to analyze page owner is rather complex. We need to enlarge
the trace buffer for preventing overlapping until userspace program
launched. And, launched program continually dump out the trace buffer
for later analysis and it would change system behaviour with more
possibility rather than just keeping it in memory, so bad for debug.

Moreover, we can use page_owner feature further for various purposes.
For example, we can use it for fragmentation statistics implemented in
this patch. And, I also plan to implement some CMA failure debugging
feature using this interface.

I'd like to give the credit for all developers contributed this feature,
but, it's not easy because I don't know exact history. Sorry about that.
Below is people who has "Signed-off-by" in the patches in Andrew's tree.

Contributor:
Alexander Nyberg <alexn@dsv.su.se>
Mel Gorman <mgorman@suse.de>
Dave Hansen <dave@linux.vnet.ibm.com>
Minchan Kim <minchan@kernel.org>
Michal Nazarewicz <mina86@mina86.com>
Andrew Morton <akpm@linux-foundation.org>
Jungsoo Son <jungsoo.son@lge.com>

v2: Do set_page_owner() more places than v1. This corrects page owner
information of memory for alloc_pages_exact() and compaction/CMA.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 Documentation/kernel-parameters.txt |    6 +
 include/linux/page_ext.h            |   10 ++
 include/linux/page_owner.h          |   19 +++
 lib/Kconfig.debug                   |   13 ++
 mm/Makefile                         |    1 +
 mm/page_alloc.c                     |   11 +-
 mm/page_ext.c                       |    4 +
 mm/page_owner.c                     |  224 +++++++++++++++++++++++++++++++++++
 mm/vmstat.c                         |   93 +++++++++++++++
 tools/vm/Makefile                   |    4 +-
 tools/vm/page_owner_sort.c          |  144 ++++++++++++++++++++++
 11 files changed, 526 insertions(+), 3 deletions(-)
 create mode 100644 include/linux/page_owner.h
 create mode 100644 mm/page_owner.c
 create mode 100644 tools/vm/page_owner_sort.c

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index b5ac055..3632005 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -884,6 +884,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			MTRR settings.  This parameter disables that behavior,
 			possibly causing your machine to run very slowly.
 
+	disable_page_owner
+			[KNL] Disable to store the information who requests
+			the page. We can avoid allocating huge chunk of memory
+			if page owner is only client for page extension and
+			this parameter is specified.
+
 	disable_timer_pin_1 [X86]
 			Disable PIN 1 of APIC timer
 			Can be useful to work around chipset bugs.
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 61c0f05..d2a2c84 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -1,6 +1,9 @@
 #ifndef __LINUX_PAGE_EXT_H
 #define __LINUX_PAGE_EXT_H
 
+#include <linux/types.h>
+#include <linux/stacktrace.h>
+
 struct pglist_data;
 struct page_ext_operations {
 	bool (*need)(void);
@@ -22,6 +25,7 @@ struct page_ext_operations {
 enum page_ext_flags {
 	PAGE_EXT_DEBUG_POISON,		/* Page is poisoned */
 	PAGE_EXT_DEBUG_GUARD,
+	PAGE_EXT_OWNER,
 };
 
 /*
@@ -33,6 +37,12 @@ enum page_ext_flags {
  */
 struct page_ext {
 	unsigned long flags;
+#ifdef CONFIG_PAGE_OWNER
+	unsigned int order;
+	gfp_t gfp_mask;
+	struct stack_trace trace;
+	unsigned long trace_entries[8];
+#endif
 };
 
 extern void pgdat_page_ext_init(struct pglist_data *pgdat);
diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
new file mode 100644
index 0000000..a2e15c3
--- /dev/null
+++ b/include/linux/page_owner.h
@@ -0,0 +1,19 @@
+#ifndef __LINUX_PAGE_OWNER_H
+#define __LINUX_PAGE_OWNER_H
+
+#ifdef CONFIG_PAGE_OWNER
+extern struct page_ext_operations page_owner_ops;
+extern void reset_page_owner(struct page *page, unsigned int order);
+extern void set_page_owner(struct page *page,
+			unsigned int order, gfp_t gfp_mask);
+#else
+static inline void reset_page_owner(struct page *page, unsigned int order)
+{
+}
+static inline void set_page_owner(struct page *page,
+			unsigned int order, gfp_t gfp_mask)
+{
+}
+
+#endif /* CONFIG_PAGE_OWNER */
+#endif /* __LINUX_PAGE_OWNER_H */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c078a76..4b03d14 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -227,6 +227,19 @@ config UNUSED_SYMBOLS
 	  you really need it, and what the merge plan to the mainline kernel for
 	  your module is.
 
+config PAGE_OWNER
+	bool "Track page owner"
+	depends on DEBUG_KERNEL && STACKTRACE_SUPPORT
+	select DEBUG_FS
+	select STACKTRACE
+	select PAGE_EXTENSION
+	help
+	  This keeps track of what call chain is the owner of a page, may
+	  help to find bare alloc_page(s) leaks. Eats a fair amount of memory.
+	  See tools/vm/page_owner_sort.c for user-space helper.
+
+	  If unsure, say N.
+
 config DEBUG_FS
 	bool "Debug Filesystem"
 	help
diff --git a/mm/Makefile b/mm/Makefile
index 0b7a784..3548460 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -63,6 +63,7 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+obj-$(CONFIG_PAGE_OWNER) += page_owner.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
 obj-$(CONFIG_ZPOOL)	+= zpool.o
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4eea173..f1968d7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -59,6 +59,7 @@
 #include <linux/page_ext.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
+#include <linux/page_owner.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -810,6 +811,8 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	if (bad)
 		return false;
 
+	reset_page_owner(page, order);
+
 	if (!PageHighMem(page)) {
 		debug_check_no_locks_freed(page_address(page),
 					   PAGE_SIZE << order);
@@ -985,6 +988,8 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
 
+	set_page_owner(page, order, gfp_flags);
+
 	return 0;
 }
 
@@ -1557,8 +1562,11 @@ void split_page(struct page *page, unsigned int order)
 		split_page(virt_to_page(page[0].shadow), order);
 #endif
 
-	for (i = 1; i < (1 << order); i++)
+	set_page_owner(page, 0, 0);
+	for (i = 1; i < (1 << order); i++) {
 		set_page_refcounted(page + i);
+		set_page_owner(page + i, 0, 0);
+	}
 }
 EXPORT_SYMBOL_GPL(split_page);
 
@@ -1598,6 +1606,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		}
 	}
 
+	set_page_owner(page, order, 0);
 	return 1UL << order;
 }
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 439f2f5..4edecea 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -5,6 +5,7 @@
 #include <linux/memory.h>
 #include <linux/vmalloc.h>
 #include <linux/kmemleak.h>
+#include <linux/page_owner.h>
 
 /*
  * struct page extension
@@ -55,6 +56,9 @@ static struct page_ext_operations *page_ext_ops[] = {
 #ifdef CONFIG_PAGE_POISONING
 	&page_poisoning_ops,
 #endif
+#ifdef CONFIG_PAGE_OWNER
+	&page_owner_ops,
+#endif
 };
 
 static unsigned long total_usage;
diff --git a/mm/page_owner.c b/mm/page_owner.c
new file mode 100644
index 0000000..f75dfe0
--- /dev/null
+++ b/mm/page_owner.c
@@ -0,0 +1,224 @@
+#include <linux/debugfs.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/bootmem.h>
+#include <linux/stacktrace.h>
+#include <linux/page_owner.h>
+#include "internal.h"
+
+static bool page_owner_disabled;
+static bool page_owner_enabled __read_mostly;
+
+static int early_disable_page_owner(char *buf)
+{
+	page_owner_disabled = true;
+
+	return 0;
+}
+early_param("disable_page_owner", early_disable_page_owner);
+
+static bool need_page_owner(void)
+{
+	if (page_owner_disabled)
+		return false;
+
+	return true;
+}
+
+static void init_page_owner(void)
+{
+	if (page_owner_disabled)
+		return;
+
+	page_owner_enabled = true;
+}
+
+struct page_ext_operations page_owner_ops = {
+	.need = need_page_owner,
+	.init = init_page_owner,
+};
+
+void reset_page_owner(struct page *page, unsigned int order)
+{
+	int i;
+	struct page_ext *page_ext;
+
+	if (!page_owner_enabled)
+		return;
+
+	for (i = 0; i < (1 << order); i++) {
+		page_ext = lookup_page_ext(page + i);
+		__clear_bit(PAGE_EXT_OWNER, &page_ext->flags);
+	}
+}
+
+void set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
+{
+	struct page_ext *page_ext;
+	struct stack_trace *trace;
+
+	if (!page_owner_enabled)
+		return;
+
+	page_ext = lookup_page_ext(page);
+
+	trace = &page_ext->trace;
+	trace->nr_entries = 0;
+	trace->max_entries = ARRAY_SIZE(page_ext->trace_entries);
+	trace->entries = &page_ext->trace_entries[0];
+	trace->skip = 3;
+	save_stack_trace(&page_ext->trace);
+
+	page_ext->order = order;
+	page_ext->gfp_mask = gfp_mask;
+
+	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
+}
+
+static ssize_t
+print_page_owner(char __user *buf, size_t count, unsigned long pfn,
+		struct page *page, struct page_ext *page_ext)
+{
+	int ret;
+	int pageblock_mt, page_mt;
+	char *kbuf;
+
+	kbuf = kmalloc(count, GFP_KERNEL);
+	if (!kbuf)
+		return -ENOMEM;
+
+	ret = snprintf(kbuf, count,
+			"Page allocated via order %u, mask 0x%x\n",
+			page_ext->order, page_ext->gfp_mask);
+
+	if (ret >= count)
+		goto err;
+
+	/* Print information relevant to grouping pages by mobility */
+	pageblock_mt = get_pfnblock_migratetype(page, pfn);
+	page_mt  = gfpflags_to_migratetype(page_ext->gfp_mask);
+	ret += snprintf(kbuf + ret, count - ret,
+			"PFN %lu Block %lu type %d %s Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
+			pfn,
+			pfn >> pageblock_order,
+			pageblock_mt,
+			pageblock_mt != page_mt ? "Fallback" : "        ",
+			PageLocked(page)	? "K" : " ",
+			PageError(page)		? "E" : " ",
+			PageReferenced(page)	? "R" : " ",
+			PageUptodate(page)	? "U" : " ",
+			PageDirty(page)		? "D" : " ",
+			PageLRU(page)		? "L" : " ",
+			PageActive(page)	? "A" : " ",
+			PageSlab(page)		? "S" : " ",
+			PageWriteback(page)	? "W" : " ",
+			PageCompound(page)	? "C" : " ",
+			PageSwapCache(page)	? "B" : " ",
+			PageMappedToDisk(page)	? "M" : " ");
+
+	if (ret >= count)
+		goto err;
+
+	ret += snprint_stack_trace(kbuf + ret, count - ret,
+					&page_ext->trace, 0);
+	if (ret >= count)
+		goto err;
+
+	ret += snprintf(kbuf + ret, count - ret, "\n");
+	if (ret >= count)
+		goto err;
+
+	if (copy_to_user(buf, kbuf, ret))
+		ret = -EFAULT;
+
+	kfree(kbuf);
+	return ret;
+
+err:
+	kfree(kbuf);
+	return -ENOMEM;
+}
+
+static ssize_t
+read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
+{
+	unsigned long pfn;
+	struct page *page;
+	struct page_ext *page_ext;
+
+	if (!page_owner_enabled)
+		return -EINVAL;
+
+	page = NULL;
+	pfn = min_low_pfn + *ppos;
+
+	/* Find a valid PFN or the start of a MAX_ORDER_NR_PAGES area */
+	while (!pfn_valid(pfn) && (pfn & (MAX_ORDER_NR_PAGES - 1)) != 0)
+		pfn++;
+
+	drain_all_pages(NULL);
+
+	/* Find an allocated page */
+	for (; pfn < max_pfn; pfn++) {
+		/*
+		 * If the new page is in a new MAX_ORDER_NR_PAGES area,
+		 * validate the area as existing, skip it if not
+		 */
+		if ((pfn & (MAX_ORDER_NR_PAGES - 1)) == 0 && !pfn_valid(pfn)) {
+			pfn += MAX_ORDER_NR_PAGES - 1;
+			continue;
+		}
+
+		/* Check for holes within a MAX_ORDER area */
+		if (!pfn_valid_within(pfn))
+			continue;
+
+		page = pfn_to_page(pfn);
+		if (PageBuddy(page)) {
+			unsigned long freepage_order = page_order_unsafe(page);
+
+			if (freepage_order < MAX_ORDER)
+				pfn += (1UL << freepage_order) - 1;
+			continue;
+		}
+
+		page_ext = lookup_page_ext(page);
+
+		/*
+		 * Pages allocated before initialization of page_owner are
+		 * non-buddy and have no page_owner info.
+		 */
+		if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
+			continue;
+
+		/* Record the next PFN to read in the file offset */
+		*ppos = (pfn - min_low_pfn) + 1;
+
+		return print_page_owner(buf, count, pfn, page, page_ext);
+	}
+
+	return 0;
+}
+
+static const struct file_operations proc_page_owner_operations = {
+	.read		= read_page_owner,
+};
+
+static int __init pageowner_init(void)
+{
+	struct dentry *dentry;
+
+	if (!page_owner_enabled) {
+		pr_info("page_owner is disabled\n");
+		return 0;
+	}
+
+	dentry = debugfs_create_file("page_owner", S_IRUSR, NULL,
+			NULL, &proc_page_owner_operations);
+	if (IS_ERR(dentry))
+		return PTR_ERR(dentry);
+
+	return 0;
+}
+module_init(pageowner_init)
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1b12d39..c2f0c58 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -22,6 +22,7 @@
 #include <linux/writeback.h>
 #include <linux/compaction.h>
 #include <linux/mm_inline.h>
+#include <linux/page_ext.h>
 
 #include "internal.h"
 
@@ -1017,6 +1018,97 @@ static int pagetypeinfo_showblockcount(struct seq_file *m, void *arg)
 	return 0;
 }
 
+#ifdef CONFIG_PAGE_OWNER
+static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
+							pg_data_t *pgdat,
+							struct zone *zone)
+{
+	struct page *page;
+	struct page_ext *page_ext;
+	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
+	unsigned long end_pfn = pfn + zone->spanned_pages;
+	unsigned long count[MIGRATE_TYPES] = { 0, };
+	int pageblock_mt, page_mt;
+	int i;
+
+	/* Scan block by block. First and last block may be incomplete */
+	pfn = zone->zone_start_pfn;
+
+	/*
+	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
+	 * a zone boundary, it will be double counted between zones. This does
+	 * not matter as the mixed block count will still be correct
+	 */
+	for (; pfn < end_pfn; ) {
+		if (!pfn_valid(pfn)) {
+			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
+			continue;
+		}
+
+		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+		block_end_pfn = min(block_end_pfn, end_pfn);
+
+		page = pfn_to_page(pfn);
+		pageblock_mt = get_pfnblock_migratetype(page, pfn);
+
+		for (; pfn < block_end_pfn; pfn++) {
+			if (!pfn_valid_within(pfn))
+				continue;
+
+			page = pfn_to_page(pfn);
+			if (PageBuddy(page)) {
+				pfn += (1UL << page_order(page)) - 1;
+				continue;
+			}
+
+			page_ext = lookup_page_ext(page);
+
+			/* We can't track early allocated pages */
+			if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
+				continue;
+
+			page_mt = gfpflags_to_migratetype(page_ext->gfp_mask);
+			if (pageblock_mt != page_mt) {
+				if (is_migrate_cma(pageblock_mt))
+					count[MIGRATE_MOVABLE]++;
+				else
+					count[pageblock_mt]++;
+				break;
+			}
+			pfn += (1UL << page_ext->order) - 1;
+		}
+	}
+
+	/* Print counts */
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (i = 0; i < MIGRATE_TYPES; i++)
+		seq_printf(m, "%12lu ", count[i]);
+	seq_putc(m, '\n');
+}
+#endif /* CONFIG_PAGE_OWNER */
+
+/*
+ * Print out the number of pageblocks for each migratetype that contain pages
+ * of other types. This gives an indication of how well fallbacks are being
+ * contained by rmqueue_fallback(). It requires information from PAGE_OWNER
+ * to determine what is going on
+ */
+static void pagetypeinfo_showmixedcount(struct seq_file *m, pg_data_t *pgdat)
+{
+#ifdef CONFIG_PAGE_OWNER
+	int mtype;
+
+	drain_all_pages(NULL);
+
+	seq_printf(m, "\n%-23s", "Number of mixed blocks ");
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12s ", migratetype_names[mtype]);
+	seq_putc(m, '\n');
+
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showmixedcount_print);
+#endif /* CONFIG_PAGE_OWNER */
+}
+
 /*
  * This prints out statistics in relation to grouping pages by mobility.
  * It is expensive to collect so do not constantly read the file.
@@ -1034,6 +1126,7 @@ static int pagetypeinfo_show(struct seq_file *m, void *arg)
 	seq_putc(m, '\n');
 	pagetypeinfo_showfree(m, pgdat);
 	pagetypeinfo_showblockcount(m, pgdat);
+	pagetypeinfo_showmixedcount(m, pgdat);
 
 	return 0;
 }
diff --git a/tools/vm/Makefile b/tools/vm/Makefile
index 3d907da..ac884b6 100644
--- a/tools/vm/Makefile
+++ b/tools/vm/Makefile
@@ -1,6 +1,6 @@
 # Makefile for vm tools
 #
-TARGETS=page-types slabinfo
+TARGETS=page-types slabinfo page_owner_sort
 
 LIB_DIR = ../lib/api
 LIBS = $(LIB_DIR)/libapikfs.a
@@ -18,5 +18,5 @@ $(LIBS):
 	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
 
 clean:
-	$(RM) page-types slabinfo
+	$(RM) page-types slabinfo page_owner_sort
 	make -C $(LIB_DIR) clean
diff --git a/tools/vm/page_owner_sort.c b/tools/vm/page_owner_sort.c
new file mode 100644
index 0000000..77147b4
--- /dev/null
+++ b/tools/vm/page_owner_sort.c
@@ -0,0 +1,144 @@
+/*
+ * User-space helper to sort the output of /sys/kernel/debug/page_owner
+ *
+ * Example use:
+ * cat /sys/kernel/debug/page_owner > page_owner_full.txt
+ * grep -v ^PFN page_owner_full.txt > page_owner.txt
+ * ./sort page_owner.txt sorted_page_owner.txt
+*/
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <string.h>
+
+struct block_list {
+	char *txt;
+	int len;
+	int num;
+};
+
+
+static struct block_list *list;
+static int list_size;
+static int max_size;
+
+struct block_list *block_head;
+
+int read_block(char *buf, int buf_size, FILE *fin)
+{
+	char *curr = buf, *const buf_end = buf + buf_size;
+
+	while (buf_end - curr > 1 && fgets(curr, buf_end - curr, fin)) {
+		if (*curr == '\n') /* empty line */
+			return curr - buf;
+		curr += strlen(curr);
+	}
+
+	return -1; /* EOF or no space left in buf. */
+}
+
+static int compare_txt(const void *p1, const void *p2)
+{
+	const struct block_list *l1 = p1, *l2 = p2;
+
+	return strcmp(l1->txt, l2->txt);
+}
+
+static int compare_num(const void *p1, const void *p2)
+{
+	const struct block_list *l1 = p1, *l2 = p2;
+
+	return l2->num - l1->num;
+}
+
+static void add_list(char *buf, int len)
+{
+	if (list_size != 0 &&
+	    len == list[list_size-1].len &&
+	    memcmp(buf, list[list_size-1].txt, len) == 0) {
+		list[list_size-1].num++;
+		return;
+	}
+	if (list_size == max_size) {
+		printf("max_size too small??\n");
+		exit(1);
+	}
+	list[list_size].txt = malloc(len+1);
+	list[list_size].len = len;
+	list[list_size].num = 1;
+	memcpy(list[list_size].txt, buf, len);
+	list[list_size].txt[len] = 0;
+	list_size++;
+	if (list_size % 1000 == 0) {
+		printf("loaded %d\r", list_size);
+		fflush(stdout);
+	}
+}
+
+#define BUF_SIZE	1024
+
+int main(int argc, char **argv)
+{
+	FILE *fin, *fout;
+	char buf[BUF_SIZE];
+	int ret, i, count;
+	struct block_list *list2;
+	struct stat st;
+
+	if (argc < 3) {
+		printf("Usage: ./program <input> <output>\n");
+		perror("open: ");
+		exit(1);
+	}
+
+	fin = fopen(argv[1], "r");
+	fout = fopen(argv[2], "w");
+	if (!fin || !fout) {
+		printf("Usage: ./program <input> <output>\n");
+		perror("open: ");
+		exit(1);
+	}
+
+	fstat(fileno(fin), &st);
+	max_size = st.st_size / 100; /* hack ... */
+
+	list = malloc(max_size * sizeof(*list));
+
+	for ( ; ; ) {
+		ret = read_block(buf, BUF_SIZE, fin);
+		if (ret < 0)
+			break;
+
+		add_list(buf, ret);
+	}
+
+	printf("loaded %d\n", list_size);
+
+	printf("sorting ....\n");
+
+	qsort(list, list_size, sizeof(list[0]), compare_txt);
+
+	list2 = malloc(sizeof(*list) * list_size);
+
+	printf("culling\n");
+
+	for (i = count = 0; i < list_size; i++) {
+		if (count == 0 ||
+		    strcmp(list2[count-1].txt, list[i].txt) != 0) {
+			list2[count++] = list[i];
+		} else {
+			list2[count-1].num += list[i].num;
+		}
+	}
+
+	qsort(list2, count, sizeof(list[0]), compare_num);
+
+	for (i = 0; i < count; i++)
+		fprintf(fout, "%d times:\n%s\n", list2[i].num, list2[i].txt);
+
+	return 0;
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
