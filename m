Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2826B0275
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:26 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l32so16351915qtd.19
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q40si6938952qtq.179.2018.04.04.12.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:25 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 63/79] mm/page: convert page's index lookup to be against specific mapping
Date: Wed,  4 Apr 2018 15:18:17 -0400
Message-Id: <20180404191831.5378-28-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Alexander Viro <viro@zeniv.linux.org.uk>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This patch switch mm to lookup the page index or offset value to be
against specific mapping. The page index value only have a meaning
against a mapping.

Using coccinelle:
---------------------------------------------------------------------
@@
struct page *P;
expression E;
@@
-P->index = E
+page_set_index(P, E)

@@
struct page *P;
@@
-P->index
+page_index(P)

@@
struct page *P;
@@
-page_index(P) << PAGE_SHIFT
+page_offset(P)

@@
expression E;
@@
-page_index(E)
+_page_index(E, mapping)

@@
expression E1, E2;
@@
-page_set_index(E1, E2)
+_page_set_index(E1, mapping, E2)

@@
expression E;
@@
-page_to_index(E)
+_page_to_index(E, mapping)

@@
expression E;
@@
-page_to_pgoff(E)
+_page_to_pgoff(E, mapping)

@@
expression E;
@@
-page_offset(E)
+_page_offset(E, mapping)

@@
expression E;
@@
-page_file_offset(E)
+_page_file_offset(E, mapping)
---------------------------------------------------------------------

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
---
 mm/filemap.c        | 26 ++++++++++++++------------
 mm/page-writeback.c | 16 +++++++++-------
 mm/shmem.c          | 11 +++++++----
 mm/truncate.c       | 11 ++++++-----
 4 files changed, 36 insertions(+), 28 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 012a53964215..a41c7cfb6351 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -118,7 +118,8 @@ static int page_cache_tree_insert(struct address_space *mapping,
 	void **slot;
 	int error;
 
-	error = __radix_tree_create(&mapping->page_tree, page->index, 0,
+	error = __radix_tree_create(&mapping->page_tree,
+				    _page_index(page, mapping), 0,
 				    &node, &slot);
 	if (error)
 		return error;
@@ -155,7 +156,8 @@ static void page_cache_tree_delete(struct address_space *mapping,
 		struct radix_tree_node *node;
 		void **slot;
 
-		__radix_tree_lookup(&mapping->page_tree, page->index + i,
+		__radix_tree_lookup(&mapping->page_tree,
+				    _page_index(page, mapping) + i,
 				    &node, &slot);
 
 		VM_BUG_ON_PAGE(!node && nr != 1, page);
@@ -791,12 +793,12 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		void (*freepage)(struct page *);
 		unsigned long flags;
 
-		pgoff_t offset = old->index;
+		pgoff_t offset = _page_index(old, mapping);
 		freepage = mapping->a_ops->freepage;
 
 		get_page(new);
 		new->mapping = mapping;
-		new->index = offset;
+		_page_set_index(new, mapping, offset);
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		__delete_from_page_cache(old, NULL);
@@ -850,7 +852,7 @@ static int __add_to_page_cache_locked(struct page *page,
 
 	get_page(page);
 	page->mapping = mapping;
-	page->index = offset;
+	_page_set_index(page, mapping, offset);
 
 	spin_lock_irq(&mapping->tree_lock);
 	error = page_cache_tree_insert(mapping, page, shadowp);
@@ -1500,7 +1502,7 @@ struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset)
 			put_page(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
+		VM_BUG_ON_PAGE(_page_to_pgoff(page, mapping) != offset, page);
 	}
 	return page;
 }
@@ -1559,7 +1561,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 			put_page(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
+		VM_BUG_ON_PAGE(_page_index(page, mapping) != offset, page);
 	}
 
 	if (page && (fgp_flags & FGP_ACCESSED))
@@ -1751,7 +1753,7 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
 
 		pages[ret] = page;
 		if (++ret == nr_pages) {
-			*start = pages[ret - 1]->index + 1;
+			*start = _page_index(pages[ret - 1], mapping) + 1;
 			goto out;
 		}
 	}
@@ -1837,7 +1839,7 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page_to_pgoff(page) != iter.index) {
+		if (page->mapping == NULL || _page_to_pgoff(page, mapping) != iter.index) {
 			put_page(page);
 			break;
 		}
@@ -1923,7 +1925,7 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
 
 		pages[ret] = page;
 		if (++ret == nr_pages) {
-			*index = pages[ret - 1]->index + 1;
+			*index = _page_index(pages[ret - 1], mapping) + 1;
 			goto out;
 		}
 	}
@@ -2540,7 +2542,7 @@ int filemap_fault(struct vm_fault *vmf)
 		put_page(page);
 		goto retry_find;
 	}
-	VM_BUG_ON_PAGE(page->index != offset, page);
+	VM_BUG_ON_PAGE(_page_index(page, mapping) != offset, page);
 
 	/*
 	 * We have a locked page in the page cache, now we need to check
@@ -2667,7 +2669,7 @@ void filemap_map_pages(struct vm_fault *vmf,
 			goto unlock;
 
 		max_idx = DIV_ROUND_UP(i_size_read(mapping->host), PAGE_SIZE);
-		if (page->index >= max_idx)
+		if (_page_index(page, mapping) >= max_idx)
 			goto unlock;
 
 		if (file->f_ra.mmap_miss > 0)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3c14d44639c8..ed9424f84715 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2201,7 +2201,7 @@ int write_cache_pages(struct address_space *mapping,
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			done_index = page->index;
+			done_index = _page_index(page, mapping);
 
 			lock_page(page);
 
@@ -2251,7 +2251,8 @@ int write_cache_pages(struct address_space *mapping,
 					 * not be suitable for data integrity
 					 * writeout).
 					 */
