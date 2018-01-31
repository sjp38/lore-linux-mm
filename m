Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7CAD6B0027
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:42 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id j3so11475546ual.3
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:42 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j28si1375797uah.117.2018.01.31.15.04.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:41 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 13/13] mm: splice local lists onto the front of the LRU
Date: Wed, 31 Jan 2018 18:04:13 -0500
Message-Id: <20180131230413.27653-14-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

Now that release_pages is scaling better with concurrent removals from
the LRU, the performance results (included below) showed increased
contention on lru_lock in the add-to-LRU path.

To alleviate some of this contention, do more work outside the LRU lock.
Prepare a local list of pages to be spliced onto the front of the LRU,
including setting PageLRU in each page, before taking lru_lock.  Since
other threads use this page flag in certain checks outside lru_lock,
ensure each page's LRU links have been properly initialized before
setting the flag, and use memory barriers accordingly.

Performance Results

This is a will-it-scale run of page_fault1 using 4 different kernels.

            kernel     kern #

          4.15-rc2          1
  large-zone-batch          2
     lru-lock-base          3
   lru-lock-splice          4

Each kernel builds on the last.  The first is a baseline, the second
makes zone->lock more scalable by increasing an order-0 per-cpu
pagelist's 'batch' and 'high' values to 310 and 1860 respectively
(courtesy of Aaron Lu's patch), the third scales lru_lock without
splicing pages (the previous patch in this series), and the fourth adds
page splicing (this patch).

N tasks mmap, fault, and munmap anonymous pages in a loop until the test
time has elapsed.

The process case generally does better than the thread case most likely
because of mmap_sem acting as a bottleneck.  There's ongoing work
upstream[*] to scale this lock, however, and once it goes in, my
hypothesis is the thread numbers here will improve.

kern #  ntask     proc      thr        proc    stdev         thr    stdev
               speedup  speedup       pgf/s                pgf/s
     1      1                       705,533    1,644     705,227    1,122
     2      1     2.5%     2.8%     722,912      453     724,807      728
     3      1     2.6%     2.6%     724,215      653     723,213      941
     4      1     2.3%     2.8%     721,746      272     724,944      728

kern #  ntask     proc      thr        proc    stdev         thr    stdev
               speedup  speedup       pgf/s                pgf/s
     1      4                     2,525,487    7,428   1,973,616   12,568
     2      4     2.6%     7.6%   2,590,699    6,968   2,123,570   10,350
     3      4     2.3%     4.4%   2,584,668   12,833   2,059,822   10,748
     4      4     4.7%     5.2%   2,643,251   13,297   2,076,808    9,506

kern #  ntask     proc      thr        proc    stdev         thr    stdev
               speedup  speedup       pgf/s                pgf/s
     1     16                     6,444,656   20,528   3,226,356   32,874
     2     16     1.9%    10.4%   6,566,846   20,803   3,560,437   64,019
     3     16    18.3%     6.8%   7,624,749   58,497   3,447,109   67,734
     4     16    28.2%     2.5%   8,264,125   31,677   3,306,679   69,443

kern #  ntask     proc      thr        proc    stdev         thr    stdev
               speedup  speedup       pgf/s                pgf/s
     1     32                    11,564,988   32,211   2,456,507   38,898
     2     32     1.8%     1.5%  11,777,119   45,418   2,494,064   27,964
     3     32    16.1%    -2.7%  13,426,746   94,057   2,389,934   40,186
     4     32    26.2%     1.2%  14,593,745   28,121   2,486,059   42,004

kern #  ntask     proc      thr        proc    stdev         thr    stdev
               speedup  speedup       pgf/s                pgf/s
     1     64                    12,080,629   33,676   2,443,043   61,973
     2     64     3.9%     9.9%  12,551,136  206,202   2,684,632   69,483
     3     64    15.0%    -3.8%  13,892,933  351,657   2,351,232   67,875
     4     64    21.9%     1.8%  14,728,765   64,945   2,485,940   66,839

[*] https://lwn.net/Articles/724502/  Range reader/writer locks
    https://lwn.net/Articles/744188/  Speculative page faults

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/memcontrol.c |   1 +
 mm/mlock.c      |   1 +
 mm/swap.c       | 113 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c     |   1 +
 4 files changed, 112 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 99a54df760e3..6911626f29b2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2077,6 +2077,7 @@ static void lock_page_lru(struct page *page, int *isolated)
 
 		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		ClearPageLRU(page);
+		smp_rmb(); /* Pairs with smp_wmb in __pagevec_lru_add */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		*isolated = 1;
 	} else
diff --git a/mm/mlock.c b/mm/mlock.c
index 6ba6a5887aeb..da294c5bbc2c 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -109,6 +109,7 @@ static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
 		if (getpage)
 			get_page(page);
 		ClearPageLRU(page);
+		smp_rmb(); /* Pairs with smp_wmb in __pagevec_lru_add */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		return true;
 	}
