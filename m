Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 235D28E0008
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 17:09:11 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d12-v6so358901qtk.13
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 14:09:11 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z47-v6sor64108qtg.10.2018.09.26.14.09.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 14:09:10 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 6/9] mm: use the cached page for filemap_fault
Date: Wed, 26 Sep 2018 17:08:53 -0400
Message-Id: <20180926210856.7895-7-josef@toxicpanda.com>
In-Reply-To: <20180926210856.7895-1-josef@toxicpanda.com>
References: <20180926210856.7895-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, tj@kernel.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, riel@redhat.com, linux-mm@kvack.org, linux-btrfs@vger.kernel.org

If we drop the mmap_sem we have to redo the vma lookup which requires
redoing the fault handler.  Chances are we will just come back to the
same page, so save this page in our vmf->cached_page and reuse it in the
next loop through the fault handler.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/filemap.c | 30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 65395ee132a0..5212ab637832 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2530,13 +2530,38 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	pgoff_t offset = vmf->pgoff;
 	int flags = vmf->flags;
 	pgoff_t max_off;
-	struct page *page;
+	struct page *page = NULL;
+	struct page *cached_page = vmf->cached_page;
 	vm_fault_t ret = 0;
 
 	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 	if (unlikely(offset >= max_off))
 		return VM_FAULT_SIGBUS;
 
+	/*
+	 * We may have read in the page already and have a page from an earlier
+	 * loop.  If so we need to see if this page is still valid, and if not
+	 * do the whole dance over again.
+	 */
+	if (cached_page) {
+		if (flags & FAULT_FLAG_KILLABLE) {
+			error = lock_page_killable(cached_page);
+			if (error) {
+				up_read(&mm->mmap_sem);
+				goto out_retry;
+			}
+		} else
+			lock_page(cached_page);
+		vmf->cached_page = NULL;
+		if (cached_page->mapping == mapping &&
+		    cached_page->index == offset) {
+			page = cached_page;
+			goto have_cached_page;
+		}
+		unlock_page(cached_page);
+		put_page(cached_page);
+	}
+
 	/*
 	 * Do we have something in the page cache already?
 	 */
@@ -2587,6 +2612,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		put_page(page);
 		goto retry_find;
 	}
+have_cached_page:
 	VM_BUG_ON_PAGE(page->index != offset, page);
 
 	/*
@@ -2677,7 +2703,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	if (fpin)
 		fput(fpin);
 	if (page)
-		put_page(page);
+		vmf->cached_page = page;
 	return ret | VM_FAULT_RETRY;
 }
 EXPORT_SYMBOL(filemap_fault);
-- 
2.14.3
