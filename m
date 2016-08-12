Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7C3828F3
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:46:20 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so5876775pab.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:46:20 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id b7si10047740pas.289.2016.08.12.11.38.49
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 29/41] ext4: make ext4_mpage_readpages() hugepage-aware
Date: Fri, 12 Aug 2016 21:38:12 +0300
Message-Id: <1471027104-115213-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch modifies ext4_mpage_readpages() to deal with huge pages.

We read out 2M at once, so we have to alloc (HPAGE_PMD_NR *
blocks_per_page) sector_t for that. I'm not entirely happy with kmalloc
in this codepath, but don't see any other option.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/readpage.c | 38 ++++++++++++++++++++++++++++++++------
 1 file changed, 32 insertions(+), 6 deletions(-)

diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index a81b829d56de..6d7cbddceeb2 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -104,12 +104,12 @@ int ext4_mpage_readpages(struct address_space *mapping,
 
 	struct inode *inode = mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
-	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	sector_t block_in_file;
 	sector_t last_block;
 	sector_t last_block_in_file;
-	sector_t blocks[MAX_BUF_PER_PAGE];
+	sector_t blocks_on_stack[MAX_BUF_PER_PAGE];
+	sector_t *blocks = blocks_on_stack;
 	unsigned page_block;
 	struct block_device *bdev = inode->i_sb->s_bdev;
 	int length;
@@ -122,8 +122,9 @@ int ext4_mpage_readpages(struct address_space *mapping,
 	map.m_flags = 0;
 
 	for (; nr_pages; nr_pages--) {
-		int fully_mapped = 1;
-		unsigned first_hole = blocks_per_page;
+		int fully_mapped = 1, nr = nr_pages;
+		unsigned blocks_per_page = PAGE_SIZE >> blkbits;
+		unsigned first_hole;
 
 		prefetchw(&page->flags);
 		if (pages) {
@@ -138,10 +139,31 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			goto confused;
 
 		block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
-		last_block = block_in_file + nr_pages * blocks_per_page;
+
+		if (PageTransHuge(page)) {
+			BUILD_BUG_ON(BIO_MAX_PAGES < HPAGE_PMD_NR);
+			nr = HPAGE_PMD_NR * blocks_per_page;
+			/* XXX: need a better solution ? */
+			blocks = kmalloc(sizeof(sector_t) * nr, GFP_NOFS);
+			if (!blocks) {
+				if (pages) {
+					delete_from_page_cache(page);
+					goto next_page;
+				}
+				return -ENOMEM;
+			}
+
+			blocks_per_page *= HPAGE_PMD_NR;
+			last_block = block_in_file + blocks_per_page;
+		} else {
+			blocks = blocks_on_stack;
+			last_block = block_in_file + nr * blocks_per_page;
+		}
+
 		last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
 		if (last_block > last_block_in_file)
 			last_block = last_block_in_file;
+		first_hole = blocks_per_page;
 		page_block = 0;
 
 		/*
@@ -213,6 +235,8 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			}
 		}
 		if (first_hole != blocks_per_page) {
+			if (PageTransHuge(page))
+				goto confused;
 			zero_user_segment(page, first_hole << blkbits,
 					  PAGE_SIZE);
 			if (first_hole == 0) {
@@ -248,7 +272,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 					goto set_error_page;
 			}
 			bio = bio_alloc(GFP_KERNEL,
-				min_t(int, nr_pages, BIO_MAX_PAGES));
+				min_t(int, nr, BIO_MAX_PAGES));
 			if (!bio) {
 				if (ctx)
 					fscrypt_release_ctx(ctx);
@@ -289,5 +313,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 	BUG_ON(pages && !list_empty(pages));
 	if (bio)
 		submit_bio(bio);
+	if (blocks != blocks_on_stack)
+		kfree(blocks);
 	return 0;
 }
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
