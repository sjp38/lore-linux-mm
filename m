Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 029AC6B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 12:33:11 -0400 (EDT)
Date: Wed, 2 Nov 2011 17:32:13 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: [rfc 2/3] mm: vmscan: treat inactive cycling as neutral
Message-ID: <20111102163213.GI19965@redhat.com>
References: <20110808110658.31053.55013.stgit@localhost6>
 <CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com>
 <4E3FD403.6000400@parallels.com>
 <20111102163056.GG19965@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111102163056.GG19965@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Gene Heskett <gene.heskett@gmail.com>

Each page that is scanned but put back to the inactive list is counted
as a successful reclaim, which tips the balance between file and anon
lists more towards the cycling list.

This does - in my opinion - not make too much sense, but at the same
time it was not much of a problem, as the conditions that lead to an
inactive list cycle were mostly temporary - locked page, concurrent
page table changes, backing device congested - or at least limited to
a single reclaimer that was not allowed to unmap or meddle with IO.
More important than being moderately rare, those conditions should
apply to both anon and mapped file pages equally and balance out in
the end.

Recently, we started cycling file pages in particular on the inactive
list much more aggressively, for used-once detection of mapped pages,
and when avoiding writeback from direct reclaim.

Those rotated pages do not exactly speak for the reclaimability of the
list they sit on and we risk putting immense pressure on file list for
no good reason.

Instead, count each page not reclaimed and put back to any list,
active or inactive, as rotated, so they are neutral with respect to
the scan/rotate ratio of the list class, as they should be.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/vmscan.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 39d3da3..6da66a7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1360,7 +1360,9 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
 	 */
 	spin_lock(&zone->lru_lock);
 	while (!list_empty(page_list)) {
+		int file;
 		int lru;
+
 		page = lru_to_page(page_list);
 		VM_BUG_ON(PageLRU(page));
 		list_del(&page->lru);
@@ -1373,11 +1375,8 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
 		SetPageLRU(page);
 		lru = page_lru(page);
 		add_page_to_lru_list(zone, page, lru);
-		if (is_active_lru(lru)) {
-			int file = is_file_lru(lru);
-			int numpages = hpage_nr_pages(page);
-			reclaim_stat->recent_rotated[file] += numpages;
-		}
+		file = is_file_lru(lru);
+		reclaim_stat->recent_rotated[file] += hpage_nr_pages(page);
 		if (!pagevec_add(&pvec, page)) {
 			spin_unlock_irq(&zone->lru_lock);
 			__pagevec_release(&pvec);
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
