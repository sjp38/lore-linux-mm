Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF746B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 12:28:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j8-v6so4645908wrh.18
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 09:28:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12-v6sor4097331wrn.56.2018.06.22.09.28.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 09:28:48 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
Date: Fri, 22 Jun 2018 18:28:41 +0200
Message-Id: <20180622162841.25114-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: JianKang Chen <chenjiankang1@huawei.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

There is no real reason to blow up just because the caller doesn't know
that __get_free_pages cannot return highmem pages. Simply fix that up
silently. Even if we have some confused users such a fixup will not be
harmful.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi Andrew,
previously posted [1] but it fell through cracks. Can we merge it now?

[1] http://lkml.kernel.org/r/20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz

 mm/page_alloc.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100f1e63..5f56f662a52d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4402,18 +4402,14 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 EXPORT_SYMBOL(__alloc_pages_nodemask);
 
 /*
- * Common helper functions.
+ * Common helper functions. Never use with __GFP_HIGHMEM because the returned
+ * address cannot represent highmem pages. Use alloc_pages and then kmap if
+ * you need to access high mem.
  */
 unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
 {
 	struct page *page;
 
-	/*
-	 * __get_free_pages() returns a virtual address, which cannot represent
-	 * a highmem page
-	 */
-	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
-
 	page = alloc_pages(gfp_mask, order);
 	if (!page)
 		return 0;
-- 
2.17.1
