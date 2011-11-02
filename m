Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E9ACC6B006E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 12:33:45 -0400 (EDT)
Date: Wed, 2 Nov 2011 17:32:47 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: [rfc 3/3] mm: vmscan: revert file list boost on lru addition
Message-ID: <20111102163247.GJ19965@redhat.com>
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

The idea in 9ff473b 'vmscan: evict streaming IO first' was to steer
reclaim focus onto file pages with every new file page that hits the
lru list, so that an influx of used-once file pages does not lead to
swapping of anonymous pages.

The problem is that nobody is fixing up the balance if the pages in
fact become part of the resident set.

Anonymous page creation is neutral to the inter-lru balance, so even a
comparably tiny number of heavily used file pages tip the balance in
favor of the file list.

In addition, there is no refault detection, and every refault will
bias the balance even more.  A thrashing file working set will be
mistaken for a very lucrative source of reclaimable pages.

As anonymous pages are no longer swapped above a certain priority
level, this mechanism is no longer needed.  Used-once file pages
should get reclaimed before the VM even considers swapping.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/swap.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..33e5387 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -683,7 +683,6 @@ static void ____pagevec_lru_add_fn(struct page *page, void *arg)
 	SetPageLRU(page);
 	if (active)
 		SetPageActive(page);
-	update_page_reclaim_stat(zone, page, file, active);
 	add_page_to_lru_list(zone, page, lru);
 }
 
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
