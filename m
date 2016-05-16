Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0E06B0253
	for <linux-mm@kvack.org>; Mon, 16 May 2016 11:25:50 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id e126so383788206vkb.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 08:25:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t12si17008307qke.163.2016.05.16.08.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 08:25:49 -0700 (PDT)
Date: Mon, 16 May 2016 17:25:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/1] userfaultfd: don't pin the user memory in
 userfaultfd_file_create()
Message-ID: <20160516152546.GA19129@redhat.com>
References: <20160516152522.GA19120@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516152522.GA19120@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

userfaultfd_file_create() increments mm->mm_users; this means that the memory
won't be unmapped/freed if mm owner exits/execs, and UFFDIO_COPY after that can
populate the orphaned mm more.

Change userfaultfd_file_create() and userfaultfd_ctx_put() to use mm->mm_count
to pin mm_struct. This means that atomic_inc_not_zero(mm->mm_users) is needed
when we are going to actually play with this memory. Except handle_userfault()
path doesn't need this, the caller must already have a reference.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 fs/userfaultfd.c | 55 ++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 42 insertions(+), 13 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 66cdb44..1a2f38a 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -70,6 +70,20 @@ struct userfaultfd_wake_range {
 	unsigned long len;
 };
 
+/*
+ * mm_struct can't go away, but we need to verify that this memory is still
+ * alive and avoid the race with exit_mmap().
+ */
+static inline bool userfaultfd_get_mm(struct userfaultfd_ctx *ctx)
+{
+	return atomic_inc_not_zero(&ctx->mm->mm_users);
+}
+
+static inline void userfaultfd_put_mm(struct userfaultfd_ctx *ctx)
+{
+	mmput(ctx->mm);
+}
+
 static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
 				     int wake_flags, void *key)
 {
@@ -137,7 +151,7 @@ static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 		VM_BUG_ON(waitqueue_active(&ctx->fault_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fd_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fd_wqh));
-		mmput(ctx->mm);
+		mmdrop(ctx->mm);
 		kmem_cache_free(userfaultfd_ctx_cachep, ctx);
 	}
 }
@@ -434,6 +448,9 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 
 	ACCESS_ONCE(ctx->released) = true;
 
+	if (!userfaultfd_get_mm(ctx))
+		goto wakeup;
+
 	/*
 	 * Flush page faults out of all CPUs. NOTE: all page faults
 	 * must be retried without returning VM_FAULT_SIGBUS if
@@ -466,7 +483,8 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 	}
 	up_write(&mm->mmap_sem);
-
+	userfaultfd_put_mm(ctx);
+wakeup:
 	/*
 	 * After no new page faults can wait on this fault_*wqh, flush
 	 * the last page faults that may have been already waiting on
@@ -760,10 +778,12 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	start = uffdio_register.range.start;
 	end = start + uffdio_register.range.len;
 
+	ret = -ENOMEM;
+	if (!userfaultfd_get_mm(ctx))
+		goto out;
+
 	down_write(&mm->mmap_sem);
 	vma = find_vma_prev(mm, start, &prev);
-
-	ret = -ENOMEM;
 	if (!vma)
 		goto out_unlock;
 
@@ -864,6 +884,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	} while (vma && vma->vm_start < end);
 out_unlock:
 	up_write(&mm->mmap_sem);
+	userfaultfd_put_mm(ctx);
 	if (!ret) {
 		/*
 		 * Now that we scanned all vmas we can already tell
@@ -902,10 +923,12 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	start = uffdio_unregister.start;
 	end = start + uffdio_unregister.len;
 
+	ret = -ENOMEM;
+	if (!userfaultfd_get_mm(ctx))
+		goto out;
+
 	down_write(&mm->mmap_sem);
 	vma = find_vma_prev(mm, start, &prev);
-
-	ret = -ENOMEM;
 	if (!vma)
 		goto out_unlock;
 
@@ -998,6 +1021,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	} while (vma && vma->vm_start < end);
 out_unlock:
 	up_write(&mm->mmap_sem);
+	userfaultfd_put_mm(ctx);
 out:
 	return ret;
 }
@@ -1067,9 +1091,11 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 		goto out;
 	if (uffdio_copy.mode & ~UFFDIO_COPY_MODE_DONTWAKE)
 		goto out;
-
-	ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
-			   uffdio_copy.len);
+	if (userfaultfd_get_mm(ctx)) {
+		ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
+				   uffdio_copy.len);
+		userfaultfd_put_mm(ctx);
+	}
 	if (unlikely(put_user(ret, &user_uffdio_copy->copy)))
 		return -EFAULT;
 	if (ret < 0)
@@ -1110,8 +1136,11 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 	if (uffdio_zeropage.mode & ~UFFDIO_ZEROPAGE_MODE_DONTWAKE)
 		goto out;
 
-	ret = mfill_zeropage(ctx->mm, uffdio_zeropage.range.start,
-			     uffdio_zeropage.range.len);
+	if (userfaultfd_get_mm(ctx)) {
+		ret = mfill_zeropage(ctx->mm, uffdio_zeropage.range.start,
+				     uffdio_zeropage.range.len);
+		userfaultfd_put_mm(ctx);
+	}
 	if (unlikely(put_user(ret, &user_uffdio_zeropage->zeropage)))
 		return -EFAULT;
 	if (ret < 0)
@@ -1289,12 +1318,12 @@ static struct file *userfaultfd_file_create(int flags)
 	ctx->released = false;
 	ctx->mm = current->mm;
 	/* prevent the mm struct to be freed */
-	atomic_inc(&ctx->mm->mm_users);
+	atomic_inc(&ctx->mm->mm_count);
 
 	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
 				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
 	if (IS_ERR(file)) {
-		mmput(ctx->mm);
+		mmdrop(ctx->mm);
 		kmem_cache_free(userfaultfd_ctx_cachep, ctx);
 	}
 out:
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
