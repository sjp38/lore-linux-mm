Subject: Re: Zoned CART
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1124024312.30836.26.camel@twins>
References: <1123857429.14899.59.camel@twins>
	 <1124024312.30836.26.camel@twins>
Content-Type: multipart/mixed; boundary="=-lCrVvqcefV6w4WYoRc0U"
Date: Fri, 26 Aug 2005 23:03:21 +0200
Message-Id: <1125090201.20161.50.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Rahul Iyer <rni@andrew.cmu.edu>
List-ID: <linux-mm.kvack.org>

--=-lCrVvqcefV6w4WYoRc0U
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I redid most of the cart code today. I went back to the 2 lists approach
instead of the 3 lists Rahul has.

Attached is my current code. I'm still off on the shortterm (n_s) count
but I'll get there.

Also this thing livelocks the kernel under severe swap pressure,
shrink_cache just doesn't make any progress.

I'll look into these two issues tomorrow after some sleep :-)

Any comments are ofcourse welcome.

Kind regards,


-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--=-lCrVvqcefV6w4WYoRc0U
Content-Disposition: attachment; filename=cart-mk2-1.patch
Content-Type: text/x-patch; name=cart-mk2-1.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

diff --git a/fs/proc/proc_misc.c b/fs/proc/proc_misc.c
--- a/fs/proc/proc_misc.c
+++ b/fs/proc/proc_misc.c
@@ -233,6 +233,20 @@ static struct file_operations proc_zonei
 	.release	= seq_release,
 };
 
