Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 548B2828F4
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:23 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id 4so106548603pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:23 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p86si16668950pfa.161.2016.03.20.11.42.14
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:42:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 56/71] qnx6: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:03 +0300
Message-Id: <1458499278-1516-57-git-send-email-kirill.shutemov@linux.intel.com>
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
 fs/qnx6/dir.c   | 16 ++++++++--------
 fs/qnx6/inode.c |  4 ++--
 fs/qnx6/qnx6.h  |  2 +-
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/qnx6/dir.c b/fs/qnx6/dir.c
index e1f37278cf97..144ceda4948e 100644
--- a/fs/qnx6/dir.c
+++ b/fs/qnx6/dir.c
@@ -35,9 +35,9 @@ static struct page *qnx6_get_page(struct inode *dir, unsigned long n)
 static unsigned last_entry(struct inode *inode, unsigned long page_nr)
 {
 	unsigned long last_byte = inode->i_size;
-	last_byte -= page_nr << PAGE_CACHE_SHIFT;
-	if (last_byte > PAGE_CACHE_SIZE)
-		last_byte = PAGE_CACHE_SIZE;
+	last_byte -= page_nr << PAGE_SHIFT;
+	if (last_byte > PAGE_SIZE)
+		last_byte = PAGE_SIZE;
 	return last_byte / QNX6_DIR_ENTRY_SIZE;
 }
 
@@ -47,9 +47,9 @@ static struct qnx6_long_filename *qnx6_longname(struct super_block *sb,
 {
 	struct qnx6_sb_info *sbi = QNX6_SB(sb);
 	u32 s = fs32_to_cpu(sbi, de->de_long_inode); /* in block units */
-	u32 n = s >> (PAGE_CACHE_SHIFT - sb->s_blocksize_bits); /* in pages */
+	u32 n = s >> (PAGE_SHIFT - sb->s_blocksize_bits); /* in pages */
 	/* within page */
-	u32 offs = (s << sb->s_blocksize_bits) & ~PAGE_CACHE_MASK;
+	u32 offs = (s << sb->s_blocksize_bits) & ~PAGE_MASK;
 	struct address_space *mapping = sbi->longfile->i_mapping;
 	struct page *page = read_mapping_page(mapping, n, NULL);
 	if (IS_ERR(page))
@@ -115,8 +115,8 @@ static int qnx6_readdir(struct file *file, struct dir_context *ctx)
 	struct qnx6_sb_info *sbi = QNX6_SB(s);
 	loff_t pos = ctx->pos & ~(QNX6_DIR_ENTRY_SIZE - 1);
 	unsigned long npages = dir_pages(inode);
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
-	unsigned start = (pos & ~PAGE_CACHE_MASK) / QNX6_DIR_ENTRY_SIZE;
+	unsigned long n = pos >> PAGE_SHIFT;
+	unsigned start = (pos & ~PAGE_MASK) / QNX6_DIR_ENTRY_SIZE;
 	bool done = false;
 
 	ctx->pos = pos;
@@ -131,7 +131,7 @@ static int qnx6_readdir(struct file *file, struct dir_context *ctx)
 
 		if (IS_ERR(page)) {
 			pr_err("%s(): read failed\n", __func__);
-			ctx->pos = (n + 1) << PAGE_CACHE_SHIFT;
+			ctx->pos = (n + 1) << PAGE_SHIFT;
 			return PTR_ERR(page);
 		}
 		de = ((struct qnx6_dir_entry *)page_address(page)) + start;
diff --git a/fs/qnx6/inode.c b/fs/qnx6/inode.c
index 47bb1de07155..1192422a1c56 100644
--- a/fs/qnx6/inode.c
+++ b/fs/qnx6/inode.c
@@ -542,8 +542,8 @@ struct inode *qnx6_iget(struct super_block *sb, unsigned ino)
 		iget_failed(inode);
 		return ERR_PTR(-EIO);
 	}
-	n = (ino - 1) >> (PAGE_CACHE_SHIFT - QNX6_INODE_SIZE_BITS);
-	offs = (ino - 1) & (~PAGE_CACHE_MASK >> QNX6_INODE_SIZE_BITS);
+	n = (ino - 1) >> (PAGE_SHIFT - QNX6_INODE_SIZE_BITS);
+	offs = (ino - 1) & (~PAGE_MASK >> QNX6_INODE_SIZE_BITS);
 	mapping = sbi->inodes->i_mapping;
 	page = read_mapping_page(mapping, n, NULL);
 	if (IS_ERR(page)) {
diff --git a/fs/qnx6/qnx6.h b/fs/qnx6/qnx6.h
index d3fb2b698800..f23b5c4a66ad 100644
--- a/fs/qnx6/qnx6.h
+++ b/fs/qnx6/qnx6.h
@@ -128,7 +128,7 @@ extern struct qnx6_super_block *qnx6_mmi_fill_super(struct super_block *s,
 static inline void qnx6_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 extern unsigned qnx6_find_entry(int len, struct inode *dir, const char *name,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
