Message-ID: <43024435.90503@andrew.cmu.edu>
Date: Tue, 16 Aug 2005 15:53:25 -0400
From: Rahul Iyer <rni@andrew.cmu.edu>
MIME-Version: 1.0
Subject: Re: Zoned CART
References: <1123857429.14899.59.camel@twins>	 <1124024312.30836.26.camel@twins> <1124141492.15180.22.camel@twins>
In-Reply-To: <1124141492.15180.22.camel@twins>
Content-Type: multipart/mixed;
 boundary="------------080907060300080304020903"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080907060300080304020903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Peter,
I have changed the patch to incorporate Marcelo's suggestions.
The changes are:
-- Fixed bug with EvictedActive() macros and related constants
-- removed the 3 fields in the non resident nodes to just one hashval field.

The second one should not affect you in any way i think, as you have 
used Rik's code for the non resident page management.

Patches:
-- linux-cartv3.patch - patches on the v2 codebase
-- linux-cartv3.vanilla.patch - patches the linux-2.6.12-rc5 kernel
-- linux-cartv3.partial.patch - fixes only the first issue. This should 
be good for you Peter.
Thanks
Rahul


Peter Zijlstra wrote:

>On Sun, 2005-08-14 at 14:58 +0200, Peter Zijlstra wrote:
>
>  
>
>>Ok, now on to putting Rahul code on top of this ;-)
>>    
>>
>
>I got UML to boot with this patch. Now for some stress and behavioural
>testing.
> 
> include/linux/cart.h       |   12 ++
> include/linux/mm_inline.h  |   36 ++++++
> include/linux/mmzone.h     |   12 +-
> include/linux/page-flags.h |    5
> include/linux/swap.h       |   14 ++
> init/main.c                |    5
> mm/Makefile                |    3
> mm/cart.c                  |  175 +++++++++++++++++++++++++++++++
> mm/nonresident.c           |  251 +++++++++++++++++++++++++++++++++++++++++++++
> mm/swap.c                  |    4
> mm/vmscan.c                |   43 +++++++
> 11 files changed, 553 insertions(+), 7 deletions(-)
>
>  
>
>------------------------------------------------------------------------
>
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/include/linux/cart.h linux-2.6.13-rc6-cart/include/linux/cart.h
>--- linux-2.6.13-rc6/include/linux/cart.h	1970-01-01 01:00:00.000000000 +0100
>+++ linux-2.6.13-rc6-cart/include/linux/cart.h	2005-08-15 17:33:07.000000000 +0200
>@@ -0,0 +1,12 @@
>+#ifndef __CART_H__
>+#define __CART_H__
>+#include <linux/list.h>
>+#include <linux/mm.h>
>+#include <linux/swap.h>
>+
>+extern void cart_init(void);
>+extern void update_cart_params(struct page *);
>+extern struct page *replace(struct zone *, unsigned int *);
>+
>+#endif
>+
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/include/linux/mm_inline.h linux-2.6.13-rc6-cart/include/linux/mm_inline.h
>--- linux-2.6.13-rc6/include/linux/mm_inline.h	2005-03-02 08:38:33.000000000 +0100
>+++ linux-2.6.13-rc6-cart/include/linux/mm_inline.h	2005-08-15 17:33:07.000000000 +0200
>@@ -38,3 +38,39 @@ del_page_from_lru(struct zone *zone, str
> 		zone->nr_inactive--;
> 	}
> }
>+
>+static inline void
>+add_page_to_active_tail(struct zone *zone, struct page *page)
>+{
>+	list_add_tail(&page->lru, &zone->active_list);
>+	zone->nr_active++;
>+}
>+
>+static inline void 
>+del_page_from_active(struct zone *zone, struct page *page)
>+{
>+	list_del(&page->lru);
>+	zone->nr_active--;
>+}
>+
>+static inline void
>+add_page_to_inactive_tail(struct zone *zone, struct page *page)
>+{
>+        list_add_tail(&page->lru, &zone->inactive_list);
>+        zone->nr_inactive++;
>+}
>+
>+static inline void 
>+del_page_from_active_longterm(struct zone *zone, struct page *page)
>+{
>+	list_del(&page->lru);
>+	zone->nr_active_longterm--;
>+}
>+
>+static inline void
>+add_page_to_active_longterm_tail(struct zone *zone, struct page *page)
>+{
>+	list_add_tail(&page->lru, &zone->active_longterm);
>+	zone->nr_active_longterm++;
>+}
>+
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/include/linux/mmzone.h linux-2.6.13-rc6-cart/include/linux/mmzone.h
>--- linux-2.6.13-rc6/include/linux/mmzone.h	2005-08-15 22:37:00.000000000 +0200
>+++ linux-2.6.13-rc6-cart/include/linux/mmzone.h	2005-08-15 17:33:07.000000000 +0200
>@@ -144,12 +144,20 @@ struct zone {
> 
> 	/* Fields commonly accessed by the page reclaim scanner */
> 	spinlock_t		lru_lock;	
>-	struct list_head	active_list;
>+	struct list_head	active_list;	/* The T1 list of CART */
>+	struct list_head	active_longterm;/* The T2 list of CART */
> 	struct list_head	inactive_list;
> 	unsigned long		nr_scan_active;
> 	unsigned long		nr_scan_inactive;
>-	unsigned long		nr_active;
>+	unsigned long		nr_active;	
>+	unsigned long		nr_active_longterm;
> 	unsigned long		nr_inactive;
>+	unsigned long 		nr_evicted_active;
>+	unsigned long 		nr_evicted_longterm;
>+	unsigned long 		nr_longterm;	/* number of long term pages */
>+	unsigned long 		nr_shortterm;	/* number of short term pages */
>+	unsigned long		cart_p;		/* p from the CART paper */
>+	unsigned long 		cart_q;		/* q from the cart paper */
> 	unsigned long		pages_scanned;	   /* since last reclaim */
> 	int			all_unreclaimable; /* All pages pinned */
> 
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/include/linux/page-flags.h linux-2.6.13-rc6-cart/include/linux/page-flags.h
>--- linux-2.6.13-rc6/include/linux/page-flags.h	2005-08-15 22:37:00.000000000 +0200
>+++ linux-2.6.13-rc6-cart/include/linux/page-flags.h	2005-08-15 17:33:07.000000000 +0200
>@@ -75,6 +75,7 @@
> #define PG_reclaim		17	/* To be reclaimed asap */
> #define PG_nosave_free		18	/* Free, should not be written */
> #define PG_uncached		19	/* Page has been mapped as uncached */
>+#define PG_longterm		20	/* Filter bit for CART see mm/cart.c */
> 
> /*
>  * Global page accounting.  One instance per CPU.  Only unsigned longs are
>@@ -305,6 +306,10 @@ extern void __mod_page_state(unsigned lo
> #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
> #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
> 
>+#define PageLongTerm(page)	test_bit(PG_longterm, &(page)->flags)
>+#define SetLongTerm(page)	set_bit(PG_longterm, &(page)->flags)
>+#define ClearLongTerm(page)	clear_bit(PG_longterm, &(page)->flags)
>+
> struct page;	/* forward declaration */
> 
> int test_clear_page_dirty(struct page *page);
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/include/linux/swap.h linux-2.6.13-rc6-cart/include/linux/swap.h
>--- linux-2.6.13-rc6/include/linux/swap.h	2005-08-15 22:37:00.000000000 +0200
>+++ linux-2.6.13-rc6-cart/include/linux/swap.h	2005-08-15 17:33:08.000000000 +0200
>@@ -154,6 +154,15 @@ extern void out_of_memory(unsigned int _
> /* linux/mm/memory.c */
> extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
> 
>+/* linux/mm/nonresident.c */
>+#define NR_filter		0x01  /* short/long */
>+#define NR_list			0x02  /* b1/b2; correlates to PG_active */
>+#define NR_evict		0x80000000
>+
>+extern u32 remember_page(struct address_space *, unsigned long, unsigned int);
>+extern unsigned int recently_evicted(struct address_space *, unsigned long);
>+extern void init_nonresident(void);
>+
> /* linux/mm/page_alloc.c */
> extern unsigned long totalram_pages;
> extern unsigned long totalhigh_pages;
>@@ -292,6 +301,11 @@ static inline swp_entry_t get_swap_page(
> #define grab_swap_token()  do { } while(0)
> #define has_swap_token(x) 0
> 
>+/* linux/mm/nonresident.c */
>+#define init_nonresident()	do { } while (0)
>+#define remember_page(x,y,z)	0
>+#define recently_evicted(x,y)	0
>+
> #endif /* CONFIG_SWAP */
> #endif /* __KERNEL__*/
> #endif /* _LINUX_SWAP_H */
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/init/main.c linux-2.6.13-rc6-cart/init/main.c
>--- linux-2.6.13-rc6/init/main.c	2005-08-15 22:37:00.000000000 +0200
>+++ linux-2.6.13-rc6-cart/init/main.c	2005-08-15 17:36:19.000000000 +0200
>@@ -47,12 +47,15 @@
> #include <linux/rmap.h>
> #include <linux/mempolicy.h>
> #include <linux/key.h>
>+#include <linux/swap.h>
> 
> #include <asm/io.h>
> #include <asm/bugs.h>
> #include <asm/setup.h>
> #include <asm/sections.h>
> 
>+#include <linux/cart.h>
>+
> /*
>  * This is one of the first .c files built. Error out early
>  * if we have compiler trouble..
>@@ -494,7 +497,9 @@ asmlinkage void __init start_kernel(void
> 	}
> #endif
> 	vfs_caches_init_early();
>+	init_nonresident();
> 	mem_init();
>+	cart_init();
> 	kmem_cache_init();
> 	setup_per_cpu_pageset();
> 	numa_policy_init();
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/mm/Makefile linux-2.6.13-rc6-cart/mm/Makefile
>--- linux-2.6.13-rc6/mm/Makefile	2005-08-15 22:37:01.000000000 +0200
>+++ linux-2.6.13-rc6-cart/mm/Makefile	2005-08-15 17:33:08.000000000 +0200
>@@ -12,7 +12,8 @@ obj-y			:= bootmem.o filemap.o mempool.o
> 			   readahead.o slab.o swap.o truncate.o vmscan.o \
> 			   prio_tree.o $(mmu-y)
> 
>-obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
>+obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o \
>+			   nonresident.o cart.o
> obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
> obj-$(CONFIG_NUMA) 	+= mempolicy.o
> obj-$(CONFIG_SPARSEMEM)	+= sparse.o
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/mm/cart.c linux-2.6.13-rc6-cart/mm/cart.c
>--- linux-2.6.13-rc6/mm/cart.c	1970-01-01 01:00:00.000000000 +0100
>+++ linux-2.6.13-rc6-cart/mm/cart.c	2005-08-15 22:22:26.000000000 +0200
>@@ -0,0 +1,175 @@
>+/* Thisfile contains the crux of the CART page replacement algorithm. This implementation however changes a few things form the classic CART scheme. This implementation splits the original active_list of the Linux implementation into two lists, namely active_list and active_longterm. The 'active' pages exist on these two lists. The active_list hopes to capture short term usage, while the active_longterm list hopes to capture long term usage. Whenever a page's state needs to be updated, the update_cart_params() function is called. The refill_incative_zone() function causes the replace() function to be evoked, resulting in the removal of pages from the active lists. Hence, which pages are deemed inactive is determined by the CART algorithm. 
>+For further details, please refer to the CART paper here - http://www.almaden.ibm.com/cs/people/dmodha/clockfast.pdf */
>+ 
>+#include <linux/cart.h>
>+#include <linux/page-flags.h>
>+#include <linux/mm_inline.h>
>+
>+/* Called from init/main.c to initialize the cart parameters */
>+void cart_init()
>+{
>+	pg_data_t *pgdat;
>+	struct zone *zone;
>+	int i;
>+
>+	pgdat = pgdat_list;
>+	
>+	do {
>+		for (i=0;i<MAX_NR_ZONES;++i) {
>+			zone = &pgdat->node_zones[i];
>+			
>+			spin_lock_init(&zone->lru_lock);
>+			INIT_LIST_HEAD(&zone->active_list);
>+			INIT_LIST_HEAD(&zone->active_longterm);
>+			INIT_LIST_HEAD(&zone->inactive_list);
>+			
>+			zone->nr_active = zone->nr_active_longterm = zone->nr_inactive = 0;
>+			zone->nr_evicted_active = 0;
>+			zone->nr_evicted_longterm = zone->present_pages - zone->pages_high;
>+			
>+			zone->cart_p = zone->cart_q = zone->nr_longterm = zone->nr_shortterm = 0;
>+		}
>+	} while ((pgdat = pgdat->pgdat_next));
>+}
>+
>+/* The heart of the CART update function. This function is responsible for the movement of pages across the lists */	
>+void update_cart_params(struct page *page)
>+{
>+	unsigned int rflags;
>+	unsigned long evicted_active;
>+	unsigned evicted_longterm;
>+	struct zone *zone;
>+
>+	zone = page_zone(page);
>+
>+	rflags = recently_evicted(page->mapping, page->index);
>+	evicted_active = (!rflags && !(rflags & NR_list));
>+	evicted_longterm = (!rflags && (rflags & NR_list));
>+	
>+	if (evicted_active) {
>+		zone->cart_p = min(zone->cart_p + max(zone->nr_shortterm/(zone->nr_evicted_active ?: 1UL), 1UL), (zone->present_pages - zone->pages_high));
>+
>+		++zone->nr_longterm;
>+		SetLongTerm(page);
>+		ClearPageReferenced(page);
>+	}
>+	else if (evicted_longterm) {
>+		zone->cart_p = max(zone->cart_p - max(1UL, zone->nr_longterm/(zone->nr_evicted_longterm ?: 1UL)), 0UL);
>+
>+		++zone->nr_longterm;
>+		ClearPageReferenced(page);
>+
>+		if (zone->nr_active_longterm + zone->nr_active + zone->nr_evicted_longterm - zone->nr_shortterm >=(zone->present_pages - zone->pages_high)) {
>+			zone->cart_q = min(zone->cart_q + 1, 2*(zone->present_pages - zone->pages_high) - zone->nr_active);
>+		}
>+	}
>+	else {
>+		++zone->nr_shortterm;
>+		ClearLongTerm(page);
>+	}
>+
>+	add_page_to_active_list(zone, page);
>+}
>+
>+/* The replace function. This function serches the active and longterm lists and looks for a candidate for replacement. This function selects the candidate and returns the corresponding structpage or returns NULL in case no page can be freed. The *where argument is used to indicate the parent list of the page so that, in case it cannot be written back, it can be placed back on the correct list */
>+struct page *replace(struct zone *zone, unsigned int *where)
>+{
>+	struct list_head *list;
>+	struct page *page = NULL;
>+	int referenced = 0;
>+	int debug_count=0;
>+	unsigned int flags = 0, rflags;
>+
>+	list = &zone->active_longterm;
>+	list = list->next;
>+	while (list !=&zone->active_longterm) {
>+		page = list_entry(list, struct page, lru);
>+
>+		if (!PageReferenced(page))
>+			break;
>+		
>+		ClearPageReferenced(page);
>+		del_page_from_active_longterm(zone, page);
>+		add_page_to_active_tail(zone, page);
>+		
>+		if ((zone->nr_active_longterm + zone->nr_active + zone->nr_evicted_longterm - zone->nr_shortterm) >= (zone->present_pages - zone->pages_high))
>+			zone->cart_q = min(zone->cart_q + 1, 2*(zone->present_pages - zone->pages_high) - zone->nr_active);
>+
>+		list = &zone->active_longterm;
>+		list = list->next;
>+		debug_count++;
>+	}
>+
>+	debug_count=0;
>+	list = &zone->active_list;
>+	list = list->next;
>+
>+	while (list != &zone->active_list) {
>+		page = list_entry(list, struct page, lru);
>+		referenced = PageReferenced(page);
>+		
>+		if (!PageLongTerm(page) && !referenced)
>+			break;
>+			
>+		ClearPageReferenced(page);
>+		if (referenced) {
>+			del_page_from_active(zone, page);
>+			add_page_to_active_tail(zone, page);
>+
>+			if (zone->nr_active >= min(zone->cart_p+1, zone->nr_evicted_active) && !PageLongTerm(page)) {
>+				SetLongTerm(page);
>+				--zone->nr_shortterm;
>+				++zone->nr_longterm;
>+			}
>+		}
>+		else {
>+			del_page_from_active(zone, page);
>+			add_page_to_active_longterm_tail(zone, page);
>+
>+			zone->cart_q = max(zone->cart_q-1, (zone->present_pages - zone->pages_high) - zone->nr_active);
>+		}
>+
>+		list = &zone->active_list;
>+		list = list->next;
>+		debug_count++;
>+	}
>+
>+	page = NULL;
>+	
>+	if (zone->nr_active > max(1UL, zone->cart_p)) {
>+		if (!list_empty(&zone->active_list)) {
>+			page = list_entry(zone->active_list.next, struct page, lru);
>+			del_page_from_active(zone, page);
>+			--zone->nr_shortterm;
>+        		++zone->nr_evicted_active;
>+		}
>+	}
>+	else {
>+		if (!list_empty(&zone->active_longterm)) {
>+			page = list_entry(zone->active_longterm.next, struct page, lru);
>+			del_page_from_active_longterm(zone, page);
>+			--zone->nr_longterm;
>+        		++zone->nr_evicted_longterm;
>+			flags |= NR_list;
>+		}
>+	}
>+
>+	if (!page) return NULL;
>+	*where = flags | NR_evict;
>+	if (PageLongTerm(page)) flags |= NR_filter;
>+
>+	/* history replacement; always remember, if the page was already remembered
>+	 * this will move it to the head.
>+	 * Also assume |B1| + |B2| == c + 1, since |B1_j| + |B2_j| == c_j.
>+	 */
>+	if (zone->nr_evicted_active <= max(0UL, zone->cart_q)) flags |= NR_evict;
>+
>+	rflags = remember_page(page->mapping, page->index, flags);
>+	if (rflags & NR_evict) {
>+		if (likely(zone->nr_evicted_longterm)) --zone->nr_evicted_longterm;
>+	} else {
>+		if (likely(zone->nr_evicted_active)) --zone->nr_evicted_active;
>+	}
>+
>+	return page;
>+}
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/mm/nonresident.c linux-2.6.13-rc6-cart/mm/nonresident.c
>--- linux-2.6.13-rc6/mm/nonresident.c	1970-01-01 01:00:00.000000000 +0100
>+++ linux-2.6.13-rc6-cart/mm/nonresident.c	2005-08-15 21:46:17.000000000 +0200
>@@ -0,0 +1,251 @@
>+/*
>+ * mm/nonresident.c
>+ * (C) 2004,2005 Red Hat, Inc
>+ * Written by Rik van Riel <riel@redhat.com>
>+ * Released under the GPL, see the file COPYING for details.
>+ * Adapted by Peter Zijlstra <a.p.zijlstra@chello.nl> for use by ARC
>+ * like algorithms.
>+ *
>+ * Keeps track of whether a non-resident page was recently evicted
>+ * and should be immediately promoted to the active list. This also
>+ * helps automatically tune the inactive target.
>+ *
>+ * The pageout code stores a recently evicted page in this cache
>+ * by calling remember_page(mapping/mm, index/vaddr)
>+ * and can look it up in the cache by calling recently_evicted()
>+ * with the same arguments.
>+ *
>+ * Note that there is no way to invalidate pages after eg. truncate
>+ * or exit, we let the pages fall out of the non-resident set through
>+ * normal replacement.
>+ *
>+ *
>+ * Modified to work with ARC like algorithms who:
>+ *  - need to balance two FIFOs; |b1| + |b2| = c,
>+ *  - keep a flag per non-resident page.
>+ *
>+ * The bucket contains two single linked cyclic lists (CLOCKS) and each
>+ * clock has a tail hand. By selecting a victim clock upon insertion it
>+ * is possible to balance them.
>+ *
>+ * The slot looks like this:
>+ * struct slot_t {
>+ *         u32 cookie : 24; // LSB 
>+ *         u32 index  :  6;
>+ *         u32 filter :  1;
>+ *         u32 clock  :  1; // MSB
>+ * };
>+ *
>+ * The bucket is guarded by a spinlock.
>+ */
>+#include <linux/swap.h>
>+#include <linux/mm.h>
>+#include <linux/cache.h>
>+#include <linux/spinlock.h>
>+#include <linux/bootmem.h>
>+#include <linux/hash.h>
>+#include <linux/prefetch.h>
>+#include <linux/kernel.h>
>+
>+#define TARGET_SLOTS	64
>+#define NR_CACHELINES  (TARGET_SLOTS*sizeof(u32) / L1_CACHE_BYTES)
>+#define NR_SLOTS	(((NR_CACHELINES * L1_CACHE_BYTES) - sizeof(spinlock_t) - 2*sizeof(u16)) / sizeof(u32))
>+#if 0
>+#if NR_SLOTS < (TARGET_SLOTS / 2)
>+#warning very small slot size
>+#if NR_SLOTS <= 0
>+#error no room for slots left
>+#endif
>+#endif
>+#endif
>+
>+#define BUILD_MASK(bits, shift) (((1 << (bits)) - 1) << (shift))
>+
>+#define FLAGS_BITS		2
>+#define FLAGS_SHIFT		(sizeof(u32)*8 - FLAGS_BITS)
>+#define FLAGS_MASK		BUILD_MASK(FLAGS_BITS, FLAGS_SHIFT)
>+
>+#define INDEX_BITS		6  /* ceil(log2(NR_SLOTS)) */
>+#define INDEX_SHIFT		(FLAGS_SHIFT - INDEX_BITS)
>+#define INDEX_MASK		BUILD_MASK(INDEX_BITS, INDEX_SHIFT)
>+
>+#define SET_INDEX(x, idx)	((x) = ((x) & ~INDEX_MASK) | ((idx) << INDEX_SHIFT))
>+#define GET_INDEX(x)		(((x) & INDEX_MASK) >> INDEX_SHIFT)
>+
>+struct nr_bucket
>+{
>+	spinlock_t lock;
>+	u16 hand[2];
>+	u32 slot[NR_SLOTS];
>+} ____cacheline_aligned;
>+
>+/* The non-resident page hash table. */
>+static struct nr_bucket * nonres_table;
>+static unsigned int nonres_shift;
>+static unsigned int nonres_mask;
>+
>+/* hash the address into a bucket */
>+static struct nr_bucket * nr_hash(void * mapping, unsigned long index)
>+{
>+	unsigned long bucket;
>+	unsigned long hash;
>+
>+	hash = hash_ptr(mapping, BITS_PER_LONG);
>+	hash = 37 * hash + hash_long(index, BITS_PER_LONG);
>+	bucket = hash & nonres_mask;
>+
>+	return nonres_table + bucket;
>+}
>+
>+/* hash the address, inode and flags into a cookie */
>+/* the two msb are flags; where msb-1 is a type flag and msb a period flag */
>+static u32 nr_cookie(struct address_space * mapping, unsigned long index, unsigned int flags)
>+{
>+	u32 c;
>+	unsigned long cookie;
>+	
>+	cookie = hash_ptr(mapping, BITS_PER_LONG);
>+	cookie = 37 * cookie + hash_long(index, BITS_PER_LONG);
>+
>+	if (mapping->host) {
>+		cookie = 37 * cookie + hash_long(mapping->host->i_ino, BITS_PER_LONG);
>+	}
>+
>+	c = (u32)(cookie >> (BITS_PER_LONG - 32));
>+	c = (c & ~FLAGS_MASK) | ((flags << FLAGS_SHIFT) & FLAGS_MASK);
>+	return c;
>+}
>+
>+unsigned int recently_evicted(struct address_space * mapping, unsigned long index)
>+{
>+	struct nr_bucket * nr_bucket;
>+	u32 wanted, mask;
>+	unsigned int r_flags = 0;
>+	int i;
>+
>+	prefetch(mapping->host);
>+	nr_bucket = nr_hash(mapping, index);
>+
>+	spin_lock_prefetch(nr_bucket); // prefetch_range(nr_bucket, NR_CACHELINES);
>+	wanted = nr_cookie(mapping, index, 0) & ~INDEX_MASK;
>+	mask = ~(FLAGS_MASK | INDEX_MASK);
>+
>+	spin_lock(&nr_bucket->lock);
>+	for (i = 0; i < NR_SLOTS; ++i) {
>+		if ((nr_bucket->slot[i] & mask) == wanted) {
>+			r_flags = nr_bucket->slot[i] >> FLAGS_SHIFT;
>+			r_flags |= NR_evict; /* set the MSB to mark presence */
>+			break;
>+		}
>+	}
>+	spin_unlock(&nr_bucket->lock);
>+
>+	return r_flags;
>+}
>+
>+/* flags: 
>+ *   logical and of the page flags (NR_filter, NR_list) and
>+ *   an NR_evict target
>+ */
>+u32 remember_page(struct address_space * mapping, unsigned long index, unsigned int flags)
>+{
>+	struct nr_bucket *nr_bucket;
>+	u32 cookie;
>+	u32 *slot, *tail;
>+	unsigned int slot_pos, tail_pos;
>+
>+	prefetch(mapping->host);
>+	nr_bucket = nr_hash(mapping, index);
>+
>+	spin_lock_prefetch(nr_bucket); // prefetchw_range(nr_bucket, NR_CACHELINES);
>+	cookie = nr_cookie(mapping, index, flags);
>+
>+	flags &= NR_evict; /* removal chain */
>+	spin_lock(&nr_bucket->lock);
>+
>+	/* free a slot */
>+again:
>+	tail_pos = nr_bucket->hand[!!flags];
>+	BUG_ON(tail_pos >= NR_SLOTS);
>+	tail = &nr_bucket->slot[tail_pos];
>+	if (unlikely((*tail & NR_evict) != flags)) {
>+		flags ^= NR_evict; /* empty chain; take other one */
>+		goto again;
>+	} 
>+	BUG_ON((*tail & NR_evict) != flags);
>+	/* free slot by swapping tail,tail+1, so that we skip over tail */
>+	slot_pos = GET_INDEX(*tail);
>+	BUG_ON(slot_pos >= NR_SLOTS);
>+	slot = &nr_bucket->slot[slot_pos];
>+	BUG_ON((*slot & NR_evict) != flags);
>+	if (likely(tail != slot)) *slot = xchg(tail, *slot);
>+	/* slot: -> [slot], old cookie */
>+	BUG_ON(GET_INDEX(*slot) != slot_pos);
>+
>+	flags = (cookie & NR_evict); /* insertion chain */
>+
>+	/* place cookie in empty slot */
>+	SET_INDEX(cookie, slot_pos); /* -> [slot], cookie */
>+	cookie = xchg(slot, cookie); /* slot: -> [slot], cookie */
>+
>+	/* insert slot before tail; ie. MRU pos */
>+	tail_pos = nr_bucket->hand[!!flags];
>+	BUG_ON(tail_pos >= NR_SLOTS);
>+	tail = &nr_bucket->slot[tail_pos];
>+	if (likely((*tail & NR_evict) == flags && tail != slot))
>+		*slot = xchg(tail, *slot); /* swap if not empty and not same */
>+	nr_bucket->hand[!!flags] = slot_pos;
>+
>+	spin_unlock(&nr_bucket->lock);
>+
>+	return cookie;
>+}
>+
>+/*
>+ * For interactive workloads, we remember about as many non-resident pages
>+ * as we have actual memory pages.  For server workloads with large inter-
>+ * reference distances we could benefit from remembering more.
>+ */
>+static __initdata unsigned long nonresident_factor = 1;
>+void __init init_nonresident(void)
>+{
>+	int target;
>+	int i, j;
>+
>+	/*
>+	 * Calculate the non-resident hash bucket target. Use a power of
>+	 * two for the division because alloc_large_system_hash rounds up.
>+	 */
>+	target = nr_all_pages * nonresident_factor;
>+	target /= (sizeof(struct nr_bucket) / sizeof(u32));
>+
>+	nonres_table = alloc_large_system_hash("Non-resident page tracking",
>+					sizeof(struct nr_bucket),
>+					target,
>+					0,
>+					HASH_EARLY | HASH_HIGHMEM,
>+					&nonres_shift,
>+					&nonres_mask,
>+					0);
>+
>+	for (i = 0; i < (1 << nonres_shift); i++) {
>+		spin_lock_init(&nonres_table[i].lock);
>+		nonres_table[i].hand[0] = nonres_table[i].hand[1] = 0;
>+		for (j = 0; j < NR_SLOTS; ++j) {
>+			nonres_table[i].slot[j] = NR_evict;
>+			if (j < NR_SLOTS - 1)
>+				SET_INDEX(nonres_table[i].slot[j], j+1);
>+			else /* j == NR_SLOTS - 1 */
>+				SET_INDEX(nonres_table[i].slot[j], 0);
>+		}
>+	}
>+}
>+
>+static int __init set_nonresident_factor(char * str)
>+{
>+	if (!str)
>+		return 0;
>+	nonresident_factor = simple_strtoul(str, &str, 0);
>+	return 1;
>+}
>+__setup("nonresident_factor=", set_nonresident_factor);
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/mm/swap.c linux-2.6.13-rc6-cart/mm/swap.c
>--- linux-2.6.13-rc6/mm/swap.c	2005-03-02 08:38:07.000000000 +0100
>+++ linux-2.6.13-rc6-cart/mm/swap.c	2005-08-15 17:33:08.000000000 +0200
>@@ -30,6 +30,7 @@
> #include <linux/cpu.h>
> #include <linux/notifier.h>
> #include <linux/init.h>
>+#include <linux/cart.h>
> 
> /* How many pages do we try to swap or page in/out together? */
> int page_cluster;
>@@ -107,7 +108,7 @@ void fastcall activate_page(struct page 
> 	if (PageLRU(page) && !PageActive(page)) {
> 		del_page_from_inactive_list(zone, page);
> 		SetPageActive(page);
>-		add_page_to_active_list(zone, page);
>+		update_cart_params(page);
> 		inc_page_state(pgactivate);
> 	}
> 	spin_unlock_irq(&zone->lru_lock);
>@@ -124,7 +125,6 @@ void fastcall mark_page_accessed(struct 
> {
> 	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
> 		activate_page(page);
>-		ClearPageReferenced(page);
> 	} else if (!PageReferenced(page)) {
> 		SetPageReferenced(page);
> 	}
>diff -NaurpX linux-2.6.13-rc6-cart/Documentation/dontdiff -x arch -x asm-um linux-2.6.13-rc6/mm/vmscan.c linux-2.6.13-rc6-cart/mm/vmscan.c
>--- linux-2.6.13-rc6/mm/vmscan.c	2005-08-15 22:37:01.000000000 +0200
>+++ linux-2.6.13-rc6-cart/mm/vmscan.c	2005-08-15 17:33:08.000000000 +0200
>@@ -38,6 +38,7 @@
> #include <asm/div64.h>
> 
> #include <linux/swapops.h>
>+#include <linux/cart.h>
> 
> /* possible outcome of pageout() */
> typedef enum {
>@@ -555,6 +556,44 @@ keep:
> 	return reclaimed;
> }
> 
>+/* This gets a page from the active_list and active_longterm lists in order to add to the incative list */
>+static int get_from_active_lists(int nr_to_scan, struct zone *zone, struct list_head *dst, int *scanned)
>+{
>+	int nr_taken = 0;
>+	struct page *page;
>+	int scan = 0;
>+	unsigned int flags;
>+
>+	while (scan++ < nr_to_scan) {
>+		flags = 0;
>+		page = replace(zone, &flags);
>+
>+		if (!page) break;
>+		BUG_ON(!TestClearPageLRU(page));
>+		BUG_ON(!flags);
>+
>+		if (get_page_testone(page)) {
>+			/*
>+			 * It is being freed elsewhere
>+			 */
>+			__put_page(page);
>+			SetPageLRU(page);
>+
>+			if (!(flags & NR_list))
>+				add_page_to_active_tail(zone, page);
>+			else
>+				add_page_to_active_longterm_tail(zone, page); 
>+			continue;
>+		} else {
>+			list_add(&page->lru, dst);
>+			nr_taken++;
>+		}
>+	}
>+
>+	*scanned = scan;
>+	return nr_taken;
>+}
>+	
> /*
>  * zone->lru_lock is heavily contended.  Some of the functions that
>  * shrink the lists perform better by taking out a batch of pages
>@@ -705,10 +744,10 @@ refill_inactive_zone(struct zone *zone, 
> 
> 	lru_add_drain();
> 	spin_lock_irq(&zone->lru_lock);
>-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
>+	pgmoved = get_from_active_lists(nr_pages, zone,
> 				    &l_hold, &pgscanned);
> 	zone->pages_scanned += pgscanned;
>-	zone->nr_active -= pgmoved;
>+//	zone->nr_active -= pgmoved;
> 	spin_unlock_irq(&zone->lru_lock);
> 
> 	/*
>  
>

--------------080907060300080304020903
Content-Type: text/x-patch;
 name="linux-cartv3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-cartv3.patch"

diff -Naur /home/rni/linux-cart.v2/include/linux/cart.h linux-cart.v3/include/linux/cart.h
--- /home/rni/linux-cart.v2/include/linux/cart.h	2005-08-16 13:58:49.000000000 -0400
+++ linux-cart.v3/include/linux/cart.h	2005-08-16 14:01:20.000000000 -0400
@@ -7,20 +7,18 @@
 
 #define EVICTED_ACTIVE 		1
 #define EVICTED_LONGTERM 	2
-#define ACTIVE			3
-#define ACTIVE_LONGTERM		4
+#define ACTIVE			4
+#define ACTIVE_LONGTERM		8
 
-#define EvictedActive(location)		location & EVICTED_ACTIVE
-#define EvictedLongterm(location)	location & EVICTED_LONGTERM
-#define Active(location)		location & ACTIVE
-#define ActiveLongterm(location)	location & ACTIVE_LONGTERM
+#define EvictedActive(location)		(location & EVICTED_ACTIVE)
+#define EvictedLongterm(location)	(location & EVICTED_LONGTERM)
+#define Active(location)		(location & ACTIVE)
+#define ActiveLongterm(location)	(location & ACTIVE_LONGTERM)
 
 struct non_res_list_node {
 	struct list_head list;
 	struct list_head hash;
-	unsigned long mapping;
-	unsigned long offset;
-	unsigned long inode;
+	unsigned long hashval;
 };
 
 extern void cart_init();
diff -Naur /home/rni/linux-cart.v2/include/linux/evicted_hash.h linux-cart.v3/include/linux/evicted_hash.h
--- /home/rni/linux-cart.v2/include/linux/evicted_hash.h	2005-08-16 13:58:50.000000000 -0400
+++ linux-cart.v3/include/linux/evicted_hash.h	2005-08-16 14:06:54.000000000 -0400
@@ -3,7 +3,7 @@
 #include <linux/cart.h>
 
 void hashtable_init(struct hashtable *h);
-unsigned long mk_hash(struct page *page);
+unsigned long mk_hash_page(struct page *page);
 unsigned long find_in_hashtable(struct hashtable *h, struct page *page);
 void add_to_hashtable (struct hashtable *, struct non_res_list_node *);
 unsigned long get_inode_num(void *addr);
diff -Naur /home/rni/linux-cart.v2/mm/cart.c linux-cart.v3/mm/cart.c
--- /home/rni/linux-cart.v2/mm/cart.c	2005-08-16 13:58:40.000000000 -0400
+++ linux-cart.v3/mm/cart.c	2005-08-16 14:06:12.000000000 -0400
@@ -67,9 +67,7 @@
 		printk (KERN_EMERG "Couldn't get a non_res_node!\n");
 		return;
 
-	node->offset = page->index;
-	node->mapping = (unsigned long) page->mapping;
-	node->inode = get_inode_num(page->mapping);
+	node->hashval = mk_hash_page(page);
 	
 	list_add(&node->list, l);
 	add_to_hashtable(h, node);
diff -Naur /home/rni/linux-cart.v2/mm/evicted_hash.c linux-cart.v3/mm/evicted_hash.c
--- /home/rni/linux-cart.v2/mm/evicted_hash.c	2005-08-16 13:58:40.000000000 -0400
+++ linux-cart.v3/mm/evicted_hash.c	2005-08-16 14:05:29.000000000 -0400
@@ -34,13 +34,13 @@
 /* The hashing function... a better one is needed */
 static inline unsigned long mk_hash_page(struct page *page)
 {
-        return (((unsigned long)page->mapping ^ page->index) ^ get_inode_num(page->mapping))%HASHTABLE_SIZE;
+        return ((unsigned long)page->mapping ^ page->index) ^ get_inode_num(page->mapping);
 }
 
 /* Hashing for non resident nodes */
 static inline unsigned long mk_hash_non_res(struct non_res_list_node *node)
 {
-	return (node->offset ^ node->mapping ^ node->inode)%HASHTABLE_SIZE;
+	return (node->hashval)%HASHTABLE_SIZE;
 }
 
 /* Search in the hash table */
@@ -49,11 +49,12 @@
         unsigned long index;
         struct non_res_list_node *node;
 	struct list_head *list;
-
-        index = mk_hash_page(page);
+	unsigned long hashval = mk_hash_page(page);
+	
+        index = hashval%HASHTABLE_SIZE;
 
         list_for_each_entry(node, &h->buckets[index], hash) {
-                if (node->mapping == (unsigned long)page->mapping && node->offset == page->index && node->inode == get_inode_num(page->mapping))
+                if (node->hashval == hashval)
                        return 1;
         }
 	

--------------080907060300080304020903
Content-Type: text/x-patch;
 name="linux-cartv3.vanilla.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-cartv3.vanilla.patch"

diff -Naur /home/rni/linux-2.6.12-rc5/include/linux/cart.h linux-cart.v3/include/linux/cart.h
--- /home/rni/linux-2.6.12-rc5/include/linux/cart.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-cart.v3/include/linux/cart.h	2005-08-16 14:01:20.000000000 -0400
@@ -0,0 +1,28 @@
+#ifndef __CART_H__
+#define __CART_H__
+#include <linux/list.h>
+#include <linux/mm.h>
+
+#define MIN_POOL 		512
+
+#define EVICTED_ACTIVE 		1
+#define EVICTED_LONGTERM 	2
+#define ACTIVE			4
+#define ACTIVE_LONGTERM		8
+
+#define EvictedActive(location)		(location & EVICTED_ACTIVE)
+#define EvictedLongterm(location)	(location & EVICTED_LONGTERM)
+#define Active(location)		(location & ACTIVE)
+#define ActiveLongterm(location)	(location & ACTIVE_LONGTERM)
+
+struct non_res_list_node {
+	struct list_head list;
+	struct list_head hash;
+	unsigned long hashval;
+};
+
+extern void cart_init();
+void update_cart_params(struct page *);
+struct page *replace(struct zone *, int *);
+#endif
+
diff -Naur /home/rni/linux-2.6.12-rc5/include/linux/evicted_hash.h linux-cart.v3/include/linux/evicted_hash.h
--- /home/rni/linux-2.6.12-rc5/include/linux/evicted_hash.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-cart.v3/include/linux/evicted_hash.h	2005-08-16 14:06:54.000000000 -0400
@@ -0,0 +1,10 @@
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/cart.h>
+
+void hashtable_init(struct hashtable *h);
+unsigned long mk_hash_page(struct page *page);
+unsigned long find_in_hashtable(struct hashtable *h, struct page *page);
+void add_to_hashtable (struct hashtable *, struct non_res_list_node *);
+unsigned long get_inode_num(void *addr);
+
diff -Naur /home/rni/linux-2.6.12-rc5/include/linux/mm_inline.h linux-cart.v3/include/linux/mm_inline.h
--- /home/rni/linux-2.6.12-rc5/include/linux/mm_inline.h	2005-05-24 23:31:20.000000000 -0400
+++ linux-cart.v3/include/linux/mm_inline.h	2005-08-16 13:59:51.000000000 -0400
@@ -38,3 +38,32 @@
 		zone->nr_inactive--;
 	}
 }
+
+static inline void
+add_page_to_active_list_tail(struct zone *zone, struct page *page)
+{
+	list_add_tail(&page->lru, &zone->active_list);
+	zone->nr_active++;
+}
+
+static inline void
+add_page_to_inactive_list_tail(struct zone *zone, struct page *page)
+{
+        list_add_tail(&page->lru, &zone->inactive_list);
+        zone->nr_inactive++;
+}
+
+static inline void 
+del_page_from_active_longterm(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	zone->nr_active_longterm--;
+}
+
+static inline void
+add_page_to_active_longterm_tail(struct zone *zone, struct page *page)
+{
+	list_add_tail(&page->lru, &zone->active_longterm);
+	zone->nr_active_longterm++;
+}
+
diff -Naur /home/rni/linux-2.6.12-rc5/include/linux/mmzone.h linux-cart.v3/include/linux/mmzone.h
--- /home/rni/linux-2.6.12-rc5/include/linux/mmzone.h	2005-05-24 23:31:20.000000000 -0400
+++ linux-cart.v3/include/linux/mmzone.h	2005-08-16 13:59:50.000000000 -0400
@@ -26,6 +26,18 @@
 	unsigned long		nr_free;
 };
 
+/* A Hashtable for the evicted list entries
+ * This is here, and not in linux/evicted_hash.h
+ * as the hashtable is needed in struct zone, but
+ * the function prototypes for the hash table use 
+ * struct page, which is as yet unrecognised here
+ */
+#define HASHTABLE_SIZE          512
+
+struct hashtable {
+        struct list_head buckets[HASHTABLE_SIZE];
+};
+
 struct pglist_data;
 
 /*
@@ -135,12 +147,24 @@
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
-	struct list_head	active_list;
+	struct list_head	active_list;	/* The T1 list of CART */
+	struct list_head	active_longterm;/* The T2 list of CART */
 	struct list_head	inactive_list;
+	struct list_head	evicted_active;	/* The B1 list of CART */
+	struct list_head	evicted_longterm;/*B2 list of CART */
+	struct hashtable	evicted_active_hashtable;	/*Hash table for evicted active list */
+	struct hashtable 	evicted_longterm_hashtable;	/*Hast table for evicted inactive list */
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
-	unsigned long		nr_active;
+	unsigned long		nr_active;	
+	unsigned long		nr_active_longterm;
 	unsigned long		nr_inactive;
+	unsigned long 		nr_evicted_active;
+	unsigned long 		nr_evicted_longterm;
+	unsigned long 		nr_longterm;	/* number of long term pages */
+	unsigned long 		nr_shortterm;	/* number of short term pages */
+	unsigned long		p;		/* p from the CART paper */
+	unsigned long 		q;		/* q from the cart paper */
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
diff -Naur /home/rni/linux-2.6.12-rc5/include/linux/page-flags.h linux-cart.v3/include/linux/page-flags.h
--- /home/rni/linux-2.6.12-rc5/include/linux/page-flags.h	2005-05-24 23:31:20.000000000 -0400
+++ linux-cart.v3/include/linux/page-flags.h	2005-08-16 13:59:51.000000000 -0400
@@ -58,7 +58,7 @@
 
 #define PG_dirty	 	 4
 #define PG_lru			 5
-#define PG_active		 6
+#define PG_active		 6	
 #define PG_slab			 7	/* slab debug (Suparna wants this) */
 
 #define PG_highmem		 8
@@ -76,6 +76,7 @@
 #define PG_reclaim		18	/* To be reclaimed asap */
 #define PG_nosave_free		19	/* Free, should not be written */
 #define PG_uncached		20	/* Page has been mapped as uncached */
+#define PG_longterm		21	/* Filter bit for CART see mm/cart.c */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -306,6 +307,10 @@
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageLongTerm(page)	test_bit(PG_longterm, &(page)->flags)
+#define SetLongTerm(page)	set_bit(PG_longterm, &(page)->flags)
+#define ClearLongTerm(page)	clear_bit(PG_longterm, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
diff -Naur /home/rni/linux-2.6.12-rc5/init/main.c linux-cart.v3/init/main.c
--- /home/rni/linux-2.6.12-rc5/init/main.c	2005-05-24 23:31:20.000000000 -0400
+++ linux-cart.v3/init/main.c	2005-08-16 13:59:51.000000000 -0400
@@ -52,6 +52,8 @@
 #include <asm/bugs.h>
 #include <asm/setup.h>
 
+#include <linux/cart.h>
+
 /*
  * This is one of the first .c files built. Error out early
  * if we have compiler trouble..
@@ -490,6 +492,7 @@
 	vfs_caches_init_early();
 	mem_init();
 	kmem_cache_init();
+	cart_init();
 	numa_policy_init();
 	if (late_time_init)
 		late_time_init();
diff -Naur /home/rni/linux-2.6.12-rc5/mm/cart.c linux-cart.v3/mm/cart.c
--- /home/rni/linux-2.6.12-rc5/mm/cart.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-cart.v3/mm/cart.c	2005-08-16 14:06:12.000000000 -0400
@@ -0,0 +1,282 @@
+/* Thisfile contains the crux of the CART page replacement algorithm. This implementation however changes a few things form the classic CART scheme. This implementation splits the original active_list of the Linux implementation into two lists, namely active_list and active_longterm. The 'active' pages exist on these two lists. The active_list hopes to capture short term usage, while the active_longterm list hopes to capture long term usage. Whenever a page's state needs to be updated, the update_cart_params() function is called. The refill_incative_zone() function causes the replace() function to be evoked, resulting in the removal of pages from the active lists. Hence, which pages are deemed inactive is determined by the CART algorithm. 
+For further details, please refer to the CART paper here - http://www.almaden.ibm.com/cs/people/dmodha/clockfast.pdf */
+ 
+#include <linux/cart.h>
+#include <linux/mmzone.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/mempool.h>
+#include <linux/page-flags.h>
+#include <linux/evicted_hash.h>
+#include <linux/mm_inline.h>
+
+kmem_cache_t *evicted_node_cache;
+mempool_t *evicted_node_pool;
+
+/* Called from init/main.c to initialize the cart parameters */
+void cart_init()
+{
+	pg_data_t *pgdat;
+	struct zone *zone;
+	int i;
+
+	pgdat = pgdat_list;
+	
+	do {
+		for (i=0;i<MAX_NR_ZONES;++i) {
+			zone = &pgdat->node_zones[i];
+			
+			spin_lock_init(&zone->lru_lock);
+			INIT_LIST_HEAD(&zone->active_list);
+			INIT_LIST_HEAD(&zone->active_longterm);
+			INIT_LIST_HEAD(&zone->inactive_list);
+			INIT_LIST_HEAD(&zone->evicted_active);
+			INIT_LIST_HEAD(&zone->evicted_longterm);
+			
+			hashtable_init(&zone->evicted_active_hashtable);
+			hashtable_init(&zone->evicted_longterm_hashtable);
+
+			zone->nr_active = zone->nr_active_longterm = zone->nr_inactive = zone->nr_evicted_active = zone->nr_evicted_longterm = 0;
+			
+			zone->p = zone->q = zone->nr_longterm = zone->nr_shortterm = 0;
+		}
+	} while ((pgdat = pgdat->pgdat_next));
+
+	/* Create a slab for non resident nodes */
+	evicted_node_cache = kmem_cache_create("EvictedPool", sizeof(struct non_res_list_node), 0, 0, NULL, NULL);
+
+	if (!evicted_node_cache)
+		panic("Could not allocate evicted node cache!\n");
+	
+	/* Create a mempool of preallocated objects */
+	evicted_node_pool = mempool_create(MIN_POOL, mempool_alloc_slab, mempool_free_slab, evicted_node_cache);
+
+	if (!evicted_node_pool)
+		panic("Could not allocate evicted node_pool!\n");
+
+}
+
+/* Add a node to the evicted list specified */
+void add_to_evicted(struct hashtable *h, struct list_head *l, struct page *page)
+{	
+	struct non_res_list_node *node;
+	node = mempool_alloc(evicted_node_pool, GFP_ATOMIC);
+	
+	if (!node)
+		/* This is usually bad news :) */
+		printk (KERN_EMERG "Couldn't get a non_res_node!\n");
+		return;
+
+	node->hashval = mk_hash_page(page);
+	
+	list_add(&node->list, l);
+	add_to_hashtable(h, node);
+}
+
+/* Delete a node form the tail of an evicted list */
+void del_from_evicted_tail(struct list_head *head)
+{
+	struct list_head *list;
+	struct non_res_list_node *node;
+	if(list_empty(head))
+		return;
+	
+	list = head->prev;
+	node = list_entry(list, struct non_res_list_node, list);
+	list_del(list);
+	list_del(&node->hash);
+
+	mempool_free(node, evicted_node_pool);
+}
+
+/* Remove the tail node of the evicted active list */
+void del_from_evicted_active_tail(struct zone *zone)
+{
+	del_from_evicted_tail(&zone->evicted_active);
+}
+
+/* Remove the tail node of the evicted longterm list */
+void del_from_evicted_longterm_tail(struct zone *zone)
+{
+	del_from_evicted_tail(&zone->evicted_longterm);
+}
+
+/* Add a node to the evicted active list */
+void add_to_evicted_active(struct zone *zone, struct page *page)
+{
+	add_to_evicted(&zone->evicted_active_hashtable, &zone->evicted_active, page);
+	++zone->nr_evicted_active;
+}
+
+/* Add a node to the evicted longterm list */
+void add_to_evicted_longterm(struct zone *zone, struct page *page)
+{
+	add_to_evicted(&zone->evicted_longterm_hashtable, &zone->evicted_longterm, page);
+        ++zone->nr_evicted_longterm;
+}
+
+/* Search for a node in the evicted active list */
+unsigned long find_in_evicted_active(struct page *page)
+{
+	struct zone *zone;
+	zone = page_zone(page);
+	return find_in_hashtable(&zone->evicted_active_hashtable, page);
+}
+
+/* Search for a node in the evicted longterm list */
+unsigned long find_in_evicted_longterm(struct page *page)
+{
+	struct zone *zone;
+	zone = page_zone(page);
+	return find_in_hashtable(&zone->evicted_longterm_hashtable, page);
+}
+
+/* Look to see whether a node is in any evicted list */
+unsigned long find_in_evicted_list(struct page *page)
+{
+	if (find_in_evicted_active(page)) 
+		return EVICTED_ACTIVE;
+	if (find_in_evicted_longterm(page))
+		return EVICTED_LONGTERM;
+
+	return 0;
+}
+
+/* The heart of the CART update function. This function is responsible for the movement of pages across the lists */	
+void update_cart_params(struct page *page)
+{
+	unsigned long location;
+	unsigned long evicted_active;
+	unsigned evicted_longterm;
+	struct zone *zone;
+
+	zone = page_zone(page);
+
+	location = find_in_evicted_list(page);
+	evicted_active = EvictedActive(location);
+	evicted_longterm = EvictedLongterm(location);
+	
+	if (evicted_active) {
+		zone->p = min(zone->p + max(zone->nr_shortterm/zone->nr_evicted_active, 1), zone->pages_high);
+
+		++zone->nr_longterm;
+		SetLongTerm(page);
+		ClearPageReferenced(page);
+	}
+	else if (evicted_longterm) {
+		zone->p = max(zone->p - max(1, zone->nr_longterm/zone->nr_evicted_longterm), 0);
+		++zone->nr_longterm;
+		ClearPageReferenced(page);
+
+		if (zone->nr_active_longterm + zone->nr_active + zone->nr_evicted_longterm - zone->nr_shortterm >=zone->pages_high) {
+			zone->q = min(zone->q + 1, 2*zone->pages_high - zone->nr_active);
+		}
+	}
+	else {
+		++zone->nr_shortterm;
+		ClearLongTerm(page);
+	}
+
+	add_page_to_active_list(zone, page);
+}
+
+/* The replace function. This function serches the active and longterm lists and looks for a candidate for replacement. This function selects the candidate and returns the corresponding structpage or returns NULL in case no page can be freed. The *where argument is used to indicate the parent list of the page so that, in case it cannot be written back, it can be placed back on the correct list */
+struct page *replace(struct zone *zone, int *where)
+{
+	struct list_head *list;
+	struct page *page = NULL;
+	int referenced = 0;
+	unsigned long location;
+	int debug_count=0;
+
+	list = &zone->active_longterm;
+	list = list->next;
+	while (list !=&zone->active_longterm) {
+		page = list_entry(list, struct page, lru);
+
+		if (!PageReferenced(page))
+			break;
+		
+		ClearPageReferenced(page);
+		del_page_from_active_longterm(zone, page);
+		add_page_to_active_list_tail(zone, page);
+		
+		if ((zone->nr_active_longterm + zone->nr_active + zone->nr_evicted_longterm - zone->nr_shortterm) >= zone->pages_high)
+			zone->q = min(zone->q + 1, 2*zone->pages_high - zone->nr_active);
+
+		list = &zone->active_longterm;
+		list = list->next;
+		debug_count++;
+	}
+
+	debug_count=0;
+	list = &zone->active_list;
+	list = list->next;
+
+	while (list != &zone->active_list) {
+		page = list_entry(list, struct page, lru);
+		referenced = PageReferenced(page);
+		
+		if (!PageLongTerm(page) && !referenced)
+			break;
+			
+		ClearPageReferenced(page);
+		if (referenced) {
+			del_page_from_active_list(zone, page);
+			add_page_to_active_list_tail(zone, page);
+
+			if (zone->nr_active >= min(zone->p+1, zone->nr_evicted_active) && !PageLongTerm(page)) {
+				SetLongTerm(page);
+				--zone->nr_shortterm;
+				++zone->nr_longterm;
+			}
+		}
+		else {
+			del_page_from_active_list(zone, page);
+			add_page_to_active_longterm_tail(zone, page);
+
+			zone->q = max(zone->q-1, zone->pages_high - zone->nr_active);
+		}
+
+		list = &zone->active_list;
+		list = list->next;
+		debug_count++;
+	}
+
+	page = NULL;
+	
+	if (zone->nr_active > max(1, zone->p)) {
+		if (!list_empty(&zone->active_list)) {
+			page = list_entry(zone->active_list.next, struct page, lru);
+			del_page_from_active_list(zone, page);
+			add_to_evicted_active(zone, page);
+			*where = ACTIVE;
+		}
+	}
+	else {
+		if (!list_empty(&zone->active_longterm)) {
+			page = list_entry(zone->active_longterm.next, struct page, lru);
+			del_page_from_active_longterm(zone, page);
+			--zone->nr_longterm;
+			add_to_evicted_longterm(zone, page);
+			*where = ACTIVE_LONGTERM;
+		}
+	}
+
+	if (!page)
+		return NULL;
+
+	if (*where == 0)
+		BUG();
+
+	location = find_in_evicted_list(page);
+
+	if (!location && (zone->nr_evicted_active + zone->nr_evicted_longterm == zone->pages_high+1) && ((zone->nr_evicted_active > max(0, zone->q) ||zone->nr_evicted_longterm == 0))) {
+		del_from_evicted_active_tail(zone);
+	}
+	else if (!location && (zone->nr_evicted_active + zone->nr_evicted_longterm == zone->pages_high + 1))
+		del_from_evicted_longterm_tail(zone);
+
+	return page;
+}
+
diff -Naur /home/rni/linux-2.6.12-rc5/mm/evicted_hash.c linux-cart.v3/mm/evicted_hash.c
--- /home/rni/linux-2.6.12-rc5/mm/evicted_hash.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-cart.v3/mm/evicted_hash.c	2005-08-16 14:05:29.000000000 -0400
@@ -0,0 +1,73 @@
+/* This file contains the functions required to manage the evicted list hash table. The evicted nodes are maintained as a couple of lists, but the hash table is used for speedy lookup */
+
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/cart.h>
+
+/* Initialize the hashtable */
+void hashtable_init(struct hashtable *h)
+{
+	int i;
+
+	for (i=0;i<HASHTABLE_SIZE;++i) {
+		INIT_LIST_HEAD(&h->buckets[i]);
+	}
+}
+
+/* Get the inode number of a page if it is file backed, return 0 if it is anonymous */
+unsigned long get_inode_num(void *addr)
+{
+	struct address_space *p;
+
+	if (!addr)
+		return 0;
+
+	/* If lower bit is set, then it is a anon_vma object */
+	if (((unsigned long)addr) & 0x1)
+		return 0;
+
+	p = (struct address_space *)addr;
+
+	return p->host->i_ino;
+}
+
+/* The hashing function... a better one is needed */
+static inline unsigned long mk_hash_page(struct page *page)
+{
+        return ((unsigned long)page->mapping ^ page->index) ^ get_inode_num(page->mapping);
+}
+
+/* Hashing for non resident nodes */
+static inline unsigned long mk_hash_non_res(struct non_res_list_node *node)
+{
+	return (node->hashval)%HASHTABLE_SIZE;
+}
+
+/* Search in the hash table */
+unsigned long find_in_hashtable(struct hashtable *h, struct page *page)
+{
+        unsigned long index;
+        struct non_res_list_node *node;
+	struct list_head *list;
+	unsigned long hashval = mk_hash_page(page);
+	
+        index = hashval%HASHTABLE_SIZE;
+
+        list_for_each_entry(node, &h->buckets[index], hash) {
+                if (node->hashval == hashval)
+                       return 1;
+        }
+	
+	return 0;
+}
+
+/* Add a node to the hash table */
+void add_to_hashtable(struct hashtable *h, struct non_res_list_node *node)
+{
+	unsigned long index;
+
+        index = mk_hash_non_res(node);
+
+	list_add(&node->hash, &h->buckets[index]);
+}
+
diff -Naur /home/rni/linux-2.6.12-rc5/mm/filemap.c linux-cart.v3/mm/filemap.c
--- /home/rni/linux-2.6.12-rc5/mm/filemap.c	2005-05-24 23:31:20.000000000 -0400
+++ linux-cart.v3/mm/filemap.c	2005-08-16 13:59:51.000000000 -0400
@@ -107,7 +107,6 @@
 void __remove_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
-
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
diff -Naur /home/rni/linux-2.6.12-rc5/mm/Makefile linux-cart.v3/mm/Makefile
--- /home/rni/linux-2.6.12-rc5/mm/Makefile	2005-05-24 23:31:20.000000000 -0400
+++ linux-cart.v3/mm/Makefile	2005-08-16 13:59:51.000000000 -0400
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o
+			   vmalloc.o cart.o evicted_hash.o
 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   page_alloc.o page-writeback.o pdflush.o \
diff -Naur /home/rni/linux-2.6.12-rc5/mm/swap.c linux-cart.v3/mm/swap.c
--- /home/rni/linux-2.6.12-rc5/mm/swap.c	2005-05-24 23:31:20.000000000 -0400
+++ linux-cart.v3/mm/swap.c	2005-08-16 13:59:51.000000000 -0400
@@ -30,6 +30,7 @@
 #include <linux/cpu.h>
 #include <linux/notifier.h>
 #include <linux/init.h>
+#include <linux/cart.h>
 
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
@@ -107,7 +108,7 @@
 	if (PageLRU(page) && !PageActive(page)) {
 		del_page_from_inactive_list(zone, page);
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		update_cart_params(page);
 		inc_page_state(pgactivate);
 	}
 	spin_unlock_irq(&zone->lru_lock);
@@ -124,7 +125,6 @@
 {
 	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
 		activate_page(page);
-		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
diff -Naur /home/rni/linux-2.6.12-rc5/mm/vmscan.c linux-cart.v3/mm/vmscan.c
--- /home/rni/linux-2.6.12-rc5/mm/vmscan.c	2005-05-24 23:31:20.000000000 -0400
+++ linux-cart.v3/mm/vmscan.c	2005-08-16 13:59:51.000000000 -0400
@@ -38,6 +38,7 @@
 #include <asm/div64.h>
 
 #include <linux/swapops.h>
+#include <linux/cart.h>
 
 /* possible outcome of pageout() */
 typedef enum {
@@ -545,6 +546,50 @@
 	return reclaimed;
 }
 
+/* This gets a page from the active_list and active_longterm lists in order to add to the incative list */
+static int get_from_active_lists(int nr_to_scan, struct zone *zone, struct list_head *dst, int *scanned)
+{
+        int nr_taken = 0;
+        struct page *page;
+        int scan = 0;
+	int location;
+
+        while (scan++ < nr_to_scan) {
+		location = 0;
+                page = replace(zone, &location);
+	
+		if (!page)
+			break;
+
+                if (!TestClearPageLRU(page)) {
+                        BUG();
+		}
+
+		if (!location)
+			BUG();
+	
+                if (get_page_testone(page)) {
+                        /*
+                         * It is being freed elsewhere
+                         */
+                        __put_page(page);
+                        SetPageLRU(page);
+        		
+			if (Active(location))
+				add_page_to_active_list_tail(zone, page);
+			else
+				add_page_to_active_longterm_tail(zone, page); 
+                        continue;
+                } else {
+                        list_add(&page->lru, dst);
+                        nr_taken++;
+                }
+        }
+
+        *scanned = scan;
+        return nr_taken;
+}
+	
 /*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
@@ -695,10 +740,10 @@
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
+	pgmoved = get_from_active_lists(nr_pages, zone,
 				    &l_hold, &pgscanned);
 	zone->pages_scanned += pgscanned;
-	zone->nr_active -= pgmoved;
+//	zone->nr_active -= pgmoved;
 	spin_unlock_irq(&zone->lru_lock);
 
 	/*

--------------080907060300080304020903
Content-Type: text/x-patch;
 name="linux-cartv3.partial.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-cartv3.partial.patch"

diff -Naur /home/rni/linux-cart.v2/include/linux/cart.h linux-cart.v3/include/linux/cart.h
--- /home/rni/linux-cart.v2/include/linux/cart.h	2005-08-16 13:58:49.000000000 -0400
+++ linux-cart.v3/include/linux/cart.h	2005-08-16 14:01:20.000000000 -0400
@@ -7,20 +7,18 @@
 
 #define EVICTED_ACTIVE 		1
 #define EVICTED_LONGTERM 	2
-#define ACTIVE			3
-#define ACTIVE_LONGTERM		4
+#define ACTIVE			4
+#define ACTIVE_LONGTERM		8
 
-#define EvictedActive(location)		location & EVICTED_ACTIVE
-#define EvictedLongterm(location)	location & EVICTED_LONGTERM
-#define Active(location)		location & ACTIVE
-#define ActiveLongterm(location)	location & ACTIVE_LONGTERM
+#define EvictedActive(location)		(location & EVICTED_ACTIVE)
+#define EvictedLongterm(location)	(location & EVICTED_LONGTERM)
+#define Active(location)		(location & ACTIVE)
+#define ActiveLongterm(location)	(location & ACTIVE_LONGTERM)
 

--------------080907060300080304020903--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
