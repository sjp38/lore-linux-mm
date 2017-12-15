Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D4D0B6B0286
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:54 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r196so16660604itc.4
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f5si5424740iof.103.2017.12.15.14.05.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:53 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 25/78] page cache: Add page_cache_range_empty function
Date: Fri, 15 Dec 2017 14:03:57 -0800
Message-Id: <20171215220450.7899-26-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

btrfs has its own custom function for determining whether the page cache
has any pages in a particular range.  Move this functionality to the
page cache, and call it from btrfs.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/btrfs_inode.h  |  7 ++++-
 fs/btrfs/inode.c        | 70 -------------------------------------------------
 include/linux/pagemap.h |  2 ++
 mm/filemap.c            | 26 ++++++++++++++++++
 4 files changed, 34 insertions(+), 71 deletions(-)

diff --git a/fs/btrfs/btrfs_inode.h b/fs/btrfs/btrfs_inode.h
index 63f0ccc92a71..a48bd6e0a0bb 100644
--- a/fs/btrfs/btrfs_inode.h
+++ b/fs/btrfs/btrfs_inode.h
@@ -365,6 +365,11 @@ static inline void btrfs_print_data_csum_error(struct btrfs_inode *inode,
 			logical_start, csum, csum_expected, mirror_num);
 }
 
-bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end);
+static inline bool btrfs_page_exists_in_range(struct inode *inode,
+						loff_t start, loff_t end)
+{
+	return page_cache_range_empty(inode->i_mapping, start >> PAGE_SHIFT,
+							end >> PAGE_SHIFT);
+}
 
 #endif
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index dbdb5bf6bca1..d7d2c556d5a2 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7541,76 +7541,6 @@ noinline int can_nocow_extent(struct inode *inode, u64 offset, u64 *len,
 	return ret;
 }
 
-bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
-{
-	struct radix_tree_root *root = &inode->i_mapping->pages;
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
-			 * here so return it without attempting to raise page
-			 * count.
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
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0db127c3ccac..34d4fa3ad1c5 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -245,6 +245,8 @@ pgoff_t page_cache_next_gap(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan);
 pgoff_t page_cache_prev_gap(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan);
+bool page_cache_range_empty(struct address_space *mapping,
+				pgoff_t index, pgoff_t max);
 
 #define FGP_ACCESSED		0x00000001
 #define FGP_LOCK		0x00000002
diff --git a/mm/filemap.c b/mm/filemap.c
index 146e8ec16ec0..f1b4480723dd 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1398,6 +1398,32 @@ pgoff_t page_cache_prev_gap(struct address_space *mapping,
 }
 EXPORT_SYMBOL(page_cache_prev_gap);
 
+bool page_cache_range_empty(struct address_space *mapping, pgoff_t index,
+				pgoff_t max)
+{
+	struct page *page;
+	XA_STATE(xas, &mapping->pages, index);
+
+	rcu_read_lock();
+	do {
+		page = xas_find(&xas, max);
+		if (xas_retry(&xas, page))
+			continue;
+		/* Shadow entries don't count */
+		if (xa_is_value(page))
+			continue;
+		/*
+		 * We don't need to try to pin this page; we're about to
+		 * release the RCU lock anyway.  It is enough to know that
+		 * there was a page here recently.
+		 */
+	} while (0);
+	rcu_read_unlock();
+
+	return page != NULL;
+}
+EXPORT_SYMBOL_GPL(page_cache_range_empty);
+
 /**
  * find_get_entry - find and get a page cache entry
  * @mapping: the address_space to search
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
