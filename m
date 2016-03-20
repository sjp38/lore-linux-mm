Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3CBFE82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:50:03 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id 4so106679038pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:50:03 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qx12si13425508pab.169.2016.03.20.11.41.49
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 40/71] hfsplus: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:47 +0300
Message-Id: <1458499278-1516-41-git-send-email-kirill.shutemov@linux.intel.com>
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
 fs/hfsplus/bitmap.c |  2 +-
 fs/hfsplus/bnode.c  | 90 ++++++++++++++++++++++++++---------------------------
 fs/hfsplus/btree.c  | 22 ++++++-------
 fs/hfsplus/inode.c  |  8 ++---
 fs/hfsplus/super.c  |  2 +-
 fs/hfsplus/xattr.c  |  6 ++--
 6 files changed, 65 insertions(+), 65 deletions(-)

diff --git a/fs/hfsplus/bitmap.c b/fs/hfsplus/bitmap.c
index d2954451519e..c0ae274c0a22 100644
--- a/fs/hfsplus/bitmap.c
+++ b/fs/hfsplus/bitmap.c
@@ -13,7 +13,7 @@
 #include "hfsplus_fs.h"
 #include "hfsplus_raw.h"
 
-#define PAGE_CACHE_BITS	(PAGE_CACHE_SIZE * 8)
+#define PAGE_CACHE_BITS	(PAGE_SIZE * 8)
 
 int hfsplus_block_allocate(struct super_block *sb, u32 size,
 		u32 offset, u32 *max)
diff --git a/fs/hfsplus/bnode.c b/fs/hfsplus/bnode.c
index 63924662aaf3..ce014ceb89ef 100644
--- a/fs/hfsplus/bnode.c
+++ b/fs/hfsplus/bnode.c
@@ -24,16 +24,16 @@ void hfs_bnode_read(struct hfs_bnode *node, void *buf, int off, int len)
 	int l;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
-	off &= ~PAGE_CACHE_MASK;
+	pagep = node->page + (off >> PAGE_SHIFT);
+	off &= ~PAGE_MASK;
 
-	l = min_t(int, len, PAGE_CACHE_SIZE - off);
+	l = min_t(int, len, PAGE_SIZE - off);
 	memcpy(buf, kmap(*pagep) + off, l);
 	kunmap(*pagep);
 
 	while ((len -= l) != 0) {
 		buf += l;
-		l = min_t(int, len, PAGE_CACHE_SIZE);
+		l = min_t(int, len, PAGE_SIZE);
 		memcpy(buf, kmap(*++pagep), l);
 		kunmap(*pagep);
 	}
@@ -77,17 +77,17 @@ void hfs_bnode_write(struct hfs_bnode *node, void *buf, int off, int len)
 	int l;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
-	off &= ~PAGE_CACHE_MASK;
+	pagep = node->page + (off >> PAGE_SHIFT);
+	off &= ~PAGE_MASK;
 
