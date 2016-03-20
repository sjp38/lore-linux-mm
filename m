Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9935C6B0262
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:48 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id l68so91599103wml.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 05:42:48 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id k10si13064wjy.108.2016.03.20.05.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 20 Mar 2016 05:42:44 -0700 (PDT)
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rapoport@il.ibm.com>;
	Sun, 20 Mar 2016 12:42:44 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9C8EA1B0805F
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:43:12 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2KCgfYw262540
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:42:41 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2KCgf69017321
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:41 -0400
From: Mike Rapoport <rapoport@il.ibm.com>
Subject: [PATCH 4/5] uffd: Add mremap() event
Date: Sun, 20 Mar 2016 14:42:20 +0200
Message-Id: <1458477741-6942-5-git-send-email-rapoport@il.ibm.com>
In-Reply-To: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
References: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>, Mike Rapoport <rapoport@il.ibm.com>

From: Pavel Emelyanov <xemul@parallels.com>

The event denotes that an area [start:end] moves to different
location. Length change isn't reported as "new" addresses, if
they appear on the uffd reader side they will not contain any
data and the latter can just zeromap them.

Waiting for the event ACK is also done outside of mmap sem, as
for fork event.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Mike Rapoport <rapoport@il.ibm.com>
---
 fs/userfaultfd.c                 | 37 +++++++++++++++++++++++++++++++++++++
 include/linux/userfaultfd_k.h    | 17 +++++++++++++++++
 include/uapi/linux/userfaultfd.h | 10 +++++++++-
 mm/mremap.c                      | 17 ++++++++++++-----
 4 files changed, 75 insertions(+), 6 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 565d8f2..a7771bd 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -562,6 +562,43 @@ void dup_userfaultfd_complete(struct list_head *fcs)
 	}
 }
 
+void mremap_userfaultfd_prep(struct vm_area_struct *vma,
+			     struct vm_userfaultfd_ctx *vm_ctx)
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
+void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx vm_ctx,
+				 unsigned long from, unsigned long to,
+				 unsigned long len)
+{
+	struct userfaultfd_ctx *ctx = vm_ctx.ctx;
+	struct userfaultfd_wait_queue ewq;
+
+	if (!ctx)
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
index 0c7b723..42ea277 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -56,6 +56,12 @@ static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 extern int dup_userfaultfd(struct vm_area_struct *, struct list_head *);
 extern void dup_userfaultfd_complete(struct list_head *);
 
+extern void mremap_userfaultfd_prep(struct vm_area_struct *,
+				    struct vm_userfaultfd_ctx *);
+extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx,
+					unsigned long from, unsigned long to,
+					unsigned long len);
+
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
@@ -92,6 +98,17 @@ static inline void dup_userfaultfd_complete(struct list_head *)
 {
 }
 
+static inline void mremap_userfaultfd_prep(struct vm_area_struct *vma,
+					   struct vm_userfaultfd_ctx *ctx)
+{
+}
+
+static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx ctx,
+					       unsigned long from,
+					       unsigned long to,
+					       unsigned long len)
+{
+}
 #endif /* CONFIG_USERFAULTFD */
 
 #endif /* _LINUX_USERFAULTFD_K_H */
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index d89eef6..46bbb6f 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -16,7 +16,7 @@
  * After implementing the respective features it will become:
  * #define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP)
  */
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK)
+#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK|UFFD_FEATURE_EVENT_REMAP)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -75,6 +75,12 @@ struct uffd_msg {
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
@@ -88,6 +94,7 @@ struct uffd_msg {
  */
 #define UFFD_EVENT_PAGEFAULT	0x12
 #define UFFD_EVENT_FORK		0x13
+#define UFFD_EVENT_REMAP	0x14
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -110,6 +117,7 @@ struct uffdio_api {
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #endif
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
+#define UFFD_FEATURE_EVENT_REMAP		(1<<2)
 	__u64 features;
 
 	__u64 ioctls;
diff --git a/mm/mremap.c b/mm/mremap.c
index 3fa0a467..3581f31 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -22,6 +22,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/uaccess.h>
 #include <linux/mm-arch-hooks.h>
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
@@ -293,6 +295,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		old_addr = new_addr;
 		new_addr = err;
 	} else {
+		mremap_userfaultfd_prep(new_vma, uf);
 		arch_remap(mm, old_addr, old_addr + old_len,
 			   new_addr, new_addr + new_len);
 	}
@@ -397,7 +400,8 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 }
 
 static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
-		unsigned long new_addr, unsigned long new_len, bool *locked)
+		unsigned long new_addr, unsigned long new_len, bool *locked,
+		struct vm_userfaultfd_ctx *uf)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
@@ -442,7 +446,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (offset_in_page(ret))
 		goto out1;
 
-	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked);
+	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked, uf);
 	if (!(offset_in_page(ret)))
 		goto out;
 out1:
@@ -481,6 +485,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	unsigned long ret = -EINVAL;
 	unsigned long charged = 0;
 	bool locked = false;
+	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
 
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;
@@ -506,7 +511,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
-				&locked);
+				&locked, &uf);
 		goto out;
 	}
 
@@ -575,7 +580,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 			goto out;
 		}
 
-		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
+		ret = move_vma(vma, addr, old_len, new_len, new_addr,
+			       &locked, &uf);
 	}
 out:
 	if (offset_in_page(ret)) {
@@ -585,5 +591,6 @@ out:
 	up_write(&current->mm->mmap_sem);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
+	mremap_userfaultfd_complete(uf, addr, new_addr, old_len);
 	return ret;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
