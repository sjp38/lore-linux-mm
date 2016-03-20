Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 59BCC82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:57 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id x3so237554602pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:57 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id fk7si16102086pac.50.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 27/71] cramfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:34 +0300
Message-Id: <1458499278-1516-28-git-send-email-kirill.shutemov@linux.intel.com>
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
 Documentation/filesystems/cramfs.txt |  2 +-
 fs/cramfs/README                     | 26 +++++++++++++-------------
 fs/cramfs/inode.c                    | 32 ++++++++++++++++----------------
 3 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/Documentation/filesystems/cramfs.txt b/Documentation/filesystems/cramfs.txt
index 31f53f0ab957..4006298f6707 100644
--- a/Documentation/filesystems/cramfs.txt
+++ b/Documentation/filesystems/cramfs.txt
@@ -38,7 +38,7 @@ the update lasts only as long as the inode is cached in memory, after
 which the timestamp reverts to 1970, i.e. moves backwards in time.
 
 Currently, cramfs must be written and read with architectures of the
-same endianness, and can be read only by kernels with PAGE_CACHE_SIZE
+same endianness, and can be read only by kernels with PAGE_SIZE
 == 4096.  At least the latter of these is a bug, but it hasn't been
 decided what the best fix is.  For the moment if you have larger pages
 you can just change the #define in mkcramfs.c, so long as you don't
