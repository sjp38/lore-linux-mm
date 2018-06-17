Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64ED06B0276
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p16-v6so6649419pfn.7
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x15-v6si11130458pfk.25.2018.06.16.19.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:05 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 39/74] mm: Convert delete_from_swap_cache to XArray
Date: Sat, 16 Jun 2018 19:00:17 -0700
Message-Id: <20180617020052.4759-40-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Both callers of __delete_from_swap_cache have the swp_entry_t already,
so pass that in to make constructing the XA_STATE easier.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/swap.h |  5 +++--
 mm/swap_state.c      | 24 ++++++++++--------------
 mm/vmscan.c          |  2 +-
 3 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index a450a1d40b19..470570dac9e8 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -404,7 +404,7 @@ extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *page);
 extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
 extern int __add_to_swap_cache(struct page *page, swp_entry_t entry);
-extern void __delete_from_swap_cache(struct page *);
+extern void __delete_from_swap_cache(struct page *, swp_entry_t entry);
 extern void delete_from_swap_cache(struct page *);
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
@@ -564,7 +564,8 @@ static inline int add_to_swap_cache(struct page *page, swp_entry_t entry,
 	return -1;
 }
 
-static inline void __delete_from_swap_cache(struct page *page)
+static inline void __delete_from_swap_cache(struct page *page,
+							swp_entry_t entry)
 {
 }
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index ca18407a79aa..5cd42d05177e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -154,23 +154,22 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp)
  * This must be called only on pages that have
  * been verified to be in the swap cache.
  */
-void __delete_from_swap_cache(struct page *page)
+void __delete_from_swap_cache(struct page *page, swp_entry_t entry)
 {
-	struct address_space *address_space;
+	struct address_space *address_space = swap_address_space(entry);
 	int i, nr = hpage_nr_pages(page);
-	swp_entry_t entry;
-	pgoff_t idx;
+	pgoff_t idx = swp_offset(entry);
+	XA_STATE(xas, &address_space->i_pages, idx);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(PageWriteback(page), page);
 
-	entry.val = page_private(page);
-	address_space = swap_address_space(entry);
-	idx = swp_offset(entry);
 	for (i = 0; i < nr; i++) {
-		radix_tree_delete(&address_space->i_pages, idx + i);
+		void *entry = xas_store(&xas, NULL);
+		VM_BUG_ON_PAGE(entry != page + i, entry);
 		set_page_private(page + i, 0);
+		xas_next(&xas);
 	}
 	ClearPageSwapCache(page);
 	address_space->nrpages -= nr;
@@ -243,14 +242,11 @@ int add_to_swap(struct page *page)
  */
 void delete_from_swap_cache(struct page *page)
 {
-	swp_entry_t entry;
-	struct address_space *address_space;
-
-	entry.val = page_private(page);
+	swp_entry_t entry = { .val = page_private(page) };
+	struct address_space *address_space = swap_address_space(entry);
 
-	address_space = swap_address_space(entry);
 	xa_lock_irq(&address_space->i_pages);
-	__delete_from_swap_cache(page);
+	__delete_from_swap_cache(page, entry);
 	xa_unlock_irq(&address_space->i_pages);
 
 	put_swap_page(page, entry);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f86f288..0448b1b366d9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -753,7 +753,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
 		mem_cgroup_swapout(page, swap);
-		__delete_from_swap_cache(page);
+		__delete_from_swap_cache(page, swap);
 		xa_unlock_irqrestore(&mapping->i_pages, flags);
 		put_swap_page(page, swap);
 	} else {
-- 
2.17.1
