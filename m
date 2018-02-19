Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA3696B02C3
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:48:05 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 67so632044pfg.0
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:48:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n10si2455258pge.256.2018.02.19.11.46.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:33 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 58/61] f2fs: Convert to XArray
Date: Mon, 19 Feb 2018 11:45:53 -0800
Message-Id: <20180219194556.6575-59-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a straightforward conversion.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/f2fs/data.c   |  3 +--
 fs/f2fs/dir.c    |  5 +----
 fs/f2fs/inline.c |  6 +-----
 fs/f2fs/node.c   | 10 ++--------
 4 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index ce029060acd0..6de3d82377e4 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -2384,8 +2384,7 @@ void f2fs_set_page_dirty_nobuffers(struct page *page)
 	xa_lock_irqsave(&mapping->pages, flags);
 	WARN_ON_ONCE(!PageUptodate(page));
 	account_page_dirtied(page, mapping);
-	radix_tree_tag_set(&mapping->pages,
-			page_index(page), PAGECACHE_TAG_DIRTY);
+	__xa_set_tag(&mapping->pages, page_index(page), PAGECACHE_TAG_DIRTY);
 	xa_unlock_irqrestore(&mapping->pages, flags);
 	unlock_page_memcg(page);
 
diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index 0fd9695eddf6..ab833f624cc2 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -708,7 +708,6 @@ void f2fs_delete_entry(struct f2fs_dir_entry *dentry, struct page *page,
 	unsigned int bit_pos;
 	int slots = GET_DENTRY_SLOTS(le16_to_cpu(dentry->name_len));
 	struct address_space *mapping = page_mapping(page);
-	unsigned long flags;
 	int i;
 
 	f2fs_update_time(F2FS_I_SB(dir), REQ_TIME);
@@ -741,10 +740,8 @@ void f2fs_delete_entry(struct f2fs_dir_entry *dentry, struct page *page,
 
 	if (bit_pos == NR_DENTRY_IN_BLOCK &&
 			!truncate_hole(dir, page->index, page->index + 1)) {
-		xa_lock_irqsave(&mapping->pages, flags);
-		radix_tree_tag_clear(&mapping->pages, page_index(page),
+		xa_clear_tag(&mapping->pages, page_index(page),
 				     PAGECACHE_TAG_DIRTY);
-		xa_unlock_irqrestore(&mapping->pages, flags);
 
 		clear_page_dirty_for_io(page);
 		ClearPagePrivate(page);
diff --git a/fs/f2fs/inline.c b/fs/f2fs/inline.c
index 7858b8e15f33..d3c3f84beca9 100644
--- a/fs/f2fs/inline.c
+++ b/fs/f2fs/inline.c
@@ -204,7 +204,6 @@ int f2fs_write_inline_data(struct inode *inode, struct page *page)
 	void *src_addr, *dst_addr;
 	struct dnode_of_data dn;
 	struct address_space *mapping = page_mapping(page);
-	unsigned long flags;
 	int err;
 
 	set_new_dnode(&dn, inode, NULL, NULL, 0);
@@ -226,10 +225,7 @@ int f2fs_write_inline_data(struct inode *inode, struct page *page)
 	kunmap_atomic(src_addr);
 	set_page_dirty(dn.inode_page);
 
-	xa_lock_irqsave(&mapping->pages, flags);
-	radix_tree_tag_clear(&mapping->pages, page_index(page),
-			     PAGECACHE_TAG_DIRTY);
-	xa_unlock_irqrestore(&mapping->pages, flags);
+	xa_clear_tag(&mapping->pages, page_index(page), PAGECACHE_TAG_DIRTY);
 
 	set_inode_flag(inode, FI_APPEND_WRITE);
 	set_inode_flag(inode, FI_DATA_EXIST);
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index fba2644abdf0..0c1e9add0952 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -88,14 +88,10 @@ bool available_free_memory(struct f2fs_sb_info *sbi, int type)
 static void clear_node_page_dirty(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
-	unsigned int long flags;
 
 	if (PageDirty(page)) {
-		xa_lock_irqsave(&mapping->pages, flags);
-		radix_tree_tag_clear(&mapping->pages,
-				page_index(page),
+		xa_clear_tag(&mapping->pages, page_index(page),
 				PAGECACHE_TAG_DIRTY);
-		xa_unlock_irqrestore(&mapping->pages, flags);
 
 		clear_page_dirty_for_io(page);
 		dec_page_count(F2FS_M_SB(mapping), F2FS_DIRTY_NODES);
@@ -1139,9 +1135,7 @@ void ra_node_page(struct f2fs_sb_info *sbi, nid_t nid)
 		return;
 	f2fs_bug_on(sbi, check_nid_range(sbi, nid));
 
-	rcu_read_lock();
-	apage = radix_tree_lookup(&NODE_MAPPING(sbi)->pages, nid);
-	rcu_read_unlock();
+	apage = xa_load(&NODE_MAPPING(sbi)->pages, nid);
 	if (apage)
 		return;
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