-	l = min_t(int, len, PAGE_CACHE_SIZE - off);
+	l = min_t(int, len, PAGE_SIZE - off);
 	memcpy(kmap(*pagep) + off, buf, l);
 	set_page_dirty(*pagep);
 	kunmap(*pagep);
 
 	while ((len -= l) != 0) {
 		buf += l;
-		l = min_t(int, len, PAGE_CACHE_SIZE);
+		l = min_t(int, len, PAGE_SIZE);
 		memcpy(kmap(*++pagep), buf, l);
 		set_page_dirty(*pagep);
 		kunmap(*pagep);
@@ -107,16 +107,16 @@ void hfs_bnode_clear(struct hfs_bnode *node, int off, int len)
 	int l;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
-	off &= ~PAGE_CACHE_MASK;
+	pagep = node->page + (off >> PAGE_SHIFT);
+	off &= ~PAGE_MASK;
 
-	l = min_t(int, len, PAGE_CACHE_SIZE - off);
+	l = min_t(int, len, PAGE_SIZE - off);
 	memset(kmap(*pagep) + off, 0, l);
 	set_page_dirty(*pagep);
 	kunmap(*pagep);
 
 	while ((len -= l) != 0) {
-		l = min_t(int, len, PAGE_CACHE_SIZE);
+		l = min_t(int, len, PAGE_SIZE);
 		memset(kmap(*++pagep), 0, l);
 		set_page_dirty(*pagep);
 		kunmap(*pagep);
@@ -136,20 +136,20 @@ void hfs_bnode_copy(struct hfs_bnode *dst_node, int dst,
 	tree = src_node->tree;
 	src += src_node->page_offset;
 	dst += dst_node->page_offset;
-	src_page = src_node->page + (src >> PAGE_CACHE_SHIFT);
-	src &= ~PAGE_CACHE_MASK;
-	dst_page = dst_node->page + (dst >> PAGE_CACHE_SHIFT);
-	dst &= ~PAGE_CACHE_MASK;
+	src_page = src_node->page + (src >> PAGE_SHIFT);
+	src &= ~PAGE_MASK;
+	dst_page = dst_node->page + (dst >> PAGE_SHIFT);
+	dst &= ~PAGE_MASK;
 
 	if (src == dst) {
-		l = min_t(int, len, PAGE_CACHE_SIZE - src);
+		l = min_t(int, len, PAGE_SIZE - src);
 		memcpy(kmap(*dst_page) + src, kmap(*src_page) + src, l);
 		kunmap(*src_page);
 		set_page_dirty(*dst_page);
 		kunmap(*dst_page);
 
 		while ((len -= l) != 0) {
-			l = min_t(int, len, PAGE_CACHE_SIZE);
+			l = min_t(int, len, PAGE_SIZE);
 			memcpy(kmap(*++dst_page), kmap(*++src_page), l);
 			kunmap(*src_page);
 			set_page_dirty(*dst_page);
@@ -161,12 +161,12 @@ void hfs_bnode_copy(struct hfs_bnode *dst_node, int dst,
 		do {
 			src_ptr = kmap(*src_page) + src;
 			dst_ptr = kmap(*dst_page) + dst;
-			if (PAGE_CACHE_SIZE - src < PAGE_CACHE_SIZE - dst) {
-				l = PAGE_CACHE_SIZE - src;
+			if (PAGE_SIZE - src < PAGE_SIZE - dst) {
+				l = PAGE_SIZE - src;
 				src = 0;
 				dst += l;
 			} else {
-				l = PAGE_CACHE_SIZE - dst;
+				l = PAGE_SIZE - dst;
 				src += l;
 				dst = 0;
 			}
@@ -195,11 +195,11 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 	dst += node->page_offset;
 	if (dst > src) {
 		src += len - 1;
-		src_page = node->page + (src >> PAGE_CACHE_SHIFT);
-		src = (src & ~PAGE_CACHE_MASK) + 1;
+		src_page = node->page + (src >> PAGE_SHIFT);
+		src = (src & ~PAGE_MASK) + 1;
 		dst += len - 1;
-		dst_page = node->page + (dst >> PAGE_CACHE_SHIFT);
-		dst = (dst & ~PAGE_CACHE_MASK) + 1;
+		dst_page = node->page + (dst >> PAGE_SHIFT);
+		dst = (dst & ~PAGE_MASK) + 1;
 
 		if (src == dst) {
 			while (src < len) {
@@ -208,7 +208,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 				set_page_dirty(*dst_page);
 				kunmap(*dst_page);
 				len -= src;
-				src = PAGE_CACHE_SIZE;
+				src = PAGE_SIZE;
 				src_page--;
 				dst_page--;
 			}
@@ -226,32 +226,32 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 				dst_ptr = kmap(*dst_page) + dst;
 				if (src < dst) {
 					l = src;
-					src = PAGE_CACHE_SIZE;
+					src = PAGE_SIZE;
 					dst -= l;
 				} else {
 					l = dst;
 					src -= l;
-					dst = PAGE_CACHE_SIZE;
+					dst = PAGE_SIZE;
 				}
 				l = min(len, l);
 				memmove(dst_ptr - l, src_ptr - l, l);
 				kunmap(*src_page);
 				set_page_dirty(*dst_page);
 				kunmap(*dst_page);
-				if (dst == PAGE_CACHE_SIZE)
+				if (dst == PAGE_SIZE)
 					dst_page--;
 				else
 					src_page--;
 			} while ((len -= l));
 		}
 	} else {
-		src_page = node->page + (src >> PAGE_CACHE_SHIFT);
-		src &= ~PAGE_CACHE_MASK;
-		dst_page = node->page + (dst >> PAGE_CACHE_SHIFT);
-		dst &= ~PAGE_CACHE_MASK;
+		src_page = node->page + (src >> PAGE_SHIFT);
+		src &= ~PAGE_MASK;
+		dst_page = node->page + (dst >> PAGE_SHIFT);
+		dst &= ~PAGE_MASK;
 
 		if (src == dst) {
-			l = min_t(int, len, PAGE_CACHE_SIZE - src);
+			l = min_t(int, len, PAGE_SIZE - src);
 			memmove(kmap(*dst_page) + src,
 				kmap(*src_page) + src, l);
 			kunmap(*src_page);
@@ -259,7 +259,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 			kunmap(*dst_page);
 
 			while ((len -= l) != 0) {
-				l = min_t(int, len, PAGE_CACHE_SIZE);
+				l = min_t(int, len, PAGE_SIZE);
 				memmove(kmap(*++dst_page),
 					kmap(*++src_page), l);
 				kunmap(*src_page);
@@ -272,13 +272,13 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 			do {
 				src_ptr = kmap(*src_page) + src;
 				dst_ptr = kmap(*dst_page) + dst;
-				if (PAGE_CACHE_SIZE - src <
-						PAGE_CACHE_SIZE - dst) {
-					l = PAGE_CACHE_SIZE - src;
+				if (PAGE_SIZE - src <
+						PAGE_SIZE - dst) {
+					l = PAGE_SIZE - src;
 					src = 0;
 					dst += l;
 				} else {
-					l = PAGE_CACHE_SIZE - dst;
+					l = PAGE_SIZE - dst;
 					src += l;
 					dst = 0;
 				}
@@ -444,14 +444,14 @@ static struct hfs_bnode *__hfs_bnode_create(struct hfs_btree *tree, u32 cnid)
 
 	mapping = tree->inode->i_mapping;
 	off = (loff_t)cnid << tree->node_size_shift;
-	block = off >> PAGE_CACHE_SHIFT;
-	node->page_offset = off & ~PAGE_CACHE_MASK;
+	block = off >> PAGE_SHIFT;
+	node->page_offset = off & ~PAGE_MASK;
 	for (i = 0; i < tree->pages_per_bnode; block++, i++) {
 		page = read_mapping_page(mapping, block, NULL);
 		if (IS_ERR(page))
 			goto fail;
 		if (PageError(page)) {
-			page_cache_release(page);
+			put_page(page);
 			goto fail;
 		}
 		node->page[i] = page;
@@ -569,7 +569,7 @@ void hfs_bnode_free(struct hfs_bnode *node)
 
 	for (i = 0; i < node->tree->pages_per_bnode; i++)
 		if (node->page[i])
-			page_cache_release(node->page[i]);
+			put_page(node->page[i]);
 	kfree(node);
 }
 
@@ -597,11 +597,11 @@ struct hfs_bnode *hfs_bnode_create(struct hfs_btree *tree, u32 num)
 
 	pagep = node->page;
 	memset(kmap(*pagep) + node->page_offset, 0,
-	       min_t(int, PAGE_CACHE_SIZE, tree->node_size));
+	       min_t(int, PAGE_SIZE, tree->node_size));
 	set_page_dirty(*pagep);
 	kunmap(*pagep);
 	for (i = 1; i < tree->pages_per_bnode; i++) {
-		memset(kmap(*++pagep), 0, PAGE_CACHE_SIZE);
+		memset(kmap(*++pagep), 0, PAGE_SIZE);
 		set_page_dirty(*pagep);
 		kunmap(*pagep);
 	}
diff --git a/fs/hfsplus/btree.c b/fs/hfsplus/btree.c
index 3345c7553edc..d9d1a36ba826 100644
--- a/fs/hfsplus/btree.c
+++ b/fs/hfsplus/btree.c
@@ -236,15 +236,15 @@ struct hfs_btree *hfs_btree_open(struct super_block *sb, u32 id)
 	tree->node_size_shift = ffs(size) - 1;
 
 	tree->pages_per_bnode =
-		(tree->node_size + PAGE_CACHE_SIZE - 1) >>
-		PAGE_CACHE_SHIFT;
+		(tree->node_size + PAGE_SIZE - 1) >>
+		PAGE_SHIFT;
 
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 	return tree;
 
  fail_page:
-	page_cache_release(page);
+	put_page(page);
  free_inode:
 	tree->inode->i_mapping->a_ops = &hfsplus_aops;
 	iput(tree->inode);
@@ -380,9 +380,9 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 	off = off16;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
+	pagep = node->page + (off >> PAGE_SHIFT);
 	data = kmap(*pagep);
-	off &= ~PAGE_CACHE_MASK;
+	off &= ~PAGE_MASK;
 	idx = 0;
 
 	for (;;) {
@@ -403,7 +403,7 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 					}
 				}
 			}
-			if (++off >= PAGE_CACHE_SIZE) {
+			if (++off >= PAGE_SIZE) {
 				kunmap(*pagep);
 				data = kmap(*++pagep);
 				off = 0;
@@ -426,9 +426,9 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
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
 
@@ -475,9 +475,9 @@ void hfs_bmap_free(struct hfs_bnode *node)
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
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index 1a6394cdb54e..b28f39865c3a 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -87,9 +87,9 @@ static int hfsplus_releasepage(struct page *page, gfp_t mask)
 	}
 	if (!tree)
 		return 0;
-	if (tree->node_size >= PAGE_CACHE_SIZE) {
+	if (tree->node_size >= PAGE_SIZE) {
 		nidx = page->index >>
-			(tree->node_size_shift - PAGE_CACHE_SHIFT);
+			(tree->node_size_shift - PAGE_SHIFT);
 		spin_lock(&tree->hash_lock);
 		node = hfs_bnode_findhash(tree, nidx);
 		if (!node)
@@ -103,8 +103,8 @@ static int hfsplus_releasepage(struct page *page, gfp_t mask)
 		spin_unlock(&tree->hash_lock);
 	} else {
 		nidx = page->index <<
-			(PAGE_CACHE_SHIFT - tree->node_size_shift);
-		i = 1 << (PAGE_CACHE_SHIFT - tree->node_size_shift);
+			(PAGE_SHIFT - tree->node_size_shift);
+		i = 1 << (PAGE_SHIFT - tree->node_size_shift);
 		spin_lock(&tree->hash_lock);
 		do {
 			node = hfs_bnode_findhash(tree, nidx++);
diff --git a/fs/hfsplus/super.c b/fs/hfsplus/super.c
index 5d54490a136d..c35911362ff9 100644
--- a/fs/hfsplus/super.c
+++ b/fs/hfsplus/super.c
@@ -438,7 +438,7 @@ static int hfsplus_fill_super(struct super_block *sb, void *data, int silent)
 	err = -EFBIG;
 	last_fs_block = sbi->total_blocks - 1;
 	last_fs_page = (last_fs_block << sbi->alloc_blksz_shift) >>
-			PAGE_CACHE_SHIFT;
+			PAGE_SHIFT;
 
 	if ((last_fs_block > (sector_t)(~0ULL) >> (sbi->alloc_blksz_shift - 9)) ||
 	    (last_fs_page > (pgoff_t)(~0ULL))) {
diff --git a/fs/hfsplus/xattr.c b/fs/hfsplus/xattr.c
index ab01530b4930..70e445ff0cff 100644
--- a/fs/hfsplus/xattr.c
+++ b/fs/hfsplus/xattr.c
@@ -220,7 +220,7 @@ check_attr_tree_state_again:
 
 	index = 0;
 	written = 0;
-	for (; written < node_size; index++, written += PAGE_CACHE_SIZE) {
+	for (; written < node_size; index++, written += PAGE_SIZE) {
 		void *kaddr;
 
 		page = read_mapping_page(mapping, index, NULL);
@@ -231,11 +231,11 @@ check_attr_tree_state_again:
 
 		kaddr = kmap_atomic(page);
 		memcpy(kaddr, buf + written,
-			min_t(size_t, PAGE_CACHE_SIZE, node_size - written));
+			min_t(size_t, PAGE_SIZE, node_size - written));
 		kunmap_atomic(kaddr);
 
 		set_page_dirty(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	hfsplus_mark_inode_dirty(attr_file, HFSPLUS_I_ATTR_DIRTY);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