diff --git a/mm/swap.c b/mm/swap.c
index a302224293ad..46a98dc8e9ad 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -220,6 +220,7 @@ static void pagevec_move_tail_fn(struct page *page, struct lruvec *lruvec,
 	int *pgmoved = arg;
 
 	if (PageLRU(page) && !PageUnevictable(page)) {
+		smp_rmb();	/* Pairs with smp_wmb in __pagevec_lru_add */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		ClearPageActive(page);
 		add_page_to_lru_list_tail(page, lruvec, page_lru(page));
@@ -277,6 +278,7 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 		int file = page_is_file_cache(page);
 		int lru = page_lru_base_type(page);
 
+		smp_rmb();	/* Pairs with smp_wmb in __pagevec_lru_add */
 		del_page_from_lru_list(page, lruvec, lru);
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
@@ -544,6 +546,7 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 	file = page_is_file_cache(page);
 	lru = page_lru_base_type(page);
 
+	smp_rmb();	/* Pairs with smp_wmb in __pagevec_lru_add */
 	del_page_from_lru_list(page, lruvec, lru + active);
 	ClearPageActive(page);
 	ClearPageReferenced(page);
@@ -578,6 +581,7 @@ static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
 	    !PageSwapCache(page) && !PageUnevictable(page)) {
 		bool active = PageActive(page);
 
+		smp_rmb();	/* Pairs with smp_wmb in __pagevec_lru_add */
 		del_page_from_lru_list(page, lruvec,
 				       LRU_INACTIVE_ANON + active);
 		ClearPageActive(page);
@@ -903,6 +907,60 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 	trace_mm_lru_insertion(page, lru);
 }
 
+#define	MAX_LRU_SPLICES 4
+
+struct lru_splice {
+	struct list_head list;
+	struct lruvec *lruvec;
+	enum lru_list lru;
+	int nid;
+	int zid;
+	size_t nr_pages;
+};
+
+/*
+ * Adds a page to a local list for splicing, or else to the singletons
+ * list for individual processing.
+ *
+ * Returns the new number of splices in the splices list.
+ */
+size_t add_page_to_lru_splice(struct lru_splice *splices, size_t nr_splices,
+			      struct list_head *singletons, struct page *page)
+{
+	int i;
+	enum lru_list lru = page_lru(page);
+	enum zone_type zid = page_zonenum(page);
+	int nid = page_to_nid(page);
+	struct lruvec *lruvec;
+
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+
+	lruvec = mem_cgroup_page_lruvec(page, NODE_DATA(nid));
+
+	for (i = 0; i < nr_splices; ++i) {
+		if (splices[i].lruvec == lruvec && splices[i].zid == zid) {
+			list_add(&page->lru, &splices[i].list);
+			splices[nr_splices].nr_pages += hpage_nr_pages(page);
+			return nr_splices;
+		}
+	}
+
+	if (nr_splices < MAX_LRU_SPLICES) {
+		INIT_LIST_HEAD(&splices[nr_splices].list);
+		splices[nr_splices].lruvec = lruvec;
+		splices[nr_splices].lru = lru;
+		splices[nr_splices].nid = nid;
+		splices[nr_splices].zid = zid;
+		splices[nr_splices].nr_pages = hpage_nr_pages(page);
+		list_add(&page->lru, &splices[nr_splices].list);
+		++nr_splices;
+	} else {
+		list_add(&page->lru, singletons);
+	}
+
+	return nr_splices;
+}
+
 /*
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
@@ -911,12 +969,59 @@ void __pagevec_lru_add(struct pagevec *pvec)
 {
 	int i;
 	struct pglist_data *pgdat = NULL;
-	struct lruvec *lruvec;
 	unsigned long flags = 0;
+	struct lru_splice splices[MAX_LRU_SPLICES];
+	size_t nr_splices = 0;
+	LIST_HEAD(singletons);
+	struct page *page, *next;
 
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		struct pglist_data *pagepgdat = page_pgdat(page);
+	/*
+	 * Sort the pages into local lists to splice onto the LRU once we
+	 * hold lru_lock.  In the common case there should be few of these
+	 * local lists.
+	 */
+	for (i = 0; i < pagevec_count(pvec); ++i) {
+		page = pvec->pages[i];
+		nr_splices = add_page_to_lru_splice(splices, nr_splices,
+						    &singletons, page);
+	}
+
+	/*
+	 * Paired with read barriers where we check PageLRU and modify
+	 * page->lru, for example pagevec_move_tail_fn.
+	 */
+	smp_wmb();
+
+	for (i = 0; i < pagevec_count(pvec); i++)
+		SetPageLRU(pvec->pages[i]);
+
+	for (i = 0; i < nr_splices; ++i) {
+		struct lru_splice *s = &splices[i];
+		struct pglist_data *splice_pgdat = NODE_DATA(s->nid);
+
+		if (splice_pgdat != pgdat) {
+			if (pgdat)
+				spin_unlock_irqrestore(&pgdat->lru_lock, flags);
+			pgdat = splice_pgdat;
+			spin_lock_irqsave(&pgdat->lru_lock, flags);
+		}
+
+		update_lru_size(s->lruvec, s->lru, s->zid, s->nr_pages);
+		list_splice(&s->list, lru_head(&s->lruvec->lists[s->lru]));
+		update_page_reclaim_stat(s->lruvec, is_file_lru(s->lru),
+					 is_active_lru(s->lru));
+		/* XXX add splice tracepoint */
+	}
+
+       while (!list_empty(&singletons)) {
+		struct pglist_data *pagepgdat;
+		struct lruvec *lruvec;
+		struct list_head *list;
+
+		list = singletons.next;
+		page = list_entry(list, struct page, lru);
+		list_del(list);
+		pagepgdat = page_pgdat(page);
 
 		if (pagepgdat != pgdat) {
 			if (pgdat)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7f5ff0bb133f..338850ad03a6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1629,6 +1629,7 @@ int isolate_lru_page(struct page *page)
 			int lru = page_lru(page);
 			get_page(page);
 			ClearPageLRU(page);
+			smp_rmb(); /* Pairs with smp_wmb in __pagevec_lru_add */
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
