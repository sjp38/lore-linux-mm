Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 456C16B004F
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 15:39:49 -0400 (EDT)
Date: Fri, 28 Aug 2009 20:39:15 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH mmotm] vmscan move pgdeactivate modification to shrink_active_list
 fix
Message-ID: <Pine.LNX.4.64.0908282034240.19475@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mmotm 2009-08-27-16-51 lets the OOM killer loose on my loads even
quicker than last time: one bug fixed but another bug introduced.
vmscan-move-pgdeactivate-modification-to-shrink_active_list.patch
forgot to add NR_LRU_BASE to lru index to make zone_page_state index.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/vmscan.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- mmotm/mm/vmscan.c	2009-08-28 10:07:57.000000000 +0100
+++ linux/mm/vmscan.c	2009-08-28 18:30:33.000000000 +0100
@@ -1381,8 +1381,10 @@ static void shrink_active_list(unsigned
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 	__count_vm_events(PGDEACTIVATE, nr_deactivated);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	__mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, nr_rotated);
-	__mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_deactivated);
+	__mod_zone_page_state(zone, NR_ACTIVE_ANON + file * LRU_FILE,
+							nr_rotated);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON + file * LRU_FILE,
+							nr_deactivated);
 	spin_unlock_irq(&zone->lru_lock);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
