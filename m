Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48D406B59F2
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 14:58:22 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id t17so4380254ywc.23
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 11:58:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u186-v6sor2671556ybf.135.2018.11.30.11.58.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 11:58:21 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 4/4] mm: use the cached page for filemap_fault
Date: Fri, 30 Nov 2018 14:58:12 -0500
Message-Id: <20181130195812.19536-5-josef@toxicpanda.com>
In-Reply-To: <20181130195812.19536-1-josef@toxicpanda.com>
References: <20181130195812.19536-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

If we drop the mmap_sem we have to redo the vma lookup which requires
redoing the fault handler.  Chances are we will just come back to the
same page, so save this page in our vmf->cached_page and reuse it in the
next loop through the fault handler.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/filemap.c | 45 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 43 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 5e76b24b2a0f..d4385b704e04 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2392,6 +2392,35 @@ static struct file *do_async_mmap_readahead(struct vm_area_struct *vma,
 	return fpin;
 }
 
+static int vmf_has_cached_page(struct vm_fault *vmf, struct page **page)
+{
+	struct page *cached_page = vmf->cached_page;
+	struct mm_struct *mm = vmf->vma->vm_mm;
+	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
+	pgoff_t offset = vmf->pgoff;
+
+	if (!cached_page)
+		return 0;
+
+	if (vmf->flags & FAULT_FLAG_KILLABLE) {
+		int ret = lock_page_killable(cached_page);
+		if (ret) {
+			up_read(&mm->mmap_sem);
+			return ret;
+		}
+	} else
+		lock_page(cached_page);
+	vmf->cached_page = NULL;
+	if (cached_page->mapping == mapping &&
+	    cached_page->index == offset) {
+		*page = cached_page;
+	} else {
+		unlock_page(cached_page);
+		put_page(cached_page);
+	}
+	return 0;
+}
+
 /**
  * filemap_fault - read in file data for page fault handling
  * @vmf:	struct vm_fault containing details of the fault
@@ -2425,13 +2454,24 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	struct inode *inode = mapping->host;
 	pgoff_t offset = vmf->pgoff;
 	pgoff_t max_off;
-	struct page *page;
+	struct page *page = NULL;
 	vm_fault_t ret = 0;
 
 	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 	if (unlikely(offset >= max_off))
 		return VM_FAULT_SIGBUS;
 
+	/*
+	 * We may have read in the page already and have a page from an earlier
+	 * loop.  If so we need to see if this page is still valid, and if not
+	 * do the whole dance over again.
+	 */
+	error = vmf_has_cached_page(vmf, &page);
+	if (error)
+		goto out_retry;
+	if (page)
+		goto have_cached_page;
+
 	/*
 	 * Do we have something in the page cache already?
 	 */
@@ -2492,6 +2532,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		put_page(page);
 		goto retry_find;
 	}
+have_cached_page:
 	VM_BUG_ON_PAGE(page->index != offset, page);
 
 	/*
@@ -2558,7 +2599,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	 * page.
 	 */
 	if (page)
-		put_page(page);
+		vmf->cached_page = page;
 	if (fpin)
 		fput(fpin);
 	return ret | VM_FAULT_RETRY;
-- 
2.14.3
