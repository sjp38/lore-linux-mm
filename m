Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFDE6B0287
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:54 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id tz10so20150380pab.3
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:54 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w5si17884711pfj.223.2016.10.24.17.14.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 40/43] ext4: fix SEEK_DATA/SEEK_HOLE for huge pages
Date: Tue, 25 Oct 2016 03:13:39 +0300
Message-Id: <20161025001342.76126-41-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
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
index 2a822d30e73f..8b70c1660342 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -467,7 +467,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 			 * range, it will be a hole.
 			 */
 			if (lastoff < endoff && whence == SEEK_HOLE &&
-			    page->index > end) {
+			    page_to_pgoff(page) > end) {
 				found = 1;
 				*offset = lastoff;
 				goto out;
@@ -475,7 +475,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 
 			lock_page(page);
 
-			if (unlikely(page->mapping != inode->i_mapping)) {
+			if (unlikely(page_mapping(page) != inode->i_mapping)) {
 				unlock_page(page);
 				continue;
 			}
@@ -486,8 +486,12 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
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
@@ -508,8 +512,12 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
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
@@ -522,7 +530,9 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
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
