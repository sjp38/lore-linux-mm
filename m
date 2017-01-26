Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE486B0284
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so308389721pgd.7
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:55 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j9si1196448pfc.290.2017.01.26.03.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:54 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 33/37] ext4: fix SEEK_DATA/SEEK_HOLE for huge pages
Date: Thu, 26 Jan 2017 14:58:15 +0300
Message-Id: <20170126115819.58875-34-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
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
index d663d3d7c81c..0b11aadfb75f 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -519,7 +519,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 			 * range, it will be a hole.
 			 */
 			if (lastoff < endoff && whence == SEEK_HOLE &&
-			    page->index > end) {
+			    page_to_pgoff(page) > end) {
 				found = 1;
 				*offset = lastoff;
 				goto out;
@@ -527,7 +527,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 
 			lock_page(page);
 
-			if (unlikely(page->mapping != inode->i_mapping)) {
+			if (unlikely(page_mapping(page) != inode->i_mapping)) {
 				unlock_page(page);
 				continue;
 			}
@@ -538,8 +538,12 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
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
@@ -560,8 +564,12 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
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
@@ -574,7 +582,9 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 			break;
 		}
 
-		index = pvec.pages[i - 1]->index + 1;
+		index = page_to_pgoff(pvec.pages[i - 1]) + 1;
+		if (PageTransCompound(pvec.pages[i - 1]))
+			index = round_up(index, HPAGE_PMD_NR);
 		pagevec_release(&pvec);
 	} while (index <= end);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
