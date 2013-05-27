Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 2C9276B00FC
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:03:04 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/4] mm: vmscan: Block kswapd if it is encountering pages under writeback -fix
Date: Mon, 27 May 2013 14:02:55 +0100
Message-Id: <1369659778-6772-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1369659778-6772-1-git-send-email-mgorman@suse.de>
References: <1369659778-6772-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The patch "mm: vmscan: Block kswapd if it is encountering pages
under writeback" stalls in congestion_wait it encounters a page under
writeback that is marked for immediate reclaim. Initially this was a
wait_on_page_writeback() but after the switch to congestion_wait(),
there is no guarantee the page has completed writeback and it can
be placed on a list for freeing.

This is a fix for
mm-vmscan-block-kswapd-if-it-is-encountering-pages-under-writeback.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b1b38ad..4a43c28 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -766,8 +766,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (current_is_kswapd() &&
 			    PageReclaim(page) &&
 			    zone_is_reclaim_writeback(zone)) {
+				unlock_page(page);
 				congestion_wait(BLK_RW_ASYNC, HZ/10);
 				zone_clear_flag(zone, ZONE_WRITEBACK);
+				goto keep;
 
 			/* Case 2 above */
 			} else if (global_reclaim(sc) ||
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
