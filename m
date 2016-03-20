Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id BD00282F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:08 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id 4so106663537pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:08 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id oi7si1467849pab.183.2016.03.20.11.41.48
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 39/71] hfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:46 +0300
Message-Id: <1458499278-1516-40-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/hfs/bnode.c | 12 ++++++------
 fs/hfs/btree.c | 20 ++++++++++----------
 fs/hfs/inode.c |  8 ++++----
 3 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/fs/hfs/bnode.c b/fs/hfs/bnode.c
index 221719eac5de..d77d844b668b 100644
--- a/fs/hfs/bnode.c
+++ b/fs/hfs/bnode.c
@@ -278,14 +278,14 @@ static struct hfs_bnode *__hfs_bnode_create(struct hfs_btree *tree, u32 cnid)
 
 	mapping = tree->inode->i_mapping;
 	off = (loff_t)cnid * tree->node_size;
-	block = off >> PAGE_CACHE_SHIFT;
-	node->page_offset = off & ~PAGE_CACHE_MASK;
+	block = off >> PAGE_SHIFT;
+	node->page_offset = off & ~PAGE_MASK;
 	for (i = 0; i < tree->pages_per_bnode; i++) {
 		page = read_mapping_page(mapping, block++, NULL);
 		if (IS_ERR(page))
 			goto fail;
 		if (PageError(page)) {
-			page_cache_release(page);
+			put_page(page);
 			goto fail;
 		}
 		node->page[i] = page;
@@ -401,7 +401,7 @@ void hfs_bnode_free(struct hfs_bnode *node)
 
 	for (i = 0; i < node->tree->pages_per_bnode; i++)
 		if (node->page[i])
-			page_cache_release(node->page[i]);
+			put_page(node->page[i]);
 	kfree(node);
 }
 
@@ -429,11 +429,11 @@ struct hfs_bnode *hfs_bnode_create(struct hfs_btree *tree, u32 num)
 
 	pagep = node->page;
 	memset(kmap(*pagep) + node->page_offset, 0,
-	       min((int)PAGE_CACHE_SIZE, (int)tree->node_size));
+	       min((int)PAGE_SIZE, (int)tree->node_size));
 	set_page_dirty(*pagep);
 	kunmap(*pagep);
 	for (i = 1; i < tree->pages_per_bnode; i++) {
-		memset(kmap(*++pagep), 0, PAGE_CACHE_SIZE);
+		memset(kmap(*++pagep), 0, PAGE_SIZE);
 		set_page_dirty(*pagep);
 		kunmap(*pagep);
 	}
diff --git a/fs/hfs/btree.c b/fs/hfs/btree.c
index 1ab19e660e69..37cdd955eceb 100644
--- a/fs/hfs/btree.c
+++ b/fs/hfs/btree.c
@@ -116,14 +116,14 @@ struct hfs_btree *hfs_btree_open(struct super_block *sb, u32 id, btree_keycmp ke
 	}
 
 	tree->node_size_shift = ffs(size) - 1;
-	tree->pages_per_bnode = (tree->node_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	tree->pages_per_bnode = (tree->node_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 	return tree;
 
 fail_page:
-	page_cache_release(page);
+	put_page(page);
 free_inode:
 	tree->inode->i_mapping->a_ops = &hfs_aops;
 	iput(tree->inode);
@@ -257,9 +257,9 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 	off = off16;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
+	pagep = node->page + (off >> PAGE_SHIFT);
 	data = kmap(*pagep);
-	off &= ~PAGE_CACHE_MASK;
+	off &= ~PAGE_MASK;
 	idx = 0;
 
 	for (;;) {
@@ -279,7 +279,7 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 					}
 				}
 			}
-			if (++off >= PAGE_CACHE_SIZE) {
+			if (++off >= PAGE_SIZE) {
 				kunmap(*pagep);
 				data = kmap(*++pagep);
 				off = 0;
@@ -302,9 +302,9 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 		len = hfs_brec_lenoff(node, 0, &off16);
 		off = off16;
 		off += node->page_offset;
-		pagep = node->page + (off >> PAGE_CACHE_SHIFT);
+		pagep = node->page + (off >> PAGE_SHIFT);
 		data = kmap(*pagep);
-		off &= ~PAGE_CACHE_MASK;
+		off &= ~PAGE_MASK;
 	}
 }
 
@@ -348,9 +348,9 @@ void hfs_bmap_free(struct hfs_bnode *node)
 		len = hfs_brec_lenoff(node, 0, &off);
 	}
 	off += node->page_offset + nidx / 8;
-	page = node->page[off >> PAGE_CACHE_SHIFT];
+	page = node->page[off >> PAGE_SHIFT];
 	data = kmap(page);
-	off &= ~PAGE_CACHE_MASK;
+	off &= ~PAGE_MASK;
 	m = 1 << (~nidx & 7);
 	byte = data[off];
 	if (!(byte & m)) {
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index 6686bf39a5b5..cb1e5faa2fb7 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -91,8 +91,8 @@ static int hfs_releasepage(struct page *page, gfp_t mask)
 	if (!tree)
 		return 0;
 
-	if (tree->node_size >= PAGE_CACHE_SIZE) {
-		nidx = page->index >> (tree->node_size_shift - PAGE_CACHE_SHIFT);
+	if (tree->node_size >= PAGE_SIZE) {
+		nidx = page->index >> (tree->node_size_shift - PAGE_SHIFT);
 		spin_lock(&tree->hash_lock);
 		node = hfs_bnode_findhash(tree, nidx);
 		if (!node)
@@ -105,8 +105,8 @@ static int hfs_releasepage(struct page *page, gfp_t mask)
 		}
 		spin_unlock(&tree->hash_lock);
 	} else {
-		nidx = page->index << (PAGE_CACHE_SHIFT - tree->node_size_shift);
-		i = 1 << (PAGE_CACHE_SHIFT - tree->node_size_shift);
+		nidx = page->index << (PAGE_SHIFT - tree->node_size_shift);
+		i = 1 << (PAGE_SHIFT - tree->node_size_shift);
 		spin_lock(&tree->hash_lock);
 		do {
 			node = hfs_bnode_findhash(tree, nidx++);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
