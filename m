From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:42:52 +0200
Message-Id: <20060712144252.16998.79748.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 30/39] mm: clockpro: CLOCK-Pro policy implementation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

This patch implememnts an approximation to the CLOCKPro page replace
algorithm presented in:
  http://www.cs.wm.edu/hpcs/WWW/HTML/publications/abs05-3.html

<insert rant on coolness and some numbers that prove it/>

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_clockpro_data.h     |   21 
 include/linux/mm_clockpro_policy.h   |  139 ++++++
 include/linux/mm_page_replace.h      |    2 
 include/linux/mm_page_replace_data.h |    2 
 mm/Kconfig                           |    5 
 mm/Makefile                          |    1 
 mm/clockpro.c                        |  759 +++++++++++++++++++++++++++++++++++
 7 files changed, 929 insertions(+)

Index: linux-2.6/mm/clockpro.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/clockpro.c	2006-07-12 16:11:22.000000000 +0200
@@ -0,0 +1,759 @@
+/*
+ * mm/clockpro.c
+ *
+ * Written by Peter Zijlstra <a.p.zijlstra@chello.nl>
+ * Released under the GPLv2, see the file COPYING for details.
+ *
+ * This file implements an approximation to the CLOCKPro page replace
+ * algorithm presented in:
+ *   http://www.cs.wm.edu/hpcs/WWW/HTML/publications/abs05-3.html
+ *
+ * ===> The Algorithm <===
+ *
+ * This algorithm strifes to separate the pages with a small reuse distance
+ * from those with a large reuse distance. Pages with a small reuse distance
+ * are called hot pages and are not available for reclaim. Cold pages are those
+ * that have a large reuse distance. In order to track the reuse distance a
+ * test period is started when a reference is detected. When another reference
+ * is detected during this test period the page has a small enough reuse
+ * distance to be classified as hot.
+ *
+ * The test period is terminated when the page would get a larger reuse
+ * distance than the current largest hot page. This is directly coupled to the
+ * cold page target - the target number of cold pages. More cold pages
+ * mean fewer hot pages and hence the test period will be shorter.
+ *
+ * The cold page target is adjusted when a test period expires (dec) or when
+ * a page is referenced during its test period (inc).
+ *
+ * If we faulted in a nonresident page that is still in the test period, the
+ * inter-reference distance of that page is by definition smaller than that of
+ * the coldest page on the hot list. Meaning the hot list contains pages that
+ * are colder than at least one page that got evicted from memory, and the hot
+ * list should be smaller - conversely, the cold list should be larger.
+ *
+ * Since it is very likely that pages that are about to be evicted are still in
+ * their test period, their state has to be kept around until it expires, or
+ * the total number of pages tracks is twice the total of resident pages.
+ *
+ * The data-structre used is a single CLOCK with three hands: Hcold, Hhot and
+ * Htest. The dynamic is thusly: Hcold is rotated to look for unreferenced cold
+ * pages - those can be evicted. When Hcold encounters a referenced page it
+ * either starts a test period or promotes the page to hot if it already was in
+ * its test period. Then if there are less cold pages left than targeted, Hhot
+ * is rotated which will demote unreferenced hot pages. Hhot also terminates
+ * the test period of all cold pages it encounters. Then if after all this
+ * there are more nonresident pages tracked than there are resident pages,
+ * Htest will be rotated. Htest terminates all test periods it encounters,
+ * thereby removing nonresident pages. (Htest is pushed by Hhot - Hcold moves
+ * independently)
+ *
+ *        res | h/c | tst | ref || Hcold  |  Hhot  | Htest  || Flt
+ *        ----+-----+-----+-----++--------+--------+--------++-----
+ *         1  |  1  |  0  |  1  || = 1101 |   1100 | = 1101 ||
+ *         1  |  1  |  0  |  0  || = 1100 |   1000 | = 1100 ||
+ *        ----+-----+-----+-----++--------+--------+--------++-----
+ *         1  |  0  |  1  |  1  ||   1100 |   1001 |   1001 ||
+ *         1  |  0  |  1  |  0  || N 0010 |   1000 |   1000 ||
+ *         1  |  0  |  0  |  1  ||   1010 | = 1001 | = 1001 ||
+ *         1  |  0  |  0  |  0  || X 0000 | = 1000 | = 1000 ||
+ *        ----+-----+-----+-----++--------+--------+--------++-----
+ *        ----+-----+-----+-----++--------+--------+--------++-----
+ *         0  |  0  |  1  |  1  ||        |        |        || 1100
+ *         0  |  0  |  1  |  0  || = 0010 | X 0000 | X 0000 ||
+ *         0  |  0  |  0  |  1  ||        |        |        || 1010
+ *
+ * The table gives the state transitions for each hand, '=' denotes no change,
+ * 'N' denotes becomes nonresident and 'X' denotes removal.
+ *
+ * (XXX: mention LIRS hot/cold page swapping which makes for the relocation on
+ *  promotion/demotion)
+ *
+ * ===> The Approximation <===
+ *
+ * h/c -> PageHot()
+ * tst -> PageTest()
+ * ref -> page_referenced()
+ *
+ * Because pages can be evicted from one zone and paged back into another,
+ * nonresident page tracking needs to be inter-zone whereas resident page
+ * tracking is per definition per zone. Hence the resident and nonresident
+ * page tracking needs to be separated.
+ *
+ * This is accomplished by using two CLOCKs instead of one. One two handed
+ * CLOCK for the resident pages, and one single handed CLOCK for the
+ * nonresident pages. These CLOCKs are then coupled so that one can be seen
+ * as an overlay on the other - thereby approximating the relative order of
+ * the pages.
+ *
+ * The resident CLOCK has, as mentioned, two hands, one is Hcold (it does not
+ * affect nonresident pages) and the other is the resident part of Hhot.
+ *
+ * The nonresident CLOCK's single hand will be the nonresident part of Hhot.
+ * Htest is replaced by limiting the size of the nonresident CLOCK.
+ *
+ * The Hhot parts are coupled so that when all resident Hhot have made a full
+ * revolution so will the nonresident Hhot.
+ *
+ * (XXX: mention use-once, the two list/single list duality)
+ * TODO: numa
+ *
+ * All functions that are prefixed with '__' assume that zone->lru_lock is taken.
+ */
+
+#include <linux/mm_page_replace.h>
+#include <linux/rmap.h>
+#include <linux/buffer_head.h>
+#include <linux/pagevec.h>
+#include <linux/bootmem.h>
+#include <linux/init.h>
+#include <linux/swap.h>
+#include <linux/module.h>
+#include <linux/percpu.h>
+#include <linux/writeback.h>
+
+#include <asm/div64.h>
+
+#include <linux/nonresident.h>
+
+/* The nonresident code can be seen as a single handed clock that
+ * lacks the ability to remove tail pages. However it can report the
+ * distance to the head.
+ *
+ * What is done is to set a threshold that cuts of the clock tail.
+ */
+static DEFINE_PER_CPU(unsigned long, nonres_cutoff) = 0;
+
+/* Keep track of the number of nonresident pages tracked.
+ * This is used to scale the hand hot vs nonres hand rotation.
+ */
+static DEFINE_PER_CPU(unsigned long, nonres_count) = 0;
+
+static inline unsigned long __nonres_cutoff(void)
+{
+	return __sum_cpu_var(unsigned long, nonres_cutoff);
+}
+
+static inline unsigned long __nonres_count(void)
+{
+	return __sum_cpu_var(unsigned long, nonres_count);
+}
+
+static inline unsigned long __nonres_threshold(void)
+{
+	unsigned long cutoff = __nonres_cutoff() / 2;
+	unsigned long count = __nonres_count();
+
+	if (cutoff > count)
+		return 0;
+
+	return count - cutoff;
+}
+
+static void __nonres_cutoff_inc(unsigned long dt)
+{
+	unsigned long count = __nonres_count() * 2;
+	unsigned long cutoff = __nonres_cutoff();
+	if (cutoff < count - dt)
+		__get_cpu_var(nonres_cutoff) += dt;
+	else
+		__get_cpu_var(nonres_cutoff) += count - cutoff;
+}
+
+static void __nonres_cutoff_dec(unsigned long dt)
+{
+	unsigned long cutoff = __nonres_cutoff();
+	if (cutoff > dt)
+		__get_cpu_var(nonres_cutoff) -= dt;
+	else
+		__get_cpu_var(nonres_cutoff) -= cutoff;
+}
+
+static int nonres_get(struct address_space *mapping, unsigned long index)
+{
+	int found = 0;
+	unsigned long distance = nonresident_get(mapping, index);
+	if (distance != ~0UL) { /* valid page */
+		--__get_cpu_var(nonres_count);
+
+		/* If the distance is below the threshold the test
+		 * period is still valid. Otherwise a tail page
+		 * was found and we can decrease the the cutoff.
+		 *
+		 * Even if not found the hole introduced by the removal
+		 * of the cookie increases the avg. distance by 1/2.
+		 *
+		 * NOTE: the cold target was adjusted when the threshold
+		 * was decreased.
+		 */
+		found = distance < __nonres_cutoff();
+		__nonres_cutoff_dec(1 + !!found);
+	}
+
+	return found;
+}
+
+static int nonres_put(struct address_space *mapping, unsigned long index)
+{
+	if (nonresident_put(mapping, index)) {
+		/* nonresident clock eats tail due to limited
+		 * size; hand test equivalent.
+		 */
+		__nonres_cutoff_dec(2);
+		return 1;
+	}
+
+	++__get_cpu_var(nonres_count);
+	return 0;
+}
+
+static inline void nonres_rotate(unsigned long nr)
+{
+	__nonres_cutoff_inc(nr * 2);
+}
+
+static inline unsigned long nonres_count(void)
+{
+	return __nonres_threshold();
+}
+
+void __init pgrep_init(void)
+{
+	nonresident_init();
+}
+
+/* Called to initialize the clockpro parameters */
+void __init pgrep_init_zone(struct zone *zone)
+{
+	INIT_LIST_HEAD(&zone->policy.list_hand[0]);
+	INIT_LIST_HEAD(&zone->policy.list_hand[1]);
+	zone->policy.nr_resident = 0;
+	zone->policy.nr_cold = 0;
+	zone->policy.nr_cold_target = 2*zone->pages_high;
+	zone->policy.nr_nonresident_scale = 0;
+}
+
+/*
+ * Increase the cold pages target; limit it to the total number of resident
+ * pages present in the current zone.
+ *
+ * @zone: current zone
+ * @dct: intended increase
+ */
+static void __cold_target_inc(struct zone *zone, unsigned long dct)
+{
+	if (zone->policy.nr_cold_target < zone->policy.nr_resident - dct)
+		zone->policy.nr_cold_target += dct;
+	else
+		zone->policy.nr_cold_target = zone->policy.nr_resident;
+}
+
+/*
+ * Decrease the cold pages target; limit it to the high watermark in order
+ * to always have some pages available for quick reclaim.
+ *
+ * @zone: current zone
+ * @dct: intended decrease
+ */
+static void __cold_target_dec(struct zone *zone, unsigned long dct)
+{
+	if (zone->policy.nr_cold_target > (2*zone->pages_high) + dct)
+		zone->policy.nr_cold_target -= dct;
+	else
+		zone->policy.nr_cold_target = (2*zone->pages_high);
+}
+
+/*
+ * Instead of a single CLOCK with two hands, two lists are used.
+ * When the two lists are laid head to tail two junction points
+ * appear, these points are the hand positions.
+ *
+ * This approach has the advantage that there is no pointer magic
+ * associated with the hands. It is impossible to remove the page
+ * a hand is pointing to.
+ *
+ * To allow the hands to lap each other the lists are swappable; eg.
+ * when the hands point to the same position, one of the lists has to
+ * be empty - however it does not matter which list is. Hence we make
+ * sure that the hand we are going to work on contains the pages.
+ */
+static inline
+void __select_list_hand(struct zone *zone, struct list_head *list)
+{
+	if (list_empty(list)) {
+		LIST_HEAD(tmp);
+		list_splice_init(&zone->policy.list_hand[0], &tmp);
+		list_splice_init(&zone->policy.list_hand[1],
+				 &zone->policy.list_hand[0]);
+		list_splice(&tmp, &zone->policy.list_hand[1]);
+	}
+}
+
+static DEFINE_PER_CPU(struct pagevec, clockpro_add_pvecs) = { 0, };
+
+/*
+ * Insert page into @zones clock and update adaptive parameters.
+ *
+ * Several page flags are used for insertion hints:
+ *  PG_test - use the use-once logic
+ *
+ * For now we will ignore the active hint; the use once logic is
+ * explained below.
+ *
+ * @zone: target zone.
+ * @page: new page.
+ */
+void __pgrep_add(struct zone *zone, struct page *page)
+{
+	int found = 0;
+	struct address_space *mapping = page_mapping(page);
+	int hand = HAND_HOT;
+
+	if (mapping)
+		found = nonres_get(mapping, page_index(page));
+
+#if 0
+	/* prefill the hot list */
+	if (zone->free_pages > zone->policy.nr_cold_target) {
+		SetPageHot(page);
+		hand = HAND_COLD;
+	} else
+#endif
+	/* abuse the PG_test flag for pagecache use-once */
+	if (PageTest(page)) {
+		/*
+		 * Use-Once insert; we want to avoid activation on the first
+		 * reference (which we know will come).
+		 *
+		 * This is accomplished by inserting the page one state lower
+		 * than usual so the activation that does come ups it to the
+		 * normal insert state. Also we insert right behind Hhot so
+		 * 1) Hhot cannot interfere; and 2) we lose the first reference
+		 * quicker.
+		 *
+		 * Insert (cold,test)/(cold) so the following activation will
+		 * elevate the state to (hot)/(cold,test). (NOTE: the activation
+		 * will take care of the cold target increment).
+		 */
+		if (!found)
+			ClearPageTest(page);
+		++zone->policy.nr_cold;
+		hand = HAND_COLD;
+	} else {
+		/*
+		 * Insert (hot) when found in the nonresident list, otherwise
+		 * insert as (cold,test). Insert at the head of the Hhot list,
+		 * ie. right behind Hcold.
+		 */
+		if (found) {
+			SetPageHot(page);
+			__cold_target_inc(zone, 1);
+			hand = HAND_COLD;
+		} else {
+			SetPageTest(page);
+			++zone->policy.nr_cold;
+		}
+	}
+	++zone->policy.nr_resident;
+	list_add(&page->lru, &zone->policy.list_hand[hand]);
+
+	BUG_ON(!PageLRU(page));
+}
+
+void fastcall pgrep_add(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(clockpro_add_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_pgrep_add(pvec);
+	put_cpu_var(clockpro_add_pvecs);
+}
+
+void __pgrep_add_drain(unsigned int cpu)
+{
+	struct pagevec *pvec = &per_cpu(clockpro_add_pvecs, cpu);
+
+	if (pagevec_count(pvec))
+		__pagevec_pgrep_add(pvec);
+}
+
+/*
+ * Add page to a release pagevec, temp. drop zone lock to release pagevec if full.
+ * Set PG_lru, update zone->policy.nr_cold and zone->policy.nr_resident.
+ *
+ * @zone: @pages zone.
+ * @page: page to be released.
+ * @pvec: pagevec to collect pages in.
+ */
+static void __page_release(struct zone *zone, struct page *page,
+			   struct pagevec *pvec)
+{
+	BUG_ON(PageLRU(page));
+	SetPageLRU(page);
+	if (!PageHot(page))
+		++zone->policy.nr_cold;
+	++zone->policy.nr_resident;
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
+		struct list_head *list;
+		struct zone *pagezone = page_zone(page);
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		if (PageHot(page))
+			list = &zone->policy.list_hand[HAND_COLD];
+		else
+			list = &zone->policy.list_hand[HAND_HOT];
+		list_move(&page->lru, list);
+		__page_release(zone, page, &pvec);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	pagevec_release(&pvec);
+}
+
+/*
+ * Try to reclaim a specified number of pages.
+ *
+ * Reclaim cadidates have:
+ *  - PG_lru cleared
+ *  - 1 extra ref
+ *
+ * NOTE: hot pages are also returned but will be spit back by try_pageout()
+ *       this to preserve CLOCK order.
+ *
+ * @zone: target zone to reclaim pages from.
+ * @nr_to_scan: nr of pages to try for reclaim.
+ * @page_list: list to put the pages on.
+ * @nr_scanned: number of pages scanned.
+ */
+void __pgrep_get_candidates(struct zone *zone, int priority,
+		unsigned long nr_to_scan, struct list_head *page_list,
+		unsigned long *nr_scanned)
+{
+	unsigned long nr_scan, nr_total_scan = 0;
+	unsigned long nr_cold_prio;
+	int nr_taken;
+
+	do {
+		__select_list_hand(zone, &zone->policy.list_hand[HAND_COLD]);
+		nr_taken = isolate_lru_pages(zone, nr_to_scan,
+				&zone->policy.list_hand[HAND_COLD],
+				page_list, &nr_scan);
+		nr_to_scan -= nr_scan;
+		nr_total_scan += nr_scan;
+	} while (nr_to_scan > 0 && nr_taken);
+
+	*nr_scanned = nr_total_scan;
+
+	/*
+	 * Artificially increase the cold target when the priority rises
+	 * so we have enough pages to reclaim.
+	 */
+	if (priority <= DEF_PRIORITY/2) {
+		nr_cold_prio =
+			(zone->policy.nr_resident - zone->policy.nr_cold) >>
+			priority;
+		__cold_target_inc(zone, nr_cold_prio);
+	}
+
+}
+
+static void rotate_hot(struct zone *, int, int, struct pagevec *);
+
+/*
+ * Reinsert those candidate pages that were not freed in shrink_list().
+ * Account pages that were promoted to hot by pgrep_activate().
+ * Rotate hand hot to balance the new hot and lost cold pages vs.
+ * the cold pages target.
+ *
+ * Candidate pages have:
+ *  - PG_lru cleared
+ *  - 1 extra ref
+ * undo that.
+ *
+ * @zone: zone we're working on.
+ * @page_list: the left over pages.
+ * @nr_freed: number of pages freed by shrink_list()
+ */
+void pgrep_put_candidates(struct zone *zone, struct list_head *page_list,
+	       unsigned long nr_freed, int may_swap)
+{
+	struct pagevec pvec;
+	unsigned long dct = 0;
+
+	pagevec_init(&pvec, 1);
+	spin_lock_irq(&zone->lru_lock);
+	while (!list_empty(page_list)) {
+		int hand = HAND_HOT;
+		struct page *page = lru_to_page(page_list);
+		prefetchw_prev_lru_page(page, page_list, flags);
+
+		if (PageHot(page) && PageTest(page)) {
+			ClearPageTest(page);
+			++dct;
+			hand = HAND_COLD; /* relocate promoted pages */
+		}
+
+		list_move(&page->lru, &zone->policy.list_hand[hand]);
+		__page_release(zone, page, &pvec);
+	}
+	__cold_target_inc(zone, dct);
+	spin_unlock_irq(&zone->lru_lock);
+
+	/*
+	 * Limit the hot hand to half a revolution.
+	 */
+	if (zone->policy.nr_cold < zone->policy.nr_cold_target) {
+		int i, nr = 1 + (zone->policy.nr_resident / 2*SWAP_CLUSTER_MAX);
+		int reclaim_mapped = 0; /* should_reclaim_mapped(zone); */
+		for (i = 0; zone->policy.nr_cold < zone->policy.nr_cold_target &&
+		     i < nr; ++i)
+			rotate_hot(zone, SWAP_CLUSTER_MAX, reclaim_mapped, &pvec);
+	}
+
+	pagevec_release(&pvec);
+}
+
+/*
+ * Puts cold pages that have their test bit set on the non-resident lists.
+ *
+ * @zone: dead pages zone.
+ * @page: dead page.
+ */
+void pgrep_remember(struct zone *zone, struct page *page)
+{
+	if (PageTest(page) &&
+	    nonres_put(page_mapping(page), page_index(page)))
+			__cold_target_dec(zone, 1);
+}
+
+void pgrep_forget(struct address_space *mapping, unsigned long index)
+{
+	nonres_get(mapping, index);
+}
+
+static unsigned long estimate_pageable_memory(void)
+{
+#if 0
+	static unsigned long next_check;
+	static unsigned long total = 0;
+
+	if (!total || time_after(jiffies, next_check)) {
+		struct zone *z;
+		total = 0;
+		for_each_zone(z)
+			total += z->nr_resident;
+		next_check = jiffies + HZ/10;
+	}
+
+	// gave 0 first time, SIGFPE in kernel sucks
+	// hence the !total
+#else
+	unsigned long total = 0;
+	struct zone *z;
+	for_each_zone(z)
+		total += z->policy.nr_resident;
+#endif
+	return total;
+}
+
+/*
+ * Rotate the non-resident hand; scale the rotation speed so that when all
+ * hot hands have made one full revolution the non-resident hand will have
+ * too.
+ *
+ * @zone: current zone
+ * @dh: number of pages the hot hand has moved
+ */
+static void __nonres_term(struct zone *zone, unsigned long dh)
+{
+	unsigned long long cycles;
+	unsigned long nr_count = nonres_count();
+
+	/*
+	 *         |n1| Rhot     |N| Rhot
+	 * Nhot = ----------- ~ ----------
+	 *           |r1|           |R|
+	 *
+	 * NOTE depends on |N|, hence use the nonresident_forget() hook.
+	 */
+	cycles = zone->policy.nr_nonresident_scale + 1ULL * dh * nr_count;
+	zone->policy.nr_nonresident_scale =
+		do_div(cycles, estimate_pageable_memory() + 1UL);
+	nonres_rotate(cycles);
+	__cold_target_dec(zone, cycles);
+}
+
+/*
+ * Rotate hand hot;
+ *
+ * @zone: current zone
+ * @nr_to_scan: batch quanta
+ * @reclaim_mapped: whether to demote mapped pages too
+ * @pvec: release pagevec
+ */
+static void rotate_hot(struct zone *zone, int nr_to_scan, int reclaim_mapped,
+		       struct pagevec *pvec)
+{
+	LIST_HEAD(l_hold);
+	LIST_HEAD(l_tmp);
+	unsigned long dh = 0, dct = 0;
+	unsigned long pgscanned;
+	int pgdeactivate = 0;
+	int nr_taken;
+
+	spin_lock_irq(&zone->lru_lock);
+	__select_list_hand(zone, &zone->policy.list_hand[HAND_HOT]);
+	nr_taken = isolate_lru_pages(zone, nr_to_scan,
+				 &zone->policy.list_hand[HAND_HOT],
+				 &l_hold, &pgscanned);
+	spin_unlock_irq(&zone->lru_lock);
+
+	while (!list_empty(&l_hold)) {
+		struct page *page = lru_to_page(&l_hold);
+		prefetchw_prev_lru_page(page, &l_hold, flags);
+
+		if (PageHot(page)) {
+			BUG_ON(PageTest(page));
+
+			/*
+			 * Ignore the swap token; this is not actual reclaim
+			 * and it will give a better reflection of the actual
+			 * hotness of pages.
+			 *
+			 * XXX do something with this reclaim_mapped stuff.
+			 */
+			if (/*(((reclaim_mapped && mapped) || !mapped) ||
+			     (total_swap_pages == 0 && PageAnon(page))) && */
+			    !page_referenced(page, 0, 1)) {
+				SetPageTest(page);
+				++pgdeactivate;
+			}
+
+			++dh;
+		} else {
+			if (PageTest(page)) {
+				ClearPageTest(page);
+				++dct;
+			}
+		}
+		list_move(&page->lru, &l_tmp);
+
+		cond_resched();
+	}
+
+	spin_lock_irq(&zone->lru_lock);
+	while (!list_empty(&l_tmp)) {
+		int hand = HAND_COLD;
+		struct page *page = lru_to_page(&l_tmp);
+		prefetchw_prev_lru_page(page, &l_tmp, flags);
+
+		if (PageHot(page) && PageTest(page)) {
+			ClearPageHot(page);
+			ClearPageTest(page);
+			hand = HAND_HOT; /* relocate demoted page */
+		}
+
+		list_move(&page->lru, &zone->policy.list_hand[hand]);
+		__page_release(zone, page, pvec);
+	}
+	__nonres_term(zone, nr_taken);
+	__cold_target_dec(zone, dct);
+	spin_unlock(&zone->lru_lock);
+
+	__mod_page_state_zone(zone, pgrefill, pgscanned);
+	__mod_page_state(pgdeactivate, pgdeactivate);
+
+	local_irq_enable();
+}
+
+#define K(x) ((x) << (PAGE_SHIFT-10))
+
+void pgrep_show(struct zone *zone)
+{
+	printk("%s"
+	       " free:%lukB"
+	       " min:%lukB"
+	       " low:%lukB"
+	       " high:%lukB"
+	       " resident:%lukB"
+	       " cold:%lukB"
+	       " present:%lukB"
+	       " pages_scanned:%lu"
+	       " all_unreclaimable? %s"
+	       "\n",
+	       zone->name,
+	       K(zone->free_pages),
+	       K(zone->pages_min),
+	       K(zone->pages_low),
+	       K(zone->pages_high),
+	       K(zone->policy.nr_resident),
+	       K(zone->policy.nr_cold),
+	       K(zone->present_pages),
+	       zone->pages_scanned,
+	       (zone->all_unreclaimable ? "yes" : "no")
+	      );
+}
+
+void pgrep_zoneinfo(struct zone *zone, struct seq_file *m)
+{
+	seq_printf(m,
+		   "\n  pages free     %lu"
+		   "\n        min      %lu"
+		   "\n        low      %lu"
+		   "\n        high     %lu"
+		   "\n        resident %lu"
+		   "\n        cold     %lu"
+		   "\n        cold_tar %lu"
+		   "\n        nr_count %lu"
+		   "\n        scanned  %lu"
+		   "\n        spanned  %lu"
+		   "\n        present  %lu",
+		   zone->free_pages,
+		   zone->pages_min,
+		   zone->pages_low,
+		   zone->pages_high,
+		   zone->policy.nr_resident,
+		   zone->policy.nr_cold,
+		   zone->policy.nr_cold_target,
+		   nonres_count(),
+		   zone->pages_scanned,
+		   zone->spanned_pages,
+		   zone->present_pages);
+}
+
+void __pgrep_counts(unsigned long *active, unsigned long *inactive,
+			   unsigned long *free, struct zone *zones)
+{
+	int i;
+
+	*active = 0;
+	*inactive = 0;
+	*free = 0;
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		*active += zones[i].policy.nr_resident - zones[i].policy.nr_cold;
+		*inactive += zones[i].policy.nr_cold;
+		*free += zones[i].free_pages;
+	}
+}
Index: linux-2.6/include/linux/mm_clockpro_data.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mm_clockpro_data.h	2006-07-12 16:09:19.000000000 +0200
@@ -0,0 +1,21 @@
+#ifndef _LINUX_CLOCKPRO_DATA_H_
+#define _LINUX_CLOCKPRO_DATA_H_
+
+#ifdef __KERNEL__
+
+enum {
+	HAND_HOT = 0,
+	HAND_COLD = 1
+};
+
+struct pgrep_data {
+	struct list_head        list_hand[2];
+	unsigned long		nr_scan;
+	unsigned long           nr_resident;
+	unsigned long           nr_cold;
+	unsigned long           nr_cold_target;
+	unsigned long           nr_nonresident_scale;
+};
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_CLOCKPRO_DATA_H_ */
Index: linux-2.6/include/linux/mm_clockpro_policy.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mm_clockpro_policy.h	2006-07-12 16:09:19.000000000 +0200
@@ -0,0 +1,139 @@
+#ifndef _LINUX_MM_CLOCKPRO_POLICY_H
+#define _LINUX_MM_CLOCKPRO_POLICY_H
+
+#ifdef __KERNEL__
+
+#include <linux/rmap.h>
+#include <linux/page-flags.h>
+
+#define PG_hot		PG_reclaim1
+#define PG_test		PG_reclaim2
+
+#define PageHot(page)		test_bit(PG_hot, &(page)->flags)
+#define SetPageHot(page)	set_bit(PG_hot, &(page)->flags)
+#define ClearPageHot(page)	clear_bit(PG_hot, &(page)->flags)
+#define TestClearPageHot(page)	test_and_clear_bit(PG_hot, &(page)->flags)
+#define TestSetPageHot(page)	test_and_set_bit(PG_hot, &(page)->flags)
+
+#define PageTest(page)		test_bit(PG_test, &(page)->flags)
+#define SetPageTest(page)	set_bit(PG_test, &(page)->flags)
+#define ClearPageTest(page)	clear_bit(PG_test, &(page)->flags)
+#define TestClearPageTest(page)	test_and_clear_bit(PG_test, &(page)->flags)
+
+static inline void pgrep_hint_active(struct page *page)
+{
+}
+
+static inline void pgrep_hint_use_once(struct page *page)
+{
+	if (PageLRU(page))
+		BUG();
+	if (PageHot(page))
+		BUG();
+	SetPageTest(page);
+}
+
+extern void __pgrep_add(struct zone *, struct page *);
+
+/*
+ * Activate a cold page:
+ *   cold, !test -> cold, test
+ *   cold, test  -> hot
+ *
+ * @page: page to activate
+ */
+static inline int fastcall pgrep_activate(struct page *page)
+{
+	int hot, test;
+
+	hot = PageHot(page);
+	test = PageTest(page);
+
+	if (hot) {
+		BUG_ON(test);
+	} else {
+		if (test) {
+			SetPageHot(page);
+			/*
+			 * Leave PG_test set for new hot pages in order to
+			 * recognise them in put_candidates() and do accounting.
+			 */
+			return 1;
+		} else {
+			SetPageTest(page);
+		}
+	}
+
+	return 0;
+}
+
+static inline void pgrep_copy_state(struct page *dpage, struct page *spage)
+{
+	if (PageHot(spage))
+		SetPageHot(dpage);
+	if (PageTest(spage))
+		SetPageTest(dpage);
+}
+
+static inline void pgrep_clear_state(struct page *page)
+{
+	if (PageHot(page))
+		ClearPageHot(page);
+	if (PageTest(page))
+		ClearPageTest(page);
+}
+
+static inline int pgrep_is_active(struct page *page)
+{
+	return PageHot(page);
+}
+
+static inline void __pgrep_remove(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	--zone->policy.nr_resident;
+	if (!PageHot(page))
+		--zone->policy.nr_cold;
+}
+
+static inline reclaim_t pgrep_reclaimable(struct page *page)
+{
+	if (PageHot(page))
+		return RECLAIM_KEEP;
+
+	if (page_referenced(page, 1, 0))
+		return RECLAIM_ACTIVATE;
+
+	return RECLAIM_OK;
+}
+
+static inline void __pgrep_rotate_reclaimable(struct zone *zone, struct page *page)
+{
+	if (PageLRU(page) && !PageHot(page)) {
+		list_move_tail(&page->lru, &zone->policy.list_hand[HAND_COLD]);
+		inc_page_state(pgrotated);
+	}
+}
+
+static inline void pgrep_mark_accessed(struct page *page)
+{
+	SetPageReferenced(page);
+}
+
+#define MM_POLICY_HAS_NONRESIDENT
+
+extern void pgrep_remember(struct zone *, struct page *);
+extern void pgrep_forget(struct address_space *, unsigned long);
+
+static inline unsigned long __pgrep_nr_pages(struct zone *zone)
+{
+	return zone->policy.nr_resident;
+}
+
+static inline unsigned long __pgrep_nr_scan(struct zone *zone)
+{
+	return zone->policy.nr_resident;
+}
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_MM_CLOCKPRO_POLICY_H_ */
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:25.000000000 +0200
@@ -98,6 +98,8 @@ extern void __pgrep_counts(unsigned long
 
 #ifdef CONFIG_MM_POLICY_USEONCE
 #include <linux/mm_use_once_policy.h>
+#elif CONFIG_MM_POLICY_CLOCKPRO
+#include <linux/mm_clockpro_policy.h>
 #else
 #error no mm policy
 #endif
Index: linux-2.6/include/linux/mm_page_replace_data.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace_data.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace_data.h	2006-07-12 16:11:25.000000000 +0200
@@ -5,6 +5,8 @@
 
 #ifdef CONFIG_MM_POLICY_USEONCE
 #include <linux/mm_use_once_data.h>
+#elif CONFIG_MM_POLICY_CLOCKPRO
+#include <linux/mm_clockpro_data.h>
 #else
 #error no mm policy
 #endif
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/Kconfig	2006-07-12 16:11:25.000000000 +0200
@@ -142,6 +142,11 @@ config MM_POLICY_USEONCE
 	help
 	  This option selects the standard multi-queue LRU policy.
 
+config MM_POLICY_CLOCKPRO
+	bool "CLOCK-Pro"
+	help
+	  This option selects a CLOCK-Pro based policy
+
 endchoice
 
 #
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/Makefile	2006-07-12 16:11:25.000000000 +0200
@@ -13,6 +13,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   prio_tree.o util.o mmzone.o $(mmu-y)
 
 obj-$(CONFIG_MM_POLICY_USEONCE) += useonce.o
+obj-$(CONFIG_MM_POLICY_CLOCKPRO) += nonresident.o clockpro.o
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
