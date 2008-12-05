Date: Fri, 5 Dec 2008 15:40:07 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into
	pcp
Message-ID: <20081205154006.GA19366@csn.ul.ie>
References: <20081106091431.0D2A.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081106164644.GA14012@csn.ul.ie> <20081107104224.1631057e.kamezawa.hiroyu@jp.fujitsu.com> <20081107104242.GC13786@csn.ul.ie> <20081107200251.15e9851a.kamezawa.hiroyu@jp.fujitsu.com> <20081107112722.GE13786@csn.ul.ie> <Pine.LNX.4.64.0811071244330.5387@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0811071244330.5387@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 07, 2008 at 12:45:20PM -0600, Christoph Lameter wrote:
> On Fri, 7 Nov 2008, Mel Gorman wrote:
> 
> > Oh, do you mean splitting the list instead of searching? This is how it was
> > originally implement and shot down on the grounds it increased the size of
> > a per-cpu structure.
> 
> The situation may be better with the cpu_alloc stuff. The big pcp array in
> struct zone for all possible processors will be gone and thus the memory
> requirements will be less.
> 

I implemented this ages ago, ran some tests and then got distracted by
something shiny and forgot to post. The patch below replaces the per-cpu
list search with one list per migrate type of interest. It reduces the size of
a vmlinux built on a stripped-down config for x86 by 268 bytes which is
nothing to write home about but better than a poke in the eye.

The tests I used were kernbench, aim9 (page_test and brk_test mainly) and
tbench figuring these would exercise the page allocator path a bit. The
tests were on 2.6.28-rc5 but the patch applies to latest git as well.
Test results follow, patch is at the bottom.

vmlinux size comparison
    text	   data	    bss	    dec	    hex	filename
 3871764	1542612	3465216	8879592	 877de8	vmlinux-vanilla
 3871496	1542612	3465216	8879324	 877cdc	vmlinux-splitpcp
 
x86_64 BladeCenter LS20 4xCPUS 1GB RAM
	kernbench	+1.10% outside noise
	page_test	-5.50%
	brk_test	+4.10%
	tbench-1	+3.44% within noise
	tbench-cpus	-0.75% well within noise
	tbench-2xcpus	-0.37% well within noise
	highalloc	fine

ppc64 PPC970 4xCPUS 7GB RAM
	kernbench	-0.23% within noise
	page_test	+0.85%
	brk_test	-1.16%
	tbench-1	-1.35% just outside debiation
	tbench-cpus	+3.97% just outside noise
	tbench-2xcpus	-0.79% within noise
	highalloc	fine

x86 8xCPUs 16GB RAM
	kernbench	+0.07% well within noise
	page_test	+1.44%
	brk_test	+6.32%
	tbench-1	+1.59% within noise
	tbench-cpus	+6.29% well outside noise
	tbench-2xcpus	-0.18% well within noise

x86_64 eServer 336 4xCPUS 7GB RAM
	kernbench	+0.29% just outside noise
	page_test	+0.48%
	brk_test	-0.87%
	tbench-1	+0.88% just outside noise
	tbench-cpus	+1.61% well outside noise
	tbench-2xcpus	+0.87% within noise

x86_64 System X 3950 32xCPUs 48GB RAM
	kernbench	+0.40% within noise
	page_test	+3.36%
	brk_test	-0.63%
	tbench-1	-0.69% well within noise
	tbench-cpus	+2.02% just outside noise
	tbench-2xcpus	+1.93% just outside noise

ppc64 System p5 570 4xCPUs 4GB RAM
	kernbench	-0.09% within noise
	page_test	-1.34%
	brk_test	-1.03%
	tbench-1	-1.09% within noise
	tbench-cpus	-0.60% just outside noise
	tbench-2xcpus	-0.99% just outside noise

ppc64 System p5 575 128xCPUs 48GB RAM
	kernbench	+4.10% outside noise
	page_test	-0.11%
	brk_test	-4.22%
	tbench-1	+3.95% within noise
	tbench-cpus	+6.77% far outside noise
	tbench-2xcpus	+1.37% outside noise

====== CUT HERE ======
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC] Split per-cpu list into one-list-per-migrate-type

Currently the per-cpu page allocator searches the PCP list for pages of the
correct migrate-type to reduce the possibility of pages being inappropriate
placed from a fragmentation perspective. This search is potentially expensive
in a fast-path and undesirable. Splitting the per-cpu list into multiple lists
increases the size of a per-cpu structure and this was potentially a major
problem at the time the search was introduced. These problem has been
mitigated as now only the necessary number of structures is allocated for the
running system.

This patch replaces a list search in the per-cpu allocator with one list
per migrate type that should be in use by the per-cpu allocator - namely
unmovable, reclaimable and movable.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 include/linux/mmzone.h |    7 +++-
 mm/page_alloc.c        |   79 ++++++++++++++++++++++++++++-------------------
 2 files changed, 54 insertions(+), 32 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 35a7b5e..19661e4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -40,6 +40,7 @@
 #define MIGRATE_MOVABLE       2
 #define MIGRATE_RESERVE       3
 #define MIGRATE_ISOLATE       4 /* can't allocate from here */
+#define MIGRATE_PCPTYPES      3 /* the number of types on the pcp lists */
 #define MIGRATE_TYPES         5
 
 #define for_each_migratetype_order(order, type) \
@@ -170,7 +171,11 @@ struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
 	int batch;		/* chunk size for buddy add/remove */
