Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87E3D6B026E
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 14:20:41 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so6522988wjb.7
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 11:20:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m144si3260249wma.137.2017.02.02.11.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 11:20:40 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 7/7] mm: vmscan: move dirty pages out of the way until they're flushed fix
Date: Thu,  2 Feb 2017 14:19:57 -0500
Message-Id: <20170202191957.22872-8-hannes@cmpxchg.org>
In-Reply-To: <20170202191957.22872-1-hannes@cmpxchg.org>
References: <20170202191957.22872-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Mention the trade-off between waiting for writeback and potentially
causing hot cache refaults in the code where we make this decisions
and activate writeback pages.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 70103f411247..ae3d982216b5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1056,6 +1056,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 *    throttling so we could easily OOM just because too many
 		 *    pages are in writeback and there is nothing else to
 		 *    reclaim. Wait for the writeback to complete.
+		 *
+		 * In cases 1) and 2) we activate the pages to get them out of
+		 * the way while we continue scanning for clean pages on the
+		 * inactive list and refilling from the active list. The
+		 * observation here is that waiting for disk writes is more
+		 * expensive than potentially causing reloads down the line.
+		 * Since they're marked for immediate reclaim, they won't put
+		 * memory pressure on the cache working set any longer than it
+		 * takes to write them to disk.
 		 */
 		if (PageWriteback(page)) {
 			/* Case 1 above */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
