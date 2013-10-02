Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 772A0900006
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:07 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so947600pbb.34
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:07 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 21/26] ib: Convert ipath_get_user_pages() to get_user_pages_unlocked()
Date: Wed,  2 Oct 2013 16:28:02 +0200
Message-Id: <1380724087-13927-22-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Mike Marciniszyn <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org

Convert ipath_get_user_pages() to use get_user_pages_unlocked(). This
shortens the section where we hold mmap_sem for writing and also removes
the knowledge about get_user_pages() locking from ipath driver. We also
fix a bug in testing pinned number of pages when changing the code.

CC: Mike Marciniszyn <infinipath@intel.com>
CC: Roland Dreier <roland@kernel.org>
CC: linux-rdma@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/infiniband/hw/ipath/ipath_user_pages.c | 62 +++++++++++---------------
 1 file changed, 27 insertions(+), 35 deletions(-)

diff --git a/drivers/infiniband/hw/ipath/ipath_user_pages.c b/drivers/infiniband/hw/ipath/ipath_user_pages.c
index dc66c4506916..a89af9654112 100644
--- a/drivers/infiniband/hw/ipath/ipath_user_pages.c
+++ b/drivers/infiniband/hw/ipath/ipath_user_pages.c
@@ -52,40 +52,58 @@ static void __ipath_release_user_pages(struct page **p, size_t num_pages,
 	}
 }
 
-/* call with current->mm->mmap_sem held */
-static int __ipath_get_user_pages(unsigned long start_page, size_t num_pages,
-				  struct page **p, struct vm_area_struct **vma)
+/**
+ * ipath_get_user_pages - lock user pages into memory
+ * @start_page: the start page
+ * @num_pages: the number of pages
+ * @p: the output page structures
+ *
+ * This function takes a given start page (page aligned user virtual
+ * address) and pins it and the following specified number of pages.  For
+ * now, num_pages is always 1, but that will probably change at some point
+ * (because caller is doing expected sends on a single virtually contiguous
+ * buffer, so we can do all pages at once).
+ */
+int ipath_get_user_pages(unsigned long start_page, size_t num_pages,
+			 struct page **p)
 {
 	unsigned long lock_limit;
 	size_t got;
 	int ret;
 
+	down_write(&current->mm->mmap_sem);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
-	if (num_pages > lock_limit) {
+	if (current->mm->pinned_vm + num_pages > lock_limit && 
+	    !capable(CAP_IPC_LOCK)) {
+		up_write(&current->mm->mmap_sem);
 		ret = -ENOMEM;
 		goto bail;
 	}
+	current->mm->pinned_vm += num_pages;
+	up_write(&current->mm->mmap_sem);
 
 	ipath_cdbg(VERBOSE, "pin %lx pages from vaddr %lx\n",
 		   (unsigned long) num_pages, start_page);
 
 	for (got = 0; got < num_pages; got += ret) {
-		ret = get_user_pages(current, current->mm,
-				     start_page + got * PAGE_SIZE,
-				     num_pages - got, 1, 1,
-				     p + got, vma);
+		ret = get_user_pages_unlocked(current, current->mm,
+					      start_page + got * PAGE_SIZE,
+					      num_pages - got, 1, 1,
+					      p + got);
 		if (ret < 0)
 			goto bail_release;
 	}
 
-	current->mm->pinned_vm += num_pages;
 
 	ret = 0;
 	goto bail;
 
 bail_release:
 	__ipath_release_user_pages(p, got, 0);
+	down_write(&current->mm->mmap_sem);
+	current->mm->pinned_vm -= num_pages;
+	up_write(&current->mm->mmap_sem);
 bail:
 	return ret;
 }
@@ -146,32 +164,6 @@ dma_addr_t ipath_map_single(struct pci_dev *hwdev, void *ptr, size_t size,
 	return phys;
 }
 
-/**
- * ipath_get_user_pages - lock user pages into memory
- * @start_page: the start page
- * @num_pages: the number of pages
- * @p: the output page structures
- *
- * This function takes a given start page (page aligned user virtual
- * address) and pins it and the following specified number of pages.  For
- * now, num_pages is always 1, but that will probably change at some point
- * (because caller is doing expected sends on a single virtually contiguous
- * buffer, so we can do all pages at once).
- */
-int ipath_get_user_pages(unsigned long start_page, size_t num_pages,
-			 struct page **p)
-{
-	int ret;
-
-	down_write(&current->mm->mmap_sem);
-
-	ret = __ipath_get_user_pages(start_page, num_pages, p, NULL);
-
-	up_write(&current->mm->mmap_sem);
-
-	return ret;
-}
-
 void ipath_release_user_pages(struct page **p, size_t num_pages)
 {
 	down_write(&current->mm->mmap_sem);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
