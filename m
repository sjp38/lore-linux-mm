Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B24F982F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:35 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id n5so237541578pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:35 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id n76si6361693pfa.84.2016.03.20.11.41.49
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 42/71] isofs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:49 +0300
Message-Id: <1458499278-1516-43-git-send-email-kirill.shutemov@linux.intel.com>
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
 fs/isofs/compress.c | 36 ++++++++++++++++++------------------
 fs/isofs/inode.c    |  2 +-
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/fs/isofs/compress.c b/fs/isofs/compress.c
index f311bf084015..2e4e834d1a98 100644
--- a/fs/isofs/compress.c
+++ b/fs/isofs/compress.c
@@ -26,7 +26,7 @@
 #include "zisofs.h"
 
 /* This should probably be global. */
-static char zisofs_sink_page[PAGE_CACHE_SIZE];
+static char zisofs_sink_page[PAGE_SIZE];
 
 /*
  * This contains the zlib memory allocation and the mutex for the
@@ -70,11 +70,11 @@ static loff_t zisofs_uncompress_block(struct inode *inode, loff_t block_start,
 		for ( i = 0 ; i < pcount ; i++ ) {
 			if (!pages[i])
 				continue;
-			memset(page_address(pages[i]), 0, PAGE_CACHE_SIZE);
+			memset(page_address(pages[i]), 0, PAGE_SIZE);
 			flush_dcache_page(pages[i]);
 			SetPageUptodate(pages[i]);
 		}
-		return ((loff_t)pcount) << PAGE_CACHE_SHIFT;
+		return ((loff_t)pcount) << PAGE_SHIFT;
 	}
 
 	/* Because zlib is not thread-safe, do all the I/O at the top. */
@@ -121,11 +121,11 @@ static loff_t zisofs_uncompress_block(struct inode *inode, loff_t block_start,
 			if (pages[curpage]) {
 				stream.next_out = page_address(pages[curpage])
 						+ poffset;
-				stream.avail_out = PAGE_CACHE_SIZE - poffset;
+				stream.avail_out = PAGE_SIZE - poffset;
 				poffset = 0;
 			} else {
 				stream.next_out = (void *)&zisofs_sink_page;
-				stream.avail_out = PAGE_CACHE_SIZE;
+				stream.avail_out = PAGE_SIZE;
 			}
 		}
 		if (!stream.avail_in) {
@@ -220,14 +220,14 @@ static int zisofs_fill_pages(struct inode *inode, int full_page, int pcount,
 	 * pages with the data we have anyway...
 	 */
 	start_off = page_offset(pages[full_page]);
-	end_off = min_t(loff_t, start_off + PAGE_CACHE_SIZE, inode->i_size);
+	end_off = min_t(loff_t, start_off + PAGE_SIZE, inode->i_size);
 
 	cstart_block = start_off >> zisofs_block_shift;
 	cend_block = (end_off + (1 << zisofs_block_shift) - 1)
 			>> zisofs_block_shift;
 
-	WARN_ON(start_off - (full_page << PAGE_CACHE_SHIFT) !=
-		((cstart_block << zisofs_block_shift) & PAGE_CACHE_MASK));
+	WARN_ON(start_off - (full_page << PAGE_SHIFT) !=
+		((cstart_block << zisofs_block_shift) & PAGE_MASK));
 
 	/* Find the pointer to this specific chunk */
 	/* Note: we're not using isonum_731() here because the data is known aligned */
@@ -260,10 +260,10 @@ static int zisofs_fill_pages(struct inode *inode, int full_page, int pcount,
 		ret = zisofs_uncompress_block(inode, block_start, block_end,
 					      pcount, pages, poffset, &err);
 		poffset += ret;
-		pages += poffset >> PAGE_CACHE_SHIFT;
-		pcount -= poffset >> PAGE_CACHE_SHIFT;
-		full_page -= poffset >> PAGE_CACHE_SHIFT;
-		poffset &= ~PAGE_CACHE_MASK;
+		pages += poffset >> PAGE_SHIFT;
+		pcount -= poffset >> PAGE_SHIFT;
+		full_page -= poffset >> PAGE_SHIFT;
+		poffset &= ~PAGE_MASK;
 
 		if (err) {
 			brelse(bh);
@@ -282,7 +282,7 @@ static int zisofs_fill_pages(struct inode *inode, int full_page, int pcount,
 
 	if (poffset && *pages) {
 		memset(page_address(*pages) + poffset, 0,
-		       PAGE_CACHE_SIZE - poffset);
+		       PAGE_SIZE - poffset);
 		flush_dcache_page(*pages);
 		SetPageUptodate(*pages);
 	}
@@ -302,12 +302,12 @@ static int zisofs_readpage(struct file *file, struct page *page)
 	int i, pcount, full_page;
 	unsigned int zisofs_block_shift = ISOFS_I(inode)->i_format_parm[1];
 	unsigned int zisofs_pages_per_cblock =
-		PAGE_CACHE_SHIFT <= zisofs_block_shift ?
-		(1 << (zisofs_block_shift - PAGE_CACHE_SHIFT)) : 0;
+		PAGE_SHIFT <= zisofs_block_shift ?
+		(1 << (zisofs_block_shift - PAGE_SHIFT)) : 0;
 	struct page *pages[max_t(unsigned, zisofs_pages_per_cblock, 1)];
 	pgoff_t index = page->index, end_index;
 
-	end_index = (inode->i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	end_index = (inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	/*
 	 * If this page is wholly outside i_size we just return zero;
 	 * do_generic_file_read() will handle this for us
@@ -318,7 +318,7 @@ static int zisofs_readpage(struct file *file, struct page *page)
 		return 0;
 	}
 
-	if (PAGE_CACHE_SHIFT <= zisofs_block_shift) {
+	if (PAGE_SHIFT <= zisofs_block_shift) {
 		/* We have already been given one page, this is the one
 		   we must do. */
 		full_page = index & (zisofs_pages_per_cblock - 1);
@@ -351,7 +351,7 @@ static int zisofs_readpage(struct file *file, struct page *page)
 			kunmap(pages[i]);
 			unlock_page(pages[i]);
 			if (i != full_page)
-				page_cache_release(pages[i]);
+				put_page(pages[i]);
 		}
 	}			
 
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index bcd2d41b318a..131dedc920d8 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -1021,7 +1021,7 @@ int isofs_get_blocks(struct inode *inode, sector_t iblock,
 		 * the page with useless information without generating any
 		 * I/O errors.
 		 */
-		if (b_off > ((inode->i_size + PAGE_CACHE_SIZE - 1) >> ISOFS_BUFFER_BITS(inode))) {
+		if (b_off > ((inode->i_size + PAGE_SIZE - 1) >> ISOFS_BUFFER_BITS(inode))) {
 			printk(KERN_DEBUG "%s: block >= EOF (%lu, %llu)\n",
 				__func__, b_off,
 				(unsigned long long)inode->i_size);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
