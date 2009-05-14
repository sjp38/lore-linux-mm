Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 408E16B0151
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:31:14 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 1/4] madvice: add MADV_SHAREABLE and MADV_UNSHAREABLE calls.
Date: Thu, 14 May 2009 03:30:45 +0300
Message-Id: <1242261048-4487-2-git-send-email-ieidus@redhat.com>
In-Reply-To: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, linux-mm@kvack.org, riel@redhat.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

This patch add MADV_SHAREABLE and MADV_UNSHAREABLE madvise calls,
this calls used to mark vm memory areas with the VM_MERGEABLE flag,
that specific if the memory inside the vma is allowed to be dinamicly shared
with other memorys.

(this is needed for ksm vma scanning support)

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 include/asm-generic/mman.h |    2 +
 include/linux/mm.h         |    2 +
 include/linux/sched.h      |    2 +
 mm/madvise.c               |  116 +++++++++++++++++++++++++++++++++----------
 4 files changed, 95 insertions(+), 27 deletions(-)

diff --git a/include/asm-generic/mman.h b/include/asm-generic/mman.h
index 5e3dde2..830295d 100644
--- a/include/asm-generic/mman.h
+++ b/include/asm-generic/mman.h
@@ -34,6 +34,8 @@
 #define MADV_REMOVE	9		/* remove these pages & resources */
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
+#define MADV_SHAREABLE	12		/* can share identical pages */
+#define MADV_UNSHAREABLE 13		/* can not share identical pages */
 
 /* compatibility flags */
 #define MAP_FILE	0
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0ddfb5..61328a4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -106,6 +106,8 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
 
+#define VM_MERGEABLE    0x80000000	/* Memory may be merged */
+
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b4c38bc..7dc786a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -439,6 +439,8 @@ extern int get_dumpable(struct mm_struct *mm);
 # define MMF_DUMP_MASK_DEFAULT_ELF	0
 #endif
 
+#define MMF_VM_MERGEABLE	9
+
 struct sighand_struct {
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];
diff --git a/mm/madvise.c b/mm/madvise.c
index b9ce574..bd215ce 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -30,36 +30,12 @@ static int madvise_need_mmap_write(int behavior)
 	}
 }
 
-/*
- * We can potentially split a vm area into separate
- * areas, each area with its own behavior.
- */
-static long madvise_behavior(struct vm_area_struct * vma,
-		     struct vm_area_struct **prev,
-		     unsigned long start, unsigned long end, int behavior)
+static int handle_vmas(struct vm_area_struct *vma, struct vm_area_struct **prev,
+		       unsigned long start, unsigned long end, int new_flags)
 {
 	struct mm_struct * mm = vma->vm_mm;
-	int error = 0;
 	pgoff_t pgoff;
-	int new_flags = vma->vm_flags;
-
-	switch (behavior) {
-	case MADV_NORMAL:
-		new_flags = new_flags & ~VM_RAND_READ & ~VM_SEQ_READ;
-		break;
-	case MADV_SEQUENTIAL:
-		new_flags = (new_flags & ~VM_RAND_READ) | VM_SEQ_READ;
-		break;
-	case MADV_RANDOM:
-		new_flags = (new_flags & ~VM_SEQ_READ) | VM_RAND_READ;
-		break;
-	case MADV_DONTFORK:
-		new_flags |= VM_DONTCOPY;
-		break;
-	case MADV_DOFORK:
-		new_flags &= ~VM_DONTCOPY;
-		break;
-	}
+	int error = 0;
 
 	if (new_flags == vma->vm_flags) {
 		*prev = vma;
@@ -101,6 +77,37 @@ out:
 }
 
 /*
+ * We can potentially split a vm area into separate
+ * areas, each area with its own behavior.
+ */
+static long madvise_behavior(struct vm_area_struct * vma,
+		     struct vm_area_struct **prev,
+		     unsigned long start, unsigned long end, int behavior)
+{
+	int new_flags = vma->vm_flags;
+
+	switch (behavior) {
+	case MADV_NORMAL:
+		new_flags = new_flags & ~VM_RAND_READ & ~VM_SEQ_READ;
+		break;
+	case MADV_SEQUENTIAL:
+		new_flags = (new_flags & ~VM_RAND_READ) | VM_SEQ_READ;
+		break;
+	case MADV_RANDOM:
+		new_flags = (new_flags & ~VM_SEQ_READ) | VM_RAND_READ;
+		break;
+	case MADV_DONTFORK:
+		new_flags |= VM_DONTCOPY;
+		break;
+	case MADV_DOFORK:
+		new_flags &= ~VM_DONTCOPY;
+		break;
+	}
+
+	return handle_vmas(vma, prev, start, end, new_flags);
+}
+
+/*
  * Schedule all required I/O operations.  Do not wait for completion.
  */
 static long madvise_willneed(struct vm_area_struct * vma,
@@ -208,6 +215,54 @@ static long madvise_remove(struct vm_area_struct *vma,
 	return error;
 }
 
+/*
+ * Application allows pages to be shared with other pages of identical
+ * content.
+ *
+ */
+static long madvise_shareable(struct vm_area_struct *vma,
+				struct vm_area_struct **prev,
+				unsigned long start, unsigned long end,
+				int behavior)
+{
+	int ret;
+	struct mm_struct *mm;
+
+	switch (behavior) {
+#if defined(CONFIG_KSM) || defined(CONFIG_KSM_MODULE)
+	case MADV_SHAREABLE:
+		ret = handle_vmas(vma, prev, start, end,
+				  vma->vm_flags | VM_MERGEABLE);
+
+		if (!ret) {
+			mm = vma->vm_mm;
+			set_bit(MMF_VM_MERGEABLE, &mm->flags);
+		}
+
+		return ret;
+	case MADV_UNSHAREABLE:
+		ret = handle_vmas(vma, prev, start, end,
+				  vma->vm_flags & ~VM_MERGEABLE);
+
+		if (!ret) {
+			mm = vma->vm_mm;
+			vma = mm->mmap;
+			while (vma) {
+				if (vma->vm_flags & VM_MERGEABLE)
+					break;
+				vma = vma->vm_next;
+			}
+			if (!vma)
+				clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+		}
+
+		return ret;
+#endif
+	default:
+		return -EINVAL;
+	}
+}
+
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
@@ -238,6 +293,11 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		error = madvise_dontneed(vma, prev, start, end);
 		break;
 
+	case MADV_SHAREABLE:
+	case MADV_UNSHAREABLE:
+		error = madvise_shareable(vma, prev, start, end, behavior);
+		break;
+
 	default:
 		error = -EINVAL;
 		break;
@@ -269,6 +329,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
  *		so the kernel can free resources associated with it.
  *  MADV_REMOVE - the application wants to free up the given range of
  *		pages and associated backing store.
+ *  MADV_SHAREABLE - the application agrees that pages in the given
+ *		range can be shared w/ other pages of identical content.
  *
  * return values:
  *  zero    - success
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
