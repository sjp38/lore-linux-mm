Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 68DDA6B00DD
	for <linux-mm@kvack.org>; Wed, 29 May 2013 19:17:46 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/8] mm: vmscan: Set zone flags before blocking
Date: Thu, 30 May 2013 00:17:33 +0100
Message-Id: <1369869457-22570-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1369869457-22570-1-git-send-email-mgorman@suse.de>
References: <1369869457-22570-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

In shrink_page_list a decision may be made to stall and flag a zone
as ZONE_WRITEBACK so that if a large number of unqueued dirty pages are
encountered later then the reclaimer will stall. Set ZONE_WRITEBACK before
potentially going to sleep so it is noticed sooner.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5b1a79c..5f80d01 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1445,8 +1445,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 */
 	if (nr_writeback && nr_writeback >=
 			(nr_taken >> (DEF_PRIORITY - sc->priority))) {
-		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
 		zone_set_flag(zone, ZONE_WRITEBACK);
+		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
 	}
 
 	/*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
