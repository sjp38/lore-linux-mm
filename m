Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12ECC6B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 16:21:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r16so2293338pgt.19
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 13:21:42 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id x185si452801pgx.159.2018.02.08.13.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 13:21:40 -0800 (PST)
From: Alexey Skidanov <alexey.skidanov@intel.com>
Subject: [PATCH] mm: Free CMA pages to the buddy allocator instead of per-cpu-pagelists
Date: Thu,  8 Feb 2018 23:21:53 +0200
Message-Id: <1518124913-31290-1-git-send-email-alexey.skidanov@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Alexey Skidanov <alexey.skidanov@intel.com>

The current code frees pages to the per-cpu-pagelists (pcp) according to
their migrate type. The exception is isolated pages that are freed
directly to the buddy allocator.

The pages are marked as isolate to indicate the buddy allocator that
they are not supposed to be allocated as opposite to the pages located
in the pcp lists that are immediate candidates for the upcoming
allocation requests.

This was likely an oversight when the CMA migrate type was added. As a
result of this, freed CMA pages go to the MIGRATE_MOVABLE per-cpu-list.
This sometime leads to CMA page allocation instead of Movable one,
increasing the probability of CMA page pining, which may cause to CMA
allocation failure. In addition, there is no gain to free CMA page to
the pcp because the CMA pages mainly allocated for DMA purpose.

To fix this, we free CMA page directly to the buddy allocator. This
avoids the CMA page allocation instead of MOVABLE one. Actually, the CMA
pages are very similar to the isolated ones - both of them should not be
supposed as immediate candidates for upcoming allocation requests and
thus shouldn't be freed to pcp. I've audited all the other checks for
isolated pageblocks to ensure that this mistake was not repeated elsewhere.

Signed-off-by: Alexey Skidanov <alexey.skidanov@intel.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59d5921..9a76b68 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2644,7 +2644,8 @@ static void free_unref_page_commit(struct page *page, unsigned long pfn)
 	 * excessively into the page allocator
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
-		if (unlikely(is_migrate_isolate(migratetype))) {
+		if (unlikely(is_migrate_isolate(migratetype) ||
+				is_migrate_cma(migratetype))) {
 			free_one_page(zone, page, pfn, 0, migratetype);
 			return;
 		}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
