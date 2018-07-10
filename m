Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 576806B0010
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:34:42 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id az8-v6so13132206plb.15
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:34:42 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id v18-v6si17492819pgl.171.2018.07.10.16.34.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:34:41 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v4 PATCH 1/3] mm: introduce VM_DEAD flag and extend check_stable_address_space to check it
Date: Wed, 11 Jul 2018 07:34:07 +0800
Message-Id: <1531265649-93433-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

VM_DEAD flag is used to mark a vma is being unmapped for the later
munmap large address space optimization. Before the optimization PF
race with munmap, may return the right content or SIGSEGV, but with
the optimization, it may return a zero page.

Use this flag to mark PF to this area is unstable, will trigger SIGSEGV,
in order to prevent from the 3rd state.

This flag will be set by the optimization for unmapping large address
space (>= 1GB) in the later patch. It is 64 bit only at the moment,
since:
  * we used up vm_flags bit for 32 bit
  * 32 bit machine typically will not have such large mapping

Extend check_stable_address_space() to check this flag, as well as the
page fault path of shmem and hugetlb.

Since oom reaper doesn't tear down shmem and hugetlb, so skip those two
cases for MMF_UNSTABLE.

Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mm.h  |  8 ++++++++
 include/linux/oom.h | 20 --------------------
 mm/huge_memory.c    |  4 ++--
 mm/hugetlb.c        |  5 +++++
 mm/memory.c         | 39 +++++++++++++++++++++++++++++++++++----
 mm/shmem.c          |  9 ++++++++-
 6 files changed, 58 insertions(+), 27 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0fbb9f..ce7b112 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -242,6 +242,12 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 #endif
 #endif /* CONFIG_ARCH_HAS_PKEYS */
 
+#ifdef CONFIG_64BIT
+#define VM_DEAD			BIT(37)	/* bit only usable on 64 bit kernel */
+#else
+#define VM_DEAD			0
+#endif
+
 #if defined(CONFIG_X86)
 # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
 #elif defined(CONFIG_PPC)
@@ -2782,5 +2788,7 @@ static inline bool page_is_guard(struct page *page)
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+extern int check_stable_address_space(struct vm_area_struct *vma);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 6adac11..0265ed5 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -75,26 +75,6 @@ static inline bool mm_is_oom_victim(struct mm_struct *mm)
 	return test_bit(MMF_OOM_VICTIM, &mm->flags);
 }
 
