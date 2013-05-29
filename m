Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 130266B015A
	for <linux-mm@kvack.org>; Wed, 29 May 2013 19:17:48 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 6/8] mm: vmscan: Treat pages marked for immediate reclaim as zone congestion
Date: Thu, 30 May 2013 00:17:35 +0100
Message-Id: <1369869457-22570-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1369869457-22570-1-git-send-email-mgorman@suse.de>
References: <1369869457-22570-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Currently a zone will only be marked congested if the underlying BDI
is congested but if dirty pages are spread across zones it is possible
that an individual zone is full of dirty pages without being congested.
The impact is that zone gets scanned very quickly potentially reclaiming
really clean pages. This patch treats pages marked for immediate reclaim
as congested for the purposes of marking a zone ZONE_CONGESTED and
stalling in wait_iff_congested.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4898daf..bf47784 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -761,9 +761,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (dirty && !writeback)
 			nr_unqueued_dirty++;
 
-		/* Treat this page as congested if underlying BDI is */
+		/*
+		 * Treat this page as congested if the underlying BDI is or if
+		 * pages are cycling through the LRU so quickly that the
+		 * pages marked for immediate reclaim are making it to the
+		 * end of the LRU a second time.
+		 */
 		mapping = page_mapping(page);
-		if (mapping && bdi_write_congested(mapping->backing_dev_info))
+		if ((mapping && bdi_write_congested(mapping->backing_dev_info)) ||
+		    (writeback && PageReclaim(page)))
 			nr_congested++;
 
 		/*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
