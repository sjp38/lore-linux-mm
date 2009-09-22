Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5153C6B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 17:02:11 -0400 (EDT)
Date: Tue, 22 Sep 2009 14:02:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
Message-Id: <20090922140206.293586cc.akpm@linux-foundation.org>
In-Reply-To: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, minchan.kim@gmail.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  2 Sep 2009 16:49:25 -0700
Vincent Li <macli@brc.ubc.ca> wrote:

> If we can't isolate pages from LRU list, we don't have to account page movement, either.
> Already, in commit 5343daceec, KOSAKI did it about shrink_inactive_list.
> 
> This patch removes unnecessary overhead of page accounting
> and locking in shrink_active_list as follow-up work of commit 5343daceec.
> 

I didn't merge this.  It's still unclear to me that the benefit of the
patch exceeds the (small) maintainability cost.

Did we end up getting any usable data on the frequency of `nr_taken == 0'?




From: Vincent Li <macli@brc.ubc.ca>

If we can't isolate pages from LRU list, we don't have to account page
movement, either.  Already, in commit 5343daceec, KOSAKI did it about
shrink_inactive_list.

This patch removes unnecessary overhead of page accounting and locking in
shrink_active_list as follow-up work of commit 5343daceec.

Signed-off-by: Vincent Li <macli@brc.ubc.ca>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff -puN mm/vmscan.c~mm-vsmcan-check-shrink_active_list-sc-isolate_pages-return-value mm/vmscan.c
--- a/mm/vmscan.c~mm-vsmcan-check-shrink_active_list-sc-isolate_pages-return-value
+++ a/mm/vmscan.c
@@ -1323,9 +1323,12 @@ static void shrink_active_list(unsigned 
 	if (scanning_global_lru(sc)) {
 		zone->pages_scanned += pgscanned;
 	}
-	reclaim_stat->recent_scanned[file] += nr_taken;
-
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
+
+	if (nr_taken == 0)
+		goto done;
+
+	reclaim_stat->recent_scanned[file] += nr_taken;
 	if (file)
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
 	else
@@ -1383,6 +1386,7 @@ static void shrink_active_list(unsigned 
 	move_active_pages_to_lru(zone, &l_inactive,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
+done:
 	spin_unlock_irq(&zone->lru_lock);
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
