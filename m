Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4837A28025D
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:56:18 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id mi5so83911456pab.2
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:56:18 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id tf1si3953483pab.230.2016.09.15.04.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 04:56:17 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 31/41] ext4: handle huge pages in ext4_page_mkwrite()
Date: Thu, 15 Sep 2016 14:55:13 +0300
Message-Id: <20160915115523.29737-32-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
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
index c9c05840f6cc..9ed715ed00e7 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5644,7 +5644,7 @@ static int ext4_bh_unmapped(handle_t *handle, struct buffer_head *bh)
 
 int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct page *page = vmf->page;
+	struct page *page = compound_head(vmf->page);
 	loff_t size;
 	unsigned long len;
 	int ret;
@@ -5680,10 +5680,10 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
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
@@ -5714,7 +5714,8 @@ retry_alloc:
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
