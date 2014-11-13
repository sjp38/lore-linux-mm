Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 417E36B00E0
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 16:02:12 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id z12so17578568wgg.23
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 13:02:11 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id e9si46369495wjy.35.2014.11.13.13.02.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 13:02:11 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id n12so17712535wgh.13
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 13:02:11 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [RESEND][PATCH V3 1/4] KSM: Add auto flag new VMA as VM_MERGEABLE
Date: Fri, 14 Nov 2014 00:01:55 +0300
Message-Id: <1415912518-8508-2-git-send-email-nefelim4ag@gmail.com>
In-Reply-To: <1415912518-8508-1-git-send-email-nefelim4ag@gmail.com>
References: <1415912518-8508-1-git-send-email-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Timofey Titovets <nefelim4ag@gmail.com>

Implement two functions:
ksm_vm_flags_mod() - if existing flags supported by ksm - then mark like VM_MERGEABLE
ksm_vma_add_new() - If vma marked as VM_MERGEABLE add it to ksm page queue

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
---
 include/linux/ksm.h | 31 +++++++++++++++++++++++++++++++
 mm/mmap.c           | 17 +++++++++++++++++
 2 files changed, 48 insertions(+)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 3be6bb1..c3fff64 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -76,6 +76,29 @@ struct page *ksm_might_need_to_copy(struct page *page,
 int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
 
+/*
+ * Allow to mark new vma as VM_MERGEABLE
+ */
+#ifndef VM_SAO
+#define VM_SAO 0
+#endif
+static inline void ksm_vm_flags_mod(unsigned long *vm_flags)
+{
+	if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
+			 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
+			 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP   | VM_SAO) )
+		return;
+	*vm_flags |= VM_MERGEABLE;
+}
+
+static inline void ksm_vma_add_new(struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
+		__ksm_enter(mm);
+	}
+}
+
 #else  /* !CONFIG_KSM */
 
 static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
@@ -92,6 +115,14 @@ static inline int PageKsm(struct page *page)
 	return 0;
 }
 
+static inline void ksm_vm_flags_mod(unsigned long *vm_flags_p)
+{
+}
+
+void ksm_vma_add_new(struct vm_area_struct *vma)
+{
+}
+
 #ifdef CONFIG_MMU
 static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags)
diff --git a/mm/mmap.c b/mm/mmap.c
index 7f85520..ce0073e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -41,6 +41,7 @@
 #include <linux/notifier.h>
 #include <linux/memory.h>
 #include <linux/printk.h>
+#include <linux/ksm.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -911,10 +912,14 @@ again:			remove_next = 1 + (end > next->vm_end);
 			vma_gap_update(next);
 		else
 			mm->highest_vm_end = end;
+	} else {
+		if (next && !insert)
+			ksm_vma_add_new(next);
 	}
 	if (insert && file)
 		uprobe_mmap(insert);
 
+	ksm_vma_add_new(vma);
 	validate_mm(mm);
 
 	return 0;
@@ -1307,6 +1312,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
+	/* If ksm is enabled, we add VM_MERGABLE to new VMAs. */
+	ksm_vm_flags_mod(&vm_flags);
+
 	if (flags & MAP_LOCKED)
 		if (!can_do_mlock())
 			return -EPERM;
@@ -1648,6 +1656,7 @@ munmap_back:
 			allow_write_access(file);
 	}
 	file = vma->vm_file;
+	ksm_vma_add_new(vma);
 out:
 	perf_event_mmap(vma);
 
@@ -2484,6 +2493,8 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	else
 		err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
 
+	ksm_vma_add_new(vma);
+
 	/* Success. */
 	if (!err)
 		return 0;
@@ -2659,6 +2670,9 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	if (error)
 		return error;
 
+	/* If ksm is enabled, we add VM_MERGABLE to new VMAs. */
+	ksm_vm_flags_mod(&flags);
+
 	/*
 	 * mm->mmap_sem is required to protect against another thread
 	 * changing the mappings in case we sleep.
@@ -2708,6 +2722,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	vma->vm_flags = flags;
 	vma->vm_page_prot = vm_get_page_prot(flags);
 	vma_link(mm, vma, prev, rb_link, rb_parent);
+	ksm_vma_add_new(vma);
 out:
 	perf_event_mmap(vma);
 	mm->total_vm += len >> PAGE_SHIFT;
@@ -2887,6 +2902,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 				new_vma->vm_ops->open(new_vma);
 			vma_link(mm, new_vma, prev, rb_link, rb_parent);
 			*need_rmap_locks = false;
+			ksm_vma_add_new(new_vma);
 		}
 	}
 	return new_vma;
@@ -3004,6 +3020,7 @@ static struct vm_area_struct *__install_special_mapping(
 	mm->total_vm += len >> PAGE_SHIFT;
 
 	perf_event_mmap(vma);
+	ksm_vma_add_new(vma);
 
 	return vma;
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
