Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D57356B0073
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 07:50:51 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id bj1so716825pad.31
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 04:50:51 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yf8si1929222pab.294.2014.02.28.04.50.50
        for <linux-mm@kvack.org>;
        Fri, 28 Feb 2014 04:50:50 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: cleanup size checks in filemap_fault() and filemap_map_pages()
Date: Fri, 28 Feb 2014 14:50:25 +0200
Message-Id: <1393591825-24894-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Minor cleanups:
 - 'size' variable is now in bytes, not pages;
 - use round_up(): it should be easier to read.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 1bc12a96060d..5f4fe7f0c258 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1615,11 +1615,11 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct inode *inode = mapping->host;
 	pgoff_t offset = vmf->pgoff;
 	struct page *page;
-	pgoff_t size;
+	loff_t size;
 	int ret = 0;
 
-	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (offset >= size)
+	size = round_up(i_size_read(inode), PAGE_CACHE_SIZE);
+	if (offset >= size >> PAGE_CACHE_SHIFT)
 		return VM_FAULT_SIGBUS;
 
 	/*
@@ -1668,8 +1668,8 @@ retry_find:
 	 * Found the page and have a reference on it.
 	 * We must recheck i_size under page lock.
 	 */
-	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (unlikely(offset >= size)) {
+	size = round_up(i_size_read(inode), PAGE_CACHE_SIZE);
+	if (unlikely(offset >= size >> PAGE_CACHE_SHIFT)) {
 		unlock_page(page);
 		page_cache_release(page);
 		return VM_FAULT_SIGBUS;
@@ -1771,8 +1771,8 @@ repeat:
 		if (page->mapping != mapping || !PageUptodate(page))
 			goto unlock;
 
-		size = i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1;
-		if (page->index >= size	>> PAGE_CACHE_SHIFT)
+		size = round_up(i_size_read(mapping->host), PAGE_CACHE_SIZE);
+		if (page->index >= size >> PAGE_CACHE_SHIFT)
 			goto unlock;
 
 		pte = vmf->pte + page->index - vmf->pgoff;
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
