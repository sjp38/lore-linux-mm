Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1756B005C
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 17:59:43 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so5872467pad.23
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 14:59:43 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [RFC 16/23] mm/hugetlb: Use memblock apis for early memory allocations
Date: Sat, 12 Oct 2013 17:58:59 -0400
Message-ID: <1381615146-20342-17-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, yinghai@kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

Switch to memblock interfaces for early memory allocator

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/hugetlb.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b49579c..fe0cab4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1282,9 +1282,9 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
 	for_each_node_mask_to_alloc(h, nr_nodes, node, &node_states[N_MEMORY]) {
 		void *addr;
 
-		addr = __alloc_bootmem_node_nopanic(NODE_DATA(node),
-				huge_page_size(h), huge_page_size(h), 0);
-
+		addr = memblock_early_alloc_try_nid_nopanic(node,
+				huge_page_size(h), huge_page_size(h),
+				0, BOOTMEM_ALLOC_ACCESSIBLE);
 		if (addr) {
 			/*
 			 * Use the beginning of the huge page to store the
@@ -1324,8 +1324,8 @@ static void __init gather_bootmem_prealloc(void)
 
 #ifdef CONFIG_HIGHMEM
 		page = pfn_to_page(m->phys >> PAGE_SHIFT);
-		free_bootmem_late((unsigned long)m,
-				  sizeof(struct huge_bootmem_page));
+		memblock_free_late(__pa(m),
+				   sizeof(struct huge_bootmem_page));
 #else
 		page = virt_to_page(m);
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
