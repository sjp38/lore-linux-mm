Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF8B828F3
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:46:49 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so5777643pad.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:46:49 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id t78si10108463pfi.19.2016.08.12.11.39.02
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:39:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 31/41] ext4: handle huge pages in ext4_page_mkwrite()
Date: Fri, 12 Aug 2016 21:38:14 +0300
Message-Id: <1471027104-115213-32-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Trivial: remove assumption on page size.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index f585f9160a96..cd435d4a10f0 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5646,7 +5646,7 @@ static int ext4_bh_unmapped(handle_t *handle, struct buffer_head *bh)
 
 int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct page *page = vmf->page;
+	struct page *page = compound_head(vmf->page);
 	loff_t size;
 	unsigned long len;
 	int ret;
@@ -5682,10 +5682,10 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 		goto out;
 	}
 
-	if (page->index == size >> PAGE_SHIFT)
-		len = size & ~PAGE_MASK;
-	else
-		len = PAGE_SIZE;
+	len = hpage_size(page);
+	if (page->index + hpage_nr_pages(page) - 1 == size >> PAGE_SHIFT)
+		len = size & ~hpage_mask(page);
+
 	/*
 	 * Return if we have all the buffers mapped. This avoids the need to do
 	 * journal_start/journal_stop which can block and take a long time
@@ -5716,7 +5716,8 @@ retry_alloc:
 	ret = block_page_mkwrite(vma, vmf, get_block);
 	if (!ret && ext4_should_journal_data(inode)) {
 		if (ext4_walk_page_buffers(handle, page_buffers(page), 0,
-			  PAGE_SIZE, NULL, do_journal_get_write_access)) {
+			  hpage_size(page), NULL,
+			  do_journal_get_write_access)) {
 			unlock_page(page);
 			ret = VM_FAULT_SIGBUS;
 			ext4_journal_stop(handle);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
