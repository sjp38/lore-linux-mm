Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C87C26B02BC
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:50:26 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g187so21142069itc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:50:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p64si2971867itb.12.2016.12.16.06.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:26 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 11/42] userfaultfd: non-cooperative: Add mremap() event
Date: Fri, 16 Dec 2016 15:47:50 +0100
Message-Id: <20161216144821.5183-12-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Pavel Emelyanov <xemul@parallels.com>

The event denotes that an area [start:end] moves to different
location. Length change isn't reported as "new" addresses, if
they appear on the uffd reader side they will not contain any
data and the latter can just zeromap them.

Waiting for the event ACK is also done outside of mmap sem, as
for fork event.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c                 | 37 +++++++++++++++++++++++++++++++++++++
 include/linux/userfaultfd_k.h    | 17 +++++++++++++++++
 include/uapi/linux/userfaultfd.h | 11 ++++++++++-
 mm/mremap.c                      | 17 ++++++++++++-----
 4 files changed, 76 insertions(+), 6 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 9bb7caf..c047b6f 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -563,6 +563,43 @@ void dup_userfaultfd_complete(struct list_head *fcs)
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
index 79002bc..7f318a4 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -55,6 +55,12 @@ static inline bool userfaultfd_armed(struct vm_area_struct *vma)
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
@@ -89,6 +95,17 @@ static inline void dup_userfaultfd_complete(struct list_head *l)
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
index c8953c8..79a85e5 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -18,7 +18,8 @@
  * means the userland is reading).
  */
 #define UFFD_API ((__u64)0xAA)
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK)
+#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |	    \
+			   UFFD_FEATURE_EVENT_REMAP)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -77,6 +78,12 @@ struct uffd_msg {
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
@@ -90,6 +97,7 @@ struct uffd_msg {
  */
 #define UFFD_EVENT_PAGEFAULT	0x12
 #define UFFD_EVENT_FORK		0x13
+#define UFFD_EVENT_REMAP	0x14
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -110,6 +118,7 @@ struct uffdio_api {
 	 */
 #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
 #define UFFD_FEATURE_EVENT_FORK			(1<<1)
+#define UFFD_FEATURE_EVENT_REMAP		(1<<2)
 	__u64 features;
 
 	__u64 ioctls;
diff --git a/mm/mremap.c b/mm/mremap.c
index 30d7d24..504b560 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -22,6 +22,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/uaccess.h>
 #include <linux/mm-arch-hooks.h>
+#include <linux/userfaultfd_k.h>
 
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
@@ -250,7 +251,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 static unsigned long move_vma(struct vm_area_struct *vma,
 		unsigned long old_addr, unsigned long old_len,
-		unsigned long new_len, unsigned long new_addr, bool *locked)
+		unsigned long new_len, unsigned long new_addr,
+		bool *locked, struct vm_userfaultfd_ctx *uf)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma;
@@ -309,6 +311,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		old_addr = new_addr;
 		new_addr = err;
 	} else {
+		mremap_userfaultfd_prep(new_vma, uf);
 		arch_remap(mm, old_addr, old_addr + old_len,
 			   new_addr, new_addr + new_len);
 	}
@@ -413,7 +416,8 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 }
 
 static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
-		unsigned long new_addr, unsigned long new_len, bool *locked)
+		unsigned long new_addr, unsigned long new_len, bool *locked,
+		struct vm_userfaultfd_ctx *uf)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
@@ -458,7 +462,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (offset_in_page(ret))
 		goto out1;
 
-	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked);
+	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked, uf);
 	if (!(offset_in_page(ret)))
 		goto out;
 out1:
@@ -497,6 +501,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	unsigned long ret = -EINVAL;
 	unsigned long charged = 0;
 	bool locked = false;
+	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
 
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;
@@ -523,7 +528,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
-				&locked);
+				&locked, &uf);
 		goto out;
 	}
 
@@ -592,7 +597,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 			goto out;
 		}
 
-		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
+		ret = move_vma(vma, addr, old_len, new_len, new_addr,
+			       &locked, &uf);
 	}
 out:
 	if (offset_in_page(ret)) {
@@ -602,5 +608,6 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	up_write(&current->mm->mmap_sem);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
+	mremap_userfaultfd_complete(uf, addr, new_addr, old_len);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
