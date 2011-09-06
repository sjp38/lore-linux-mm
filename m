Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 877296B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 11:12:07 -0400 (EDT)
Received: by iagv1 with SMTP id v1so10660326iag.14
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 08:12:05 -0700 (PDT)
Date: Wed, 7 Sep 2011 00:11:40 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: Do reclaim stall in case of mlocked page.
Message-ID: <20110906151140.GA1589@barrios-fedora.local>
References: <1321285043-3470-1-git-send-email-minchan.kim@gmail.com>
 <20110831173031.GA21571@redhat.com>
 <CAEwNFnDcNqLvo=oyXXkxgFxs8wNc+WTLwot0qeru1VfQKmUYDQ@mail.gmail.com>
 <20110905083321.GA15935@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110905083321.GA15935@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Sep 05, 2011 at 10:33:21AM +0200, Johannes Weiner wrote:
> On Fri, Sep 02, 2011 at 11:19:49AM +0900, Minchan Kim wrote:
> > On Thu, Sep 1, 2011 at 2:30 AM, Johannes Weiner <jweiner@redhat.com> wrote:
> > > On Tue, Nov 15, 2011 at 12:37:23AM +0900, Minchan Kim wrote:
> > >> [1] made avoid unnecessary reclaim stall when second shrink_page_list(ie, synchronous
> > >> shrink_page_list) try to reclaim page_list which has not-dirty pages.
> > >> But it seems rather awkawrd on unevictable page.
> > >> The unevictable page in shrink_page_list would be moved into unevictable lru from page_list.
> > >> So it would be not on page_list when shrink_page_list returns.
> > >> Nevertheless it skips reclaim stall.
> > >>
> > >> This patch fixes it so that it can do reclaim stall in case of mixing mlocked pages
> > >> and writeback pages on page_list.
> > >>
> > >> [1] 7d3579e,vmscan: narrow the scenarios in whcih lumpy reclaim uses synchrounous reclaim
> > >
> > > Lumpy isolates physically contiguous in the hope to free a bunch of
> > > pages that can be merged to a bigger page.  If an unevictable page is
> > > encountered, the chance of that is gone.  Why invest the allocation
> > > latency when we know it won't pay off anymore?
> > >
> > 
> > Good point!
> > 
> > Except some cases, when we require higher orer page, we used zone
> > defensive algorithm by zone_watermark_ok. So the number of fewer
> > higher order pages would be factor of failure of allocation. If it was
> > problem, we could rescue the situation by only reclaim part of the
> > block in the hope to free fewer higher order pages.
> 
> You mean if we fail to get an order-4, we may still successfully free
> some order-3?
> 
> I'm not sure we should speculatively do lumpy reclaim.  If someone
> wants order-3, they have to get it themselves.
> 
> > I thought the lumpy was designed to consider the case.(I might be wrong).
> > Why I thought is that when we isolate the pages for lumpy and found
> > the page isn't able to isolate, we don't rollback the isolated pages
> > in the lumpy phsyical block. It's very pointless to get a higher order
> > pages.
> > 
> > If we consider that, we have to fix other reset_reclaim_mode cases as
> > well as mlocked pages.
> > Or
> > fix isolataion logic for the lumpy? (When we find the page isn't able
> > to isolate, rollback the pages in the lumpy block to the LRU)
> > Or
> > Nothing and wait to remove lumpy completely.
> > 
> > What do you think about it?
> 
> The rollback may be overkill and we already abort clustering the
> isolation when one of the pages fails.

I think abort isn't enough
Because we know the chace to make a bigger page is gone when we isolate page.
But we still try to reclaim pages to make bigger space in a vain.
It causes unnecessary unmap operation by try_to_unmap which is costly operation
, evict some working set pages and make reclaim latency long.

As a matter of fact, I though as follows patch to solve this problem(Totally, untested)

---
 mm/vmscan.c |   35 +++++++++++++++++++++++++++++++----
 1 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 23256e8..ff2fe47 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1116,6 +1116,15 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_lumpy_dirty = 0;
 	unsigned long nr_lumpy_failed = 0;
 	unsigned long scan;
+	/*
+	 * We keep high order page list to return pages of blocks
+	 * which have a pinned page
+	 */
+	LIST_HEAD(hop_isolated_list);
+
+	struct list_head *isolated_page_list = dst;
+	if (order)
+		isolated_page_list = &hop_isolated_list;
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
@@ -1131,7 +1140,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
-			list_move(&page->lru, dst);
+			list_move(&page->lru, isolated_page_list);
 			mem_cgroup_del_lru(page);
 			nr_taken += hpage_nr_pages(page);
 			break;
@@ -1189,7 +1198,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
-				list_move(&cursor_page->lru, dst);
+				list_move(&cursor_page->lru, isolated_page_list);
 				mem_cgroup_del_lru(cursor_page);
 				nr_taken += hpage_nr_pages(page);
 				nr_lumpy_taken++;
@@ -1216,11 +1225,29 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			}
 		}
 
-		/* If we break out of the loop above, lumpy reclaim failed */
-		if (pfn < end_pfn)
+		/*
+		 * If we succeed to isolate *all* pages of the block,
+		 * we will try to reclaim that pages.
+		 */
+		if (pfn >= end_pfn)
+			list_splice(isolated_page_list, dst);
+		else {
+			/*
+			 * If we break out of the loop above, lumpy reclaim failed
+			 * Let's rollback isolated pages.
+			 */
+			struct page *page, *page2;
+
+			list_for_each_entry_safe(page, page2, isolated_page_list, lru) {
+				list_del(&page->lru);
+				putback_lru_page(page);
+			}
+
 			nr_lumpy_failed++;
+		}
 	}
 
+
 	*scanned = scan;
 
 	trace_mm_vmscan_lru_isolate(order,
-- 
1.7.5.4


I think this concept could be applied to compaction in case of compact for high order pages.

> 
> I would go with the last option.  Lumpy reclaim is on its way out and
> already disabled for a rather common configuration, so I would defer
> non-obvious fixes like these until actual bug reports show up.

It's hard to report above problem as it might not make big difference on normal worklaod.
But I agree last option, too. Then, when does we suppose to remove lumpy?
Mel, Could you have a any plan?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
