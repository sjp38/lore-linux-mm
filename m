Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 935C86B0031
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 07:43:17 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id z10so2256993pdj.19
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 04:43:17 -0700 (PDT)
Received: from psmtp.com ([74.125.245.104])
        by mx.google.com with SMTP id pz2si12732828pac.202.2013.10.28.04.43.16
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 04:43:16 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so5116003pde.17
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 04:43:14 -0700 (PDT)
From: zhang.mingjun@linaro.org
Subject: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot  page
Date: Mon, 28 Oct 2013 19:42:49 +0800
Message-Id: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, m.szyprowski@samsung.com, akpm@linux-foundation.org, mgorman@suse.de, haojian.zhuang@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mingjun Zhang <troy.zhangmingjun@linaro.org>

From: Mingjun Zhang <troy.zhangmingjun@linaro.org>

free_contig_range frees cma pages one by one and MIGRATE_CMA pages will be
used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary
migration action when these pages reused by CMA.

Signed-off-by: Mingjun Zhang <troy.zhangmingjun@linaro.org>
---
 mm/page_alloc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0ee638f..84b9d84 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1362,7 +1362,8 @@ void free_hot_cold_page(struct page *page, int cold)
 	 * excessively into the page allocator
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
-		if (unlikely(is_migrate_isolate(migratetype))) {
+		if (unlikely(is_migrate_isolate(migratetype))
+			|| is_migrate_cma(migratetype))
 			free_one_page(zone, page, 0, migratetype);
 			goto out;
 		}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
