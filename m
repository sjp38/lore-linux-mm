Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E17166B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 18:07:22 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w84so16589430qka.11
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 15:07:22 -0700 (PDT)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com. [209.85.220.178])
        by mx.google.com with ESMTPS id r52si1667727qte.281.2017.08.16.15.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 15:07:21 -0700 (PDT)
Received: by mail-qk0-f178.google.com with SMTP id o124so19375766qke.3
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 15:07:21 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCH] mm/vmalloc: Don't unconditonally use __GFP_HIGHMEM
Date: Wed, 16 Aug 2017 15:07:05 -0700
Message-Id: <20170816220705.31374-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 19809c2da28a ("mm, vmalloc: use __GFP_HIGHMEM implicitly")
added use of __GFP_HIGHMEM for allocations. vmalloc_32 may use
GFP_DMA/GFP_DMA32 which does not play nice with __GFP_HIGHMEM
and will drigger a BUG in gfp_zone. Only add __GFP_HIGHMEM if
we aren't using GFP_DMA/GFP_DMA32.

Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=1482249
Fixes: 19809c2da28a ("mm, vmalloc: use __GFP_HIGHMEM implicitly")
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 mm/vmalloc.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8698c1c86c4d..a47e3894c775 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1671,7 +1671,10 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
 	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
-	const gfp_t alloc_mask = gfp_mask | __GFP_HIGHMEM | __GFP_NOWARN;
+	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
+	const gfp_t highmem_mask = (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
+					0 :
+					__GFP_HIGHMEM;
 
 	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
@@ -1679,7 +1682,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	area->nr_pages = nr_pages;
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE) {
-		pages = __vmalloc_node(array_size, 1, nested_gfp|__GFP_HIGHMEM,
+		pages = __vmalloc_node(array_size, 1, nested_gfp|highmem_mask,
 				PAGE_KERNEL, node, area->caller);
 	} else {
 		pages = kmalloc_node(array_size, nested_gfp, node);
@@ -1700,9 +1703,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		}
 
 		if (node == NUMA_NO_NODE)
-			page = alloc_page(alloc_mask);
+			page = alloc_page(alloc_mask|highmem_mask);
 		else
-			page = alloc_pages_node(node, alloc_mask, 0);
+			page = alloc_pages_node(node, alloc_mask|highmem_mask, 0);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
@@ -1710,7 +1713,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			goto fail;
 		}
 		area->pages[i] = page;
-		if (gfpflags_allow_blocking(gfp_mask))
+		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
 			cond_resched();
 	}
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
