Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0CAE9900002
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:04 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so940797pbc.39
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:04 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 20/26] ib: Convert ib_umem_get() to get_user_pages_unlocked()
Date: Wed,  2 Oct 2013 16:28:01 +0200
Message-Id: <1380724087-13927-21-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org

Convert ib_umem_get() to use get_user_pages_unlocked(). This
significantly shortens the section where mmap_sem is held (we only need
it for updating of mm->pinned_vm and inside get_user_pages()) and removes
the knowledge about locking of get_user_pages().

CC: Roland Dreier <roland@kernel.org>
CC: linux-rdma@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/infiniband/core/umem.c | 41 +++++++++++++++++------------------------
 1 file changed, 17 insertions(+), 24 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index a84112322071..0640a89021a9 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -80,7 +80,6 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 {
 	struct ib_umem *umem;
 	struct page **page_list;
-	struct vm_area_struct **vma_list;
 	struct ib_umem_chunk *chunk;
 	unsigned long locked;
 	unsigned long lock_limit;
@@ -125,34 +124,31 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	/*
-	 * if we can't alloc the vma_list, it's not so bad;
-	 * just assume the memory is not hugetlb memory
-	 */
-	vma_list = (struct vm_area_struct **) __get_free_page(GFP_KERNEL);
-	if (!vma_list)
-		umem->hugetlb = 0;
-
 	npages = PAGE_ALIGN(size + umem->offset) >> PAGE_SHIFT;
 
 	down_write(&current->mm->mmap_sem);
 
-	locked     = npages + current->mm->pinned_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-
-	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
-		ret = -ENOMEM;
-		goto out;
+	locked = npages;
+	if (npages + current->mm->pinned_vm > lock_limit &&
+	    !capable(CAP_IPC_LOCK)) {
+		up_write(&current->mm->mmap_sem);
+		kfree(umem);
+		free_page((unsigned long) page_list);
+		return ERR_PTR(-ENOMEM);
 	}
+	current->mm->pinned_vm += npages;
+
+	up_write(&current->mm->mmap_sem);
 
 	cur_base = addr & PAGE_MASK;
 
 	ret = 0;
 	while (npages) {
-		ret = get_user_pages(current, current->mm, cur_base,
+		ret = get_user_pages_unlocked(current, current->mm, cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
-				     1, !umem->writable, page_list, vma_list);
+				     1, !umem->writable, page_list);
 
 		if (ret < 0)
 			goto out;
@@ -174,8 +170,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 			chunk->nents = min_t(int, ret, IB_UMEM_MAX_PAGE_CHUNK);
 			sg_init_table(chunk->page_list, chunk->nents);
 			for (i = 0; i < chunk->nents; ++i) {
-				if (vma_list &&
-				    !is_vm_hugetlb_page(vma_list[i + off]))
+				if (!PageHuge(page_list[i + off]))
 					umem->hugetlb = 0;
 				sg_set_page(&chunk->page_list[i], page_list[i + off], PAGE_SIZE, 0);
 			}
@@ -206,12 +201,10 @@ out:
 	if (ret < 0) {
 		__ib_umem_release(context->device, umem, 0);
 		kfree(umem);
-	} else
-		current->mm->pinned_vm = locked;
-
-	up_write(&current->mm->mmap_sem);
-	if (vma_list)
-		free_page((unsigned long) vma_list);
+		down_write(&current->mm->mmap_sem);
+		current->mm->pinned_vm -= locked;
+		up_write(&current->mm->mmap_sem);
+	}
 	free_page((unsigned long) page_list);
 
 	return ret < 0 ? ERR_PTR(ret) : umem;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