-	struct list_head list;	/* the list of pages */
+	/*
+	 * the lists of pages, one per migrate type stored on the pcp-lists
+	 * which is unreclaimable, reclaimable and movable
+	 */
+	struct list_head lists[MIGRATE_PCPTYPES];
 };
 
 struct per_cpu_pageset {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d8ac014..4433b7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -482,7 +482,7 @@ static inline int free_pages_check(struct page *page)
 }
 
 /*
- * Frees a list of pages. 
+ * Frees a number of pages from the PCP lists
  * Assumes all pages on list are in same zone, and of same order.
  * count is the number of pages to free.
  *
@@ -492,20 +492,28 @@ static inline int free_pages_check(struct page *page)
  * And clear the zone's pages_scanned counter, to hold off the "all pages are
  * pinned" detection logic.
  */
-static void free_pages_bulk(struct zone *zone, int count,
-					struct list_head *list, int order)
+static void free_pcppages_bulk(struct zone *zone, int count,
+					struct per_cpu_pages *pcp)
 {
+	int migratetype = 0;
+
 	spin_lock(&zone->lock);
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
 	while (count--) {
 		struct page *page;
+		struct list_head *list;
+
+		/* Remove pages from lists in a round-robin fashion */
+		do {
+			migratetype = (migratetype + 1) % MIGRATE_PCPTYPES;
+			list = &pcp->lists[migratetype];
+		} while (list_empty(list));
 
-		VM_BUG_ON(list_empty(list));
 		page = list_entry(list->prev, struct page, lru);
 		/* have to delete it as __free_one_page list manipulates */
 		list_del(&page->lru);
-		__free_one_page(page, zone, order);
+		__free_one_page(page, zone, 0);
 	}
 	spin_unlock(&zone->lock);
 }
@@ -892,7 +900,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 		to_drain = pcp->batch;
 	else
 		to_drain = pcp->count;
-	free_pages_bulk(zone, to_drain, &pcp->list, 0);
+	free_pcppages_bulk(zone, to_drain, pcp);
 	pcp->count -= to_drain;
 	local_irq_restore(flags);
 }
@@ -921,7 +929,7 @@ static void drain_pages(unsigned int cpu)
 
 		pcp = &pset->pcp;
 		local_irq_save(flags);
-		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
+		free_pcppages_bulk(zone, pcp->count, pcp);
 		pcp->count = 0;
 		local_irq_restore(flags);
 	}
@@ -987,6 +995,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
+	int migratetype;
 
 	if (PageAnon(page))
 		page->mapping = NULL;
@@ -1003,16 +1012,32 @@ static void free_hot_cold_page(struct page *page, int cold)
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
+
+	/*
+	 * Only store unreclaimable, reclaimable and movable on pcp lists.
+	 * The one concern is that if the minimum number of free pages is not
+	 * aligned to a pageblock-boundary that allocations/frees from the
+	 * MIGRATE_RESERVE pageblocks may call free_one_page() excessively
+	 */
+	migratetype = get_pageblock_migratetype(page);
+	if (migratetype >= MIGRATE_PCPTYPES) {
+		free_one_page(zone, page, 0);
+		goto out;
+	}
+
 	if (cold)
-		list_add_tail(&page->lru, &pcp->list);
+		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	else
-		list_add(&page->lru, &pcp->list);
-	set_page_private(page, get_pageblock_migratetype(page));
+		list_add(&page->lru, &pcp->lists[migratetype]);
+	set_page_private(page, migratetype);
 	pcp->count++;
+
 	if (pcp->count >= pcp->high) {
-		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
+		free_pcppages_bulk(zone, pcp->batch, pcp);
 		pcp->count -= pcp->batch;
 	}
+
+out:
 	local_irq_restore(flags);
 	put_cpu();
 }
@@ -1066,31 +1091,21 @@ again:
 
 		pcp = &zone_pcp(zone, cpu)->pcp;
 		local_irq_save(flags);
-		if (!pcp->count) {
-			pcp->count = rmqueue_bulk(zone, 0,
-					pcp->batch, &pcp->list, migratetype);
-			if (unlikely(!pcp->count))
+		if (list_empty(&pcp->lists[migratetype])) {
+			pcp->count += rmqueue_bulk(zone, 0, pcp->batch,
+				&pcp->lists[migratetype], migratetype);
+			if (unlikely(list_empty(&pcp->lists[migratetype])))
 				goto failed;
 		}
 
-		/* Find a page of the appropriate migrate type */
+
 		if (cold) {
-			list_for_each_entry_reverse(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
+			page = list_entry(pcp->lists[migratetype].prev,
+							struct page, lru);
 		} else {
-			list_for_each_entry(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
-		}
-
-		/* Allocate more to the pcp list if necessary */
-		if (unlikely(&page->lru == &pcp->list)) {
-			pcp->count += rmqueue_bulk(zone, 0,
-					pcp->batch, &pcp->list, migratetype);
-			page = list_entry(pcp->list.next, struct page, lru);
+			page = list_entry(pcp->lists[migratetype].next,
+							struct page, lru);
 		}
-
 		list_del(&page->lru);
 		pcp->count--;
 	} else {
@@ -2705,6 +2720,7 @@ static int zone_batchsize(struct zone *zone)
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 {
 	struct per_cpu_pages *pcp;
+	int migratetype;
 
 	memset(p, 0, sizeof(*p));
 
@@ -2712,7 +2728,8 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 	pcp->count = 0;
 	pcp->high = 6 * batch;
 	pcp->batch = max(1UL, 1 * batch);
-	INIT_LIST_HEAD(&pcp->list);
+	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
+		INIT_LIST_HEAD(&pcp->lists[migratetype]);
 }
 
 /*

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
