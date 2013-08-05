Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 8D3C36B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 15:44:12 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id bi5so3675152pad.36
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 12:44:11 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [RFC 1/3] mm: Add MADV_WILLWRITE to indicate that a range will be written to
Date: Mon,  5 Aug 2013 12:43:59 -0700
Message-Id: <ebef32f36450626c3aee13b13154c8be404c6443.1375729665.git.luto@amacapital.net>
In-Reply-To: <cover.1375729665.git.luto@amacapital.net>
References: <cover.1375729665.git.luto@amacapital.net>
In-Reply-To: <cover.1375729665.git.luto@amacapital.net>
References: <cover.1375729665.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>

This should not cause data to be written to disk.  It should, however,
do any expensive operations that would otherwise happen on the first
write fault to this range.

Some day this may COW private mappings, allocate real memory instead
of zero pages, etc.  For now it just passes the request down to
filesystems on shared writable mappings.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 include/linux/mm.h                     | 12 ++++++++++++
 include/uapi/asm-generic/mman-common.h |  3 +++
 mm/madvise.c                           | 28 ++++++++++++++++++++++++++--
 3 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f022460..d3c89ab 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -205,6 +205,18 @@ struct vm_operations_struct {
 	 * writable, if an error is returned it will cause a SIGBUS */
 	int (*page_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
+	/* request to make future writes to this page fast.  only called
+	 * on shared writable maps.  return 0 on success (or if there's
+	 * nothing to do).
+	 *
+	 * return the number of bytes for which the operation worked (i.e.
+	 * zero if unsupported) or a negative error if something goes wrong.
+	 *
+	 * called with mmap_sem held for read.
+	 */
+	long (*willwrite)(struct vm_area_struct *vma,
+			  unsigned long start, unsigned long end);
+
 	/* called by access_process_vm when get_user_pages() fails, typically
 	 * for use by special VMAs that can switch between memory and hardware
 	 */
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 4164529..e65e97d 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -52,6 +52,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
 
+#define MADV_WILLWRITE	18		/* Will write to this page, but maybe
+					   only after a while */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 7055883..7b537fd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -31,6 +31,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_WILLWRITE:
 		return 0;
 	default:
 		/* be safe, default to 1. list exceptions explicitly */
@@ -337,6 +338,24 @@ static long madvise_remove(struct vm_area_struct *vma,
 	return error;
 }
 
+static long madvise_willwrite(struct vm_area_struct * vma,
+			     struct vm_area_struct ** prev,
+			     unsigned long start, unsigned long end)
+{
+	*prev = vma;
+
+	if (!(vma->vm_flags & VM_WRITE))
+		return -EFAULT;
+
+	if ((vma->vm_flags & (VM_SHARED|VM_WRITE)) != (VM_SHARED|VM_WRITE))
+		return 0;  /* Not yet supported */
+
+	if (!vma->vm_file || !vma->vm_ops || !vma->vm_ops->willwrite)
+		return 0;  /* Not supported */
+
+	return vma->vm_ops->willwrite(vma, start, end);
+}
+
 #ifdef CONFIG_MEMORY_FAILURE
 /*
  * Error injection support for memory error handling.
@@ -380,6 +399,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
+	case MADV_WILLWRITE:
+		return madvise_willwrite(vma, prev, start, end);
 	default:
 		return madvise_behavior(vma, prev, start, end, behavior);
 	}
@@ -407,6 +428,7 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+	case MADV_WILLWRITE:
 		return 1;
 
 	default:
@@ -465,6 +487,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	int write;
 	size_t len;
 	struct blk_plug plug;
+	long sum_rets = 0;
 
 #ifdef CONFIG_MEMORY_FAILURE
 	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
@@ -526,8 +549,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
 		error = madvise_vma(vma, &prev, start, tmp, behavior);
-		if (error)
+		if (error < 0)
 			goto out;
+		sum_rets += error;
 		start = tmp;
 		if (prev && start < prev->vm_end)
 			start = prev->vm_end;
@@ -546,5 +570,5 @@ out:
 	else
 		up_read(&current->mm->mmap_sem);
 
-	return error;
+	return error ? error : sum_rets;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
