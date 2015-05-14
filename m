Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4F49B6B00AA
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:32:17 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so41068063qgf.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:32:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 82si3050072qhw.114.2015.05.14.10.31.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:52 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 16/23] userfaultfd: allocate the userfaultfd_ctx cacheline aligned
Date: Thu, 14 May 2015 19:31:13 +0200
Message-Id: <1431624680-20153-17-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Use proper slab to guarantee alignment.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 39 +++++++++++++++++++++++++++++++--------
 1 file changed, 31 insertions(+), 8 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 3d26f41..5542fe7 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -27,20 +27,26 @@
 #include <linux/ioctl.h>
 #include <linux/security.h>
 
+static struct kmem_cache *userfaultfd_ctx_cachep __read_mostly;
+
 enum userfaultfd_state {
 	UFFD_STATE_WAIT_API,
 	UFFD_STATE_RUNNING,
 };
 
+/*
+ * Start with fault_pending_wqh and fault_wqh so they're more likely
+ * to be in the same cacheline.
+ */
 struct userfaultfd_ctx {
-	/* pseudo fd refcounting */
-	atomic_t refcount;
 	/* waitqueue head for the pending (i.e. not read) userfaults */
 	wait_queue_head_t fault_pending_wqh;
 	/* waitqueue head for the userfaults */
 	wait_queue_head_t fault_wqh;
 	/* waitqueue head for the pseudo fd to wakeup poll/read */
 	wait_queue_head_t fd_wqh;
+	/* pseudo fd refcounting */
+	atomic_t refcount;
 	/* userfaultfd syscall flags */
 	unsigned int flags;
 	/* state machine */
@@ -117,7 +123,7 @@ static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 		VM_BUG_ON(spin_is_locked(&ctx->fd_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fd_wqh));
 		mmput(ctx->mm);
-		kfree(ctx);
+		kmem_cache_free(userfaultfd_ctx_cachep, ctx);
 	}
 }
 
@@ -987,6 +993,15 @@ static const struct file_operations userfaultfd_fops = {
 	.llseek		= noop_llseek,
 };
 
+static void init_once_userfaultfd_ctx(void *mem)
+{
+	struct userfaultfd_ctx *ctx = (struct userfaultfd_ctx *) mem;
+
+	init_waitqueue_head(&ctx->fault_pending_wqh);
+	init_waitqueue_head(&ctx->fault_wqh);
+	init_waitqueue_head(&ctx->fd_wqh);
+}
+
 /**
  * userfaultfd_file_create - Creates an userfaultfd file pointer.
  * @flags: Flags for the userfaultfd file.
@@ -1017,14 +1032,11 @@ static struct file *userfaultfd_file_create(int flags)
 		goto out;
 
 	file = ERR_PTR(-ENOMEM);
-	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
+	ctx = kmem_cache_alloc(userfaultfd_ctx_cachep, GFP_KERNEL);
 	if (!ctx)
 		goto out;
 
 	atomic_set(&ctx->refcount, 1);
-	init_waitqueue_head(&ctx->fault_pending_wqh);
-	init_waitqueue_head(&ctx->fault_wqh);
-	init_waitqueue_head(&ctx->fd_wqh);
 	ctx->flags = flags;
 	ctx->state = UFFD_STATE_WAIT_API;
 	ctx->released = false;
@@ -1035,7 +1047,7 @@ static struct file *userfaultfd_file_create(int flags)
 	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
 				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
 	if (IS_ERR(file))
-		kfree(ctx);
+		kmem_cache_free(userfaultfd_ctx_cachep, ctx);
 out:
 	return file;
 }
@@ -1064,3 +1076,14 @@ err_put_unused_fd:
 
 	return error;
 }
+
+static int __init userfaultfd_init(void)
+{
+	userfaultfd_ctx_cachep = kmem_cache_create("userfaultfd_ctx_cache",
+						sizeof(struct userfaultfd_ctx),
+						0,
+						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+						init_once_userfaultfd_ctx);
+	return 0;
+}
+__initcall(userfaultfd_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
