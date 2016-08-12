Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 690BE828FF
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:39:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so5464980pac.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:39:09 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id d2si10065893pfj.266.2016.08.12.11.38.48
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 25/41] fs: make block_page_mkwrite() aware about huge pages
Date: Fri, 12 Aug 2016 21:38:08 +0300
Message-Id: <1471027104-115213-26-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index 7f50e5a63670..e53808e790e2 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2502,7 +2502,7 @@ EXPORT_SYMBOL(block_commit_write);
 int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 			 get_block_t get_block)
 {
-	struct page *page = vmf->page;
+	struct page *page = compound_head(vmf->page);
 	struct inode *inode = file_inode(vma->vm_file);
 	unsigned long end;
 	loff_t size;
@@ -2510,7 +2510,7 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	lock_page(page);
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
+	if ((page_mapping(page) != inode->i_mapping) ||
 	    (page_offset(page) > size)) {
 		/* We overload EFAULT to mean page got truncated */
 		ret = -EFAULT;
@@ -2518,10 +2518,10 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
