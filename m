Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 7124F6B0031
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 18:06:32 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id t12so3216084pdi.35
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 15:06:31 -0700 (PDT)
Message-ID: <51BF8860.7010909@gmail.com>
Date: Tue, 18 Jun 2013 06:06:24 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: Remove unlikely from the current_order test
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

In __rmqueue_fallback(), current_order loops down from MAX_ORDER - 1
to the order passed. MAX_ORDER is typically 11 and pageblock_order
is typically 9 on x86. Integer division truncates, so pageblock_order / 2
is 4.  For the first eight iterations, it's guaranteed that
current_order >= pageblock_order / 2 if it even gets that far!

So just remove the unlikely(), it's completely bogus.

Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c3edb62..7b4f367 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1050,7 +1050,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			 * MIGRATE_CMA areas.
 			 */
 			if (!is_migrate_cma(migratetype) &&
-			    (unlikely(current_order >= pageblock_order / 2) ||
+			    (current_order >= pageblock_order / 2 ||
 			     start_migratetype == MIGRATE_RECLAIMABLE ||
 			     page_group_by_mobility_disabled)) {
 				int pages;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
