Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6B246B02A4
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:30 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 4so6715511plb.1
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c5-v6si8443388plo.194.2018.02.19.11.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:29 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 49/61] shmem: Convert shmem_add_to_page_cache to XArray
Date: Mon, 19 Feb 2018 11:45:44 -0800
Message-Id: <20180219194556.6575-50-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This removes the last caller of radix_tree_maybe_preload_order().
Simpler code, unless we run out of memory for new xa_nodes partway through
inserting entries into the xarray.  Hopefully we can support multi-index
entries in the page cache soon and all the awful code goes away.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/shmem.c | 87 ++++++++++++++++++++++++++++----------------------------------
 1 file changed, 39 insertions(+), 48 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index ccb6d7ecdee0..347661653803 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -558,9 +558,10 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
  */
 static int shmem_add_to_page_cache(struct page *page,
 				   struct address_space *mapping,
-				   pgoff_t index, void *expected)
+				   pgoff_t index, void *expected, gfp_t gfp)
 {
-	int error, nr = hpage_nr_pages(page);
+	XA_STATE(xas, &mapping->pages, index);
+	unsigned long i, nr = 1UL << compound_order(page);
 
 	VM_BUG_ON_PAGE(PageTail(page), page);
 	VM_BUG_ON_PAGE(index != round_down(index, nr), page);
@@ -569,49 +570,47 @@ static int shmem_add_to_page_cache(struct page *page,
 	VM_BUG_ON(expected && PageTransHuge(page));
 
 	page_ref_add(page, nr);
-	page->mapping = mapping;
 	page->index = index;
+	page->mapping = mapping;
 
-	xa_lock_irq(&mapping->pages);
-	if (PageTransHuge(page)) {
-		void __rcu **results;
-		pgoff_t idx;
-		int i;
-
-		error = 0;
-		if (radix_tree_gang_lookup_slot(&mapping->pages,
-					&results, &idx, index, 1) &&
-				idx < index + HPAGE_PMD_NR) {
-			error = -EEXIST;
+	do {
+		xas_lock_irq(&xas);
+		xas_create_range(&xas, index + nr - 1);
+		if (xas_error(&xas))
+			goto unlock;
+		for (i = 0; i < nr; i++) {
+			void *entry = xas_load(&xas);
+			if (entry != expected)
+				xas_set_err(&xas, -ENOENT);
+			if (xas_error(&xas))
+				goto undo;
+			xas_store(&xas, page + i);
+			xas_next(&xas);
 		}
-
-		if (!error) {
-			for (i = 0; i < HPAGE_PMD_NR; i++) {
-				error = radix_tree_insert(&mapping->pages,
-						index + i, page + i);
-				VM_BUG_ON(error);
-			}
+		if (PageTransHuge(page)) {
 			count_vm_event(THP_FILE_ALLOC);
+			__inc_node_page_state(page, NR_SHMEM_THPS);
 		}
-	} else if (!expected) {
-		error = radix_tree_insert(&mapping->pages, index, page);
-	} else {
-		error = shmem_xa_replace(mapping, index, expected, page);
-	}
-
-	if (!error) {
 		mapping->nrpages += nr;
-		if (PageTransHuge(page))
-			__inc_node_page_state(page, NR_SHMEM_THPS);
 		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
 		__mod_node_page_state(page_pgdat(page), NR_SHMEM, nr);
-		xa_unlock_irq(&mapping->pages);
-	} else {
+		goto unlock;
+undo:
+		while (i-- > 0) {
+			xas_store(&xas, NULL);
+			xas_prev(&xas);
+		}
+unlock:
+		xas_unlock_irq(&xas);
+	} while (xas_nomem(&xas, gfp));
+
+	if (xas_error(&xas)) {
 		page->mapping = NULL;
-		xa_unlock_irq(&mapping->pages);
 		page_ref_sub(page, nr);
+		return xas_error(&xas);
 	}
-	return error;
+
+	return 0;
 }
 
 /*
@@ -1159,7 +1158,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 	 */
 	if (!error)
 		error = shmem_add_to_page_cache(*pagep, mapping, index,
-						radswap);
+						radswap, gfp);
 	if (error != -ENOMEM) {
 		/*
 		 * Truncation and eviction use free_swap_and_cache(), which
@@ -1677,7 +1676,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 				false);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
-						swp_to_radix_entry(swap));
+						swp_to_radix_entry(swap), gfp);
 			/*
 			 * We already confirmed swap under page lock, and make
 			 * no memory allocation here, so usually no possibility
@@ -1783,13 +1782,8 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, inode,
 				PageTransHuge(page));
 		if (error)
 			goto unacct;
-		error = radix_tree_maybe_preload_order(gfp & GFP_RECLAIM_MASK,
-				compound_order(page));
-		if (!error) {
-			error = shmem_add_to_page_cache(page, mapping, hindex,
-							NULL);
-			radix_tree_preload_end();
-		}
+		error = shmem_add_to_page_cache(page, mapping, hindex,
+						NULL, gfp & GFP_RECLAIM_MASK);
 		if (error) {
 			mem_cgroup_cancel_charge(page, memcg,
 					PageTransHuge(page));
@@ -2256,11 +2250,8 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 	if (ret)
 		goto out_release;
 
-	ret = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
-	if (!ret) {
-		ret = shmem_add_to_page_cache(page, mapping, pgoff, NULL);
-		radix_tree_preload_end();
-	}
+	ret = shmem_add_to_page_cache(page, mapping, pgoff, NULL,
+						gfp & GFP_RECLAIM_MASK);
 	if (ret)
 		goto out_release_uncharge;
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
