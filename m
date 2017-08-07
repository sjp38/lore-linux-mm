Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE746B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 07:38:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 185so685333wmk.12
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 04:38:51 -0700 (PDT)
Received: from mail-wr0-f193.google.com (mail-wr0-f193.google.com. [209.85.128.193])
        by mx.google.com with ESMTPS id p1si9403019edb.413.2017.08.07.04.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 04:38:48 -0700 (PDT)
Received: by mail-wr0-f193.google.com with SMTP id c24so151431wra.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 04:38:48 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, oom: fix potential data corruption when oom_reaper races with writer
Date: Mon,  7 Aug 2017 13:38:39 +0200
Message-Id: <20170807113839.16695-3-mhocko@kernel.org>
In-Reply-To: <20170807113839.16695-1-mhocko@kernel.org>
References: <20170807113839.16695-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Argangeli <andrea@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Wenwei Tao has noticed that our current assumption that the oom victim
is dying and never doing any visible changes after it dies, and so the
oom_reaper can tear it down, is not entirely true.

__task_will_free_mem consider a task dying when SIGNAL_GROUP_EXIT
is set but do_group_exit sends SIGKILL to all threads _after_ the
flag is set. So there is a race window when some threads won't have
fatal_signal_pending while the oom_reaper could start unmapping the
address space. Moreover some paths might not check for fatal signals
before each PF/g-u-p/copy_from_user.

We already have a protection for oom_reaper vs. PF races by checking
MMF_UNSTABLE. This has been, however, checked only for kernel threads
(use_mm users) which can outlive the oom victim. A simple fix would be
to extend the current check in handle_mm_fault for all tasks but that
wouldn't be sufficient because the current check assumes that a kernel
thread would bail out after EFAULT from get_user*/copy_from_user and
never re-read the same address which would succeed because the PF path
has established page tables already. This seems to be the case for the
only existing use_mm user currently (virtio driver) but it is rather
fragile in general.

This is even more fragile in general for more complex paths such as
generic_perform_write which can re-read the same address more times
(e.g. iov_iter_copy_from_user_atomic to fail and then
iov_iter_fault_in_readable on retry). Therefore we have to implement
MMF_UNSTABLE protection in a robust way and never make a potentially
corrupted content visible. That requires to hook deeper into the PF
path and check for the flag _every time_ before a pte for anonymous
memory is established (that means all !VM_SHARED mappings).

The corruption can be triggered artificially [1] but there doesn't seem
to be any real life bug report. The race window should be quite tight
to trigger most of the time.

Fixes: aac453635549 ("mm, oom: introduce oom reaper")
Noticed-by: Wenwei Tao <wenwei.tww@alibaba-inc.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>

[1] http://lkml.kernel.org/r/201708040646.v746kkhC024636@www262.sakura.ne.jp
---
 include/linux/oom.h | 22 ++++++++++++++++++++++
 mm/huge_memory.c    | 30 ++++++++++++++++++++++--------
 mm/memory.c         | 46 ++++++++++++++++++++--------------------------
 3 files changed, 64 insertions(+), 34 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8a266e2be5a6..76aac4ce39bc 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -6,6 +6,8 @@
 #include <linux/types.h>
 #include <linux/nodemask.h>
 #include <uapi/linux/oom.h>
+#include <linux/sched/coredump.h> /* MMF_* */
+#include <linux/mm.h> /* VM_FAULT* */
 
 struct zonelist;
 struct notifier_block;
@@ -63,6 +65,26 @@ static inline bool tsk_is_oom_victim(struct task_struct * tsk)
 	return tsk->signal->oom_mm;
 }
 
+/*
+ * Checks whether a page fault on the given mm is still reliable.
+ * This is no longer true if the oom reaper started to reap the
+ * address space which is reflected by MMF_UNSTABLE flag set in
+ * the mm. At that moment any !shared mapping would lose the content
+ * and could cause a memory corruption (zero pages instead of the
+ * original content).
+ *
+ * User should call this before establishing a page table entry for
+ * a !shared mapping and under the proper page table lock.
+ *
+ * Return 0 when the PF is safe VM_FAULT_SIGBUS otherwise.
+ */
+static inline int check_stable_address_space(struct mm_struct *mm)
+{
+	if (unlikely(test_bit(MMF_UNSTABLE, &mm->flags)))
+		return VM_FAULT_SIGBUS;
+	return 0;
+}
+
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86975dec0ba1..b03cfc0d3141 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -32,6 +32,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
+#include <linux/oom.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -550,6 +551,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
+	int ret = 0;
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
@@ -561,9 +563,8 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 	pgtable = pte_alloc_one(vma->vm_mm, haddr);
 	if (unlikely(!pgtable)) {
-		mem_cgroup_cancel_charge(page, memcg, true);
-		put_page(page);
-		return VM_FAULT_OOM;
+		ret = VM_FAULT_OOM;
+		goto release;
 	}
 
 	clear_huge_page(page, haddr, HPAGE_PMD_NR);
