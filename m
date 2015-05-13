Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B62CB6B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 10:53:30 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so53019586pab.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 07:53:30 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qj3si27350859pbb.231.2015.05.13.07.53.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 07:53:29 -0700 (PDT)
Message-ID: <55536561.9060901@parallels.com>
Date: Wed, 13 May 2015 17:53:21 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 4/5] uffd: Add mremap() event
References: <5553651B.1020909@parallels.com>
In-Reply-To: <5553651B.1020909@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

The event denotes that an area [start:end] moves to different
location. Lenght change isn't reported as "new" addresses if
they appear on the uffd reader side will not contain any data
and the latter can just zeromap them.

Waiting for the event ACK is also done outside of mmap sem, as
for fork event.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 fs/userfaultfd.c                 | 35 +++++++++++++++++++++++++++++++++++
 include/linux/userfaultfd_k.h    | 12 ++++++++++++
 include/uapi/linux/userfaultfd.h | 10 +++++++++-
 mm/mremap.c                      | 31 ++++++++++++++++++++-----------
 4 files changed, 76 insertions(+), 12 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 202d0ac..697e636 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -511,6 +511,41 @@ void dup_userfaultfd_complete(struct list_head *fcs)
 	}
 }
 
+void mremap_userfaultfd_prep(struct vm_area_struct *vma, struct vm_userfaultfd_ctx *vm_ctx)
+{
+	struct userfaultfd_ctx *ctx;
+
+	ctx = vma->vm_userfaultfd_ctx.ctx;
+	if (ctx && (ctx->features & UFFD_FEATURE_EVENT_REMAP)) {
+		vm_ctx->ctx = ctx;
+		userfaultfd_ctx_get(ctx);
+	}
+}
+
+void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx vm_ctx, unsigned long from,
+		unsigned long to, unsigned long len)
+{
+	struct userfaultfd_ctx *ctx = vm_ctx.ctx;
+	struct userfaultfd_wait_queue ewq;
+
+	if (ctx == NULL)
+		return;
+
+	if (to & ~PAGE_MASK) {
+		userfaultfd_ctx_put(ctx);
+		return;
+	}
+
+	msg_init(&ewq.msg);
+
+	ewq.msg.event = UFFD_EVENT_REMAP;
+	ewq.msg.arg.remap.from = from;
+	ewq.msg.arg.remap.to = to;
+	ewq.msg.arg.remap.len = len;
+
+	userfaultfd_event_wait_completion(ctx, &ewq);
+}
+
 static int userfaultfd_release(struct inode *inode, struct file *file)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 44827f7..0ed5dce 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -78,6 +78,10 @@ static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 extern int dup_userfaultfd(struct vm_area_struct *, struct list_head *);
 extern void dup_userfaultfd_complete(struct list_head *);
 
+extern void mremap_userfaultfd_prep(struct vm_area_struct *, struct vm_userfaultfd_ctx *);
+extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx, unsigned long from,
+		unsigned long to, unsigned long len);
+
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
@@ -119,6 +123,14 @@ static inline void dup_userfaultfd_complete(struct list_head *)
 {
 }
 
+static inline void mremap_userfaultfd_prep(struct vm_area_struct *vma, struct vm_userfaultfd_ctx *ctx)
+{
+}
+
+static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx ctx,
+		unsigned long from, unsigned long to, unsigned long len)
+{
+}
 #endif /* CONFIG_USERFAULTFD */
 
 #endif /* _LINUX_USERFAULTFD_K_H */
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index fb9ced2..59a141c 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -14,7 +14,7 @@
  * After implementing the respective features it will become:
  * #define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP)
  */
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK)
+#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK|UFFD_FEATURE_EVENT_REMAP)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -73,6 +73,12 @@ struct uffd_msg {
 		} fork;
 
 		struct {
+			__u64	from;
+			__u64	to;
+			__u64	len;
+		} remap;
+
+		struct {
 			/* unused reserved fields */
 			__u64	reserved1;
 			__u64	reserved2;
@@ -86,6 +92,7 @@ struct uffd_msg {
  */
 #define UFFD_EVENT_PAGEFAULT	0x12
 #define UFFD_EVENT_FORK		0x13
+#define UFFD_EVENT_REMAP	0x14
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -108,6 +115,7 @@ struct uffdio_api {
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #endif
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
+#define UFFD_FEATURE_EVENT_REMAP		(1<<2)
 	__u64 features;
 
 	__u64 ioctls;
diff --git a/mm/mremap.c b/mm/mremap.c
index 034e2d3..a63287d 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -22,6 +22,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/sched/sysctl.h>
 #include <linux/uaccess.h>
+#include <linux/userfaultfd_k.h>
 
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
@@ -234,7 +235,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 static unsigned long move_vma(struct vm_area_struct *vma,
 		unsigned long old_addr, unsigned long old_len,
-		unsigned long new_len, unsigned long new_addr, bool *locked)
+		unsigned long new_len, unsigned long new_addr,
+		bool *locked, struct vm_userfaultfd_ctx *uf)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma;
@@ -286,13 +288,17 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		old_len = new_len;
 		old_addr = new_addr;
 		new_addr = -ENOMEM;
-	} else if (vma->vm_file && vma->vm_file->f_op->mremap) {
-		err = vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
-		if (err < 0) {
-			move_page_tables(new_vma, new_addr, vma, old_addr,
-					 moved_len, true);
-			return err;
+	} else {
+		if (vma->vm_file && vma->vm_file->f_op->mremap) {
+			err = vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
+			if (err < 0) {
+				move_page_tables(new_vma, new_addr, vma, old_addr,
+						moved_len, true);
+				return err;
+			}
 		}
+
+		mremap_userfaultfd_prep(new_vma, uf);
 	}
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
@@ -389,7 +395,8 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 }
 
 static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
-		unsigned long new_addr, unsigned long new_len, bool *locked)
+		unsigned long new_addr, unsigned long new_len, bool *locked,
+		struct vm_userfaultfd_ctx *uf)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
@@ -439,7 +446,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (ret & ~PAGE_MASK)
 		goto out1;
 
-	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked);
+	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked, uf);
 	if (!(ret & ~PAGE_MASK))
 		goto out;
 out1:
@@ -478,6 +485,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	unsigned long ret = -EINVAL;
 	unsigned long charged = 0;
 	bool locked = false;
+	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
 
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;
@@ -503,7 +511,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
-				&locked);
+				&locked, &uf);
 		goto out;
 	}
 
@@ -572,7 +580,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 			goto out;
 		}
 
-		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
+		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked, &uf);
 	}
 out:
 	if (ret & ~PAGE_MASK)
@@ -580,5 +588,6 @@ out:
 	up_write(&current->mm->mmap_sem);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
+	mremap_userfaultfd_complete(uf, addr, new_addr, old_len);
 	return ret;
 }
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
