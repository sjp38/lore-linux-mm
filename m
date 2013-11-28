Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6F25B6B004D
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 02:46:47 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so11421657pdj.26
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 23:46:47 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id ot3si25785247pac.166.2013.11.27.23.46.44
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 23:46:45 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 9/9] mm/rmap: use rmap_walk() in page_mkclean()
Date: Thu, 28 Nov 2013 16:48:46 +0900
Message-Id: <1385624926-28883-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have an infrastructure in rmap_walk() to handle difference
from variants of rmap traversing functions.

So, just use it in page_mkclean().

In this patch, I change following things.

1. remove some variants of rmap traversing functions.
    cf> page_mkclean_file
2. mechanical change to use rmap_walk() in page_mkclean().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/rmap.c b/mm/rmap.c
index 5e78d5c..bbbc705 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -809,12 +809,13 @@ int page_referenced(struct page *page,
 }
 
 static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
-			    unsigned long address)
+			    unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte;
 	spinlock_t *ptl;
 	int ret = 0;
+	int *cleaned = arg;
 
 	pte = page_check_address(page, mm, address, &ptl, 1);
 	if (!pte)
@@ -833,44 +834,46 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 
 	pte_unmap_unlock(pte, ptl);
 
-	if (ret)
+	if (ret) {
 		mmu_notifier_invalidate_page(mm, address);
+		(*cleaned)++;
+	}
 out:
-	return ret;
+	return SWAP_AGAIN;
 }
 
-static int page_mkclean_file(struct address_space *mapping, struct page *page)
+static int skip_vma_non_shared(struct vm_area_struct *vma, void *arg)
 {
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-	struct vm_area_struct *vma;
-	int ret = 0;
-
-	BUG_ON(PageAnon(page));
+	if (vma->vm_flags & VM_SHARED)
+		return 0;
 
-	mutex_lock(&mapping->i_mmap_mutex);
-	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
-		if (vma->vm_flags & VM_SHARED) {
-			unsigned long address = vma_address(page, vma);
-			ret += page_mkclean_one(page, vma, address);
-		}
-	}
-	mutex_unlock(&mapping->i_mmap_mutex);
-	return ret;
+	return 1;
 }
 
 int page_mkclean(struct page *page)
 {
-	int ret = 0;
+	struct address_space *mapping;
+	struct rmap_walk_control rwc;
+	int cleaned;
 
 	BUG_ON(!PageLocked(page));
 
-	if (page_mapped(page)) {
-		struct address_space *mapping = page_mapping(page);
-		if (mapping)
-			ret = page_mkclean_file(mapping, page);
-	}
+	if (!page_mapped(page))
+		return 0;
 
-	return ret;
+	mapping = page_mapping(page);
+	if (!mapping)
+		return 0;
+
+	memset(&rwc, 0, sizeof(rwc));
+	cleaned = 0;
+	rwc.main = page_mkclean_one;
+	rwc.arg = (void *)&cleaned;
+	rwc.vma_skip = skip_vma_non_shared;
+
+	rmap_walk(page, &rwc);
+
+	return cleaned;
 }
 EXPORT_SYMBOL_GPL(page_mkclean);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