@@ -576,13 +577,14 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
 	if (unlikely(!pmd_none(*vmf->pmd))) {
-		spin_unlock(vmf->ptl);
-		mem_cgroup_cancel_charge(page, memcg, true);
-		put_page(page);
-		pte_free(vma->vm_mm, pgtable);
+		goto unlock_release;
 	} else {
 		pmd_t entry;
 
+		ret = check_stable_address_space(vma->vm_mm);
+		if (ret)
+			goto unlock_release;
+
 		/* Deliver the page fault to userland */
 		if (userfaultfd_missing(vma)) {
 			int ret;
@@ -610,6 +612,15 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 	}
 
 	return 0;
+unlock_release:
+	spin_unlock(vmf->ptl);
+release:
+	if (pgtable)
+		pte_free(vma->vm_mm, pgtable);
+	mem_cgroup_cancel_charge(page, memcg, true);
+	put_page(page);
+	return ret;
+
 }
 
 /*
@@ -688,7 +699,10 @@ int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 		ret = 0;
 		set = false;
 		if (pmd_none(*vmf->pmd)) {
-			if (userfaultfd_missing(vma)) {
+			ret = check_stable_address_space(vma->vm_mm);
+			if (ret) {
+				spin_unlock(vmf->ptl);
+			} else if (userfaultfd_missing(vma)) {
 				spin_unlock(vmf->ptl);
 				ret = handle_userfault(vmf, VM_UFFD_MISSING);
 				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
diff --git a/mm/memory.c b/mm/memory.c
index 4fe5b6254688..1b4504441bd2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -68,6 +68,7 @@
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
+#include <linux/oom.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -2864,6 +2865,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	struct mem_cgroup *memcg;
 	struct page *page;
+	int ret = 0;
 	pte_t entry;
 
 	/* File mapping without ->vm_ops ? */
@@ -2896,6 +2898,9 @@ static int do_anonymous_page(struct vm_fault *vmf)
 				vmf->address, &vmf->ptl);
 		if (!pte_none(*vmf->pte))
 			goto unlock;
+		ret = check_stable_address_space(vma->vm_mm);
+		if (ret)
+			goto unlock;
 		/* Deliver the page fault to userland, check inside PT lock */
 		if (userfaultfd_missing(vma)) {
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2930,6 +2935,10 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	if (!pte_none(*vmf->pte))
 		goto release;
 
+	ret = check_stable_address_space(vma->vm_mm);
+	if (ret)
+		goto release;
+
 	/* Deliver the page fault to userland, check inside PT lock */
 	if (userfaultfd_missing(vma)) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2949,7 +2958,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	update_mmu_cache(vma, vmf->address, vmf->pte);
 unlock:
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
-	return 0;
+	return ret;
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
@@ -3223,7 +3232,7 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 int finish_fault(struct vm_fault *vmf)
 {
 	struct page *page;
-	int ret;
+	int ret = 0;
 
 	/* Did we COW the page? */
 	if ((vmf->flags & FAULT_FLAG_WRITE) &&
@@ -3231,7 +3240,15 @@ int finish_fault(struct vm_fault *vmf)
 		page = vmf->cow_page;
 	else
 		page = vmf->page;
-	ret = alloc_set_pte(vmf, vmf->memcg, page);
+
+	/*
+	 * check even for read faults because we might have lost our CoWed
+	 * page
+	 */
+	if (!(vmf->vma->vm_flags & VM_SHARED))
+		ret = check_stable_address_space(vmf->vma->vm_mm);
+	if (!ret)
+		ret = alloc_set_pte(vmf, vmf->memcg, page);
 	if (vmf->pte)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 	return ret;
@@ -3871,29 +3888,6 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 			mem_cgroup_oom_synchronize(false);
 	}
 
-	/*
-	 * This mm has been already reaped by the oom reaper and so the
-	 * refault cannot be trusted in general. Anonymous refaults would
-	 * lose data and give a zero page instead e.g. This is especially
-	 * problem for use_mm() because regular tasks will just die and
-	 * the corrupted data will not be visible anywhere while kthread
-	 * will outlive the oom victim and potentially propagate the date
-	 * further.
-	 */
-	if (unlikely((current->flags & PF_KTHREAD) && !(ret & VM_FAULT_ERROR)
-				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags))) {
-
-		/*
-		 * We are going to enforce SIGBUS but the PF path might have
-		 * dropped the mmap_sem already so take it again so that
-		 * we do not break expectations of all arch specific PF paths
-		 * and g-u-p
-		 */
-		if (ret & VM_FAULT_RETRY)
-			down_read(&vma->vm_mm->mmap_sem);
-		ret = VM_FAULT_SIGBUS;
-	}
-
 	return ret;
 }
 EXPORT_SYMBOL_GPL(handle_mm_fault);
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
