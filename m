Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CF5E36B005A
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 20:57:51 -0400 (EDT)
Date: Wed, 2 Sep 2009 01:57:21 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH mmotm] vmscan move pgdeactivate modification to shrink_active_list
 fix2
In-Reply-To: <Pine.LNX.4.64.0908282034240.19475@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909020154060.31130@sister.anvils>
References: <Pine.LNX.4.64.0908282034240.19475@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A second fix to the ill-starred
vmscan-move-pgdeactivate-modification-to-shrink_active_list.patch
which, once corrected to update the right counters by the first fix,
builds up absurdly large Active counts in /proc/meminfo.

nr_rotated is not the number of pages added back to the active list
(maybe it once was, maybe it should be again: but if so that's not
any business for a code rearrangement patch).  shrink_active_list()
needs to keep a separate nr_reactivated count of those.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
Or... revert the offending patch and its first fix.

 mm/vmscan.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- mmotm/mm/vmscan.c	2009-08-28 18:30:33.000000000 +0100
+++ linux/mm/vmscan.c	2009-09-02 01:28:34.000000000 +0100
@@ -1306,6 +1306,7 @@ static void shrink_active_list(unsigned
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	unsigned long nr_rotated = 0;
 	unsigned long nr_deactivated = 0;
+	unsigned long nr_reactivated = 0;
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -1354,6 +1355,7 @@ static void shrink_active_list(unsigned
 			 */
 			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
 				list_add(&page->lru, &l_active);
+				nr_reactivated++;
 				continue;
 			}
 		}
@@ -1382,7 +1384,7 @@ static void shrink_active_list(unsigned
 	__count_vm_events(PGDEACTIVATE, nr_deactivated);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	__mod_zone_page_state(zone, NR_ACTIVE_ANON + file * LRU_FILE,
-							nr_rotated);
+							nr_reactivated);
 	__mod_zone_page_state(zone, NR_INACTIVE_ANON + file * LRU_FILE,
 							nr_deactivated);
 	spin_unlock_irq(&zone->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
