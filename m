Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A97376B0003
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 16:57:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i137so6934400pfe.0
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 13:57:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o33-v6sor3697812plb.122.2018.04.14.13.56.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Apr 2018 13:56:59 -0700 (PDT)
Date: Sun, 15 Apr 2018 02:28:50 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm: Adding new return type vm_fault_t
Message-ID: <20180414205850.GA20500@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: willy@infradead.org

Use new return type vm_fault_t for filemap_fault() and
filemap_page_mkwrite().

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm.h | 4 ++--
 mm/filemap.c       | 8 ++++----
 mm/nommu.c         | 2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42..7fc4baf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2281,10 +2281,10 @@ extern void truncate_inode_pages_range(struct address_space *,
 extern void truncate_inode_pages_final(struct address_space *);

 /* generic vm_area_ops exported for stackable file systems */
-extern int filemap_fault(struct vm_fault *vmf);
+extern vm_fault_t filemap_fault(struct vm_fault *vmf);
 extern void filemap_map_pages(struct vm_fault *vmf,
 		pgoff_t start_pgoff, pgoff_t end_pgoff);
-extern int filemap_page_mkwrite(struct vm_fault *vmf);
+extern vm_fault_t filemap_page_mkwrite(struct vm_fault *vmf);

 /* mm/page-writeback.c */
 int __must_check write_one_page(struct page *page);
diff --git a/mm/filemap.c b/mm/filemap.c
index 693f622..cae7e4f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2491,7 +2491,7 @@ static void do_async_mmap_readahead(struct vm_area_struct *vma,
  *
  * We never return with VM_FAULT_RETRY and a bit from VM_FAULT_ERROR set.
  */
-int filemap_fault(struct vm_fault *vmf)
+vm_fault_t filemap_fault(struct vm_fault *vmf)
 {
 	int error;
 	struct file *file = vmf->vma->vm_file;
@@ -2501,7 +2501,7 @@ int filemap_fault(struct vm_fault *vmf)
 	pgoff_t offset = vmf->pgoff;
 	pgoff_t max_off;
 	struct page *page;
-	int ret = 0;
+	vm_fault_t ret = 0;

 	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 	if (unlikely(offset >= max_off))
@@ -2696,11 +2696,11 @@ void filemap_map_pages(struct vm_fault *vmf,
 }
 EXPORT_SYMBOL(filemap_map_pages);

-int filemap_page_mkwrite(struct vm_fault *vmf)
+vm_fault_t filemap_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
-	int ret = VM_FAULT_LOCKED;
+	vm_fault_t ret = VM_FAULT_LOCKED;

 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vmf->vma->vm_file);
diff --git a/mm/nommu.c b/mm/nommu.c
index ebb6e61..90456a6 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1788,7 +1788,7 @@ unsigned long arch_get_unmapped_area(struct file *file, unsigned long addr,
 	return -ENOMEM;
 }

-int filemap_fault(struct vm_fault *vmf)
+vm_fault_t filemap_fault(struct vm_fault *vmf)
 {
 	BUG();
 	return 0;
--
1.9.1
