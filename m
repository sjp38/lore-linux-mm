Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92CEE6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 22:48:44 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u186so20203121ita.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 19:48:44 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id o39si5035581oik.149.2016.07.14.19.48.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 19:48:43 -0700 (PDT)
Message-ID: <57884EAA.9030603@huawei.com>
Date: Fri, 15 Jul 2016 10:47:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] mem-hotplug: use GFP_HIGHUSER_MOVABLE in, alloc_migrate_target()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

alloc_migrate_target() is called from migrate_pages(), and the page
is always from user space, so we can add __GFP_HIGHMEM directly.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_isolation.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 612122b..4f32c9f 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -282,8 +282,6 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 struct page *alloc_migrate_target(struct page *page, unsigned long private,
 				  int **resultp)
 {
-	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
-
 	/*
 	 * TODO: allocate a destination hugepage from a nearest neighbor node,
 	 * accordance with memory policy of the user process if possible. For
@@ -293,9 +291,6 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					    next_node_in(page_to_nid(page),
 							 node_online_map));
-
-	if (PageHighMem(page))
-		gfp_mask |= __GFP_HIGHMEM;
-
-	return alloc_page(gfp_mask);
+	else
+		return alloc_page(GFP_HIGHUSER_MOVABLE);
 }
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