-/*
- * Checks whether a page fault on the given mm is still reliable.
- * This is no longer true if the oom reaper started to reap the
- * address space which is reflected by MMF_UNSTABLE flag set in
- * the mm. At that moment any !shared mapping would lose the content
- * and could cause a memory corruption (zero pages instead of the
- * original content).
- *
- * User should call this before establishing a page table entry for
- * a !shared mapping and under the proper page table lock.
- *
- * Return 0 when the PF is safe VM_FAULT_SIGBUS otherwise.
- */
-static inline int check_stable_address_space(struct mm_struct *mm)
-{
-	if (unlikely(test_bit(MMF_UNSTABLE, &mm->flags)))
-		return VM_FAULT_SIGBUS;
-	return 0;
-}
-
 void __oom_reap_task_mm(struct mm_struct *mm);
 
 extern unsigned long oom_badness(struct task_struct *p,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1cd7c1a..997bac9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -578,7 +578,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 	} else {
 		pmd_t entry;
 
-		ret = check_stable_address_space(vma->vm_mm);
+		ret = check_stable_address_space(vma);
 		if (ret)
 			goto unlock_release;
 
@@ -696,7 +696,7 @@ int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 		ret = 0;
 		set = false;
 		if (pmd_none(*vmf->pmd)) {
-			ret = check_stable_address_space(vma->vm_mm);
+			ret = check_stable_address_space(vma);
 			if (ret) {
 				spin_unlock(vmf->ptl);
 			} else if (userfaultfd_missing(vma)) {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3612fbb..8965d02 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3887,6 +3887,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	int need_wait_lock = 0;
 	unsigned long haddr = address & huge_page_mask(h);
 
+	ret = check_stable_address_space(vma);
+	if (ret)
+		goto out;
+
 	ptep = huge_pte_offset(mm, haddr, huge_page_size(h));
 	if (ptep) {
 		entry = huge_ptep_get(ptep);
@@ -4006,6 +4010,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	if (need_wait_lock)
 		wait_on_page_locked(page);
+out:
 	return ret;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 7206a63..250547f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -68,7 +68,7 @@
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
-#include <linux/oom.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -776,6 +776,37 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 }
 
 /*
+ * Checks whether a page fault on the given mm is still reliable.
+ * This is no longer true if the oom reaper started to reap the
+ * address space which is reflected by MMF_UNSTABLE flag set in
+ * the mm. At that moment any !shared mapping would lose the content
+ * and could cause a memory corruption (zero pages instead of the
+ * original content).
+ * oom reaper doesn't reap hugetlb and shmem, so skip the check for
+ * such vmas.
+ *
+ * And, check if the given vma has VM_DEAD flag set, which means
+ * the vma will be unmapped soon, PF is not safe for such vma.
+ *
+ * User should call this before establishing a page table entry for
+ * a !shared mapping (disk file based), or shmem mapping, or hugetlb
+ * mapping, and under the proper page table lock.
+ *
+ * Return 0 when the PF is safe, VM_FAULT_SIGBUS or VM_FAULT_SIGSEGV
+ * otherwise.
+ */
+int check_stable_address_space(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_DEAD)
+		return VM_FAULT_SIGSEGV;
+	if (!is_vm_hugetlb_page(vma) && !shmem_file(vma->vm_file)) {
+		if (unlikely(test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)))
+			return VM_FAULT_SIGBUS;
+	}
+	return 0;
+}
+
+/*
  * vm_normal_page -- This function gets the "struct page" associated with a pte.
  *
  * "Special" mappings do not wish to be associated with a "struct page" (either
@@ -3147,7 +3178,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 				vmf->address, &vmf->ptl);
 		if (!pte_none(*vmf->pte))
 			goto unlock;
-		ret = check_stable_address_space(vma->vm_mm);
+		ret = check_stable_address_space(vma);
 		if (ret)
 			goto unlock;
 		/* Deliver the page fault to userland, check inside PT lock */
@@ -3184,7 +3215,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	if (!pte_none(*vmf->pte))
 		goto release;
 
-	ret = check_stable_address_space(vma->vm_mm);
+	ret = check_stable_address_space(vma);
 	if (ret)
 		goto release;
 
@@ -3495,7 +3526,7 @@ int finish_fault(struct vm_fault *vmf)
 	 * page
 	 */
 	if (!(vmf->vma->vm_flags & VM_SHARED))
-		ret = check_stable_address_space(vmf->vma->vm_mm);
+		ret = check_stable_address_space(vmf->vma);
 	if (!ret)
 		ret = alloc_set_pte(vmf, vmf->memcg, page);
 	if (vmf->pte)
diff --git a/mm/shmem.c b/mm/shmem.c
index 2cab844..9f9ac7c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1953,7 +1953,13 @@ static vm_fault_t shmem_fault(struct vm_fault *vmf)
 	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 	enum sgp_type sgp;
 	int err;
-	vm_fault_t ret = VM_FAULT_LOCKED;
+	vm_fault_t ret = 0;
+
+	ret = check_stable_address_space(vma);
+	if (ret)
+		goto out;
+
+	ret = VM_FAULT_LOCKED;
 
 	/*
 	 * Trinity finds that probing a hole which tmpfs is punching can
@@ -2025,6 +2031,7 @@ static vm_fault_t shmem_fault(struct vm_fault *vmf)
 				  gfp, vma, vmf, &ret);
 	if (err)
 		return vmf_error(err);
+out:
 	return ret;
 }
 
-- 
1.8.3.1
