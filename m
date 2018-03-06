Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D30D6B0009
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 14:24:22 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id l5-v6so10164308pli.8
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 11:24:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g4si12358831pfh.98.2018.03.06.11.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 11:24:21 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v8 06/63] btrfs: Use filemap_range_has_page()
Date: Tue,  6 Mar 2018 11:23:16 -0800
Message-Id: <20180306192413.5499-7-willy@infradead.org>
In-Reply-To: <20180306192413.5499-1-willy@infradead.org>
References: <20180306192413.5499-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

The current implementation of btrfs_page_exists_in_range() gives the
wrong answer if the workingset code has stored a shadow entry in the
page cache.  The filemap_range_has_page() function does not have this
problem, and it's shared code, so use it instead.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/btrfs_inode.h |  6 ++++-
 fs/btrfs/inode.c       | 70 --------------------------------------------------
 2 files changed, 5 insertions(+), 71 deletions(-)

diff --git a/fs/btrfs/btrfs_inode.h b/fs/btrfs/btrfs_inode.h
index f527e99c9f8d..078a53e01ece 100644
--- a/fs/btrfs/btrfs_inode.h
+++ b/fs/btrfs/btrfs_inode.h
@@ -364,6 +364,10 @@ static inline void btrfs_print_data_csum_error(struct btrfs_inode *inode,
 			logical_start, csum, csum_expected, mirror_num);
 }
 
-bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end);
+static inline bool btrfs_page_exists_in_range(struct inode *inode,
+						loff_t start, loff_t end)
+{
+	return filemap_range_has_page(inode->i_mapping, start, end);
+}
 
 #endif
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 1f5b93ecffca..3340de232944 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7476,76 +7476,6 @@ noinline int can_nocow_extent(struct inode *inode, u64 offset, u64 *len,
 	return ret;
 }
 
-bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
-{
-	struct radix_tree_root *root = &inode->i_mapping->page_tree;
-	bool found = false;
-	void **pagep = NULL;
-	struct page *page = NULL;
-	unsigned long start_idx;
-	unsigned long end_idx;
-
-	start_idx = start >> PAGE_SHIFT;
-
-	/*
-	 * end is the last byte in the last page.  end == start is legal
-	 */
-	end_idx = end >> PAGE_SHIFT;
-
-	rcu_read_lock();
-
-	/* Most of the code in this while loop is lifted from
-	 * find_get_page.  It's been modified to begin searching from a
-	 * page and return just the first page found in that range.  If the
-	 * found idx is less than or equal to the end idx then we know that
-	 * a page exists.  If no pages are found or if those pages are
-	 * outside of the range then we're fine (yay!) */
-	while (page == NULL &&
-	       radix_tree_gang_lookup_slot(root, &pagep, NULL, start_idx, 1)) {
-		page = radix_tree_deref_slot(pagep);
-		if (unlikely(!page))
-			break;
-
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				page = NULL;
-				continue;
-			}
-			/*
-			 * Otherwise, shmem/tmpfs must be storing a swap entry
-			 * here as an exceptional entry: so return it without
-			 * attempting to raise page count.
-			 */
-			page = NULL;
-			break; /* TODO: Is this relevant for this use case? */
-		}
-
-		if (!page_cache_get_speculative(page)) {
-			page = NULL;
-			continue;
-		}
-
-		/*
-		 * Has the page moved?
-		 * This is part of the lockless pagecache protocol. See
-		 * include/linux/pagemap.h for details.
-		 */
-		if (unlikely(page != *pagep)) {
-			put_page(page);
-			page = NULL;
-		}
-	}
-
-	if (page) {
-		if (page->index <= end_idx)
-			found = true;
-		put_page(page);
-	}
-
-	rcu_read_unlock();
-	return found;
-}
-
 static int lock_extent_direct(struct inode *inode, u64 lockstart, u64 lockend,
 			      struct extent_state **cached_state, int writing)
 {
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