diff --git a/fs/cramfs/README b/fs/cramfs/README
index 445d1c2d7646..9d4e7ea311f4 100644
--- a/fs/cramfs/README
+++ b/fs/cramfs/README
@@ -86,26 +86,26 @@ Block Size
 
 (Block size in cramfs refers to the size of input data that is
 compressed at a time.  It's intended to be somewhere around
-PAGE_CACHE_SIZE for cramfs_readpage's convenience.)
+PAGE_SIZE for cramfs_readpage's convenience.)
 
 The superblock ought to indicate the block size that the fs was
 written for, since comments in <linux/pagemap.h> indicate that
-PAGE_CACHE_SIZE may grow in future (if I interpret the comment
+PAGE_SIZE may grow in future (if I interpret the comment
 correctly).
 
-Currently, mkcramfs #define's PAGE_CACHE_SIZE as 4096 and uses that
-for blksize, whereas Linux-2.3.39 uses its PAGE_CACHE_SIZE, which in
+Currently, mkcramfs #define's PAGE_SIZE as 4096 and uses that
+for blksize, whereas Linux-2.3.39 uses its PAGE_SIZE, which in
 turn is defined as PAGE_SIZE (which can be as large as 32KB on arm).
 This discrepancy is a bug, though it's not clear which should be
 changed.
 
-One option is to change mkcramfs to take its PAGE_CACHE_SIZE from
+One option is to change mkcramfs to take its PAGE_SIZE from
 <asm/page.h>.  Personally I don't like this option, but it does
 require the least amount of change: just change `#define
-PAGE_CACHE_SIZE (4096)' to `#include <asm/page.h>'.  The disadvantage
+PAGE_SIZE (4096)' to `#include <asm/page.h>'.  The disadvantage
 is that the generated cramfs cannot always be shared between different
 kernels, not even necessarily kernels of the same architecture if
-PAGE_CACHE_SIZE is subject to change between kernel versions
+PAGE_SIZE is subject to change between kernel versions
 (currently possible with arm and ia64).
 
 The remaining options try to make cramfs more sharable.
@@ -126,22 +126,22 @@ size.  The options are:
   1. Always 4096 bytes.
 
   2. Writer chooses blocksize; kernel adapts but rejects blocksize >
-     PAGE_CACHE_SIZE.
+     PAGE_SIZE.
 
   3. Writer chooses blocksize; kernel adapts even to blocksize >
-     PAGE_CACHE_SIZE.
+     PAGE_SIZE.
 
 It's easy enough to change the kernel to use a smaller value than
-PAGE_CACHE_SIZE: just make cramfs_readpage read multiple blocks.
+PAGE_SIZE: just make cramfs_readpage read multiple blocks.
 
-The cost of option 1 is that kernels with a larger PAGE_CACHE_SIZE
+The cost of option 1 is that kernels with a larger PAGE_SIZE
 value don't get as good compression as they can.
 
 The cost of option 2 relative to option 1 is that the code uses
 variables instead of #define'd constants.  The gain is that people
-with kernels having larger PAGE_CACHE_SIZE can make use of that if
+with kernels having larger PAGE_SIZE can make use of that if
 they don't mind their cramfs being inaccessible to kernels with
-smaller PAGE_CACHE_SIZE values.
+smaller PAGE_SIZE values.
 
 Option 3 is easy to implement if we don't mind being CPU-inefficient:
 e.g. get readpage to decompress to a buffer of size MAX_BLKSIZE (which
diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index b862bc219cd7..3a32ddf98095 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -137,7 +137,7 @@ static struct inode *get_cramfs_inode(struct super_block *sb,
  * page cache and dentry tree anyway..
  *
  * This also acts as a way to guarantee contiguous areas of up to
- * BLKS_PER_BUF*PAGE_CACHE_SIZE, so that the caller doesn't need to
+ * BLKS_PER_BUF*PAGE_SIZE, so that the caller doesn't need to
  * worry about end-of-buffer issues even when decompressing a full
  * page cache.
  */
@@ -152,7 +152,7 @@ static struct inode *get_cramfs_inode(struct super_block *sb,
  */
 #define BLKS_PER_BUF_SHIFT	(2)
 #define BLKS_PER_BUF		(1 << BLKS_PER_BUF_SHIFT)
-#define BUFFER_SIZE		(BLKS_PER_BUF*PAGE_CACHE_SIZE)
+#define BUFFER_SIZE		(BLKS_PER_BUF*PAGE_SIZE)
 
 static unsigned char read_buffers[READ_BUFFERS][BUFFER_SIZE];
 static unsigned buffer_blocknr[READ_BUFFERS];
@@ -173,8 +173,8 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 
 	if (!len)
 		return NULL;
-	blocknr = offset >> PAGE_CACHE_SHIFT;
-	offset &= PAGE_CACHE_SIZE - 1;
+	blocknr = offset >> PAGE_SHIFT;
+	offset &= PAGE_SIZE - 1;
 
 	/* Check if an existing buffer already has the data.. */
 	for (i = 0; i < READ_BUFFERS; i++) {
@@ -184,14 +184,14 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 			continue;
 		if (blocknr < buffer_blocknr[i])
 			continue;
-		blk_offset = (blocknr - buffer_blocknr[i]) << PAGE_CACHE_SHIFT;
+		blk_offset = (blocknr - buffer_blocknr[i]) << PAGE_SHIFT;
 		blk_offset += offset;
 		if (blk_offset + len > BUFFER_SIZE)
 			continue;
 		return read_buffers[i] + blk_offset;
 	}
 
-	devsize = mapping->host->i_size >> PAGE_CACHE_SHIFT;
+	devsize = mapping->host->i_size >> PAGE_SHIFT;
 
 	/* Ok, read in BLKS_PER_BUF pages completely first. */
 	for (i = 0; i < BLKS_PER_BUF; i++) {
@@ -213,7 +213,7 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 			wait_on_page_locked(page);
 			if (!PageUptodate(page)) {
 				/* asynchronous error */
-				page_cache_release(page);
+				put_page(page);
 				pages[i] = NULL;
 			}
 		}
@@ -229,12 +229,12 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 		struct page *page = pages[i];
 
 		if (page) {
-			memcpy(data, kmap(page), PAGE_CACHE_SIZE);
+			memcpy(data, kmap(page), PAGE_SIZE);
 			kunmap(page);
-			page_cache_release(page);
+			put_page(page);
 		} else
-			memset(data, 0, PAGE_CACHE_SIZE);
-		data += PAGE_CACHE_SIZE;
+			memset(data, 0, PAGE_SIZE);
+		data += PAGE_SIZE;
 	}
 	return read_buffers[buffer] + offset;
 }
@@ -353,7 +353,7 @@ static int cramfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	u64 id = huge_encode_dev(sb->s_bdev->bd_dev);
 
 	buf->f_type = CRAMFS_MAGIC;
-	buf->f_bsize = PAGE_CACHE_SIZE;
+	buf->f_bsize = PAGE_SIZE;
 	buf->f_blocks = CRAMFS_SB(sb)->blocks;
 	buf->f_bfree = 0;
 	buf->f_bavail = 0;
@@ -496,7 +496,7 @@ static int cramfs_readpage(struct file *file, struct page *page)
 	int bytes_filled;
 	void *pgdata;
 
-	maxblock = (inode->i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	maxblock = (inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	bytes_filled = 0;
 	pgdata = kmap(page);
 
@@ -516,14 +516,14 @@ static int cramfs_readpage(struct file *file, struct page *page)
 
 		if (compr_len == 0)
 			; /* hole */
-		else if (unlikely(compr_len > (PAGE_CACHE_SIZE << 1))) {
+		else if (unlikely(compr_len > (PAGE_SIZE << 1))) {
 			pr_err("bad compressed blocksize %u\n",
 				compr_len);
 			goto err;
 		} else {
 			mutex_lock(&read_mutex);
 			bytes_filled = cramfs_uncompress_block(pgdata,
-				 PAGE_CACHE_SIZE,
+				 PAGE_SIZE,
 				 cramfs_read(sb, start_offset, compr_len),
 				 compr_len);
 			mutex_unlock(&read_mutex);
@@ -532,7 +532,7 @@ static int cramfs_readpage(struct file *file, struct page *page)
 		}
 	}
 
-	memset(pgdata + bytes_filled, 0, PAGE_CACHE_SIZE - bytes_filled);
+	memset(pgdata + bytes_filled, 0, PAGE_SIZE - bytes_filled);
 	flush_dcache_page(page);
 	kunmap(page);
 	SetPageUptodate(page);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
