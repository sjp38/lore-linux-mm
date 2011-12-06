Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 840B76B004F
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 02:37:05 -0500 (EST)
Received: by iapp10 with SMTP id p10so9253796iap.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 23:37:04 -0800 (PST)
Date: Mon, 5 Dec 2011 23:36:34 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC][PATCH] memcg: remove PCG_ACCT_LRU.
In-Reply-To: <20111206095825.69426eb2.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1112052258510.28015@sister.anvils>
References: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com> <20111202120849.GA1295@cmpxchg.org> <20111205095009.b82a9bdf.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1112051552210.3938@sister.anvils>
 <20111206095825.69426eb2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 6 Dec 2011, KAMEZAWA Hiroyuki wrote:
> On Mon, 5 Dec 2011 16:13:06 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> > 
> > Ying and I found PageCgroupAcctLRU very hard to grasp, even despite
> > the comments Hannes added to explain it.  
> 
> Now, I don't think it's difficult. It seems no file system codes
> add pages to LRU before add_to_page_cache() (I checked.)
> So, what we need to care is only swap-cache. In swap-cache path,
> we can do slow work.

I've been reluctant to add more special code for SwapCache:
it may or may not be a good idea.  Hannes also noted a FUSE
case which requires the before-commit-after handling swap was
using (for memcg-zone lru locking we've merged them into commit).

> 
> > In moving the LRU locking
> > from zone to memcg, we needed to depend upon pc->mem_cgroup: that
> > was difficult while the interpretation of pc->mem_cgroup depended
> > upon two flags also; and very tricky when pages were liable to shift
> > underneath you from one LRU to another, as flags came and went.
> > So we already eliminated PageCgroupAcctLRU here.
> > 
> 
> Okay, Hm, do you see performance improvement by moving locks ?

I was expecting someone to ask that question!  I'm not up-to-date
on it, it's one of the things I have to get help to gather before
sending in the patch series.

I believe the answer is that we saw some improvement on some tests,
but not so much as to make a hugely compelling case for the change.
But by that time we'd invested a lot of testing in the memcg locking,
and little in the original zone locking, so went with the memcg
locking anyway.

We'll get more results and hope to show a stronger case for it now.
But our results will probably have to be based on in-house kernels,
with a lot of the "infrastructure" mods already in place, to allow
an easy build-time switch between zone locking and memcg locking.

That won't be such a fair test if the "infrastructure" mods are
themselves detrimental (I believe not).  It would be better to
compare, say, 3.2.0-next against 3.2.0-next plus our patches -
but my own (quad) machines for testing upstream kernels won't
be big enough to show much of interest.  I'm rather hoping
someone will be interested enough to try on something beefier.

> 
> > I'm fairly happy with what we have now, and have ported it forward
> > to 3.2.0-rc3-next-20111202: with a few improvements on top of what
> > we've got internally - Hannes's remark above about "amortizing the
> > winnings" in the page freeing hotpath has prompted me to improve
> > on what we had there, needs more testing but seems good so far.

Yes, I'm wary of my late changes, but it's now proved to run fine
overnight and day, for twenty hours on two machines.

> > 
> > However, I've hardly begun splitting the changes up into a series:
> > had intended to do so last week, but day followed day...  If you'd
> > like to see the unpolished uncommented rollup, I can post that.
> > 
> 
> please.
> Anyway, I'll post my own again as output even if I stop my work there.

Okay, here it is: my usual mix of cleanup and functional changes.
There's work by Ying and others in here - will apportion authorship
more fairly when splitting.  If you're looking through it at all,
the place to start would be memcontrol.c's lock_page_lru_irqsave().

Memcg-zone lru locking rollup based on 3.2.0-rc3-next-20111202

Not-yet-split-up-and-signed-off-by: Hugh Dickins <hughd@google.com>
---

 include/linux/memcontrol.h  |   34 --
 include/linux/mm_inline.h   |   42 +-
 include/linux/mm_types.h    |    2 
 include/linux/mmzone.h      |    8 
 include/linux/page_cgroup.h |    8 
 include/linux/pagevec.h     |   12 
 include/linux/swap.h        |    2 
 mm/compaction.c             |   62 ++--
 mm/filemap.c                |    4 
 mm/huge_memory.c            |   18 -
 mm/memcontrol.c             |  482 ++++++++++++--------------------
 mm/page_alloc.c             |    2 
 mm/rmap.c                   |    2 
 mm/swap.c                   |  213 ++++++--------
 mm/vmscan.c                 |  512 +++++++++++++++++++---------------
 15 files changed, 671 insertions(+), 732 deletions(-)

diff -purN 3023n/include/linux/memcontrol.h 3023nhh/include/linux/memcontrol.h
--- 3023n/include/linux/memcontrol.h	2011-12-03 12:49:49.528213391 -0800
+++ 3023nhh/include/linux/memcontrol.h	2011-12-04 15:33:40.309491443 -0800
@@ -38,6 +38,12 @@ struct mem_cgroup_reclaim_cookie {
 	unsigned int generation;
 };
 
+/*
+ * The full memcg version of lock_page_lru_irqsave() is in mm/memcontrol.c.
+ * The much simpler non-memcg version is in mm/swap.c.
+ */
+void lock_page_lru_irqsave(struct page *, struct lruvec **, unsigned long *);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -63,12 +69,8 @@ extern int mem_cgroup_cache_charge(struc
 					gfp_t gfp_mask);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
-struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
-				       enum lru_list);
-void mem_cgroup_lru_del_list(struct page *, enum lru_list);
-void mem_cgroup_lru_del(struct page *);
-struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
-					 enum lru_list, enum lru_list);
+extern void mem_cgroup_update_lru_count(struct lruvec *, enum lru_list, int);
+extern void mem_cgroup_move_uncharged_to_root(struct page *);
 
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
@@ -217,29 +219,15 @@ static inline struct lruvec *mem_cgroup_
 	return &zone->lruvec;
 }
 
-static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
-						     struct page *page,
-						     enum lru_list lru)
+static inline void mem_cgroup_update_lru_count(struct lruvec *lruvec,
+					enum lru_list lru, int increment)
 {
-	return &zone->lruvec;
 }
 
-static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
+static inline void mem_cgroup_move_uncharged_to_root(struct page *page)
 {
 }
 
-static inline void mem_cgroup_lru_del(struct page *page)
-{
-}
-
-static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
-						       struct page *page,
-						       enum lru_list from,
-						       enum lru_list to)
-{
-	return &zone->lruvec;
-}
-
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	return NULL;
diff -purN 3023n/include/linux/mm_inline.h 3023nhh/include/linux/mm_inline.h
--- 3023n/include/linux/mm_inline.h	2011-12-03 12:49:49.544213473 -0800
+++ 3023nhh/include/linux/mm_inline.h	2011-12-03 13:59:33.960939119 -0800
@@ -22,21 +22,23 @@ static inline int page_is_file_cache(str
 }
 
 static inline void
-add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
+add_page_to_lru_list(struct zone *zone, struct page *page,
+		     struct lruvec *lruvec, enum lru_list lru)
 {
-	struct lruvec *lruvec;
-
-	lruvec = mem_cgroup_lru_add_list(zone, page, l);
-	list_add(&page->lru, &lruvec->lists[l]);
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
+	int nr_pages = hpage_nr_pages(page);
+	mem_cgroup_update_lru_count(lruvec, lru, nr_pages);
+	list_add(&page->lru, &lruvec->lists[lru]);
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, nr_pages);
 }
 
 static inline void
