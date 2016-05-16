Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f69.google.com (mail-qg0-f69.google.com [209.85.192.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE2E46B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 13:22:58 -0400 (EDT)
Received: by mail-qg0-f69.google.com with SMTP id f101so270576357qge.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 10:22:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v6si7468212qkg.210.2016.05.16.10.22.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 10:22:57 -0700 (PDT)
Date: Mon, 16 May 2016 19:22:54 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v2 1/1] userfaultfd: don't pin the user memory in
 userfaultfd_file_create()
Message-ID: <20160516172254.GA8595@redhat.com>
References: <20160516152522.GA19120@redhat.com>
 <20160516152546.GA19129@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516152546.GA19129@redhat.com>
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

The patch adds the new trivial helper, mmget_not_zero(), it can have more users.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 fs/userfaultfd.c      | 41 ++++++++++++++++++++++++++++-------------
 include/linux/sched.h |  7 ++++++-
 2 files changed, 34 insertions(+), 14 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 66cdb44..2d97952 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -137,7 +137,7 @@ static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 		VM_BUG_ON(waitqueue_active(&ctx->fault_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fd_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fd_wqh));
-		mmput(ctx->mm);
+		mmdrop(ctx->mm);
 		kmem_cache_free(userfaultfd_ctx_cachep, ctx);
 	}
 }
@@ -434,6 +434,9 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 
 	ACCESS_ONCE(ctx->released) = true;
 
+	if (!mmget_not_zero(mm))
+		goto wakeup;
+
 	/*
 	 * Flush page faults out of all CPUs. NOTE: all page faults
 	 * must be retried without returning VM_FAULT_SIGBUS if
@@ -466,7 +469,8 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 	}
 	up_write(&mm->mmap_sem);
-
+	mmput(mm);
+wakeup:
 	/*
 	 * After no new page faults can wait on this fault_*wqh, flush
 	 * the last page faults that may have been already waiting on
@@ -760,10 +764,12 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	start = uffdio_register.range.start;
 	end = start + uffdio_register.range.len;
 
+	ret = -ENOMEM;
+	if (!mmget_not_zero(mm))
+		goto out;
+
 	down_write(&mm->mmap_sem);
 	vma = find_vma_prev(mm, start, &prev);
-
-	ret = -ENOMEM;
 	if (!vma)
 		goto out_unlock;
 
@@ -864,6 +870,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	} while (vma && vma->vm_start < end);
 out_unlock:
 	up_write(&mm->mmap_sem);
+	mmput(mm);
 	if (!ret) {
 		/*
 		 * Now that we scanned all vmas we can already tell
@@ -902,10 +909,12 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	start = uffdio_unregister.start;
 	end = start + uffdio_unregister.len;
 
+	ret = -ENOMEM;
+	if (!mmget_not_zero(mm))
+		goto out;
+
 	down_write(&mm->mmap_sem);
 	vma = find_vma_prev(mm, start, &prev);
-
-	ret = -ENOMEM;
 	if (!vma)
 		goto out_unlock;
 
@@ -998,6 +1007,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	} while (vma && vma->vm_start < end);
 out_unlock:
 	up_write(&mm->mmap_sem);
+	mmput(mm);
 out:
 	return ret;
 }
@@ -1067,9 +1077,11 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 		goto out;
 	if (uffdio_copy.mode & ~UFFDIO_COPY_MODE_DONTWAKE)
 		goto out;
-
-	ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
-			   uffdio_copy.len);
+	if (mmget_not_zero(ctx->mm)) {
+		ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
+				   uffdio_copy.len);
+		mmput(ctx->mm);
+	}
 	if (unlikely(put_user(ret, &user_uffdio_copy->copy)))
 		return -EFAULT;
 	if (ret < 0)
@@ -1110,8 +1122,11 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 	if (uffdio_zeropage.mode & ~UFFDIO_ZEROPAGE_MODE_DONTWAKE)
 		goto out;
 
-	ret = mfill_zeropage(ctx->mm, uffdio_zeropage.range.start,
-			     uffdio_zeropage.range.len);
+	if (mmget_not_zero(ctx->mm)) {
+		ret = mfill_zeropage(ctx->mm, uffdio_zeropage.range.start,
+				     uffdio_zeropage.range.len);
+		mmput(ctx->mm);
+	}
 	if (unlikely(put_user(ret, &user_uffdio_zeropage->zeropage)))
 		return -EFAULT;
 	if (ret < 0)
@@ -1289,12 +1304,12 @@ static struct file *userfaultfd_file_create(int flags)
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
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 52c4847..49997bf 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2610,12 +2610,17 @@ extern struct mm_struct * mm_alloc(void);
 
 /* mmdrop drops the mm and the page tables */
 extern void __mmdrop(struct mm_struct *);
-static inline void mmdrop(struct mm_struct * mm)
+static inline void mmdrop(struct mm_struct *mm)
 {
 	if (unlikely(atomic_dec_and_test(&mm->mm_count)))
 		__mmdrop(mm);
 }
 
+static inline bool mmget_not_zero(struct mm_struct *mm)
+{
+	return atomic_inc_not_zero(&mm->mm_users);
+}
+
 /* mmput gets rid of the mappings and all user-space */
 extern void mmput(struct mm_struct *);
 /* Grab a reference to a task's mm, if it is not already going away */
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
