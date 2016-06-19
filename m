Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D05CF6B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 21:51:58 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 5so255300769ioy.2
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 18:51:58 -0700 (PDT)
Received: from m12-13.163.com (m12-13.163.com. [220.181.12.13])
        by mx.google.com with ESMTP id w79si23228942ioi.148.2016.06.18.18.51.57
        for <linux-mm@kvack.org>;
        Sat, 18 Jun 2016 18:51:58 -0700 (PDT)
From: Wenwei Tao <wwtao0320@163.com>
Subject: [RFC PATCH 3/3] mm, page_alloc: prevent merge freepages between highatomic and others
Date: Sun, 19 Jun 2016 09:51:43 +0800
Message-Id: <1466301103-6436-1-git-send-email-wwtao0320@163.com>
In-Reply-To: <1466300927-1364-1-git-send-email-wwtao0320@163.com>
References: <1466300927-1364-1-git-send-email-wwtao0320@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ww.tao0320@gmail.com

From: Wenwei Tao <ww.tao0320@gmail.com>

We might not want other migrate types pin highatomic pageblock
away since it's reserved for high order use. And also we might
not want reserve high atomic pages out of limit, we can add
check in __free_one_page but this might be costly, so just stop
the merging.

Signed-off-by: Wenwei Tao <ww.tao0320@gmail.com>
---
 mm/page_alloc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b72b771..ffce9b5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -832,7 +832,8 @@ continue_merging:
 		 * We don't want to hit this code for the more frequent
 		 * low-order merging.
 		 */
-		if (unlikely(has_isolate_pageblock(zone))) {
+		if (unlikely(has_isolate_pageblock(zone) ||
+				zone->nr_reserved_highatomic)) {
 			int buddy_mt;
 
 			buddy_idx = __find_buddy_index(page_idx, order);
@@ -841,7 +842,9 @@ continue_merging:
 
 			if (migratetype != buddy_mt
 					&& (is_migrate_isolate(migratetype) ||
-						is_migrate_isolate(buddy_mt)))
+					is_migrate_isolate(buddy_mt) ||
+					migratetype == MIGRATE_HIGHATOMIC ||
+					buddy_mt == MIGRATE_HIGHATOMIC))
 				goto done_merging;
 		}
 		max_order++;
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
