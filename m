Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id E76B46B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:30:44 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id h3so5317810igd.8
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 15:30:44 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id bm3si2735230icb.49.2014.06.24.15.30.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 15:30:44 -0700 (PDT)
Received: by mail-ig0-f175.google.com with SMTP id h3so5321162igd.14
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 15:30:43 -0700 (PDT)
Date: Tue, 24 Jun 2014 15:30:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, vmalloc: constify allocation mask
Message-ID: <alpine.DEB.2.02.1406241527030.29176@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

tmp_mask in the __vmalloc_area_node() iteration never changes so it can be 
moved into function scope and marked with const.  This causes the movl and 
orl to only be done once per call rather than area->nr_pages times.

nested_gfp can also be marked const.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/vmalloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1566,7 +1566,8 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	const int order = 0;
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
-	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
+	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
+	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
 
 	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
@@ -1589,12 +1590,11 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
-		gfp_t tmp_mask = gfp_mask | __GFP_NOWARN;
 
 		if (node == NUMA_NO_NODE)
-			page = alloc_page(tmp_mask);
+			page = alloc_page(alloc_mask);
 		else
-			page = alloc_pages_node(node, tmp_mask, order);
+			page = alloc_pages_node(node, alloc_mask, order);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
