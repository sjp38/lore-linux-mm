Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 711216B004A
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:18:51 -0500 (EST)
Received: by pbcup15 with SMTP id up15so226313pbc.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 06:18:50 -0800 (PST)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] page_alloc.c: Slightly improve the logic in __alloc_pages_high_priority
Date: Mon,  5 Mar 2012 09:18:25 -0500
Message-Id: <1330957105-3595-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

The loop in __alloc_pages_high_priority() seems to be checking for
(!page) and (gfp_mask & __GFP_NOFAIL) multiple times.

In fact, we don't really need to check (gfp_mask & __GFP_NOFAIL)
for every iteration of the loop as the gfp_mask remains constant.

Slightly improve the logic in __alloc_pages_high_priority() to
eliminate these multiple condition checks.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/page_alloc.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a13ded1..6bb8b6d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2114,14 +2114,19 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 
-	do {
-		page = get_page_from_freelist(gfp_mask, nodemask, order,
+	page = get_page_from_freelist(gfp_mask, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
 			preferred_zone, migratetype);
 
-		if (!page && gfp_mask & __GFP_NOFAIL)
+	if (gfp_mask & __GFP_NOFAIL) {
+		while (!page) {
 			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
-	} while (!page && (gfp_mask & __GFP_NOFAIL));
+
+			page = get_page_from_freelist(gfp_mask, nodemask, order,
+				zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
+				preferred_zone, migratetype);
+		}
+	}
 
 	return page;
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
