Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7FFA66B0082
	for <linux-mm@kvack.org>; Sat, 16 May 2009 05:29:13 -0400 (EDT)
Date: Sat, 16 May 2009 17:28:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090516092858.GA12104@localhost>
References: <20090516090005.916779788@intel.com> <20090516090448.410032840@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090516090448.410032840@intel.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

[trivial update on comment text, according to Rik's comment]

--
vmscan: make mapped executable pages the first class citizen

Protect referenced PROT_EXEC mapped pages from being deactivated.

PROT_EXEC(or its internal presentation VM_EXEC) pages normally belong to some
currently running executables and their linked libraries, they shall really be
cached aggressively to provide good user experiences.

Thanks to Johannes Weiner for the advice to reuse the VMA walk in
page_referenced() to get the PROT_EXEC bit.


[more details]

( The consequences of this patch will have to be discussed together with
  Rik van Riel's recent patch "vmscan: evict use-once pages first". )

( Some of the good points and insights are taken into this changelog.
  Thanks to all the involved people for the great LKML discussions. )

the problem
-----------

For a typical desktop, the most precious working set is composed of
*actively accessed*
	(1) memory mapped executables
	(2) and their anonymous pages
	(3) and other files
	(4) and the dcache/icache/.. slabs
while the least important data are
	(5) infrequently used or use-once files

For a typical desktop, one major problem is busty and large amount of (5)
use-once files flushing out the working set.

Inside the working set, (4) dcache/icache have already been too sticky ;-)
So we only have to care (2) anonymous and (1)(3) file pages.

anonymous pages
---------------
Anonymous pages are effectively immune to the streaming IO attack, because we
now have separate file/anon LRU lists. When the use-once files crowd into the
file LRU, the list's "quality" is significantly lowered. Therefore the scan
balance policy in get_scan_ratio() will choose to scan the (low quality) file
LRU much more frequently than the anon LRU.

file pages
----------
Rik proposed to *not* scan the active file LRU when the inactive list grows
larger than active list. This guarantees that when there are use-once streaming
IO, and the working set is not too large(so that active_size < inactive_size),
the active file LRU will *not* be scanned at all. So the not-too-large working
set can be well protected.

But there are also situations where the file working set is a bit large so that
(active_size >= inactive_size), or the streaming IOs are not purely use-once.
In these cases, the active list will be scanned slowly. Because the current
shrink_active_list() policy is to deactivate active pages regardless of their
referenced bits. The deactivated pages become susceptible to the streaming IO
attack: the inactive list could be scanned fast (500MB / 50MBps = 10s) so that
the deactivated pages don't have enough time to get re-referenced. Because a
user tend to switch between windows in intervals from seconds to minutes.

This patch holds mapped executable pages in the active list as long as they
are referenced during each full scan of the active list.  Because the active
list is normally scanned much slower, they get longer grace time (eg. 100s)
for further references, which better matches the pace of user operations.

Therefore this patch greatly prolongs the in-cache time of executable code,
when there are moderate memory pressures.

	before patch: guaranteed to be cached if reference intervals < I
	after  patch: guaranteed to be cached if reference intervals < I+A
		      (except when randomly reclaimed by the lumpy reclaim)
where
	A = time to fully scan the   active file LRU
	I = time to fully scan the inactive file LRU

Note that normally A >> I.

side effects
------------

This patch is safe in general, it restores the pre-2.6.28 mmap() behavior
but in a much smaller and well targeted scope.

One may worry about some one to abuse the PROT_EXEC heuristic.  But as
Andrew Morton stated, there are other tricks to getting that sort of boost.

Another concern is the PROT_EXEC mapped pages growing large in rare cases,
and therefore hurting reclaim efficiency. But a sane application targeted for
large audience will never use PROT_EXEC for data mappings. If some home made
application tries to abuse that bit, it shall be aware of the consequences.
If it is abused to scale of 2/3 total memory, it gains nothing but overheads.

CC: Elladan <elladan@eskimo.com>
CC: Nick Piggin <npiggin@suse.de>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   51 +++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 44 insertions(+), 7 deletions(-)

--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -1233,6 +1233,7 @@ static void shrink_active_list(unsigned 
 	unsigned long pgscanned;
 	unsigned long vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
+	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
 	struct page *page;
 	struct pagevec pvec;
@@ -1272,28 +1273,41 @@ static void shrink_active_list(unsigned 
 
 		/* page_referenced clears PageReferenced */
 		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
+		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
 			pgmoved++;
+			/*
+			 * Identify referenced, file-backed active pages and
+			 * give them one more trip around the active list. So
+			 * that executable code get better chances to stay in
+			 * memory under moderate memory pressure.  Anon pages
+			 * are ignored, since JVM can create lots of anon
+			 * VM_EXEC pages.
+			 */
+			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
+				list_add(&page->lru, &l_active);
+				continue;
+			}
+		}
 
 		list_add(&page->lru, &l_inactive);
 	}
 
 	/*
-	 * Move the pages to the [file or anon] inactive list.
+	 * Move pages back to the lru list.
 	 */
 	pagevec_init(&pvec, 1);
-	lru = LRU_BASE + file * LRU_FILE;
 
 	spin_lock_irq(&zone->lru_lock);
 	/*
-	 * Count referenced pages from currently used mappings as
-	 * rotated, even though they are moved to the inactive list.
-	 * This helps balance scan pressure between file and anonymous
-	 * pages in get_scan_ratio.
+	 * Count referenced pages from currently used mappings as rotated,
+	 * even though only some of them are actually re-activated.  This
+	 * helps balance scan pressure between file and anonymous pages in
+	 * get_scan_ratio.
 	 */
 	reclaim_stat->recent_rotated[!!file] += pgmoved;
 
 	pgmoved = 0;  /* count pages moved to inactive list */
+	lru = LRU_BASE + file * LRU_FILE;
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
@@ -1316,6 +1330,29 @@ static void shrink_active_list(unsigned 
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgmoved);
+
+	pgmoved = 0;  /* count pages moved back to active list */
+	lru = LRU_ACTIVE + file * LRU_FILE;
+	while (!list_empty(&l_active)) {
+		page = lru_to_page(&l_active);
+		prefetchw_prev_lru_page(page, &l_active, flags);
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		VM_BUG_ON(!PageActive(page));
+
+		list_move(&page->lru, &zone->lru[lru].list);
+		mem_cgroup_add_lru_list(page, lru);
+		pgmoved++;
+		if (!pagevec_add(&pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			if (buffer_heads_over_limit)
+				pagevec_strip(&pvec);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+
 	spin_unlock_irq(&zone->lru_lock);
 	if (buffer_heads_over_limit)
 		pagevec_strip(&pvec);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