+extern struct seq_operations cart_op;
+static int cart_open(struct inode *inode, struct file *file)
+{
+       (void)inode;
+       return seq_open(file, &cart_op);
+}
+
+static struct file_operations cart_file_operations = {
+       .open           = cart_open,
+       .read           = seq_read,
+       .llseek         = seq_lseek,
+       .release        = seq_release,
+};
+
 static int version_read_proc(char *page, char **start, off_t off,
 				 int count, int *eof, void *data)
 {
@@ -602,6 +616,7 @@ void __init proc_misc_init(void)
 	create_seq_entry("interrupts", 0, &proc_interrupts_operations);
 	create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
 	create_seq_entry("buddyinfo",S_IRUGO, &fragmentation_file_operations);
+	create_seq_entry("cart",S_IRUGO, &cart_file_operations);
 	create_seq_entry("vmstat",S_IRUGO, &proc_vmstat_file_operations);
 	create_seq_entry("zoneinfo",S_IRUGO, &proc_zoneinfo_file_operations);
 	create_seq_entry("diskstats", 0, &proc_diskstats_operations);
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -31,10 +31,28 @@ static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
-	if (PageActive(page)) {
-		ClearPageActive(page);
+	if (TestClearPageActive(page)) {
 		zone->nr_active--;
 	} else {
 		zone->nr_inactive--;
 	}
+	if (TestClearPageLongTerm(page)) {
+		/* zone->nr_longterm--; */
+	} else {
+		zone->nr_shortterm--;
+	}
+}
+
+static inline void
+add_page_to_active_tail(struct zone *zone, struct page *page)
+{
+	list_add_tail(&page->lru, &zone->active_list);
+	zone->nr_active++;
+}
+
+static inline void
+add_page_to_inactive_tail(struct zone *zone, struct page *page)
+{
+        list_add_tail(&page->lru, &zone->inactive_list);
+        zone->nr_inactive++;
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -144,12 +144,16 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
-	struct list_head	active_list;
-	struct list_head	inactive_list;
+	struct list_head	active_list;	/* The T1 list of CART */
+	struct list_head	inactive_list;  /* The T2 list of CART */
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
-	unsigned long		nr_active;
+	unsigned long		nr_active;	
 	unsigned long		nr_inactive;
+	unsigned long 		nr_evicted_active;
+	unsigned long 		nr_shortterm;	/* number of short term pages */
+	unsigned long		cart_p;		/* p from the CART paper */
+	unsigned long 		cart_q;		/* q from the cart paper */
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -76,6 +76,8 @@
 #define PG_nosave_free		18	/* Free, should not be written */
 #define PG_uncached		19	/* Page has been mapped as uncached */
 
+#define PG_longterm		20	/* Filter bit for CART see mm/cart.c */
+
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
  * allowed.
@@ -305,6 +307,12 @@ extern void __mod_page_state(unsigned lo
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageLongTerm(page)	test_bit(PG_longterm, &(page)->flags)
+#define SetPageLongTerm(page)	set_bit(PG_longterm, &(page)->flags)
+#define TestSetPageLongTerm(page) test_and_set_bit(PG_longterm, &(page)->flags)
+#define ClearPageLongTerm(page)	clear_bit(PG_longterm, &(page)->flags)
+#define TestClearPageLongTerm(page) test_and_clear_bit(PG_longterm, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
diff --git a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -154,6 +154,23 @@ extern void out_of_memory(unsigned int _
 /* linux/mm/memory.c */
 extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
 
+/* linux/mm/nonresident.c */
+#define NR_filter	0x01  /* short/long */
+#define NR_list		0x02  /* b1/b2; correlates to PG_active */
+#define NR_evict	0x80000000
+
+extern u32 remember_page(struct address_space *, unsigned long, unsigned int);
+extern unsigned int recently_evicted(struct address_space *, unsigned long);
+extern void init_nonresident(void);
+
+/* linux/mm/cart.c */
+extern void cart_init(void);
+extern void cart_insert(struct zone*, struct page *, int);
+extern struct page *cart_replace(struct zone *, unsigned int *);
+
+#define lru_cache_add(page) cart_insert(page_zone((page)), (page), 0)
+#define add_page_to_cart(zone, page) cart_insert((zone), (page), 1)
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalhigh_pages;
@@ -164,9 +181,8 @@ extern unsigned int nr_free_buffer_pages
 extern unsigned int nr_free_pagecache_pages(void);
 
 /* linux/mm/swap.c */
-extern void FASTCALL(lru_cache_add(struct page *));
+extern void FASTCALL(lru_cache_add_inactive(struct page *));
 extern void FASTCALL(lru_cache_add_active(struct page *));
-extern void FASTCALL(activate_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
 extern int rotate_reclaimable_page(struct page *page);
@@ -292,6 +308,11 @@ static inline swp_entry_t get_swap_page(
 #define grab_swap_token()  do { } while(0)
 #define has_swap_token(x) 0
 
+/* linux/mm/nonresident.c */
+#define init_nonresident()	do { } while (0)
+#define remember_page(x,y,z)	0
+#define recently_evicted(x,y)	0
+
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
diff --git a/init/main.c b/init/main.c
--- a/init/main.c
+++ b/init/main.c
@@ -47,6 +47,7 @@
 #include <linux/rmap.h>
 #include <linux/mempolicy.h>
 #include <linux/key.h>
+#include <linux/swap.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -494,7 +495,9 @@ asmlinkage void __init start_kernel(void
 	}
 #endif
 	vfs_caches_init_early();
+	init_nonresident();
 	mem_init();
+	cart_init();
 	kmem_cache_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
diff --git a/mm/Makefile b/mm/Makefile
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -12,7 +12,8 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   readahead.o slab.o swap.o truncate.o vmscan.o \
 			   prio_tree.o $(mmu-y)
 
-obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o \
+				nonresident.o cart.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
diff --git a/mm/cart.c b/mm/cart.c
new file mode 100644
--- /dev/null
+++ b/mm/cart.c
@@ -0,0 +1,287 @@
+/* For further details, please refer to the CART paper here - 
+ *   http://www.almaden.ibm.com/cs/people/dmodha/clockfast.pdf 
+ *
+ * Modified by Peter Zijlstra to work with the nonresident code I adapted
+ * from Rik van Riel.
+ *
+ * XXX: add page accounting
+ */
+ 
+#include <linux/swap.h>
+#include <linux/mm.h>
+#include <linux/page-flags.h>
+#include <linux/mm_inline.h>
+
+#define cart_cT(zone)	((zone)->nr_active + (zone)->nr_inactive)
+#define cart_cB(zone)	((zone)->nr_active + (zone)->nr_inactive + (zone)->free_pages)
+
+#define nr_T1(zone) ((zone)->nr_active)
+#define nr_T2(zone) ((zone)->nr_inactive)
+
+#define list_T1(zone) (&(zone)->active_list)
+#define list_T2(zone) (&(zone)->inactive_list)
+
+#define cart_p(zone) ((zone)->cart_p)
+#define cart_q(zone) ((zone)->cart_q)
+
+#define nr_B1(zone) ((zone)->nr_evicted_active)
+#define nr_B2(zone) (cart_cB(zone) - nr_B1(zone))
+
+#define nr_Ns(zone) ((zone)->nr_shortterm)
+#define nr_Nl(zone) (cart_cT(zone) - nr_Ns(zone))
+
+/* Called from init/main.c to initialize the cart parameters */
+void cart_init()
+{
+	struct zone *zone;
+	for_each_zone(zone) {
+		zone->nr_evicted_active = 0;
+		/* zone->nr_evicted_inactive = cart_cB(zone); */
+		zone->nr_shortterm = 0;
+		/* zone->nr_longterm = 0; */
+		zone->cart_p = 0;
+		zone->cart_q = 0;
+	}
+}
+
+static inline void cart_q_inc(struct zone *zone)
+{
+	/* if (|T2| + |B2| + |T1| - ns >= c) q = min(q + 1, 2c - |T1|) */
+	if (nr_T2(zone) + nr_B2(zone) + nr_T1(zone) - nr_Ns(zone) >= cart_cB(zone))
+		cart_q(zone) = min(cart_q(zone) + 1, 2*cart_cB(zone) - nr_T1(zone));
+}
+
+static inline void cart_q_dec(struct zone *zone)
+{
+	/* q = max(q - 1, c - |T1|) */
+	unsigned long target = cart_cB(zone) - nr_T1(zone);
+	if (cart_q(zone) <= target)
+		cart_q(zone) = target;
+	else
+		--cart_q(zone);
+}
+
+void cart_insert(struct zone *zone, struct page *page, int direct)
+{
+	unsigned int rflags;
+	unsigned int on_B1, on_B2;
+
+	rflags = recently_evicted(page_mapping(page), page_index(page));
+	on_B1 = (rflags && !(rflags & NR_list));
+	on_B2 = (rflags && (rflags & NR_list));
+	
+	if (on_B1) {
+		/* p = min(p + max(1, ns/|B1|), c) */
+		unsigned long ratio = nr_Ns(zone) / (nr_B1(zone) ?: 1UL);
+		cart_p(zone) += ratio ?: 1UL;
+		if (unlikely(cart_p(zone) > cart_cT(zone)))
+			cart_p(zone) = cart_cT(zone);
+
+		SetPageLongTerm(page);
+		/* ++nr_Nl(zone); */
+	} else if (on_B2) {
+		/* p = max(p - max(1, nl/|B2|), 0) */
+		unsigned long ratio = nr_Nl(zone) / (nr_B2(zone) ?: 1UL);
+		cart_p(zone) -= ratio ?: 1UL;
+		if (unlikely(cart_p(zone) > cart_cT(zone))) /* unsigned; wrap around */
+			cart_p(zone) = 0UL;
+
+		SetPageLongTerm(page);
+		/* NOTE: this function is the only one that uses recently_evicted()
+		 * and it does not use the NR_filter flag; we could live without,
+		 * for now use as sanity check
+		 */
+//		BUG_ON(!(rflags & NR_filter)); /* all pages in B2 are longterm */
+
+		/* ++nr_Nl(zone); */
+		cart_q_inc(zone);
+	} else {
+		ClearPageLongTerm(page);
+		++nr_Ns(zone);
+	}
+
+	ClearPageReferenced(page);
+	if (direct) {
+		SetPageActive(page);
+		add_page_to_active_list(zone, page);
+		BUG_ON(!PageLRU(page));
+	} else lru_cache_add_active(page);
+}
+
+/* This function selects the candidate and returns the corresponding 
+ * struct page * or returns NULL in case no page can be freed. 
+ * The *where argument is used to indicate the parent list of the page 
+ * so that, in case it cannot be written back, it can be placed back on 
+ * the correct list 
+ */
+struct page *cart_replace(struct zone *zone, unsigned int *where)
+{
+	struct list_head *list;
+	struct page *page = NULL;
+	int referenced;
+	unsigned int flags, rflags;
+
+	while (!list_empty(list_T2(zone))) {
+		page = list_entry(list_T2(zone)->next, struct page, lru);
+
+		if (!TestClearPageReferenced(page))
+			break;
+		
+		del_page_from_inactive_list(zone, page);
+		add_page_to_active_tail(zone, page);
+		SetPageActive(page);
+		
+		cart_q_inc(zone);
+	}
+
+	while (!list_empty(list_T1(zone))) {
+		page = list_entry(list_T1(zone)->next, struct page, lru);
+		referenced = TestClearPageReferenced(page);
+		
+		if (!PageLongTerm(page) && !referenced)
+			break;
+			
+		if (referenced) {
+			del_page_from_active_list(zone, page);
+			add_page_to_active_tail(zone, page);
+
+			if (nr_T1(zone) >= min(cart_p(zone) + 1, nr_B1(zone)) &&
+			    !PageLongTerm(page)) {
+				SetPageLongTerm(page);
+				--nr_Ns(zone);
+				/* ++nr_Nl(zone); */
+			}
+		} else {
+			del_page_from_active_list(zone, page);
+			add_page_to_inactive_tail(zone, page);
+			ClearPageActive(page);
+
+			cart_q_dec(zone);
+		}
+	}
+
+	page = NULL;
+	if (nr_T1(zone) > max(1UL, cart_p(zone))) {
+		page = list_entry(list_T1(zone)->next, struct page, lru);
+		del_page_from_active_list(zone, page);
+		--nr_Ns(zone);
+		++nr_B1(zone);
+		flags = PageLongTerm(page) ? NR_filter : 0;
+	} else {
+		if (!list_empty(list_T2(zone))) {
+			page = list_entry(list_T2(zone)->next, struct page, lru);
+			del_page_from_inactive_list(zone, page);
+			/* --nr_Nl(zone); */
+			/* ++nr_B1(zone); */
+			flags = NR_list | NR_filter;
+		}
+	}
+	if (!page) return NULL;
+	*where = flags;
+
+	/* history replacement; always remember, if the page was already remembered
+	 * this will move it to the head. XXX: not so; fix this !!
+	 *
+	 * Assume |B1| + |B2| == c + 1, since |B1_j| + |B2_j| := c_j.
+	 * The list_empty check is done on the Bn_j size.
+	 */
+	/* |B1| <= max(0, q) */
+	if (nr_B1(zone) <= cart_q(zone)) flags |= NR_evict;
+
+	rflags = remember_page(page_mapping(page), page_index(page), flags);
+	if (rflags & NR_evict) {
+		/* if (likely(nr_B2(zone))) --nr_B2(zone); */
+	} else {
+		if (likely(nr_B1(zone))) --nr_B1(zone);
+	}
+
+	return page;
+}
+
+#ifdef CONFIG_PROC_FS
+
+#include <linux/seq_file.h>
+
+static void *stats_start(struct seq_file *m, loff_t *pos)
+{
+	if (*pos < 0 || *pos > 1)
+		return NULL;
+
+	lru_add_drain();
+
+	return pos;
+}
+
+static void *stats_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	return NULL;
+}
+
+static void stats_stop(struct seq_file *m, void *arg)
+{
+}
+
+static int stats_show(struct seq_file *m, void *arg)
+{
+	struct zone *zone;
+	for_each_zone(zone) {
+		spin_lock_irq(&zone->lru_lock);
+		seq_printf(m, "\n\n======> zone: %lu <=====\n", (unsigned long)zone);
+		seq_printf(m, "struct zone values:\n");
+		seq_printf(m, "  zone->nr_active: %lu\n", zone->nr_active);
+		seq_printf(m, "  zone->nr_inactive: %lu\n", zone->nr_inactive);
+		seq_printf(m, "  zone->nr_evicted_active: %lu\n", zone->nr_evicted_active);
+		seq_printf(m, "  zone->nr_shortterm: %lu\n", zone->nr_shortterm);
+		seq_printf(m, "  zone->cart_p: %lu\n", zone->cart_p);
+		seq_printf(m, "  zone->cart_q: %lu\n", zone->cart_q);
+		seq_printf(m, "  zone->present_pages: %lu\n", zone->present_pages);
+		seq_printf(m, "  zone->free_pages: %lu\n", zone->free_pages);
+		seq_printf(m, "  zone->pages_min: %lu\n", zone->pages_min);
+		seq_printf(m, "  zone->pages_low: %lu\n", zone->pages_low);
+		seq_printf(m, "  zone->pages_high: %lu\n", zone->pages_high);
+
+		seq_printf(m, "\n");
+		seq_printf(m, "implicit values:\n");
+		seq_printf(m, "  zone->nr_evicted_longterm: %lu\n", nr_B2(zone));
+		seq_printf(m, "  zone->nr_longterm: %lu\n", nr_Nl(zone));
+		seq_printf(m, "  zone->cart_c: %lu\n", cart_cT(zone));
+
+		seq_printf(m, "\n");
+		seq_printf(m, "counted values:\n");
+
+		{
+			struct page *page;
+			unsigned long active = 0, shortterm = 0, longterm = 0;
+			list_for_each_entry(page, &zone->active_list, lru) {
+				++active;
+				if (PageLongTerm(page)) ++longterm;
+				else ++shortterm;
+			}
+			seq_printf(m, "  zone->nr_active: %lu\n", active);
+			seq_printf(m, "  zone->nr_shortterm: %lu\n", shortterm);
+			seq_printf(m, "  zone->nr_longterm: %lu\n", longterm); // XXX: should add zone->inactive
+		}
+
+		{
+			struct page *page;
+			unsigned long inactive = 0;
+			list_for_each_entry(page, &zone->inactive_list, lru) {
+				++inactive;
+			}
+			seq_printf(m, "  zone->nr_inactive: %lu\n", inactive);
+		}
+
+		spin_unlock_irq(&zone->lru_lock);
+	}
+
+	return 0;
+}
+
+struct seq_operations cart_op = {
+	.start = stats_start,
+	.next = stats_next,
+	.stop = stats_stop,
+	.show = stats_show,
+};
+
+#endif /* CONFIG_PROC_FS */
diff --git a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -723,7 +723,6 @@ void do_generic_mapping_read(struct addr
 	unsigned long offset;
 	unsigned long last_index;
 	unsigned long next_index;
-	unsigned long prev_index;
 	loff_t isize;
 	struct page *cached_page;
 	int error;
@@ -732,7 +731,6 @@ void do_generic_mapping_read(struct addr
 	cached_page = NULL;
 	index = *ppos >> PAGE_CACHE_SHIFT;
 	next_index = index;
-	prev_index = ra.prev_page;
 	last_index = (*ppos + desc->count + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
 	offset = *ppos & ~PAGE_CACHE_MASK;
 
@@ -779,13 +777,7 @@ page_ok:
 		if (mapping_writably_mapped(mapping))
 			flush_dcache_page(page);
 
-		/*
-		 * When (part of) the same page is read multiple times
-		 * in succession, only mark it as accessed the first time.
-		 */
-		if (prev_index != index)
-			mark_page_accessed(page);
-		prev_index = index;
+		mark_page_accessed(page);
 
 		/*
 		 * Ok, we have the page, and it's up-to-date, so
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1304,7 +1304,8 @@ static int do_wp_page(struct mm_struct *
 			page_remove_rmap(old_page);
 		flush_cache_page(vma, address, pfn);
 		break_cow(vma, new_page, address, page_table);
-		lru_cache_add_active(new_page);
+		lru_cache_add(new_page);
+		SetPageReferenced(new_page);
 		page_add_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -1782,7 +1783,7 @@ do_anonymous_page(struct mm_struct *mm, 
 		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
 							 vma->vm_page_prot)),
 				      vma);
-		lru_cache_add_active(page);
+		lru_cache_add(page);
 		SetPageReferenced(page);
 		page_add_anon_rmap(page, vma, addr);
 	}
@@ -1903,7 +1904,8 @@ retry:
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
-			lru_cache_add_active(new_page);
+			lru_cache_add(new_page);
+			SetPageReferenced(new_page);
 			page_add_anon_rmap(new_page, vma, address);
 		} else
 			page_add_file_rmap(new_page);
diff --git a/mm/nonresident.c b/mm/nonresident.c
new file mode 100644
--- /dev/null
+++ b/mm/nonresident.c
@@ -0,0 +1,254 @@
+/*
+ * mm/nonresident.c
+ * (C) 2004,2005 Red Hat, Inc
+ * Written by Rik van Riel <riel@redhat.com>
+ * Released under the GPL, see the file COPYING for details.
+ * Adapted by Peter Zijlstra <a.p.zijlstra@chello.nl> for use by ARC
+ * like algorithms.
+ *
+ * Keeps track of whether a non-resident page was recently evicted
+ * and should be immediately promoted to the active list. This also
+ * helps automatically tune the inactive target.
+ *
+ * The pageout code stores a recently evicted page in this cache
+ * by calling remember_page(mapping/mm, index/vaddr)
+ * and can look it up in the cache by calling recently_evicted()
+ * with the same arguments.
+ *
+ * Note that there is no way to invalidate pages after eg. truncate
+ * or exit, we let the pages fall out of the non-resident set through
+ * normal replacement.
+ *
+ *
+ * Modified to work with ARC like algorithms who:
+ *  - need to balance two FIFOs; |b1| + |b2| = c,
+ *  - keep a flag per non-resident page.
+ *
+ * The bucket contains two single linked cyclic lists (CLOCKS) and each
+ * clock has a tail hand. By selecting a victim clock upon insertion it
+ * is possible to balance them.
+ *
+ * The slot looks like this:
+ * struct slot_t {
+ *         u32 cookie : 24; // LSB 
+ *         u32 index  :  6;
+ *         u32 filter :  1;
+ *         u32 clock  :  1; // MSB
+ * };
+ *
+ * The bucket is guarded by a spinlock.
+ */
+#include <linux/swap.h>
+#include <linux/mm.h>
+#include <linux/cache.h>
+#include <linux/spinlock.h>
+#include <linux/bootmem.h>
+#include <linux/hash.h>
+#include <linux/prefetch.h>
+#include <linux/kernel.h>
+
+#define TARGET_SLOTS	64
+#define NR_CACHELINES  (TARGET_SLOTS*sizeof(u32) / L1_CACHE_BYTES)
+#define NR_SLOTS	(((NR_CACHELINES * L1_CACHE_BYTES) - sizeof(spinlock_t) - 2*sizeof(u16)) / sizeof(u32))
+#if 0
+#if NR_SLOTS < (TARGET_SLOTS / 2)
+#warning very small slot size
+#if NR_SLOTS <= 0
+#error no room for slots left
+#endif
+#endif
+#endif
+
+#define BUILD_MASK(bits, shift) (((1 << (bits)) - 1) << (shift))
+
+#define FLAGS_BITS		2
+#define FLAGS_SHIFT		(sizeof(u32)*8 - FLAGS_BITS)
+#define FLAGS_MASK		BUILD_MASK(FLAGS_BITS, FLAGS_SHIFT)
+
+#define INDEX_BITS		6  /* ceil(log2(NR_SLOTS)) */
+#define INDEX_SHIFT		(FLAGS_SHIFT - INDEX_BITS)
+#define INDEX_MASK		BUILD_MASK(INDEX_BITS, INDEX_SHIFT)
+
+#define SET_INDEX(x, idx)	((x) = ((x) & ~INDEX_MASK) | ((idx) << INDEX_SHIFT))
+#define GET_INDEX(x)		(((x) & INDEX_MASK) >> INDEX_SHIFT)
+
+struct nr_bucket
+{
+	spinlock_t lock;
+	u16 hand[2];
+	u32 slot[NR_SLOTS];
+} ____cacheline_aligned;
+
+/* The non-resident page hash table. */
+static struct nr_bucket * nonres_table;
+static unsigned int nonres_shift;
+static unsigned int nonres_mask;
+
+/* hash the address into a bucket */
+static struct nr_bucket * nr_hash(void * mapping, unsigned long index)
+{
+	unsigned long bucket;
+	unsigned long hash;
+
+	hash = hash_ptr(mapping, BITS_PER_LONG);
+	hash = 37 * hash + hash_long(index, BITS_PER_LONG);
+	bucket = hash & nonres_mask;
+
+	return nonres_table + bucket;
+}
+
+/* hash the address, inode and flags into a cookie */
+/* the two msb are flags; where msb-1 is a type flag and msb a period flag */
+static u32 nr_cookie(struct address_space * mapping, unsigned long index, unsigned int flags)
+{
+	u32 c;
+	unsigned long cookie;
+	
+	cookie = hash_ptr(mapping, BITS_PER_LONG);
+	cookie = 37 * cookie + hash_long(index, BITS_PER_LONG);
+
+	if (mapping && mapping->host) {
+		cookie = 37 * cookie + hash_long(mapping->host->i_ino, BITS_PER_LONG);
+	}
+
+	c = (u32)(cookie >> (BITS_PER_LONG - 32));
+	c = (c & ~FLAGS_MASK) | ((flags << FLAGS_SHIFT) & FLAGS_MASK);
+	return c;
+}
+
+unsigned int recently_evicted(struct address_space * mapping, unsigned long index)
+{
+	struct nr_bucket * nr_bucket;
+	u32 wanted, mask;
+	unsigned int r_flags = 0;
+	int i;
+	unsigned long iflags;
+
+	prefetch(mapping->host);
+	nr_bucket = nr_hash(mapping, index);
+
+	spin_lock_prefetch(nr_bucket); // prefetch_range(nr_bucket, NR_CACHELINES);
+	wanted = nr_cookie(mapping, index, 0) & ~INDEX_MASK;
+	mask = ~(FLAGS_MASK | INDEX_MASK);
+
+	spin_lock_irqsave(&nr_bucket->lock, iflags);
+	for (i = 0; i < NR_SLOTS; ++i) {
+		if ((nr_bucket->slot[i] & mask) == wanted) {
+			r_flags = nr_bucket->slot[i] >> FLAGS_SHIFT;
+			r_flags |= NR_evict; /* set the MSB to mark presence */
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&nr_bucket->lock, iflags);
+
+	return r_flags;
+}
+
+/* flags: 
+ *   logical and of the page flags (NR_filter, NR_list) and
+ *   an NR_evict target
+ */
+u32 remember_page(struct address_space * mapping, unsigned long index, unsigned int flags)
+{
+	struct nr_bucket *nr_bucket;
+	u32 cookie;
+	u32 *slot, *tail;
+	unsigned int slot_pos, tail_pos;
+	unsigned long iflags;
+
+	prefetch(mapping->host);
+	nr_bucket = nr_hash(mapping, index);
+
+	spin_lock_prefetch(nr_bucket); // prefetchw_range(nr_bucket, NR_CACHELINES);
+	cookie = nr_cookie(mapping, index, flags);
+
+	flags &= NR_evict; /* removal chain */
+	spin_lock_irqsave(&nr_bucket->lock, iflags);
+
+	/* free a slot */
+again:
+	tail_pos = nr_bucket->hand[!!flags];
+	BUG_ON(tail_pos >= NR_SLOTS);
+	tail = &nr_bucket->slot[tail_pos];
+	if (unlikely((*tail & NR_evict) != flags)) {
+		flags ^= NR_evict; /* empty chain; take other one */
+		goto again;
+	} 
+	BUG_ON((*tail & NR_evict) != flags);
+	/* free slot by swapping tail,tail+1, so that we skip over tail */
+	slot_pos = GET_INDEX(*tail);
+	BUG_ON(slot_pos >= NR_SLOTS);
+	slot = &nr_bucket->slot[slot_pos];
+	BUG_ON((*slot & NR_evict) != flags);
+	if (likely(tail != slot)) *slot = xchg(tail, *slot);
+	/* slot: -> [slot], old cookie */
+	BUG_ON(GET_INDEX(*slot) != slot_pos);
+
+	flags = (cookie & NR_evict); /* insertion chain */
+
+	/* place cookie in empty slot */
+	SET_INDEX(cookie, slot_pos); /* -> [slot], cookie */
+	cookie = xchg(slot, cookie); /* slot: -> [slot], cookie */
+
+	/* insert slot before tail; ie. MRU pos */
+	tail_pos = nr_bucket->hand[!!flags];
+	BUG_ON(tail_pos >= NR_SLOTS);
+	tail = &nr_bucket->slot[tail_pos];
+	if (likely((*tail & NR_evict) == flags && tail != slot))
+		*slot = xchg(tail, *slot); /* swap if not empty and not same */
+	nr_bucket->hand[!!flags] = slot_pos;
+
+	spin_unlock_irqrestore(&nr_bucket->lock, iflags);
+
+	return cookie;
+}
+
+/*
+ * For interactive workloads, we remember about as many non-resident pages
+ * as we have actual memory pages.  For server workloads with large inter-
+ * reference distances we could benefit from remembering more.
+ */
+static __initdata unsigned long nonresident_factor = 1;
+void __init init_nonresident(void)
+{
+	int target;
+	int i, j;
+
+	/*
+	 * Calculate the non-resident hash bucket target. Use a power of
+	 * two for the division because alloc_large_system_hash rounds up.
+	 */
+	target = nr_all_pages * nonresident_factor;
+	target /= (sizeof(struct nr_bucket) / sizeof(u32));
+
+	nonres_table = alloc_large_system_hash("Non-resident page tracking",
+					sizeof(struct nr_bucket),
+					target,
+					0,
+					HASH_EARLY | HASH_HIGHMEM,
+					&nonres_shift,
+					&nonres_mask,
+					0);
+
+	for (i = 0; i < (1 << nonres_shift); i++) {
+		spin_lock_init(&nonres_table[i].lock);
+		nonres_table[i].hand[0] = nonres_table[i].hand[1] = 0;
+		for (j = 0; j < NR_SLOTS; ++j) {
+			nonres_table[i].slot[j] = NR_evict;
+			if (j < NR_SLOTS - 1)
+				SET_INDEX(nonres_table[i].slot[j], j+1);
+			else /* j == NR_SLOTS - 1 */
+				SET_INDEX(nonres_table[i].slot[j], 0);
+		}
+	}
+}
+
+static int __init set_nonresident_factor(char * str)
+{
+	if (!str)
+		return 0;
+	nonresident_factor = simple_strtoul(str, &str, 0);
+	return 1;
+}
+
+__setup("nonresident_factor=", set_nonresident_factor);
diff --git a/mm/shmem.c b/mm/shmem.c
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1500,11 +1500,8 @@ static void do_shmem_file_read(struct fi
 			 */
 			if (mapping_writably_mapped(mapping))
 				flush_dcache_page(page);
-			/*
-			 * Mark the page accessed if we read the beginning.
-			 */
-			if (!offset)
-				mark_page_accessed(page);
+
+			mark_page_accessed(page);
 		} else
 			page = ZERO_PAGE(0);
 
diff --git a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -78,8 +78,8 @@ int rotate_reclaimable_page(struct page 
 		return 1;
 	if (PageDirty(page))
 		return 1;
-	if (PageActive(page))
-		return 1;
+	/* if (PageActive(page)) */
+		/* return 1; */
 	if (!PageLRU(page))
 		return 1;
 
@@ -97,37 +97,12 @@ int rotate_reclaimable_page(struct page 
 }
 
 /*
- * FIXME: speed this up?
- */
-void fastcall activate_page(struct page *page)
-{
-	struct zone *zone = page_zone(page);
-
-	spin_lock_irq(&zone->lru_lock);
-	if (PageLRU(page) && !PageActive(page)) {
-		del_page_from_inactive_list(zone, page);
-		SetPageActive(page);
-		add_page_to_active_list(zone, page);
-		inc_page_state(pgactivate);
-	}
-	spin_unlock_irq(&zone->lru_lock);
-}
-
-/*
  * Mark a page as having seen activity.
- *
- * inactive,unreferenced	->	inactive,referenced
- * inactive,referenced		->	active,unreferenced
- * active,unreferenced		->	active,referenced
  */
 void fastcall mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
-		activate_page(page);
-		ClearPageReferenced(page);
-	} else if (!PageReferenced(page)) {
+	if (!PageReferenced(page))
 		SetPageReferenced(page);
-	}
 }
 
 EXPORT_SYMBOL(mark_page_accessed);
@@ -139,7 +114,7 @@ EXPORT_SYMBOL(mark_page_accessed);
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
 
-void fastcall lru_cache_add(struct page *page)
+void fastcall lru_cache_add_inactive(struct page *page)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
 
@@ -303,6 +278,8 @@ void __pagevec_lru_add(struct pagevec *p
 		}
 		if (TestSetPageLRU(page))
 			BUG();
+		if (TestClearPageActive(page))
+			BUG();
 		add_page_to_inactive_list(zone, page);
 	}
 	if (zone)
diff --git a/mm/swap_state.c b/mm/swap_state.c
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -359,7 +359,7 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active(new_page);
+			lru_cache_add(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -408,7 +408,7 @@ static void unuse_pte(struct vm_area_str
 	 * Move the page to the active list so it is not
 	 * immediately swapped out again after swapon.
 	 */
-	activate_page(page);
+	SetPageReferenced(page);
 }
 
 static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
@@ -508,7 +508,7 @@ static int unuse_mm(struct mm_struct *mm
 		 * Activate page so shrink_cache is unlikely to unmap its
 		 * ptes while lock is dropped, so swapoff can make progress.
 		 */
-		activate_page(page);
+		SetPageReferenced(page);
 		unlock_page(page);
 		down_read(&mm->mmap_sem);
 		lock_page(page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -235,27 +235,6 @@ static int shrink_slab(unsigned long sca
 	return ret;
 }
 
-/* Called without lock on whether page is mapped, so answer is unstable */
-static inline int page_mapping_inuse(struct page *page)
-{
-	struct address_space *mapping;
-
-	/* Page is in somebody's page tables. */
-	if (page_mapped(page))
-		return 1;
-
-	/* Be more reluctant to reclaim swapcache than pagecache */
-	if (PageSwapCache(page))
-		return 1;
-
-	mapping = page_mapping(page);
-	if (!mapping)
-		return 0;
-
-	/* File is mmap'd by somebody? */
-	return mapping_mapped(mapping);
-}
-
 static inline int is_page_cache_freeable(struct page *page)
 {
 	return page_count(page) - !!PagePrivate(page) == 2;
@@ -397,7 +376,7 @@ static int shrink_list(struct list_head 
 		if (TestSetPageLocked(page))
 			goto keep;
 
-		BUG_ON(PageActive(page));
+		/* BUG_ON(PageActive(page)); */
 
 		sc->nr_scanned++;
 		/* Double the slab pressure for mapped and swapcache pages */
@@ -408,8 +387,8 @@ static int shrink_list(struct list_head 
 			goto keep_locked;
 
 		referenced = page_referenced(page, 1, sc->priority <= 0);
-		/* In active use or really unfreeable?  Activate it. */
-		if (referenced && page_mapping_inuse(page))
+
+		if (referenced)
 			goto activate_locked;
 
 #ifdef CONFIG_SWAP
@@ -532,6 +511,7 @@ static int shrink_list(struct list_head 
 		__put_page(page);
 
 free_it:
+		ClearPageActive(page);
 		unlock_page(page);
 		reclaimed++;
 		if (!pagevec_add(&freed_pvec, page))
@@ -554,7 +534,7 @@ keep:
 	sc->nr_reclaimed += reclaimed;
 	return reclaimed;
 }
-
+	
 /*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
@@ -566,33 +546,36 @@ keep:
  * Appropriate locks must be held before calling this function.
  *
  * @nr_to_scan:	The number of pages to look through on the list.
- * @src:	The LRU list to pull pages off.
+ * @zone:	The zone to get pages from.
  * @dst:	The temp list to put pages on to.
  * @scanned:	The number of pages that were scanned.
  *
  * returns how many pages were moved onto *@dst.
  */
-static int isolate_lru_pages(int nr_to_scan, struct list_head *src,
+static int isolate_lru_pages(int nr_to_scan, struct zone *zone,
 			     struct list_head *dst, int *scanned)
 {
 	int nr_taken = 0;
 	struct page *page;
 	int scan = 0;
+	unsigned int flags;
 
-	while (scan++ < nr_to_scan && !list_empty(src)) {
-		page = lru_to_page(src);
-		prefetchw_prev_lru_page(page, src, flags);
+	while (scan++ < nr_to_scan) {
+		page = cart_replace(zone, &flags);
+		if (!page) break;
 
 		if (!TestClearPageLRU(page))
 			BUG();
-		list_del(&page->lru);
 		if (get_page_testone(page)) {
 			/*
 			 * It is being freed elsewhere
 			 */
 			__put_page(page);
 			SetPageLRU(page);
-			list_add(&page->lru, src);
+			if (!(flags & NR_list))
+				add_page_to_inactive_tail(zone, page);
+			else
+				add_page_to_active_tail(zone, page); 
 			continue;
 		} else {
 			list_add(&page->lru, dst);
@@ -624,8 +607,7 @@ static void shrink_cache(struct zone *zo
 		int nr_freed;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-					     &zone->inactive_list,
-					     &page_list, &nr_scan);
+					     zone, &page_list, &nr_scan);
 		zone->nr_inactive -= nr_taken;
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
@@ -670,194 +652,34 @@ done:
 }
 
 /*
- * This moves pages from the active list to the inactive list.
- *
- * We move them the other way if the page is referenced by one or more
- * processes, from rmap.
- *
- * If the pages are mostly unmapped, the processing is fast and it is
- * appropriate to hold zone->lru_lock across the whole operation.  But if
- * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop zone->lru_lock around each page.  It's impossible to balance
- * this, so instead we remove the pages from the LRU while processing them.
- * It is safe to rely on PG_active against the non-LRU pages in here because
- * nobody will play with that bit on a non-LRU page.
- *
- * The downside is that we have to touch page->_count against each page.
- * But we had to alter page->flags anyway.
- */
-static void
-refill_inactive_zone(struct zone *zone, struct scan_control *sc)
-{
-	int pgmoved;
-	int pgdeactivate = 0;
-	int pgscanned;
-	int nr_pages = sc->nr_to_scan;
-	LIST_HEAD(l_hold);	/* The pages which were snipped off */
-	LIST_HEAD(l_inactive);	/* Pages to go onto the inactive_list */
-	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
-	struct page *page;
-	struct pagevec pvec;
-	int reclaim_mapped = 0;
-	long mapped_ratio;
-	long distress;
-	long swap_tendency;
-
-	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-				    &l_hold, &pgscanned);
-	zone->pages_scanned += pgscanned;
-	zone->nr_active -= pgmoved;
-	spin_unlock_irq(&zone->lru_lock);
-
-	/*
-	 * `distress' is a measure of how much trouble we're having reclaiming
-	 * pages.  0 -> no problems.  100 -> great trouble.
-	 */
-	distress = 100 >> zone->prev_priority;
-
-	/*
-	 * The point of this algorithm is to decide when to start reclaiming
-	 * mapped memory instead of just pagecache.  Work out how much memory
-	 * is mapped.
-	 */
-	mapped_ratio = (sc->nr_mapped * 100) / total_memory;
-
-	/*
-	 * Now decide how much we really want to unmap some pages.  The mapped
-	 * ratio is downgraded - just because there's a lot of mapped memory
-	 * doesn't necessarily mean that page reclaim isn't succeeding.
-	 *
-	 * The distress ratio is important - we don't want to start going oom.
-	 *
-	 * A 100% value of vm_swappiness overrides this algorithm altogether.
-	 */
-	swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
-
-	/*
-	 * Now use this metric to decide whether to start moving mapped memory
-	 * onto the inactive list.
-	 */
-	if (swap_tendency >= 100)
-		reclaim_mapped = 1;
-
-	while (!list_empty(&l_hold)) {
-		cond_resched();
-		page = lru_to_page(&l_hold);
-		list_del(&page->lru);
-		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0, sc->priority <= 0)) {
-				list_add(&page->lru, &l_active);
-				continue;
-			}
-		}
-		list_add(&page->lru, &l_inactive);
-	}
-
-	pagevec_init(&pvec, 1);
-	pgmoved = 0;
-	spin_lock_irq(&zone->lru_lock);
-	while (!list_empty(&l_inactive)) {
-		page = lru_to_page(&l_inactive);
-		prefetchw_prev_lru_page(page, &l_inactive, flags);
-		if (TestSetPageLRU(page))
-			BUG();
-		if (!TestClearPageActive(page))
-			BUG();
-		list_move(&page->lru, &zone->inactive_list);
-		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
-			zone->nr_inactive += pgmoved;
-			spin_unlock_irq(&zone->lru_lock);
-			pgdeactivate += pgmoved;
-			pgmoved = 0;
-			if (buffer_heads_over_limit)
-				pagevec_strip(&pvec);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
-		}
-	}
-	zone->nr_inactive += pgmoved;
-	pgdeactivate += pgmoved;
-	if (buffer_heads_over_limit) {
-		spin_unlock_irq(&zone->lru_lock);
-		pagevec_strip(&pvec);
-		spin_lock_irq(&zone->lru_lock);
-	}
-
-	pgmoved = 0;
-	while (!list_empty(&l_active)) {
-		page = lru_to_page(&l_active);
-		prefetchw_prev_lru_page(page, &l_active, flags);
-		if (TestSetPageLRU(page))
-			BUG();
-		BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
-		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
-			zone->nr_active += pgmoved;
-			pgmoved = 0;
-			spin_unlock_irq(&zone->lru_lock);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
-		}
-	}
-	zone->nr_active += pgmoved;
-	spin_unlock_irq(&zone->lru_lock);
-	pagevec_release(&pvec);
-
-	mod_page_state_zone(zone, pgrefill, pgscanned);
-	mod_page_state(pgdeactivate, pgdeactivate);
-}
-
-/*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static void
 shrink_zone(struct zone *zone, struct scan_control *sc)
 {
 	unsigned long nr_active;
-	unsigned long nr_inactive;
 
 	/*
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
 	 */
-	zone->nr_scan_active += (zone->nr_active >> sc->priority) + 1;
+	zone->nr_scan_active += ((zone->nr_active + zone->nr_inactive) >> sc->priority) + 1;
 	nr_active = zone->nr_scan_active;
 	if (nr_active >= sc->swap_cluster_max)
 		zone->nr_scan_active = 0;
 	else
 		nr_active = 0;
 
-	zone->nr_scan_inactive += (zone->nr_inactive >> sc->priority) + 1;
-	nr_inactive = zone->nr_scan_inactive;
-	if (nr_inactive >= sc->swap_cluster_max)
-		zone->nr_scan_inactive = 0;
-	else
-		nr_inactive = 0;
 
 	sc->nr_to_reclaim = sc->swap_cluster_max;
 
-	while (nr_active || nr_inactive) {
-		if (nr_active) {
-			sc->nr_to_scan = min(nr_active,
-					(unsigned long)sc->swap_cluster_max);
-			nr_active -= sc->nr_to_scan;
-			refill_inactive_zone(zone, sc);
-		}
-
-		if (nr_inactive) {
-			sc->nr_to_scan = min(nr_inactive,
-					(unsigned long)sc->swap_cluster_max);
-			nr_inactive -= sc->nr_to_scan;
-			shrink_cache(zone, sc);
-			if (sc->nr_to_reclaim <= 0)
-				break;
-		}
+	while (nr_active) {
+		sc->nr_to_scan = min(nr_active,
+				     (unsigned long)sc->swap_cluster_max);
+		nr_active -= sc->nr_to_scan;
+		shrink_cache(zone, sc);
+		if (sc->nr_to_reclaim <= 0)
+			break;
 	}
 
 	throttle_vm_writeout();

--=-lCrVvqcefV6w4WYoRc0U--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
