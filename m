Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 681EA6B026C
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:37 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so249372048pfk.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b192si56373317pga.202.2016.11.29.03.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 19/36] fs: make block_page_mkwrite() aware about huge pages
Date: Tue, 29 Nov 2016 14:22:47 +0300
Message-Id: <20161129112304.90056-20-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Adjust check on whether part of the page beyond file size and apply
compound_head() and page_mapping() where appropriate.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/buffer.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 7d333621ccfb..8e000021513c 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2544,7 +2544,7 @@ EXPORT_SYMBOL(block_commit_write);
 int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 			 get_block_t get_block)
 {
-	struct page *page = vmf->page;
+	struct page *page = compound_head(vmf->page);
 	struct inode *inode = file_inode(vma->vm_file);
 	unsigned long end;
 	loff_t size;
@@ -2552,7 +2552,7 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	lock_page(page);
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
+	if ((page_mapping(page) != inode->i_mapping) ||
 	    (page_offset(page) > size)) {
 		/* We overload EFAULT to mean page got truncated */
 		ret = -EFAULT;
@@ -2560,10 +2560,10 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	}
 
 	/* page is wholly or partially inside EOF */
-	if (((page->index + 1) << PAGE_SHIFT) > size)
-		end = size & ~PAGE_MASK;
+	if (((page->index + hpage_nr_pages(page)) << PAGE_SHIFT) > size)
+		end = size & ~hpage_mask(page);
 	else
-		end = PAGE_SIZE;
+		end = hpage_size(page);
 
 	ret = __block_write_begin(page, 0, end, get_block);
 	if (!ret)
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
