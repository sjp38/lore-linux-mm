Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87F826B0010
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:06 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m3so18620881pgd.20
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w23-v6si6078230plk.537.2018.02.04.17.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 26/64] fs: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:16 +0100
Message-Id: <20180205012754.23615-27-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

Also fixup some previous userfaultfd changes.
No change in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 fs/aio.c                      |  4 ++--
 fs/userfaultfd.c              | 26 ++++++++++++++------------
 include/linux/userfaultfd_k.h |  5 +++--
 mm/madvise.c                  |  4 ++--
 4 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 31774b75c372..98affcf36b97 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -512,7 +512,7 @@ static int aio_setup_ring(struct kioctx *ctx, unsigned int nr_events)
 	ctx->mmap_size = nr_pages * PAGE_SIZE;
 	pr_debug("attempting mmap of %lu bytes\n", ctx->mmap_size);
 
-	if (down_write_killable(&mm->mmap_sem)) {
+	if (mm_write_lock_killable(mm, &mmrange)) {
 		ctx->mmap_size = 0;
 		aio_free_ring(ctx);
 		return -EINTR;
@@ -521,7 +521,7 @@ static int aio_setup_ring(struct kioctx *ctx, unsigned int nr_events)
 	ctx->mmap_base = do_mmap_pgoff(ctx->aio_ring_file, 0, ctx->mmap_size,
 				       PROT_READ | PROT_WRITE,
 				       MAP_SHARED, 0, &unused, NULL, &mmrange);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	if (IS_ERR((void *)ctx->mmap_base)) {
 		ctx->mmap_size = 0;
 		aio_free_ring(ctx);
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 883fbffb284e..805bdc7ecf2d 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -482,7 +482,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 						       vmf->address,
 						       vmf->flags, reason,
 						       vmf->lockrange);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, vmf->lockrange);
 
 	if (likely(must_wait && !READ_ONCE(ctx->released) &&
 		   (return_to_userland ? !signal_pending(current) :
@@ -536,7 +536,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 			 * and there's no need to retake the mmap_sem
 			 * in such case.
 			 */
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, vmf->lockrange);
 			ret = VM_FAULT_NOPAGE;
 		}
 	}
@@ -629,13 +629,14 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 	if (release_new_ctx) {
 		struct vm_area_struct *vma;
 		struct mm_struct *mm = release_new_ctx->mm;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
 		/* the various vma->vm_userfaultfd_ctx still points to it */
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 		for (vma = mm->mmap; vma; vma = vma->vm_next)
 			if (vma->vm_userfaultfd_ctx.ctx == release_new_ctx)
 				vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 
 		userfaultfd_ctx_put(release_new_ctx);
 	}
@@ -765,7 +766,8 @@ void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *vm_ctx,
 }
 
 bool userfaultfd_remove(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			struct range_lock *mmrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
@@ -776,7 +778,7 @@ bool userfaultfd_remove(struct vm_area_struct *vma,
 		return true;
 
 	userfaultfd_ctx_get(ctx);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, mmrange);
 
 	msg_init(&ewq.msg);
 
@@ -870,7 +872,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * it's critical that released is set to true (above), before
 	 * taking the mmap_sem for writing.
 	 */
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	prev = NULL;
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		cond_resched();
@@ -893,7 +895,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 		vma->vm_flags = new_flags;
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 	}
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	mmput(mm);
 wakeup:
 	/*
@@ -1321,7 +1323,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	if (!mmget_not_zero(mm))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
@@ -1450,7 +1452,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		vma = vma->vm_next;
 	} while (vma && vma->vm_start < end);
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	mmput(mm);
 	if (!ret) {
 		/*
@@ -1496,7 +1498,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (!mmget_not_zero(mm))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
@@ -1609,7 +1611,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		vma = vma->vm_next;
 	} while (vma && vma->vm_start < end);
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	mmput(mm);
 out:
 	return ret;
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index f2f3b68ba910..35164358245f 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -64,7 +64,7 @@ extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *,
 
 extern bool userfaultfd_remove(struct vm_area_struct *vma,
 			       unsigned long start,
-			       unsigned long end);
+			       unsigned long end, struct range_lock *mmrange);
 
 extern int userfaultfd_unmap_prep(struct vm_area_struct *vma,
 				  unsigned long start, unsigned long end,
@@ -120,7 +120,8 @@ static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *ctx,
 
 static inline bool userfaultfd_remove(struct vm_area_struct *vma,
 				      unsigned long start,
-				      unsigned long end)
+				      unsigned long end,
+				      struct range_lock *mmrange)
 {
 	return true;
 }
diff --git a/mm/madvise.c b/mm/madvise.c
index de8fb035955c..9ba23187445b 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -529,7 +529,7 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
 	if (!can_madv_dontneed_vma(vma))
 		return -EINVAL;
 
-	if (!userfaultfd_remove(vma, start, end)) {
+	if (!userfaultfd_remove(vma, start, end, mmrange)) {
 		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
 
 		mm_read_lock(current->mm, mmrange);
@@ -613,7 +613,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 	 * mmap_sem.
 	 */
 	get_file(f);
-	if (userfaultfd_remove(vma, start, end)) {
+	if (userfaultfd_remove(vma, start, end, mmrange)) {
 		/* mmap_sem was not released by userfaultfd_remove() */
 		mm_read_unlock(current->mm, mmrange);
 	}
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
