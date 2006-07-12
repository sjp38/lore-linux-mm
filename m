From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:43:52 +0200
Message-Id: <20060712144352.16998.85059.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 35/39] mm: random: random page replacement policy
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

Random page replacement.

Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

 include/linux/mm_page_replace.h      |    2 
 include/linux/mm_page_replace_data.h |    2 
 include/linux/mm_random_data.h       |    9 +
 include/linux/mm_random_policy.h     |   60 +++++++++
 mm/Kconfig                           |    5 
 mm/Makefile                          |    1 
 mm/random_policy.c                   |  218 +++++++++++++++++++++++++++++++++++
 7 files changed, 297 insertions(+)

Index: linux-2.6/mm/random_policy.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/random_policy.c	2006-07-12 16:09:19.000000000 +0200
@@ -0,0 +1,218 @@
+
+/* Random page replacement policy */
+
+#include <linux/module.h>
+#include <linux/mm_page_replace.h>
+#include <linux/swap.h>
+#include <linux/pagevec.h>
+#include <linux/init.h>
+#include <linux/rmap.h>
+#include <linux/hash.h>
+#include <linux/seq_file.h>
+#include <linux/writeback.h>
+#include <linux/buffer_head.h>	/* for try_to_release_page(),
+					buffer_heads_over_limit */
+#include <asm/sections.h>
+
+void __init pgrep_init(void)
+{
+	printk(KERN_ERR "Random page replacement policy init!\n");
+}
+
+void __init pgrep_init_zone(struct zone *zone)
+{
+	zone->policy.nr_pages = 0;
+}
+
+static DEFINE_PER_CPU(struct pagevec, add_pvecs) = { 0, };
+
+void fastcall pgrep_add(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(add_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_pgrep_add(pvec);
+	put_cpu_var(add_pvecs);
+}
+
+void __pgrep_add_drain(unsigned int cpu)
+{
+	struct pagevec *pvec = &per_cpu(add_pvecs, cpu);
+
+	if (pagevec_count(pvec))
+		__pagevec_pgrep_add(pvec);
+}
+
+static inline void __page_release(struct zone *zone, struct page *page,
+				       struct pagevec *pvec)
+{
+	BUG_ON(PageLRU(page));
+	SetPageLRU(page);
+	++zone->policy.nr_pages;
+
+	if (!pagevec_add(pvec, page)) {
+		spin_unlock_irq(&zone->lru_lock);
+		if (buffer_heads_over_limit)
+			pagevec_strip(pvec);
+		__pagevec_release(pvec);
+		spin_lock_irq(&zone->lru_lock);
+	}
+}
+
+void pgrep_reinsert(struct list_head *page_list)
+{
+	struct page *page, *page2;
+	struct zone *zone = NULL;
+	struct pagevec pvec;
+
+	pagevec_init(&pvec, 1);
+	list_for_each_entry_safe(page, page2, page_list, lru) {
+		struct zone *pagezone = page_zone(page);
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		__page_release(zone, page, &pvec);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	pagevec_release(&pvec);
+}
+
+/*
+ * Lehmer simple linear congruential PRNG
+ *
+ * Xn+1 = (a * Xn + c) mod m
+ *
+ * where a, c and m are constants.
+ *
+ * Note that "m" is zone->present_pages, so in this case its
+ * really not constant.
+ */
+
+static unsigned long get_random(struct zone *zone)
+{
+	zone->policy.seed =
+		hash_long(zone->policy.seed, BITS_PER_LONG) + 3147484177UL;
+	return zone->policy.seed;
+}
+
+static struct page *pick_random_cache_page(struct zone *zone)
+{
+	struct page *page;
+	unsigned long pfn;
+	do {
+		pfn = zone->zone_start_pfn +
+			get_random(zone) % zone->present_pages;
+		page = pfn_to_page(pfn);
+	} while (!PageLRU(page));
+	zone->policy.seed ^= page_index(page);
+	return page;
+}
+
+static unsigned long pick_candidates(struct zone *zone,
+	       	unsigned long nr_to_scan, struct list_head *pages)
+{
+	unsigned long nr_taken = 0;
+	for (;nr_to_scan && zone->policy.nr_pages; nr_to_scan--) {
+		struct page *page = pick_random_cache_page(zone);
+		if (!TestSetPageCandidate(page)) {
+			list_add(&page->lru, pages);
+			++nr_taken;
+		}
+	}
+	return nr_taken;
+}
+
+void __pgrep_get_candidates(struct zone *zone, int priority,
+		unsigned long nr_to_scan, struct list_head *pages,
+		unsigned long *nr_scanned)
+{
+	LIST_HEAD(candidates);
+	nr_to_scan = pick_candidates(zone, nr_to_scan, &candidates);
+	isolate_lru_pages(zone, nr_to_scan, &candidates, pages, nr_scanned);
+	while (!list_empty(&candidates)) {
+		struct page *page = lru_to_page(&candidates);
+		list_del(&page->lru);
+		ClearPageCandidate(page);
+	}
+}
+
+void pgrep_put_candidates(struct zone *zone, struct list_head *pages,
+	       unsigned long nr_freed, int may_swap)
+{
+	struct pagevec pvec;
+	pagevec_init(&pvec, 1);
+	spin_lock_irq(&zone->lru_lock);
+	while (!list_empty(pages)) {
+		struct page *page = lru_to_page(pages);
+		list_del(&page->lru);
+		__page_release(zone, page, &pvec);
+	}
+	spin_unlock_irq(&zone->lru_lock);
+	pagevec_release(&pvec);
+}
+
+#define K(x) ((x) << (PAGE_SHIFT-10))
+
+void pgrep_show(struct zone *zone)
+{
+	printk("%s"
+		" free:%lukB"
+		" min:%lukB"
+		" low:%lukB"
+		" high:%lukB"
+		" cached:%lukB"
+		" present:%lukB"
+		" pages_scanned:%lu"
+		" all_unreclaimable? %s"
+		"\n",
+		zone->name,
+		K(zone->free_pages),
+		K(zone->pages_min),
+		K(zone->pages_low),
+		K(zone->pages_high),
+		K(zone->policy.nr_pages),
+		K(zone->present_pages),
+		zone->pages_scanned,
+		(zone->all_unreclaimable ? "yes" : "no")
+		);
+}
+
+void pgrep_zoneinfo(struct zone *zone, struct seq_file *m)
+{
+	seq_printf(m,
+		   "\n  pages free     %lu"
+		   "\n        min      %lu"
+		   "\n        low      %lu"
+		   "\n        high     %lu"
+		   "\n        cached   %lu"
+		   "\n        scanned  %lu"
+		   "\n        spanned  %lu"
+		   "\n        present  %lu",
+		   zone->free_pages,
+		   zone->pages_min,
+		   zone->pages_low,
+		   zone->pages_high,
+		   zone->policy.nr_pages,
+		   zone->pages_scanned,
+		   zone->spanned_pages,
+		   zone->present_pages);
+}
+
+void __pgrep_counts(unsigned long *active, unsigned long *inactive,
+			unsigned long *free, struct zone *zones)
+{
+	int i;
+
+	*active = 0;
+	*inactive = 0;
+	*free = 0;
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		*free += zones[i].free_pages;
+	}
+}
+
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/Kconfig	2006-07-12 16:11:22.000000000 +0200
@@ -158,6 +158,11 @@ config MM_POLICY_CART_R
 	  This option selects a CART based policy modified to handle cyclic
 	  access patterns.
 
+config MM_POLICY_RANDOM
+	bool "Random"
+	help
+	  This option selects the random replacement policy.
+
 endchoice
 
 #
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:09:19.000000000 +0200
@@ -102,6 +102,8 @@ extern void __pgrep_counts(unsigned long
 #include <linux/mm_clockpro_policy.h>
 #elif defined CONFIG_MM_POLICY_CART || defined CONFIG_MM_POLICY_CART_R
 #include <linux/mm_cart_policy.h>
+#elif defined CONFIG_MM_POLICY_RANDOM
+#include <linux/mm_random_policy.h>
 #else
 #error no mm policy
 #endif
Index: linux-2.6/include/linux/mm_page_replace_data.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace_data.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace_data.h	2006-07-12 16:09:19.000000000 +0200
@@ -9,6 +9,8 @@
 #include <linux/mm_clockpro_data.h>
 #elif defined CONFIG_MM_POLICY_CART || defined CONFIG_MM_POLICY_CART_R
 #include <linux/mm_cart_data.h>
+#elif defined CONFIG_MM_POLICY_RANDOM
+#include <linux/mm_random_data.h>
 #else
 #error no mm policy
 #endif
Index: linux-2.6/include/linux/mm_random_policy.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mm_random_policy.h	2006-07-12 16:09:19.000000000 +0200
@@ -0,0 +1,60 @@
+#ifndef _LINUX_MM_RANDOM_POLICY_H
+#define _LINUX_MM_RANDOM_POLICY_H
+
+#ifdef __KERNEL__
+
+#include <linux/page-flags.h>
+
+#define PG_candidate	PG_reclaim1
+
+#define PageCandidate(page)		test_bit(PG_candidate, &(page)->flags)
+#define TestSetPageCandidate(page)	test_and_set_bit(PG_candidate, &(page)->flags)
+#define ClearPageCandidate(page)	clear_bit(PG_candidate, &(page)->flags)
+
+#define pgrep_hint_active(p) do { } while (0)
+#define pgrep_hint_use_once(p) do { } while (0)
+
+static inline
+void __pgrep_add(struct zone *zone, struct page *page)
+{
+	zone->policy.nr_pages++;
+}
+
+#define pgrep_activate(p) 0
+#define pgrep_reclaimable(p) RECLAIM_OK
+#define pgrep_mark_accessed(p) do { } while (0)
+
+static inline
+void __pgrep_remove(struct zone *zone, struct page *page)
+{
+	if (PageCandidate(page)) {
+		ClearPageCandidate(page);
+		list_del(&page->lru);
+	}
+	zone->policy.nr_pages--;
+}
+
+static inline
+void __pgrep_rotate_reclaimable(struct zone *zone, struct page *page)
+{
+}
+
+#define pgrep_copy_state(d, s) do { } while (0)
+#define pgrep_clear_state(p) do { } while (0)
+#define pgrep_is_active(p) 0
+
+#define pgrep_remember(z, p) do { } while (0)
+#define pgrep_forget(m, i) do { } while (0)
+
+static inline unsigned long __pgrep_nr_pages(struct zone *zone)
+{
+	return zone->policy.nr_pages;
+}
+
+static inline unsigned long __pgrep_nr_scan(struct zone *zone)
+{
+	return zone->policy.nr_pages;
+}
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_MM_LRU_POLICY_H */
Index: linux-2.6/include/linux/mm_random_data.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mm_random_data.h	2006-07-12 16:09:19.000000000 +0200
@@ -0,0 +1,9 @@
+#ifdef __KERNEL__
+
+struct pgrep_data {
+	unsigned long nr_scan;
+	unsigned long nr_pages;
+	unsigned long seed;
+};
+
+#endif /* __KERNEL__ */
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/Makefile	2006-07-12 16:11:22.000000000 +0200
@@ -16,6 +16,7 @@ obj-$(CONFIG_MM_POLICY_USEONCE) += useon
 obj-$(CONFIG_MM_POLICY_CLOCKPRO) += nonresident.o clockpro.o
 obj-$(CONFIG_MM_POLICY_CART) += nonresident-cart.o cart.o
 obj-$(CONFIG_MM_POLICY_CART_R) += nonresident-cart.o cart.o
+obj-$(CONFIG_MM_POLICY_RANDOM) += random_policy.o
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