-					done_index = page->index + 1;
+					done_index = _page_index(page,
+								 mapping) + 1;
 					done = 1;
 					break;
 				}
@@ -2470,7 +2471,8 @@ int __set_page_dirty_nobuffers(struct page *page)
 		BUG_ON(page_mapping(page) != mapping);
 		WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
-		radix_tree_tag_set(&mapping->page_tree, page_index(page),
+		radix_tree_tag_set(&mapping->page_tree,
+				   _page_index(page, mapping),
 				   PAGECACHE_TAG_DIRTY);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 		unlock_page_memcg(page);
@@ -2732,7 +2734,7 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 		if (ret) {
 			radix_tree_tag_clear(&mapping->page_tree,
-						page_index(page),
+						_page_index(page, mapping),
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi)) {
 				struct bdi_writeback *wb = inode_to_wb(inode);
@@ -2785,7 +2787,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 						   PAGECACHE_TAG_WRITEBACK);
 
 			radix_tree_tag_set(&mapping->page_tree,
-						page_index(page),
+						_page_index(page, mapping),
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi))
 				inc_wb_stat(inode_to_wb(inode), WB_WRITEBACK);
@@ -2800,11 +2802,11 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,
-						page_index(page),
+						_page_index(page, mapping),
 						PAGECACHE_TAG_DIRTY);
 		if (!keep_write)
 			radix_tree_tag_clear(&mapping->page_tree,
-						page_index(page),
+						_page_index(page, mapping),
 						PAGECACHE_TAG_TOWRITE);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
diff --git a/mm/shmem.c b/mm/shmem.c
index 7fee65df10b4..7f3168d547c8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -588,7 +588,7 @@ static int shmem_add_to_page_cache(struct page *page,
 
 	page_ref_add(page, nr);
 	page->mapping = mapping;
-	page->index = index;
+	_page_set_index(page, mapping, index);
 
 	spin_lock_irq(&mapping->tree_lock);
 	if (PageTransHuge(page)) {
@@ -644,7 +644,9 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 	VM_BUG_ON_PAGE(PageCompound(page), page);
 
 	spin_lock_irq(&mapping->tree_lock);
-	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
+	error = shmem_radix_tree_replace(mapping, _page_index(page, mapping),
+					 page,
+					 radswap);
 	page->mapping = NULL;
 	mapping->nrpages--;
 	__dec_node_page_state(page, NR_FILE_PAGES);
@@ -822,7 +824,8 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				continue;
 			}
 
-			VM_BUG_ON_PAGE(page_to_pgoff(page) != index, page);
+			VM_BUG_ON_PAGE(_page_to_pgoff(page, mapping) != index,
+				       page);
 
 			if (!trylock_page(page))
 				continue;
@@ -1267,7 +1270,7 @@ static int shmem_writepage(struct address_space *_mapping, struct page *page,
 	VM_BUG_ON_PAGE(PageCompound(page), page);
 	BUG_ON(!PageLocked(page));
 	mapping = page->mapping;
-	index = page->index;
+	index = _page_index(page, mapping);
 	inode = mapping->host;
 	info = SHMEM_I(inode);
 	if (info->flags & VM_LOCKED)
diff --git a/mm/truncate.c b/mm/truncate.c
index a9415c96c966..57d4d0948f40 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -181,7 +181,8 @@ truncate_cleanup_page(struct address_space *mapping, struct page *page)
 {
 	if (page_mapped(page)) {
 		pgoff_t nr = PageTransHuge(page) ? HPAGE_PMD_NR : 1;
-		unmap_mapping_pages(mapping, page->index, nr, false);
+		unmap_mapping_pages(mapping, _page_index(page, mapping), nr,
+				    false);
 	}
 
 	if (page_has_private(page))
@@ -353,7 +354,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 			if (!trylock_page(page))
 				continue;
-			WARN_ON(page_to_index(page) != index);
+			WARN_ON(_page_to_index(page, mapping) != index);
 			if (PageWriteback(page)) {
 				unlock_page(page);
 				continue;
@@ -447,7 +448,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				continue;
 
 			lock_page(page);
-			WARN_ON(page_to_index(page) != index);
+			WARN_ON(_page_to_index(page, mapping) != index);
 			wait_on_page_writeback(page);
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
@@ -571,7 +572,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			if (!trylock_page(page))
 				continue;
 
-			WARN_ON(page_to_index(page) != index);
+			WARN_ON(_page_to_index(page, mapping) != index);
 
 			/* Middle of THP: skip */
 			if (PageTransTail(page)) {
@@ -701,7 +702,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 			}
 
 			lock_page(page);
-			WARN_ON(page_to_index(page) != index);
+			WARN_ON(_page_to_index(page, mapping) != index);
 			if (page_is_truncated(page, mapping)) {
 				unlock_page(page);
 				continue;
-- 
2.14.3
