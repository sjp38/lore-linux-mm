Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44E8428025D
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:58 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so83645617pab.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:58 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a68si39039746pfb.39.2016.09.15.04.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:51 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 38/41] ext4: fix SEEK_DATA/SEEK_HOLE for huge pages
Date: Thu, 15 Sep 2016 14:55:20 +0300
Message-Id: <20160915115523.29737-39-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

ext4_find_unwritten_pgoff() needs few tweaks to work with huge pages.
Mostly trivial page_mapping()/page_to_pgoff() and adjustment to how we
find relevant block.

Signe-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/file.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 261ac3734c58..2c3d6bb0edfe 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -473,7 +473,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 			 * range, it will be a hole.
 			 */
 			if (lastoff < endoff && whence == SEEK_HOLE &&
-			    page->index > end) {
+			    page_to_pgoff(page) > end) {
 				found = 1;
 				*offset = lastoff;
 				goto out;
@@ -481,7 +481,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 
 			lock_page(page);
 
-			if (unlikely(page->mapping != inode->i_mapping)) {
+			if (unlikely(page_mapping(page) != inode->i_mapping)) {
 				unlock_page(page);
 				continue;
 			}
@@ -492,8 +492,12 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 			}
 
 			if (page_has_buffers(page)) {
+				int diff;
 				lastoff = page_offset(page);
 				bh = head = page_buffers(page);
+				diff = (page - compound_head(page)) << inode->i_blkbits;
+				while (diff--)
+					bh = bh->b_this_page;
 				do {
 					if (buffer_uptodate(bh) ||
 					    buffer_unwritten(bh)) {
@@ -514,8 +518,12 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 				} while (bh != head);
 			}
 
-			lastoff = page_offset(page) + PAGE_SIZE;
+			lastoff = page_offset(page) + hpage_size(page);
 			unlock_page(page);
+			if (PageTransCompound(page)) {
+				i++;
+				break;
+			}
 		}
 
 		/*
@@ -528,7 +536,9 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 			break;
 		}
 
-		index = pvec.pages[i - 1]->index + 1;
+		index = page_to_pgoff(pvec.pages[i - 1]) + 1;
+		if (PageTransCompound(pvec.pages[i - 1]))
+			index = round_up(index, HPAGE_PMD_NR);
 		pagevec_release(&pvec);
 	} while (index <= end);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