-del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
+del_page_from_lru_list(struct zone *zone, struct page *page,
+		       struct lruvec *lruvec, enum lru_list lru)
 {
-	mem_cgroup_lru_del_list(page, l);
+	int nr_pages = hpage_nr_pages(page);
+	mem_cgroup_update_lru_count(lruvec, lru, -nr_pages);
 	list_del(&page->lru);
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_pages);
 }
 
 /**
@@ -54,24 +56,27 @@ static inline enum lru_list page_lru_bas
 	return LRU_INACTIVE_ANON;
 }
 
-static inline void
-del_page_from_lru(struct zone *zone, struct page *page)
+/**
+ * page_off_lru - clear flags and return which LRU page is coming off
+ * @page: the page to test and clear its active and unevictable flags
+ *
+ * Returns the LRU list the page is coming off.
+ */
+static inline enum lru_list page_off_lru(struct page *page)
 {
-	enum lru_list l;
+	enum lru_list lru;
 
 	if (PageUnevictable(page)) {
 		__ClearPageUnevictable(page);
-		l = LRU_UNEVICTABLE;
+		lru = LRU_UNEVICTABLE;
 	} else {
-		l = page_lru_base_type(page);
+		lru = page_lru_base_type(page);
 		if (PageActive(page)) {
 			__ClearPageActive(page);
-			l += LRU_ACTIVE;
+			lru += LRU_ACTIVE;
 		}
 	}
-	mem_cgroup_lru_del_list(page, l);
-	list_del(&page->lru);
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
+	return lru;
 }
 
 /**
@@ -92,7 +97,6 @@ static inline enum lru_list page_lru(str
 		if (PageActive(page))
 			lru += LRU_ACTIVE;
 	}
-
 	return lru;
 }
 
diff -purN 3023n/include/linux/mm_types.h 3023nhh/include/linux/mm_types.h
--- 3023n/include/linux/mm_types.h	2011-12-03 12:49:49.548213498 -0800
+++ 3023nhh/include/linux/mm_types.h	2011-12-03 13:59:33.964939336 -0800
@@ -95,7 +95,7 @@ struct page {
 	/* Third double word block */
 	union {
 		struct list_head lru;	/* Pageout list, eg. active_list
-					 * protected by zone->lru_lock !
+					 * protected by lruvec.lru_lock !
 					 */
 		struct {		/* slub per cpu partial pages */
 			struct page *next;	/* Next partial slab */
diff -purN 3023n/include/linux/mmzone.h 3023nhh/include/linux/mmzone.h
--- 3023n/include/linux/mmzone.h	2011-12-03 12:49:49.552213510 -0800
+++ 3023nhh/include/linux/mmzone.h	2011-12-03 13:59:33.968939418 -0800
@@ -62,10 +62,10 @@ struct free_area {
 struct pglist_data;
 
 /*
- * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
+ * zone->lock and lruvec.lru_lock are two of the hottest locks in the kernel.
  * So add a wild amount of padding here to ensure that they fall into separate
- * cachelines.  There are very few zone structures in the machine, so space
- * consumption is not a concern here.
+ * cachelines.  There are very few zone structures in the machine, so
+ * space consumption is not a concern here.
  */
 #if defined(CONFIG_SMP)
 struct zone_padding {
@@ -160,6 +160,7 @@ static inline int is_unevictable_lru(enu
 }
 
 struct lruvec {
+	spinlock_t lru_lock;
 	struct list_head lists[NR_LRU_LISTS];
 };
 
@@ -368,7 +369,6 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
 	struct zone_reclaim_stat reclaim_stat;
diff -purN 3023n/include/linux/page_cgroup.h 3023nhh/include/linux/page_cgroup.h
--- 3023n/include/linux/page_cgroup.h	2011-12-03 12:49:49.572213617 -0800
+++ 3023nhh/include/linux/page_cgroup.h	2011-12-03 13:59:33.968939418 -0800
@@ -10,8 +10,6 @@ enum {
 	/* flags for mem_cgroup and file and I/O status */
 	PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
 	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
-	/* No lock in page_cgroup */
-	PCG_ACCT_LRU, /* page has been accounted for (under lru_lock) */
 	__NR_PCG_FLAGS,
 };
 
@@ -75,12 +73,6 @@ TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 SETPCGFLAG(Used, USED)
 
-SETPCGFLAG(AcctLRU, ACCT_LRU)
-CLEARPCGFLAG(AcctLRU, ACCT_LRU)
-TESTPCGFLAG(AcctLRU, ACCT_LRU)
-TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
-
-
 SETPCGFLAG(FileMapped, FILE_MAPPED)
 CLEARPCGFLAG(FileMapped, FILE_MAPPED)
 TESTPCGFLAG(FileMapped, FILE_MAPPED)
diff -purN 3023n/include/linux/pagevec.h 3023nhh/include/linux/pagevec.h
--- 3023n/include/linux/pagevec.h	2011-12-03 12:49:49.572213617 -0800
+++ 3023nhh/include/linux/pagevec.h	2011-12-03 13:59:33.968939418 -0800
@@ -21,8 +21,7 @@ struct pagevec {
 };
 
 void __pagevec_release(struct pagevec *pvec);
-void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
-void pagevec_strip(struct pagevec *pvec);
+void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
@@ -59,7 +58,6 @@ static inline unsigned pagevec_add(struc
 	return pagevec_space(pvec);
 }
 
-
 static inline void pagevec_release(struct pagevec *pvec)
 {
 	if (pagevec_count(pvec))
@@ -68,22 +66,22 @@ static inline void pagevec_release(struc
 
 static inline void __pagevec_lru_add_anon(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
+	__pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
 }
 
 static inline void __pagevec_lru_add_active_anon(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_ACTIVE_ANON);
+	__pagevec_lru_add(pvec, LRU_ACTIVE_ANON);
 }
 
 static inline void __pagevec_lru_add_file(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_INACTIVE_FILE);
+	__pagevec_lru_add(pvec, LRU_INACTIVE_FILE);
 }
 
 static inline void __pagevec_lru_add_active_file(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
+	__pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
 }
 
 static inline void pagevec_lru_add_file(struct pagevec *pvec)
diff -purN 3023n/include/linux/swap.h 3023nhh/include/linux/swap.h
--- 3023n/include/linux/swap.h	2011-12-03 12:49:49.620213855 -0800
+++ 3023nhh/include/linux/swap.h	2011-12-03 13:59:33.972939719 -0800
@@ -224,7 +224,7 @@ extern unsigned int nr_free_pagecache_pa
 /* linux/mm/swap.c */
 extern void __lru_cache_add(struct page *, enum lru_list lru);
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
-extern void lru_add_page_tail(struct zone* zone,
+extern void lru_add_page_tail(struct zone *zone, struct lruvec *lruvec,
 			      struct page *page, struct page *page_tail);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
diff -purN 3023n/mm/compaction.c 3023nhh/mm/compaction.c
--- 3023n/mm/compaction.c	2011-12-03 12:49:49.864215057 -0800
+++ 3023nhh/mm/compaction.c	2011-12-04 15:33:40.309491443 -0800
@@ -10,6 +10,7 @@
 #include <linux/swap.h>
 #include <linux/migrate.h>
 #include <linux/compaction.h>
+#include <linux/memcontrol.h>
 #include <linux/mm_inline.h>
 #include <linux/backing-dev.h>
 #include <linux/sysctl.h>
@@ -262,6 +263,8 @@ static isolate_migrate_t isolate_migrate
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
+	struct lruvec *lruvec = NULL;
+	unsigned long flags;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -293,25 +296,23 @@ static isolate_migrate_t isolate_migrate
 
 	/* Time to isolate some pages for migration */
 	cond_resched();
-	spin_lock_irq(&zone->lru_lock);
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
-		bool locked = true;
 
-		/* give a chance to irqs before checking need_resched() */
-		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
-			spin_unlock_irq(&zone->lru_lock);
-			locked = false;
+		/* give a chance to irqs before cond_resched() */
+		if (lruvec) {
+			if (!((low_pfn+1) % SWAP_CLUSTER_MAX) ||
+			    spin_is_contended(&lruvec->lru_lock) ||
+			    need_resched()) {
+				spin_unlock_irq(&lruvec->lru_lock);
+				lruvec = NULL;
+			}
 		}
-		if (need_resched() || spin_is_contended(&zone->lru_lock)) {
-			if (locked)
-				spin_unlock_irq(&zone->lru_lock);
+		if (!lruvec) {
 			cond_resched();
-			spin_lock_irq(&zone->lru_lock);
 			if (fatal_signal_pending(current))
 				break;
-		} else if (!locked)
-			spin_lock_irq(&zone->lru_lock);
+		}
 
 		if (!pfn_valid_within(low_pfn))
 			continue;
@@ -336,19 +337,6 @@ static isolate_migrate_t isolate_migrate
 			continue;
 		}
 
-		if (!PageLRU(page))
-			continue;
-
-		/*
-		 * PageLRU is set, and lru_lock excludes isolation,
-		 * splitting and collapsing (collapsing has already
-		 * happened if PageLRU is set).
-		 */
-		if (PageTransHuge(page)) {
-			low_pfn += (1 << compound_order(page)) - 1;
-			continue;
-		}
-
 		if (!cc->sync)
 			mode |= ISOLATE_CLEAN;
 
@@ -356,10 +344,26 @@ static isolate_migrate_t isolate_migrate
 		if (__isolate_lru_page(page, mode, 0) != 0)
 			continue;
 
+		lock_page_lru_irqsave(page, &lruvec, &flags);
+		if (unlikely(!PageLRU(page) || PageUnevictable(page) ||
+						PageTransHuge(page))) {
+			/*
+			 * lru_lock excludes splitting a huge page,
+			 * but cannot hold lru_lock while freeing page.
+			 */
+			low_pfn += (1 << compound_order(page)) - 1;
+			spin_unlock_irqrestore(&lruvec->lru_lock, flags);
+			lruvec = NULL;
+			put_page(page);
+			continue;
+		}
+
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
-		del_page_from_lru_list(zone, page, page_lru(page));
+		ClearPageLRU(page);
+		mem_cgroup_move_uncharged_to_root(page);
+		del_page_from_lru_list(zone, page, lruvec, page_lru(page));
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
@@ -371,9 +375,13 @@ static isolate_migrate_t isolate_migrate
 		}
 	}
 
+	if (lruvec)
+		spin_unlock(&lruvec->lru_lock);
+	else
+		local_irq_disable();
 	acct_isolated(zone, cc);
+	local_irq_enable();
 
-	spin_unlock_irq(&zone->lru_lock);
 	cc->migrate_pfn = low_pfn;
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
diff -purN 3023n/mm/filemap.c 3023nhh/mm/filemap.c
--- 3023n/mm/filemap.c	2011-12-03 12:49:49.868215078 -0800
+++ 3023nhh/mm/filemap.c	2011-12-03 13:59:33.976940014 -0800
@@ -91,8 +91,8 @@
  *    ->swap_lock		(try_to_unmap_one)
  *    ->private_lock		(try_to_unmap_one)
  *    ->tree_lock		(try_to_unmap_one)
- *    ->zone.lru_lock		(follow_page->mark_page_accessed)
- *    ->zone.lru_lock		(check_pte_range->isolate_lru_page)
+ *    ->lruvec.lru_lock		(follow_page->mark_page_accessed)
+ *    ->lruvec.lru_lock		(check_pte_range->isolate_lru_page)
  *    ->private_lock		(page_remove_rmap->set_page_dirty)
  *    ->tree_lock		(page_remove_rmap->set_page_dirty)
  *    bdi.wb->list_lock		(page_remove_rmap->set_page_dirty)
diff -purN 3023n/mm/huge_memory.c 3023nhh/mm/huge_memory.c
--- 3023n/mm/huge_memory.c	2011-12-03 12:49:49.872215104 -0800
+++ 3023nhh/mm/huge_memory.c	2011-12-03 14:39:19.612770559 -0800
@@ -1229,11 +1229,12 @@ static void __split_huge_page_refcount(s
 {
 	int i;
 	struct zone *zone = page_zone(page);
-	int zonestat;
 	int tail_count = 0;
+	struct lruvec *lruvec = NULL;
+	unsigned long flags;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
+	lock_page_lru_irqsave(page, &lruvec, &flags);
 	compound_lock(page);
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
@@ -1309,7 +1310,7 @@ static void __split_huge_page_refcount(s
 		BUG_ON(!PageSwapBacked(page_tail));
 
 
-		lru_add_page_tail(zone, page, page_tail);
+		lru_add_page_tail(zone, lruvec, page, page_tail);
 	}
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
@@ -1317,18 +1318,9 @@ static void __split_huge_page_refcount(s
 	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
 
-	/*
-	 * A hugepage counts for HPAGE_PMD_NR pages on the LRU statistics,
-	 * so adjust those appropriately if this page is on the LRU.
-	 */
-	if (PageLRU(page)) {
-		zonestat = NR_LRU_BASE + page_lru(page);
-		__mod_zone_page_state(zone, zonestat, -(HPAGE_PMD_NR-1));
-	}
-
 	ClearPageCompound(page);
 	compound_unlock(page);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(&lruvec->lru_lock);
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
diff -purN 3023n/mm/memcontrol.c 3023nhh/mm/memcontrol.c
--- 3023n/mm/memcontrol.c	2011-12-03 12:49:49.880215139 -0800
+++ 3023nhh/mm/memcontrol.c	2011-12-04 15:33:40.313491574 -0800
@@ -145,8 +145,6 @@ struct mem_cgroup_per_zone {
 	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
 						/* use container_of	   */
 };
-/* Macro for accessing counter */
-#define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
 
 struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
@@ -635,14 +633,14 @@ mem_cgroup_zone_nr_lru_pages(struct mem_
 			unsigned int lru_mask)
 {
 	struct mem_cgroup_per_zone *mz;
-	enum lru_list l;
+	enum lru_list lru;
 	unsigned long ret = 0;
 
 	mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
-	for_each_lru(l) {
-		if (BIT(l) & lru_mask)
-			ret += MEM_CGROUP_ZSTAT(mz, l);
+	for_each_lru(lru) {
+		if (BIT(lru) & lru_mask)
+			ret += mz->count[lru];
 	}
 	return ret;
 }
@@ -950,204 +948,99 @@ struct lruvec *mem_cgroup_zone_lruvec(st
  * If PCG_USED bit is not set, page_cgroup is not added to this private LRU.
  * When moving account, the page is not on LRU. It's isolated.
  */
-
-/**
- * mem_cgroup_lru_add_list - account for adding an lru page and return lruvec
- * @zone: zone of the page
- * @page: the page
- * @lru: current lru
- *
- * This function accounts for @page being added to @lru, and returns
- * the lruvec for the given @zone and the memcg @page is charged to.
- *
- * The callsite is then responsible for physically linking the page to
- * the returned lruvec->lists[@lru].
- */
-struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
-				       enum lru_list lru)
+void lock_page_lru_irqsave(struct page *page, struct lruvec **lruvec,
+			   unsigned long *flags)
 {
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup *memcg;
 	struct page_cgroup *pc;
+	struct mem_cgroup *memcg;
+	struct mem_cgroup_per_zone *mz;
+	struct lruvec *new_lruvec;
 
-	if (mem_cgroup_disabled())
-		return &zone->lruvec;
+	if (unlikely(mem_cgroup_disabled())) {
+		struct zone *zone = page_zone(page);
+		new_lruvec = &zone->lruvec;
+		if (*lruvec && *lruvec != new_lruvec) {
+			spin_unlock_irqrestore(&(*lruvec)->lru_lock, *flags);
+			*lruvec = NULL;
+		}
+		if (!*lruvec) {
+			*lruvec = new_lruvec;
+			spin_lock_irqsave(&new_lruvec->lru_lock, *flags);
+		}
+		return;
+	}
 
 	pc = lookup_page_cgroup(page);
-	VM_BUG_ON(PageCgroupAcctLRU(pc));
-	/*
-	 * putback:				charge:
-	 * SetPageLRU				SetPageCgroupUsed
-	 * smp_mb				smp_mb
-	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
-	 *
-	 * Ensure that one of the two sides adds the page to the memcg
-	 * LRU during a race.
-	 */
-	smp_mb();
+	rcu_read_lock();
+again:
+	memcg = rcu_dereference(pc->mem_cgroup);
+	mz = page_cgroup_zoneinfo(memcg ? : root_mem_cgroup, page);
+	new_lruvec = &mz->lruvec;
+
 	/*
-	 * If the page is uncharged, it may be freed soon, but it
-	 * could also be swap cache (readahead, swapoff) that needs to
-	 * be reclaimable in the future.  root_mem_cgroup will babysit
-	 * it for the time being.
+	 * Sometimes we are called with non-NULL lruvec spinlock already held:
+	 * hold on if we want the same again, otherwise drop and acquire.
 	 */
-	if (PageCgroupUsed(pc)) {
-		/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-		smp_rmb();
-		memcg = pc->mem_cgroup;
-		SetPageCgroupAcctLRU(pc);
-	} else
-		memcg = root_mem_cgroup;
-	mz = page_cgroup_zoneinfo(memcg, page);
-	/* compound_order() is stabilized through lru_lock */
-	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
-	return &mz->lruvec;
+	if (*lruvec && *lruvec != new_lruvec) {
+		spin_unlock_irqrestore(&(*lruvec)->lru_lock, *flags);
+		*lruvec = NULL;
+	}
+	if (!*lruvec) {
+		*lruvec = new_lruvec;
+		spin_lock_irqsave(&new_lruvec->lru_lock, *flags);
+		/*
+		 * But pc->mem_cgroup may have changed since we looked...
+		 */
+		if (unlikely(pc->mem_cgroup != memcg))
+			goto again;
+	}
+	if (memcg != root_mem_cgroup && (!memcg || !page_count(page)))
+		pc->mem_cgroup = root_mem_cgroup;
+	rcu_read_unlock();
 }
 
-/**
- * mem_cgroup_lru_del_list - account for removing an lru page
- * @page: the page
- * @lru: target lru
- *
- * This function accounts for @page being removed from @lru.
- *
- * The callsite is then responsible for physically unlinking
- * @page->lru.
- */
-void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
+void mem_cgroup_move_uncharged_to_root(struct page *page)
 {
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup *memcg;
 	struct page_cgroup *pc;
 
 	if (mem_cgroup_disabled())
 		return;
 
-	pc = lookup_page_cgroup(page);
+	VM_BUG_ON(PageLRU(page));
 	/*
-	 * root_mem_cgroup babysits uncharged LRU pages, but
-	 * PageCgroupUsed is cleared when the page is about to get
-	 * freed.  PageCgroupAcctLRU remembers whether the
-	 * LRU-accounting happened against pc->mem_cgroup or
-	 * root_mem_cgroup.
+	 * Caller just did ClearPageLRU():
+	 * make sure that __mem_cgroup_uncharge_common()
+	 * can see that before we test PageCgroupUsed(pc).
 	 */
-	if (TestClearPageCgroupAcctLRU(pc)) {
-		VM_BUG_ON(!pc->mem_cgroup);
-		memcg = pc->mem_cgroup;
-	} else
-		memcg = root_mem_cgroup;
-	mz = page_cgroup_zoneinfo(memcg, page);
-	/* huge page split is done under lru_lock. so, we have no races. */
-	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
-}
+	smp_mb__after_clear_bit();
 
-void mem_cgroup_lru_del(struct page *page)
-{
-	mem_cgroup_lru_del_list(page, page_lru(page));
+	/*
+	 * Once an uncharged page is isolated from the mem_cgroup's lru,
+	 * it no longer protects that mem_cgroup from rmdir: move to root.
+	 */
+	pc = lookup_page_cgroup(page);
+	if (!PageCgroupUsed(pc) && pc->mem_cgroup != root_mem_cgroup)
+		pc->mem_cgroup = root_mem_cgroup;
 }
 
 /**
- * mem_cgroup_lru_move_lists - account for moving a page between lrus
- * @zone: zone of the page
- * @page: the page
- * @from: current lru
- * @to: target lru
- *
- * This function accounts for @page being moved between the lrus @from
- * and @to, and returns the lruvec for the given @zone and the memcg
- * @page is charged to.
+ * mem_cgroup_update_lru_count - account for adding or removing an lru page
+ * @lruvec: mem_cgroup per zone lru vector
+ * @lru: index of lru list the page is sitting on
+ * @nr_pages: positive when adding or negative when removing
  *
- * The callsite is then responsible for physically relinking
- * @page->lru to the returned lruvec->lists[@to].
+ * This function must be called when a page is added to or removed from an
+ * lru list.
  */
-struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
-					 struct page *page,
-					 enum lru_list from,
-					 enum lru_list to)
+void mem_cgroup_update_lru_count(struct lruvec *lruvec, enum lru_list lru,
+				 int nr_pages)
 {
-	/* XXX: Optimize this, especially for @from == @to */
-	mem_cgroup_lru_del_list(page, from);
-	return mem_cgroup_lru_add_list(zone, page, to);
-}
-
-/*
- * At handling SwapCache and other FUSE stuff, pc->mem_cgroup may be changed
- * while it's linked to lru because the page may be reused after it's fully
- * uncharged. To handle that, unlink page_cgroup from LRU when charge it again.
- * It's done under lock_page and expected that zone->lru_lock isnever held.
- */
-static void mem_cgroup_lru_del_before_commit(struct page *page)
-{
-	enum lru_list lru;
-	unsigned long flags;
-	struct zone *zone = page_zone(page);
-	struct page_cgroup *pc = lookup_page_cgroup(page);
-
-	/*
-	 * Doing this check without taking ->lru_lock seems wrong but this
-	 * is safe. Because if page_cgroup's USED bit is unset, the page
-	 * will not be added to any memcg's LRU. If page_cgroup's USED bit is
-	 * set, the commit after this will fail, anyway.
-	 * This all charge/uncharge is done under some mutual execustion.
-	 * So, we don't need to taking care of changes in USED bit.
-	 */
-	if (likely(!PageLRU(page)))
-		return;
-
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	lru = page_lru(page);
-	/*
-	 * The uncharged page could still be registered to the LRU of
-	 * the stale pc->mem_cgroup.
-	 *
-	 * As pc->mem_cgroup is about to get overwritten, the old LRU
-	 * accounting needs to be taken care of.  Let root_mem_cgroup
-	 * babysit the page until the new memcg is responsible for it.
-	 *
-	 * The PCG_USED bit is guarded by lock_page() as the page is
-	 * swapcache/pagecache.
-	 */
-	if (PageLRU(page) && PageCgroupAcctLRU(pc) && !PageCgroupUsed(pc)) {
-		del_page_from_lru_list(zone, page, lru);
-		add_page_to_lru_list(zone, page, lru);
-	}
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
-}
+	struct mem_cgroup_per_zone *mz;
 
-static void mem_cgroup_lru_add_after_commit(struct page *page)
-{
-	enum lru_list lru;
-	unsigned long flags;
-	struct zone *zone = page_zone(page);
-	struct page_cgroup *pc = lookup_page_cgroup(page);
-	/*
-	 * putback:				charge:
-	 * SetPageLRU				SetPageCgroupUsed
-	 * smp_mb				smp_mb
-	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
-	 *
-	 * Ensure that one of the two sides adds the page to the memcg
-	 * LRU during a race.
-	 */
-	smp_mb();
-	/* taking care of that the page is added to LRU while we commit it */
-	if (likely(!PageLRU(page)))
+	if (mem_cgroup_disabled())
 		return;
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	lru = page_lru(page);
-	/*
-	 * If the page is not on the LRU, someone will soon put it
-	 * there.  If it is, and also already accounted for on the
-	 * memcg-side, it must be on the right lruvec as setting
-	 * pc->mem_cgroup and PageCgroupUsed is properly ordered.
-	 * Otherwise, root_mem_cgroup has been babysitting the page
-	 * during the charge.  Move it to the new memcg now.
-	 */
-	if (PageLRU(page) && !PageCgroupAcctLRU(pc)) {
-		del_page_from_lru_list(zone, page, lru);
-		add_page_to_lru_list(zone, page, lru);
-	}
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
+	mz->count[lru] += nr_pages;
 }
 
 /*
@@ -1394,7 +1287,6 @@ void mem_cgroup_print_oom_info(struct me
 	if (!memcg || !p)
 		return;
 
-
 	rcu_read_lock();
 
 	mem_cgrp = memcg->css.cgroup;
@@ -1773,22 +1665,22 @@ static DEFINE_SPINLOCK(memcg_oom_lock);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
 struct oom_wait_info {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	wait_queue_t	wait;
 };
 
 static int memcg_oom_wake_function(wait_queue_t *wait,
 	unsigned mode, int sync, void *arg)
 {
-	struct mem_cgroup *wake_memcg = (struct mem_cgroup *)arg,
-			  *oom_wait_memcg;
+	struct mem_cgroup *wake_memcg = (struct mem_cgroup *)arg;
+	struct mem_cgroup *oom_wait_memcg;
 	struct oom_wait_info *oom_wait_info;
 
 	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
-	oom_wait_memcg = oom_wait_info->mem;
+	oom_wait_memcg = oom_wait_info->memcg;
 
 	/*
-	 * Both of oom_wait_info->mem and wake_mem are stable under us.
+	 * Both of oom_wait_info->memcg and wake_memcg are stable under us.
 	 * Then we can use css_is_ancestor without taking care of RCU.
 	 */
 	if (!mem_cgroup_same_or_subtree(oom_wait_memcg, wake_memcg)
@@ -1817,7 +1709,7 @@ bool mem_cgroup_handle_oom(struct mem_cg
 	struct oom_wait_info owait;
 	bool locked, need_to_kill;
 
-	owait.mem = memcg;
+	owait.memcg = memcg;
 	owait.wait.flags = 0;
 	owait.wait.func = memcg_oom_wake_function;
 	owait.wait.private = current;
@@ -1894,6 +1786,9 @@ void mem_cgroup_update_page_stat(struct
 	bool need_unlock = false;
 	unsigned long uninitialized_var(flags);
 
+	if (unlikely(!pc))	/* mem_cgroup_disabled() */
+		return;
+
 	rcu_read_lock();
 	memcg = pc->mem_cgroup;
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
@@ -1926,7 +1821,6 @@ out:
 	if (unlikely(need_unlock))
 		move_unlock_page_cgroup(pc, &flags);
 	rcu_read_unlock();
-	return;
 }
 EXPORT_SYMBOL(mem_cgroup_update_page_stat);
 
@@ -2422,6 +2316,10 @@ static void __mem_cgroup_commit_charge(s
 				       struct page_cgroup *pc,
 				       enum charge_type ctype)
 {
+	struct lruvec *lruvec = NULL;
+	unsigned long flags;
+	bool was_on_lru = false;
+
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
@@ -2429,18 +2327,32 @@ static void __mem_cgroup_commit_charge(s
 		return;
 	}
 	/*
-	 * we don't need page_cgroup_lock about tail pages, becase they are not
-	 * accessed by any other context at this point.
+	 * We don't need lock_page_cgroup on tail pages, because they are not
+	 * accessible to any other context at this point.
 	 */
-	pc->mem_cgroup = memcg;
+
 	/*
-	 * We access a page_cgroup asynchronously without lock_page_cgroup().
-	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
-	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
-	 * before USED bit, we need memory barrier here.
-	 * See mem_cgroup_add_lru_list(), etc.
- 	 */
-	smp_wmb();
+	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
+	 * may already be on some other page_cgroup's LRU.  Take care of it.
+	 *
+	 * PageLRU() is not a good enough test for whether we need lru
+	 * locking here: the page may be in pagevec heading towards lru,
+	 * and need lru locking in case its add races with the del here.
+	 * But we don't want to add unnecessary locking to common cases,
+	 * so use a page_count heuristic to avoid it most of the time.
+	 */
+	if ((PageLRU(page) || page_count(page) > 1) && pc->mem_cgroup != memcg) {
+		lock_page_lru_irqsave(page, &lruvec, &flags);
+		if (PageLRU(page)) {
+			ClearPageLRU(page);
+			del_page_from_lru_list(page_zone(page), page,
+						lruvec, page_lru(page));
+			was_on_lru = true;
+		}
+	}
+
+	pc->mem_cgroup = memcg;
+
 	switch (ctype) {
 	case MEM_CGROUP_CHARGE_TYPE_CACHE:
 	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
@@ -2452,7 +2364,19 @@ static void __mem_cgroup_commit_charge(s
 		SetPageCgroupUsed(pc);
 		break;
 	default:
-		break;
+		BUG();
+	}
+
+	if (lruvec) {
+		if (was_on_lru) {
+			lock_page_lru_irqsave(page, &lruvec, &flags);
+			if (!PageLRU(page)) {
+				SetPageLRU(page);
+				add_page_to_lru_list(page_zone(page), page,
+						lruvec, page_lru(page));
+			}
+		}
+		spin_unlock_irqrestore(&lruvec->lru_lock, flags);
 	}
 
 	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), nr_pages);
@@ -2467,11 +2391,12 @@ static void __mem_cgroup_commit_charge(s
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
-#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MOVE_LOCK) |\
-			(1 << PCG_ACCT_LRU) | (1 << PCG_MIGRATION))
+#define PCGF_NOCOPY_AT_SPLIT	((1 << PCG_LOCK) |\
+				 (1 << PCG_MOVE_LOCK) |\
+				 (1 << PCG_MIGRATION))
 /*
  * Because tail pages are not marked as "used", set it. We're under
- * zone->lru_lock, 'splitting on pmd' and compound_lock.
+ * lruvec.lru_lock, 'splitting on pmd' and compound_lock.
  * charge/uncharge will be never happen and move_account() is done under
  * compound_lock(), so we don't have to take care of races.
  */
@@ -2493,17 +2418,6 @@ void mem_cgroup_split_huge_fixup(struct
 		 */
 		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
 	}
-
-	if (PageCgroupAcctLRU(head_pc)) {
-		enum lru_list lru;
-		struct mem_cgroup_per_zone *mz;
-		/*
-		 * We hold lru_lock, then, reduce counter directly.
-		 */
-		lru = page_lru(head);
-		mz = page_cgroup_zoneinfo(head_pc->mem_cgroup, head);
-		MEM_CGROUP_ZSTAT(mz, lru) -= HPAGE_PMD_NR - 1;
-	}
 }
 #endif
 
@@ -2690,22 +2604,6 @@ static void
 __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 					enum charge_type ctype);
 
-static void
-__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
-					enum charge_type ctype)
-{
-	struct page_cgroup *pc = lookup_page_cgroup(page);
-	/*
-	 * In some case, SwapCache, FUSE(splice_buf->radixtree), the page
-	 * is already on LRU. It means the page may on some other page_cgroup's
-	 * LRU. Take care of it.
-	 */
-	mem_cgroup_lru_del_before_commit(page);
-	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
-	mem_cgroup_lru_add_after_commit(page);
-	return;
-}
-
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
@@ -2730,7 +2628,8 @@ int mem_cgroup_cache_charge(struct page
 		 * put that would remove them from the LRU list, make
 		 * sure that they get relinked properly.
 		 */
-		__mem_cgroup_commit_charge_lrucare(page, memcg,
+		__mem_cgroup_commit_charge(memcg, page,
+					1, lookup_page_cgroup(page),
 					MEM_CGROUP_CHARGE_TYPE_CACHE);
 		return ret;
 	}
@@ -2798,7 +2697,8 @@ __mem_cgroup_commit_charge_swapin(struct
 		return;
 	cgroup_exclude_rmdir(&memcg->css);
 
-	__mem_cgroup_commit_charge_lrucare(page, memcg, ctype);
+	__mem_cgroup_commit_charge(memcg, page,
+				   1, lookup_page_cgroup(page), ctype);
 	/*
 	 * Now swap is on-memory. This means this page may be
 	 * counted both as mem and swap....double count.
@@ -2902,7 +2802,6 @@ direct_uncharge:
 		res_counter_uncharge(&memcg->memsw, nr_pages * PAGE_SIZE);
 	if (unlikely(batch->memcg != memcg))
 		memcg_oom_recover(memcg);
-	return;
 }
 
 /*
@@ -2961,11 +2860,31 @@ __mem_cgroup_uncharge_common(struct page
 
 	ClearPageCgroupUsed(pc);
 	/*
-	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
-	 * freed from LRU. This is safe because uncharged page is expected not
-	 * to be reused (freed soon). Exception is SwapCache, it's handled by
-	 * special functions.
+	 * Make sure that mem_cgroup_move_uncharged_to_root()
+	 * can see that before we test PageLRU(page).
 	 */
+	smp_mb__after_clear_bit();
+
+	/*
+	 * Once an uncharged page is isolated from the mem_cgroup's lru,
+	 * it no longer protects that mem_cgroup from rmdir: move to root.
+	 *
+	 * The page_count() test avoids the lock in the common case when
+	 * shrink_page_list()'s __remove_mapping() has frozen references
+	 * to 0 and the page is on its way to freedom.
+	 */
+	if (!PageLRU(page) && pc->mem_cgroup != root_mem_cgroup) {
+		struct lruvec *lruvec = NULL;
+		unsigned long flags;
+		int locked;
+
+		if ((locked = page_count(page)))
+			lock_page_lru_irqsave(page, &lruvec, &flags);
+		if (!PageLRU(page))
+			pc->mem_cgroup = root_mem_cgroup;
+		if (locked)
+			spin_unlock_irqrestore(&lruvec->lru_lock, flags);
+	}
 
 	unlock_page_cgroup(pc);
 	/*
@@ -3316,7 +3235,11 @@ static struct page_cgroup *lookup_page_c
 	 * Can be NULL while feeding pages into the page allocator for
 	 * the first time, i.e. during boot or memory hotplug.
 	 */
-	if (likely(pc) && PageCgroupUsed(pc))
+	if (unlikely(!pc))
+		return NULL;
+	if (PageCgroupUsed(pc))
+		return pc;
+	if (pc->mem_cgroup && pc->mem_cgroup != root_mem_cgroup)
 		return pc;
 	return NULL;
 }
@@ -3335,23 +3258,8 @@ void mem_cgroup_print_bad_page(struct pa
 
 	pc = lookup_page_cgroup_used(page);
 	if (pc) {
-		int ret = -1;
-		char *path;
-
-		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p",
+		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p\n",
 		       pc, pc->flags, pc->mem_cgroup);
-
-		path = kmalloc(PATH_MAX, GFP_KERNEL);
-		if (path) {
-			rcu_read_lock();
-			ret = cgroup_path(pc->mem_cgroup->css.cgroup,
-							path, PATH_MAX);
-			rcu_read_unlock();
-		}
-
-		printk(KERN_CONT "(%s)\n",
-				(ret < 0) ? "cannot get the path" : path);
-		kfree(path);
 	}
 }
 #endif
@@ -3596,7 +3504,7 @@ static int mem_cgroup_force_empty_list(s
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
 	list = &mz->lruvec.lists[lru];
 
-	loop = MEM_CGROUP_ZSTAT(mz, lru);
+	loop = mz->count[lru];
 	/* give some margin against EBUSY etc...*/
 	loop += 256;
 	busy = NULL;
@@ -3605,19 +3513,19 @@ static int mem_cgroup_force_empty_list(s
 		struct page *page;
 
 		ret = 0;
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		spin_lock_irqsave(&mz->lruvec.lru_lock, flags);
 		if (list_empty(list)) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			spin_unlock_irqrestore(&mz->lruvec.lru_lock, flags);
 			break;
 		}
 		page = list_entry(list->prev, struct page, lru);
 		if (busy == page) {
 			list_move(&page->lru, list);
 			busy = NULL;
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			spin_unlock_irqrestore(&mz->lruvec.lru_lock, flags);
 			continue;
 		}
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(&mz->lruvec.lru_lock, flags);
 
 		pc = lookup_page_cgroup(page);
 
@@ -3670,10 +3578,10 @@ move_account:
 		mem_cgroup_start_move(memcg);
 		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
-				enum lru_list l;
-				for_each_lru(l) {
+				enum lru_list lru;
+				for_each_lru(lru) {
 					ret = mem_cgroup_force_empty_list(memcg,
-							node, zid, l);
+							node, zid, lru);
 					if (ret)
 						break;
 				}
@@ -3906,7 +3814,6 @@ static void memcg_get_hierarchical_limit
 out:
 	*mem_limit = min_limit;
 	*memsw_limit = min_memsw_limit;
-	return;
 }
 
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
@@ -4065,38 +3972,38 @@ static int mem_control_numa_stat_show(st
 	unsigned long total_nr, file_nr, anon_nr, unevictable_nr;
 	unsigned long node_nr;
 	struct cgroup *cont = m->private;
-	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
-	total_nr = mem_cgroup_nr_lru_pages(mem_cont, LRU_ALL);
+	total_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL);
 	seq_printf(m, "total=%lu", total_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid, LRU_ALL);
+		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
 
-	file_nr = mem_cgroup_nr_lru_pages(mem_cont, LRU_ALL_FILE);
+	file_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_FILE);
 	seq_printf(m, "file=%lu", file_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid,
+		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
 				LRU_ALL_FILE);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
 
-	anon_nr = mem_cgroup_nr_lru_pages(mem_cont, LRU_ALL_ANON);
+	anon_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_ANON);
 	seq_printf(m, "anon=%lu", anon_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid,
+		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
 				LRU_ALL_ANON);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
 
-	unevictable_nr = mem_cgroup_nr_lru_pages(mem_cont, BIT(LRU_UNEVICTABLE));
+	unevictable_nr = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_UNEVICTABLE));
 	seq_printf(m, "unevictable=%lu", unevictable_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid,
+		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
 				BIT(LRU_UNEVICTABLE));
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
@@ -4108,12 +4015,12 @@ static int mem_control_numa_stat_show(st
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				 struct cgroup_map_cb *cb)
 {
-	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	struct mcs_total_stat mystat;
 	int i;
 
 	memset(&mystat, 0, sizeof(mystat));
-	mem_cgroup_get_local_stat(mem_cont, &mystat);
+	mem_cgroup_get_local_stat(memcg, &mystat);
 
 
 	for (i = 0; i < NR_MCS_STAT; i++) {
@@ -4125,14 +4032,14 @@ static int mem_control_stat_show(struct
 	/* Hierarchical information */
 	{
 		unsigned long long limit, memsw_limit;
-		memcg_get_hierarchical_limit(mem_cont, &limit, &memsw_limit);
+		memcg_get_hierarchical_limit(memcg, &limit, &memsw_limit);
 		cb->fill(cb, "hierarchical_memory_limit", limit);
 		if (do_swap_account)
 			cb->fill(cb, "hierarchical_memsw_limit", memsw_limit);
 	}
 
 	memset(&mystat, 0, sizeof(mystat));
-	mem_cgroup_get_total_stat(mem_cont, &mystat);
+	mem_cgroup_get_total_stat(memcg, &mystat);
 	for (i = 0; i < NR_MCS_STAT; i++) {
 		if (i == MCS_SWAP && !do_swap_account)
 			continue;
@@ -4148,7 +4055,7 @@ static int mem_control_stat_show(struct
 
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
+				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
 				recent_rotated[0] +=
 					mz->reclaim_stat.recent_rotated[0];
@@ -4672,7 +4579,7 @@ static int alloc_mem_cgroup_per_zone_inf
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
-	enum lru_list l;
+	enum lru_list lru;
 	int zone, tmp = node;
 	/*
 	 * This routine is called against possible nodes.
@@ -4690,8 +4597,9 @@ static int alloc_mem_cgroup_per_zone_inf
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		for_each_lru(l)
-			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
+		spin_lock_init(&mz->lruvec.lru_lock);
+		for_each_lru(lru)
+			INIT_LIST_HEAD(&mz->lruvec.lists[lru]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = memcg;
@@ -4707,29 +4615,29 @@ static void free_mem_cgroup_per_zone_inf
 
 static struct mem_cgroup *mem_cgroup_alloc(void)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	int size = sizeof(struct mem_cgroup);
 
 	/* Can be very big if MAX_NUMNODES is very big */
 	if (size < PAGE_SIZE)
-		mem = kzalloc(size, GFP_KERNEL);
+		memcg = kzalloc(size, GFP_KERNEL);
 	else
-		mem = vzalloc(size);
+		memcg = vzalloc(size);
 
-	if (!mem)
+	if (!memcg)
 		return NULL;
 
-	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
-	if (!mem->stat)
+	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
+	if (!memcg->stat)
 		goto out_free;
-	spin_lock_init(&mem->pcp_counter_lock);
-	return mem;
+	spin_lock_init(&memcg->pcp_counter_lock);
+	return memcg;
 
 out_free:
 	if (size < PAGE_SIZE)
-		kfree(mem);
+		kfree(memcg);
 	else
-		vfree(mem);
+		vfree(memcg);
 	return NULL;
 }
 
diff -purN 3023n/mm/page_alloc.c 3023nhh/mm/page_alloc.c
--- 3023n/mm/page_alloc.c	2011-12-03 12:49:49.892215197 -0800
+++ 3023nhh/mm/page_alloc.c	2011-12-03 13:59:33.992940800 -0800
@@ -4486,7 +4486,7 @@ static void __paginginit free_area_init_
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
+		spin_lock_init(&zone->lruvec.lru_lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
diff -purN 3023n/mm/rmap.c 3023nhh/mm/rmap.c
--- 3023n/mm/rmap.c	2011-12-03 12:49:49.900215238 -0800
+++ 3023nhh/mm/rmap.c	2011-12-03 13:59:33.992940800 -0800
@@ -26,7 +26,7 @@
  *       mapping->i_mmap_mutex
  *         anon_vma->mutex
  *           mm->page_table_lock or pte_lock
- *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
+ *             lruvec.lru_lock (in mark_page_accessed, isolate_lru_page)
  *             swap_lock (in swap_duplicate, swap_info_get)
  *               mmlist_lock (in mmput, drain_mmlist and others)
  *               mapping->private_lock (in __set_page_dirty_buffers)
diff -purN 3023n/mm/swap.c 3023nhh/mm/swap.c
--- 3023n/mm/swap.c	2011-12-03 12:49:49.908215283 -0800
+++ 3023nhh/mm/swap.c	2011-12-04 15:33:40.313491574 -0800
@@ -23,7 +23,6 @@
 #include <linux/init.h>
 #include <linux/export.h>
 #include <linux/mm_inline.h>
-#include <linux/buffer_head.h>	/* for try_to_release_page() */
 #include <linux/percpu_counter.h>
 #include <linux/percpu.h>
 #include <linux/cpu.h>
@@ -41,6 +40,30 @@ static DEFINE_PER_CPU(struct pagevec[NR_
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
+#ifndef CONFIG_CGROUP_MEM_RES_CTLR
+/*
+ * This is the simple version: see mm/memcontrol.c for the full version.
+ */
+void lock_page_lru_irqsave(struct page *page, struct lruvec **lruvec,
+			   unsigned long *flags)
+{
+	struct lruvec *new_lruvec = &page_zone(page)->lruvec;
+
+	/*
+	 * Sometimes we are called with non-NULL lruvec spinlock already held:
+	 * hold on if we want the same again, otherwise drop and acquire.
+	 */
+	if (*lruvec && *lruvec != new_lruvec) {
+		spin_unlock_irqrestore(&(*lruvec)->lru_lock, *flags);
+		*lruvec = NULL;
+	}
+	if (!*lruvec) {
+		*lruvec = new_lruvec;
+		spin_lock_irqsave(&new_lruvec->lru_lock, *flags);
+	}
+}
+#endif /* !CONFIG_CGROUP_MEM_RES_CTLR */
+
 /*
  * This path almost never happens for VM activity - pages are normally
  * freed via pagevecs.  But it gets used by networking.
@@ -48,14 +71,15 @@ static DEFINE_PER_CPU(struct pagevec, lr
 static void __page_cache_release(struct page *page)
 {
 	if (PageLRU(page)) {
-		unsigned long flags;
 		struct zone *zone = page_zone(page);
+		struct lruvec *lruvec = NULL;
+		unsigned long flags;
 
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		lock_page_lru_irqsave(page, &lruvec, &flags);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
-		del_page_from_lru(zone, page);
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		del_page_from_lru_list(zone, page, lruvec, page_off_lru(page));
+		spin_unlock_irqrestore(&lruvec->lru_lock, flags);
 	}
 }
 
@@ -203,42 +227,32 @@ void put_pages_list(struct list_head *pa
 EXPORT_SYMBOL(put_pages_list);
 
 static void pagevec_lru_move_fn(struct pagevec *pvec,
-				void (*move_fn)(struct page *page, void *arg),
-				void *arg)
+	void (*move_fn)(struct page *page, struct lruvec *lruvec, void *arg),
+	void *arg)
 {
 	int i;
-	struct zone *zone = NULL;
+	struct lruvec *lruvec = NULL;
 	unsigned long flags = 0;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
 
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-			zone = pagezone;
-			spin_lock_irqsave(&zone->lru_lock, flags);
-		}
-
-		(*move_fn)(page, arg);
+		lock_page_lru_irqsave(page, &lruvec, &flags);
+		(*move_fn)(page, lruvec, arg);
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (lruvec)
+		spin_unlock_irqrestore(&lruvec->lru_lock, flags);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
 
-static void pagevec_move_tail_fn(struct page *page, void *arg)
+static void pagevec_move_tail_fn(struct page *page, struct lruvec *lruvec,
+				 void *arg)
 {
 	int *pgmoved = arg;
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		struct lruvec *lruvec;
-
-		lruvec = mem_cgroup_lru_move_lists(page_zone(page),
-						   page, lru, lru);
 		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		(*pgmoved)++;
 	}
@@ -297,25 +311,24 @@ static void update_page_reclaim_stat(str
 		memcg_reclaim_stat->recent_rotated[file]++;
 }
 
-static void __activate_page(struct page *page, void *arg)
+static void __activate_page(struct page *page, struct lruvec *lruvec,
+			    void *arg)
 {
-	struct zone *zone = page_zone(page);
-
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
+		struct zone *zone = page_zone(page);
 		int file = page_is_file_cache(page);
 		int lru = page_lru_base_type(page);
-		del_page_from_lru_list(zone, page, lru);
 
+		del_page_from_lru_list(zone, page, lruvec, lru);
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
-		add_page_to_lru_list(zone, page, lru);
-		__count_vm_event(PGACTIVATE);
+		add_page_to_lru_list(zone, page, lruvec, lru);
 
+		__count_vm_event(PGACTIVATE);
 		update_page_reclaim_stat(zone, page, file, 1);
 	}
 }
 
-#ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
 
 static void activate_page_drain(int cpu)
@@ -338,21 +351,6 @@ void activate_page(struct page *page)
 	}
 }
 
-#else
-static inline void activate_page_drain(int cpu)
-{
-}
-
-void activate_page(struct page *page)
-{
-	struct zone *zone = page_zone(page);
-
-	spin_lock_irq(&zone->lru_lock);
-	__activate_page(page, NULL);
-	spin_unlock_irq(&zone->lru_lock);
-}
-#endif
-
 /*
  * Mark a page as having seen activity.
  *
@@ -370,7 +368,6 @@ void mark_page_accessed(struct page *pag
 		SetPageReferenced(page);
 	}
 }
-
 EXPORT_SYMBOL(mark_page_accessed);
 
 void __lru_cache_add(struct page *page, enum lru_list lru)
@@ -379,7 +376,7 @@ void __lru_cache_add(struct page *page,
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		____pagevec_lru_add(pvec, lru);
+		__pagevec_lru_add(pvec, lru);
 	put_cpu_var(lru_add_pvecs);
 }
 EXPORT_SYMBOL(__lru_cache_add);
@@ -416,12 +413,14 @@ void lru_cache_add_lru(struct page *page
 void add_page_to_unevictable_list(struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec = NULL;
+	unsigned long flags;
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_page_lru_irqsave(page, &lruvec, &flags);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
-	add_page_to_lru_list(zone, page, LRU_UNEVICTABLE);
-	spin_unlock_irq(&zone->lru_lock);
+	add_page_to_lru_list(zone, page, lruvec, LRU_UNEVICTABLE);
+	spin_unlock_irqrestore(&lruvec->lru_lock, flags);
 }
 
 /*
@@ -445,7 +444,8 @@ void add_page_to_unevictable_list(struct
  * be write it out by flusher threads as this is much more effective
  * than the single-page writeout from reclaim.
  */
-static void lru_deactivate_fn(struct page *page, void *arg)
+static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
+			      void *arg)
 {
 	int lru, file;
 	bool active;
@@ -462,28 +462,25 @@ static void lru_deactivate_fn(struct pag
 		return;
 
 	active = PageActive(page);
-
 	file = page_is_file_cache(page);
 	lru = page_lru_base_type(page);
-	del_page_from_lru_list(zone, page, lru + active);
+
+	del_page_from_lru_list(zone, page, lruvec, lru + active);
 	ClearPageActive(page);
 	ClearPageReferenced(page);
-	add_page_to_lru_list(zone, page, lru);
+	add_page_to_lru_list(zone, page, lruvec, lru);
 
 	if (PageWriteback(page) || PageDirty(page)) {
 		/*
-		 * PG_reclaim could be raced with end_page_writeback
+		 * PG_reclaim could have raced with end_page_writeback.
 		 * It can make readahead confusing.  But race window
 		 * is _really_ small and  it's non-critical problem.
 		 */
 		SetPageReclaim(page);
 	} else {
-		struct lruvec *lruvec;
 		/*
-		 * The page's writeback ends up during pagevec
-		 * We moves tha page into tail of inactive.
+		 * We move the page to tail of inactive.
 		 */
-		lruvec = mem_cgroup_lru_move_lists(zone, page, lru, lru);
 		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		__count_vm_event(PGROTATED);
 	}
@@ -507,7 +504,7 @@ static void drain_cpu_pagevecs(int cpu)
 	for_each_lru(lru) {
 		pvec = &pvecs[lru - LRU_BASE];
 		if (pagevec_count(pvec))
-			____pagevec_lru_add(pvec, lru);
+			__pagevec_lru_add(pvec, lru);
 	}
 
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
@@ -538,7 +535,7 @@ static void drain_cpu_pagevecs(int cpu)
 void deactivate_page(struct page *page)
 {
 	/*
-	 * In a workload with many unevictable page such as mprotect, unevictable
+	 * In a workload with many unevictable page such as mlock, unevictable
 	 * page deactivation for accelerating reclaim is pointless.
 	 */
 	if (PageUnevictable(page))
@@ -577,7 +574,7 @@ int lru_add_drain_all(void)
  * passed pages.  If it fell to zero then remove the page from the LRU and
  * free it.
  *
- * Avoid taking zone->lru_lock if possible, but if it is taken, retain it
+ * Avoid taking lruvec.lru_lock if possible, but if it is taken, retain it
  * for the remainder of the operation.
  *
  * The locking in this function is against shrink_inactive_list(): we recheck
@@ -589,16 +586,17 @@ void release_pages(struct page **pages,
 {
 	int i;
 	LIST_HEAD(pages_to_free);
-	struct zone *zone = NULL;
+	struct lruvec *lruvec = NULL;
 	unsigned long uninitialized_var(flags);
 
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
 		if (unlikely(PageCompound(page))) {
-			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-				zone = NULL;
+			if (lruvec) {
+				spin_unlock_irqrestore(&lruvec->lru_lock,
+							flags);
+				lruvec = NULL;
 			}
 			put_compound_page(page);
 			continue;
@@ -608,24 +606,17 @@ void release_pages(struct page **pages,
 			continue;
 
 		if (PageLRU(page)) {
-			struct zone *pagezone = page_zone(page);
-
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irqrestore(&zone->lru_lock,
-									flags);
-				zone = pagezone;
-				spin_lock_irqsave(&zone->lru_lock, flags);
-			}
+			lock_page_lru_irqsave(page, &lruvec, &flags);
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
-			del_page_from_lru(zone, page);
+			del_page_from_lru_list(page_zone(page), page,
+						lruvec, page_off_lru(page));
 		}
 
 		list_add(&page->lru, &pages_to_free);
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (lruvec)
+		spin_unlock_irqrestore(&lruvec->lru_lock, flags);
 
 	free_hot_cold_page_list(&pages_to_free, cold);
 }
@@ -638,8 +629,7 @@ EXPORT_SYMBOL(release_pages);
  * cache-warm and we want to give them back to the page allocator ASAP.
  *
  * So __pagevec_release() will drain those queues here.  __pagevec_lru_add()
- * and __pagevec_lru_add_active() call release_pages() directly to avoid
- * mutual recursion.
+ * calls release_pages() directly to avoid mutual recursion.
  */
 void __pagevec_release(struct pagevec *pvec)
 {
@@ -647,11 +637,11 @@ void __pagevec_release(struct pagevec *p
 	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
 	pagevec_reinit(pvec);
 }
-
 EXPORT_SYMBOL(__pagevec_release);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /* used by __split_huge_page_refcount() */
-void lru_add_page_tail(struct zone* zone,
+void lru_add_page_tail(struct zone *zone, struct lruvec *lruvec,
 		       struct page *page, struct page *page_tail)
 {
 	int active;
@@ -661,13 +651,11 @@ void lru_add_page_tail(struct zone* zone
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
 	VM_BUG_ON(PageLRU(page_tail));
-	VM_BUG_ON(!spin_is_locked(&zone->lru_lock));
+	VM_BUG_ON(!spin_is_locked(&lruvec->lru_lock));
 
 	SetPageLRU(page_tail);
 
 	if (page_evictable(page_tail, NULL)) {
-		struct lruvec *lruvec;
-
 		if (PageActive(page)) {
 			SetPageActive(page_tail);
 			active = 1;
@@ -677,20 +665,26 @@ void lru_add_page_tail(struct zone* zone
 			lru = LRU_INACTIVE_ANON;
 		}
 		update_page_reclaim_stat(zone, page_tail, file, active);
-		lruvec = mem_cgroup_lru_add_list(zone, page_tail, lru);
-		if (likely(PageLRU(page)))
-			list_add(&page_tail->lru, page->lru.prev);
-		else
-			list_add(&page_tail->lru, lruvec->lists[lru].prev);
-		__mod_zone_page_state(zone, NR_LRU_BASE + lru,
-				      hpage_nr_pages(page_tail));
 	} else {
 		SetPageUnevictable(page_tail);
-		add_page_to_lru_list(zone, page_tail, LRU_UNEVICTABLE);
+		lru = LRU_UNEVICTABLE;
+	}
+
+	if (likely(PageLRU(page)))
+		list_add(&page_tail->lru, page->lru.prev);
+	else {
+		/*
+		 * Head page has not yet been counted, as an hpage,
+		 * so we must account for each subpage individually.
+		 */
+		add_page_to_lru_list(zone, page_tail, lruvec, lru);
+		list_move(&page_tail->lru, lruvec->lists[lru].prev);
 	}
 }
+#endif
 
-static void ____pagevec_lru_add_fn(struct page *page, void *arg)
+static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
+				 void *arg)
 {
 	enum lru_list lru = (enum lru_list)arg;
 	struct zone *zone = page_zone(page);
@@ -705,39 +699,20 @@ static void ____pagevec_lru_add_fn(struc
 	if (active)
 		SetPageActive(page);
 	update_page_reclaim_stat(zone, page, file, active);
-	add_page_to_lru_list(zone, page, lru);
+	add_page_to_lru_list(zone, page, lruvec, lru);
 }
 
 /*
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
-void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
+void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 {
 	VM_BUG_ON(is_unevictable_lru(lru));
 
-	pagevec_lru_move_fn(pvec, ____pagevec_lru_add_fn, (void *)lru);
-}
-
-EXPORT_SYMBOL(____pagevec_lru_add);
-
-/*
- * Try to drop buffers from the pages in a pagevec
- */
-void pagevec_strip(struct pagevec *pvec)
-{
-	int i;
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-
-		if (page_has_private(page) && trylock_page(page)) {
-			if (page_has_private(page))
-				try_to_release_page(page, 0);
-			unlock_page(page);
-		}
-	}
+	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, (void *)lru);
 }
+EXPORT_SYMBOL(__pagevec_lru_add);
 
 /**
  * pagevec_lookup - gang pagecache lookup
@@ -761,7 +736,6 @@ unsigned pagevec_lookup(struct pagevec *
 	pvec->nr = find_get_pages(mapping, start, nr_pages, pvec->pages);
 	return pagevec_count(pvec);
 }
-
 EXPORT_SYMBOL(pagevec_lookup);
 
 unsigned pagevec_lookup_tag(struct pagevec *pvec, struct address_space *mapping,
@@ -771,7 +745,6 @@ unsigned pagevec_lookup_tag(struct pagev
 					nr_pages, pvec->pages);
 	return pagevec_count(pvec);
 }
-
 EXPORT_SYMBOL(pagevec_lookup_tag);
 
 /*
diff -purN 3023n/mm/vmscan.c 3023nhh/mm/vmscan.c
--- 3023n/mm/vmscan.c	2011-12-03 12:49:49.920215342 -0800
+++ 3023nhh/mm/vmscan.c	2011-12-04 22:42:31.384618033 -0800
@@ -982,11 +982,6 @@ static unsigned long shrink_page_list(st
 		__clear_page_locked(page);
 free_it:
 		nr_reclaimed++;
-
-		/*
-		 * Is there need to periodically free_page_list? It would
-		 * appear not as the counts should be low
-		 */
 		list_add(&page->lru, &free_pages);
 		continue;
 
@@ -1083,19 +1078,136 @@ int __isolate_lru_page(struct page *page
 
 	if (likely(get_page_unless_zero(page))) {
 		/*
-		 * Be careful not to clear PageLRU until after we're
-		 * sure the page is not being freed elsewhere -- the
-		 * page release code relies on it.
+		 * Beware of interface change: now leave ClearPageLRU(page)
+		 * to the caller, because the lumpy memcg case may not have
+		 * the right lru lock yet.
 		 */
-		ClearPageLRU(page);
 		ret = 0;
 	}
 
 	return ret;
 }
 
+struct lumpy_stats {
+	unsigned long nr_taken;
+	unsigned long nr_dirty;
+	unsigned long nr_failed;
+};
+
+static unsigned long isolate_lumpy_pages(struct page *page,
+		struct list_head *dst, struct lumpy_stats *lumpy,
+		int order, int mode, int file,
+		struct lruvec *lruvec, unsigned long *flags)
+{
+	int zone_id = page_zone_id(page);
+	unsigned long page_pfn = page_to_pfn(page);
+	unsigned long pfn = page_pfn & ~((1 << order) - 1);
+	unsigned long end_pfn = pfn + (1 << order);
+	unsigned long lump = 0;
+	struct lruvec *home_lruvec = lruvec;
+
+	/*
+	 * Attempt to take all pages in the order aligned region
+	 * surrounding the tag page.  Only take those pages of
+	 * the same active state as that tag page.  We may safely
+	 * round the target page pfn down to the requested order
+	 * as the mem_map is guarenteed valid out to MAX_ORDER,
+	 * where that page is in a different zone we will detect
+	 * it from its zone id and abort this block scan.
+	 */
+
+	for (; pfn < end_pfn; pfn++) {
+
+		/* The target page is in the block, ignore it. */
+		if (unlikely(pfn == page_pfn))
+			continue;
+
+		/* Avoid holes within the zone. */
+		if (unlikely(!pfn_valid_within(pfn)))
+			break;
+
+		page = pfn_to_page(pfn);
+
+		/* Check that we have not crossed a zone boundary. */
+		if (unlikely(page_zone_id(page) != zone_id))
+			break;
+
+		/*
+		 * If we don't have enough swap space, reclaiming of swap
+		 * backed pages which don't already have a swap slot is
+		 * pointless.
+		 */
+		if (nr_swap_pages <= 0 &&
+		    PageSwapBacked(page) && !PageSwapCache(page))
+			break;
+
+		if (__isolate_lru_page(page, mode, file) == 0) {
+			/*
+			 * This locking call is a no-op in the non-memcg
+			 * case, since we already hold the right lru lock;
+			 * but it may change the lock in the memcg case.
+			 * It is then vital to recheck PageLRU, but not
+			 * important to recheck isolation mode.
+			 */
+			lock_page_lru_irqsave(page, &lruvec, flags);
+			if (PageLRU(page) && !PageUnevictable(page)) {
+				unsigned int isolated_pages;
+
+				ClearPageLRU(page);
+				isolated_pages = hpage_nr_pages(page);
+				mem_cgroup_move_uncharged_to_root(page);
+				mem_cgroup_update_lru_count(lruvec,
+					page_lru(page), -isolated_pages);
+				list_move(&page->lru, dst);
+
+				lump += isolated_pages;
+				lumpy->nr_taken += isolated_pages;
+				if (PageDirty(page))
+					lumpy->nr_dirty += isolated_pages;
+				pfn += isolated_pages - 1;
+			} else {
+				/* Cannot hold lru_lock while freeing page */
+				spin_unlock_irqrestore(&lruvec->lru_lock,
+							*flags);
+				lruvec = NULL;
+				put_page(page);
+				break;
+			}
+		} else {
+			/*
+			 * Check if the page is freed already.
+			 *
+			 * We can't use page_count() as that
+			 * requires compound_head and we don't
+			 * have a pin on the page here. If a
+			 * page is tail, we may or may not
+			 * have isolated the head, so assume
+			 * it's not free, it'd be tricky to
+			 * track the head status without a
+			 * page pin.
+			 */
+			if (!PageTail(page) &&
+			    !atomic_read(&page->_count))
+				continue;
+			break;
+		}
+	}
+
+	/* If we break out of the loop above, lumpy reclaim failed */
+	if (pfn < end_pfn)
+		lumpy->nr_failed++;
+
+	if (lruvec != home_lruvec) {
+		if (lruvec)
+			spin_unlock_irqrestore(&lruvec->lru_lock, *flags);
+		lruvec = home_lruvec;
+		spin_lock_irqsave(&lruvec->lru_lock, *flags);
+	}
+	return lump;
+}
+
 /*
- * zone->lru_lock is heavily contended.  Some of the functions that
+ * lruvec.lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
  *
@@ -1105,43 +1217,59 @@ int __isolate_lru_page(struct page *page
  * Appropriate locks must be held before calling this function.
  *
  * @nr_to_scan:	The number of pages to look through on the list.
- * @src:	The LRU list to pull pages off.
  * @dst:	The temp list to put pages on to.
  * @scanned:	The number of pages that were scanned.
  * @order:	The caller's attempted allocation order
  * @mode:	One of the LRU isolation modes
- * @file:	True [1] if isolating file [!anon] pages
+ * @active:	True (1) if isolating active pages
+ * @file:	True (1) if isolating file (!swapbacked) pages
+ * @lruvec:	The LRU vector to take pages from (with lru_lock)
+ * @flags:	Saved IRQ flags to restore when dropping lru_lock
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
-		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, isolate_mode_t mode,
-		int file)
+		struct list_head *dst, unsigned long *scanned,
+		int order, isolate_mode_t mode, int active, int file,
+		struct lruvec *lruvec, unsigned long *flags)
 {
+	struct lumpy_stats lumpy = {0, 0, 0};
 	unsigned long nr_taken = 0;
-	unsigned long nr_lumpy_taken = 0;
-	unsigned long nr_lumpy_dirty = 0;
-	unsigned long nr_lumpy_failed = 0;
 	unsigned long scan;
+	struct list_head *src;
+	int lru = LRU_BASE;
+
+	if (active)
+		lru += LRU_ACTIVE;
+	if (file)
+		lru += LRU_FILE;
+	src = &lruvec->lists[lru];
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
-		unsigned long pfn;
-		unsigned long end_pfn;
-		unsigned long page_pfn;
-		int zone_id;
+		int nr_pages;
 
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
 
-		VM_BUG_ON(!PageLRU(page));
-
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
-			mem_cgroup_lru_del(page);
+#ifdef CONFIG_DEBUG_VM
+		{
+			struct lruvec *home_lruvec = lruvec;
+			/* check lock on page is lock we already got */
+			lock_page_lru_irqsave(page, &lruvec, flags);
+			BUG_ON(lruvec != home_lruvec);
+			BUG_ON(page != lru_to_page(src));
+			BUG_ON(page_lru(page) != lru);
+		}
+#endif
+			ClearPageLRU(page);
+			nr_pages = hpage_nr_pages(page);
+			mem_cgroup_move_uncharged_to_root(page);
+			mem_cgroup_update_lru_count(lruvec, lru, -nr_pages);
 			list_move(&page->lru, dst);
-			nr_taken += hpage_nr_pages(page);
+			nr_taken += nr_pages;
 			break;
 
 		case -EBUSY:
@@ -1153,106 +1281,21 @@ static unsigned long isolate_lru_pages(u
 			BUG();
 		}
 
-		if (!order)
-			continue;
-
-		/*
-		 * Attempt to take all pages in the order aligned region
-		 * surrounding the tag page.  Only take those pages of
-		 * the same active state as that tag page.  We may safely
-		 * round the target page pfn down to the requested order
-		 * as the mem_map is guaranteed valid out to MAX_ORDER,
-		 * where that page is in a different zone we will detect
-		 * it from its zone id and abort this block scan.
-		 */
-		zone_id = page_zone_id(page);
-		page_pfn = page_to_pfn(page);
-		pfn = page_pfn & ~((1 << order) - 1);
-		end_pfn = pfn + (1 << order);
-		for (; pfn < end_pfn; pfn++) {
-			struct page *cursor_page;
-
-			/* The target page is in the block, ignore it. */
-			if (unlikely(pfn == page_pfn))
-				continue;
-
-			/* Avoid holes within the zone. */
-			if (unlikely(!pfn_valid_within(pfn)))
-				break;
-
-			cursor_page = pfn_to_page(pfn);
-
-			/* Check that we have not crossed a zone boundary. */
-			if (unlikely(page_zone_id(cursor_page) != zone_id))
-				break;
-
-			/*
-			 * If we don't have enough swap space, reclaiming of
-			 * anon page which don't already have a swap slot is
-			 * pointless.
-			 */
-			if (nr_swap_pages <= 0 && PageAnon(cursor_page) &&
-			    !PageSwapCache(cursor_page))
-				break;
-
-			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
-				mem_cgroup_lru_del(cursor_page);
-				list_move(&cursor_page->lru, dst);
-				nr_taken += hpage_nr_pages(page);
-				nr_lumpy_taken++;
-				if (PageDirty(cursor_page))
-					nr_lumpy_dirty++;
-				scan++;
-			} else {
-				/*
-				 * Check if the page is freed already.
-				 *
-				 * We can't use page_count() as that
-				 * requires compound_head and we don't
-				 * have a pin on the page here. If a
-				 * page is tail, we may or may not
-				 * have isolated the head, so assume
-				 * it's not free, it'd be tricky to
-				 * track the head status without a
-				 * page pin.
-				 */
-				if (!PageTail(cursor_page) &&
-				    !atomic_read(&cursor_page->_count))
-					continue;
-				break;
-			}
+		if (order) {
+			unsigned long lump;
+			lump = isolate_lumpy_pages(page, dst, &lumpy,
+					order, mode, file, lruvec, flags);
+			nr_taken += lump;
+			scan += lump;
 		}
-
-		/* If we break out of the loop above, lumpy reclaim failed */
-		if (pfn < end_pfn)
-			nr_lumpy_failed++;
 	}
 
 	*scanned = scan;
 
-	trace_mm_vmscan_lru_isolate(order,
-			nr_to_scan, scan,
-			nr_taken,
-			nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
-			mode);
-	return nr_taken;
-}
-
-static unsigned long isolate_pages(unsigned long nr, struct mem_cgroup_zone *mz,
-				   struct list_head *dst,
-				   unsigned long *scanned, int order,
-				   isolate_mode_t mode, int active, int file)
-{
-	struct lruvec *lruvec;
-	int lru = LRU_BASE;
+	trace_mm_vmscan_lru_isolate(order, nr_to_scan, scan, nr_taken,
+		lumpy.nr_taken, lumpy.nr_dirty, lumpy.nr_failed, mode);
 
-	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
-	if (active)
-		lru += LRU_ACTIVE;
-	if (file)
-		lru += LRU_FILE;
-	return isolate_lru_pages(nr, &lruvec->lists[lru], dst,
-				 scanned, order, mode, file);
+	return nr_taken;
 }
 
 /*
@@ -1314,17 +1357,19 @@ int isolate_lru_page(struct page *page)
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
+		struct lruvec *lruvec = NULL;
+		unsigned long flags;
 
-		spin_lock_irq(&zone->lru_lock);
+		lock_page_lru_irqsave(page, &lruvec, &flags);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
-			ret = 0;
 			get_page(page);
 			ClearPageLRU(page);
-
-			del_page_from_lru_list(zone, page, lru);
+			mem_cgroup_move_uncharged_to_root(page);
+			del_page_from_lru_list(zone, page, lruvec, lru);
+			ret = 0;
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irqrestore(&lruvec->lru_lock, flags);
 	}
 	return ret;
 }
@@ -1358,56 +1403,75 @@ static int too_many_isolated(struct zone
  * TODO: Try merging with migrations version of putback_lru_pages
  */
 static noinline_for_stack void
-putback_lru_pages(struct mem_cgroup_zone *mz, struct scan_control *sc,
+putback_lru_pages(struct mem_cgroup_zone *mz,
 		  unsigned long nr_anon, unsigned long nr_file,
-		  struct list_head *page_list)
+		  unsigned long nr_reclaimed, struct list_head *page_list)
 {
 	struct page *page;
-	struct pagevec pvec;
+	LIST_HEAD(pages_to_free);
 	struct zone *zone = mz->zone;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
+	struct lruvec *lruvec;
+	unsigned long flags;
+	int lru;
 
-	pagevec_init(&pvec, 1);
+	lruvec = mem_cgroup_zone_lruvec(zone, mz->mem_cgroup);
+	/* use irqsave variant to get the flags to pass down */
+	spin_lock_irqsave(&lruvec->lru_lock, flags);
 
 	/*
 	 * Put back any unfreeable pages.
 	 */
-	spin_lock(&zone->lru_lock);
 	while (!list_empty(page_list)) {
-		int lru;
 		page = lru_to_page(page_list);
 		VM_BUG_ON(PageLRU(page));
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page, NULL))) {
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irq(&lruvec->lru_lock);
 			putback_lru_page(page);
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(&lruvec->lru_lock);
 			continue;
 		}
+
+		/* lock lru, occasionally changing lruvec */
+		lock_page_lru_irqsave(page, &lruvec, &flags);
+
 		SetPageLRU(page);
 		lru = page_lru(page);
-		add_page_to_lru_list(zone, page, lru);
+		add_page_to_lru_list(zone, page, lruvec, lru);
+
 		if (is_active_lru(lru)) {
 			int file = is_file_lru(lru);
 			int numpages = hpage_nr_pages(page);
 			reclaim_stat->recent_rotated[file] += numpages;
 		}
-		if (!pagevec_add(&pvec, page)) {
-			spin_unlock_irq(&zone->lru_lock);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+		if (put_page_testzero(page)) {
+			__ClearPageLRU(page);
+			__ClearPageActive(page);
+			del_page_from_lru_list(zone, page, lruvec, lru);
+
+			if (unlikely(PageCompound(page))) {
+				spin_unlock_irq(&lruvec->lru_lock);
+				(*get_compound_page_dtor(page))(page);
+				spin_lock_irq(&lruvec->lru_lock);
+			} else
+				list_add(&page->lru, &pages_to_free);
 		}
 	}
+
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
-	spin_unlock_irq(&zone->lru_lock);
-	pagevec_release(&pvec);
+	if (current_is_kswapd())
+		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
+	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
+
+	spin_unlock_irq(&lruvec->lru_lock);
+	free_hot_cold_page_list(&pages_to_free, 1);
 }
 
 static noinline_for_stack void
 update_isolated_counts(struct mem_cgroup_zone *mz,
-		       struct scan_control *sc,
 		       unsigned long *nr_anon,
 		       unsigned long *nr_file,
 		       struct list_head *isolated_list)
@@ -1497,6 +1561,8 @@ shrink_inactive_list(unsigned long nr_to
 	unsigned long nr_writeback = 0;
 	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
 	struct zone *zone = mz->zone;
+	struct lruvec *lruvec;
+	unsigned long flags;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1509,37 +1575,36 @@ shrink_inactive_list(unsigned long nr_to
 	set_reclaim_mode(priority, sc, false);
 	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
 		reclaim_mode |= ISOLATE_ACTIVE;
-
-	lru_add_drain();
-
 	if (!sc->may_unmap)
 		reclaim_mode |= ISOLATE_UNMAPPED;
 	if (!sc->may_writepage)
 		reclaim_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	lru_add_drain();
 
-	nr_taken = isolate_pages(nr_to_scan, mz, &page_list,
-				 &nr_scanned, sc->order,
-				 reclaim_mode, 0, file);
+	lruvec = mem_cgroup_zone_lruvec(zone, mz->mem_cgroup);
+	/* use irqsave variant to get the flags to pass down */
+	spin_lock_irqsave(&lruvec->lru_lock, flags);
+
+	nr_taken = isolate_lru_pages(nr_to_scan, &page_list, &nr_scanned,
+				     sc->order, reclaim_mode, 0, file,
+				     lruvec, &flags);
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
-			__count_zone_vm_events(PGSCAN_KSWAPD, zone,
-					       nr_scanned);
+			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scanned);
 		else
-			__count_zone_vm_events(PGSCAN_DIRECT, zone,
-					       nr_scanned);
+			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
 	}
 
 	if (nr_taken == 0) {
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(&lruvec->lru_lock);
 		return 0;
 	}
 
-	update_isolated_counts(mz, sc, &nr_anon, &nr_file, &page_list);
+	update_isolated_counts(mz, &nr_anon, &nr_file, &page_list);
 
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(&lruvec->lru_lock);
 
 	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
 						&nr_dirty, &nr_writeback);
@@ -1551,12 +1616,7 @@ shrink_inactive_list(unsigned long nr_to
 					priority, &nr_dirty, &nr_writeback);
 	}
 
-	local_irq_disable();
-	if (current_is_kswapd())
-		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
-	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
-
-	putback_lru_pages(mz, sc, nr_anon, nr_file, &page_list);
+	putback_lru_pages(mz, nr_anon, nr_file, nr_reclaimed, &page_list);
 
 	/*
 	 * If reclaim is isolating dirty pages under writeback, it implies
@@ -1599,9 +1659,9 @@ shrink_inactive_list(unsigned long nr_to
  * processes, from rmap.
  *
  * If the pages are mostly unmapped, the processing is fast and it is
- * appropriate to hold zone->lru_lock across the whole operation.  But if
+ * appropriate to hold lruvec.lru_lock across the whole operation.  But if
  * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop zone->lru_lock around each page.  It's impossible to balance
+ * should drop lruvec.lru_lock around each page.  It's impossible to balance
  * this, so instead we remove the pages from the LRU while processing them.
  * It is safe to rely on PG_active against the non-LRU pages in here because
  * nobody will play with that bit on a non-LRU page.
@@ -1612,34 +1672,55 @@ shrink_inactive_list(unsigned long nr_to
 
 static void move_active_pages_to_lru(struct zone *zone,
 				     struct list_head *list,
+				     struct list_head *pages_to_free,
 				     enum lru_list lru)
 {
 	unsigned long pgmoved = 0;
-	struct pagevec pvec;
 	struct page *page;
-
-	pagevec_init(&pvec, 1);
+	struct lruvec *lruvec = NULL;
+	unsigned long flags;
+	int nr_pages;
+
+	if (buffer_heads_over_limit) {
+		local_irq_enable();
+		list_for_each_entry(page, list, lru) {
+			if (page_has_private(page) && trylock_page(page)) {
+				if (page_has_private(page))
+					try_to_release_page(page, 0);
+				unlock_page(page);
+			}
+		}
+		local_irq_disable();
+	}
 
 	while (!list_empty(list)) {
-		struct lruvec *lruvec;
-
 		page = lru_to_page(list);
+		/* lock lru, occasionally changing lruvec */
+		lock_page_lru_irqsave(page, &lruvec, &flags);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		lruvec = mem_cgroup_lru_add_list(zone, page, lru);
+		nr_pages = hpage_nr_pages(page);
 		list_move(&page->lru, &lruvec->lists[lru]);
-		pgmoved += hpage_nr_pages(page);
+		mem_cgroup_update_lru_count(lruvec, lru, nr_pages);
+		pgmoved += nr_pages;
 
-		if (!pagevec_add(&pvec, page) || list_empty(list)) {
-			spin_unlock_irq(&zone->lru_lock);
-			if (buffer_heads_over_limit)
-				pagevec_strip(&pvec);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+		if (put_page_testzero(page)) {
+			__ClearPageLRU(page);
+			__ClearPageActive(page);
+			del_page_from_lru_list(zone, page, lruvec, lru);
+
+			if (unlikely(PageCompound(page))) {
+				spin_unlock_irq(&lruvec->lru_lock);
+				(*get_compound_page_dtor(page))(page);
+				spin_lock_irq(&lruvec->lru_lock);
+			} else
+				list_add(&page->lru, pages_to_free);
 		}
 	}
+	if (lruvec)
+		spin_unlock(&lruvec->lru_lock);
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
@@ -1661,20 +1742,23 @@ static void shrink_active_list(unsigned
 	unsigned long nr_rotated = 0;
 	isolate_mode_t reclaim_mode = ISOLATE_ACTIVE;
 	struct zone *zone = mz->zone;
-
-	lru_add_drain();
+	struct lruvec *lruvec = NULL;
+	unsigned long flags;
 
 	if (!sc->may_unmap)
 		reclaim_mode |= ISOLATE_UNMAPPED;
 	if (!sc->may_writepage)
 		reclaim_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
-
-	nr_taken = isolate_pages(nr_pages, mz, &l_hold,
-				 &pgscanned, sc->order,
-				 reclaim_mode, 1, file);
+	lru_add_drain();
 
+	lruvec = mem_cgroup_zone_lruvec(zone, mz->mem_cgroup);
+	/* use irqsave variant to get the flags to pass down */
+	spin_lock_irqsave(&lruvec->lru_lock, flags);
+
+	nr_taken = isolate_lru_pages(nr_pages, &l_hold, &pgscanned,
+				     sc->order, reclaim_mode, 1, file,
+				     lruvec, &flags);
 	if (global_reclaim(sc))
 		zone->pages_scanned += pgscanned;
 
@@ -1686,7 +1770,7 @@ static void shrink_active_list(unsigned
 	else
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(&lruvec->lru_lock);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1722,7 +1806,7 @@ static void shrink_active_list(unsigned
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	local_irq_disable();
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1731,12 +1815,14 @@ static void shrink_active_list(unsigned
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(zone, &l_active,
+	move_active_pages_to_lru(zone, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(zone, &l_inactive,
+	move_active_pages_to_lru(zone, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	local_irq_enable();
+
+	free_hot_cold_page_list(&l_hold, 1);
 }
 
 #ifdef CONFIG_SWAP
@@ -1866,6 +1952,7 @@ static void get_scan_count(struct mem_cg
 	enum lru_list l;
 	int noswap = 0;
 	bool force_scan = false;
+	struct lruvec *lruvec;
 
 	/*
 	 * If the zone or memcg is small, nr[l] can be 0.  This
@@ -1926,7 +2013,8 @@ static void get_scan_count(struct mem_cg
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&mz->zone->lru_lock);
+	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
+	spin_lock_irq(&lruvec->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -1947,7 +2035,7 @@ static void get_scan_count(struct mem_cg
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&mz->zone->lru_lock);
+	spin_unlock_irq(&lruvec->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3421,36 +3509,31 @@ int page_evictable(struct page *page, st
  * check_move_unevictable_page - check page for evictability and move to appropriate zone lru list
  * @page: page to check evictability and move to appropriate lru list
  * @zone: zone page is in
+ * @lruvec: vector or lru lists
  *
  * Checks a page for evictability and moves the page to the appropriate
  * zone lru list.
  *
- * Restrictions: zone->lru_lock must be held, page must be on LRU and must
+ * Restrictions: lruvec.lru_lock must be held, page must be on LRU and must
  * have PageUnevictable set.
  */
-static void check_move_unevictable_page(struct page *page, struct zone *zone)
+static void check_move_unevictable_page(struct page *page, struct zone *zone,
+					struct lruvec *lruvec)
 {
-	struct lruvec *lruvec;
-
 	VM_BUG_ON(PageActive(page));
 retry:
 	ClearPageUnevictable(page);
 	if (page_evictable(page, NULL)) {
-		enum lru_list l = page_lru_base_type(page);
+		enum lru_list lru = page_lru_base_type(page);
 
-		__dec_zone_state(zone, NR_UNEVICTABLE);
-		lruvec = mem_cgroup_lru_move_lists(zone, page,
-						   LRU_UNEVICTABLE, l);
-		list_move(&page->lru, &lruvec->lists[l]);
-		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
+		del_page_from_lru_list(zone, page, lruvec, LRU_UNEVICTABLE);
+		add_page_to_lru_list(zone, page, lruvec, lru);
 		__count_vm_event(UNEVICTABLE_PGRESCUED);
 	} else {
 		/*
 		 * rotate unevictable list
 		 */
 		SetPageUnevictable(page);
-		lruvec = mem_cgroup_lru_move_lists(zone, page, LRU_UNEVICTABLE,
-						   LRU_UNEVICTABLE);
 		list_move(&page->lru, &lruvec->lists[LRU_UNEVICTABLE]);
 		if (page_evictable(page, NULL))
 			goto retry;
@@ -3469,8 +3552,9 @@ void scan_mapping_unevictable_pages(stru
 	pgoff_t next = 0;
 	pgoff_t end   = (i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1) >>
 			 PAGE_CACHE_SHIFT;
-	struct zone *zone;
 	struct pagevec pvec;
+	struct lruvec *lruvec;
+	unsigned long flags;
 
 	if (mapping->nrpages == 0)
 		return;
@@ -3481,35 +3565,27 @@ void scan_mapping_unevictable_pages(stru
 		int i;
 		int pg_scanned = 0;
 
-		zone = NULL;
-
+		lruvec = NULL;
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index = page->index;
-			struct zone *pagezone = page_zone(page);
 
 			pg_scanned++;
 			if (page_index > next)
 				next = page_index;
 			next++;
 
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irq(&zone->lru_lock);
-				zone = pagezone;
-				spin_lock_irq(&zone->lru_lock);
-			}
-
+			lock_page_lru_irqsave(page, &lruvec, &flags);
 			if (PageLRU(page) && PageUnevictable(page))
-				check_move_unevictable_page(page, zone);
+				check_move_unevictable_page(page,
+						page_zone(page), lruvec);
 		}
-		if (zone)
-			spin_unlock_irq(&zone->lru_lock);
+		if (lruvec)
+			spin_unlock_irqrestore(&lruvec->lru_lock, flags);
 		pagevec_release(&pvec);
-
 		count_vm_events(UNEVICTABLE_PGSCANNED, pg_scanned);
+		cond_resched();
 	}
-
 }
 
 static void warn_scan_unevictable_pages(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
