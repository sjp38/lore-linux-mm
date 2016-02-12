Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1474B6B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 16:02:00 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id fy10so12775340pac.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:02:00 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id e69si22193002pfd.66.2016.02.12.13.01.54
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 13:01:54 -0800 (PST)
Subject: [PATCH 01/33] mm: introduce get_user_pages_remote()
From: Dave Hansen <dave@sr71.net>
Date: Fri, 12 Feb 2016 13:01:54 -0800
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
In-Reply-To: <20160212210152.9CAD15B0@viggo.jf.intel.com>
Message-Id: <20160212210154.3F0E51EA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz


From: Dave Hansen <dave.hansen@linux.intel.com>

For protection keys, we need to understand whether protections
should be enforced in software or not.  In general, we enforce
protections when working on our own task, but not when on others.
We call these "current" and "remote" operations.

This patch introduces a new get_user_pages() variant:

        get_user_pages_remote()

Which is a replacement for when get_user_pages() is called on
non-current tsk/mm.

We also introduce a new gup flag: FOLL_REMOTE which can be used
for the "__" gup variants to get this new behavior.

The uprobes is_trap_at_addr() location holds mmap_sem and
calls get_user_pages(current->mm) on an instruction address.  This
makes it a pretty unique gup caller.  Being an instruction access
and also really originating from the kernel (vs. the app), I opted
to consider this a 'remote' access where protection keys will not
be enforced.

Without protection keys, this patch should not change any behavior.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: jack@suse.cz
---

 b/drivers/gpu/drm/etnaviv/etnaviv_gem.c   |    6 +++---
 b/drivers/gpu/drm/i915/i915_gem_userptr.c |   10 +++++-----
 b/drivers/infiniband/core/umem_odp.c      |    8 ++++----
 b/fs/exec.c                               |    8 ++++++--
 b/include/linux/mm.h                      |    5 +++++
 b/kernel/events/uprobes.c                 |   10 ++++++++--
 b/mm/gup.c                                |   27 ++++++++++++++++++++++-----
 b/mm/memory.c                             |    2 +-
 b/mm/process_vm_access.c                  |   11 ++++++++---
 b/security/tomoyo/domain.c                |    9 ++++++++-
 b/virt/kvm/async_pf.c                     |    8 +++++++-
 11 files changed, 77 insertions(+), 27 deletions(-)

diff -puN drivers/gpu/drm/etnaviv/etnaviv_gem.c~introduce-get_user_pages_remote drivers/gpu/drm/etnaviv/etnaviv_gem.c
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.170106660 -0800
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c	2016-02-12 10:44:13.190107574 -0800
@@ -753,9 +753,9 @@ static struct page **etnaviv_gem_userptr
 
 	down_read(&mm->mmap_sem);
 	while (pinned < npages) {
-		ret = get_user_pages(task, mm, ptr, npages - pinned,
-				     !etnaviv_obj->userptr.ro, 0,
-				     pvec + pinned, NULL);
+		ret = get_user_pages_remote(task, mm, ptr, npages - pinned,
+					    !etnaviv_obj->userptr.ro, 0,
+					    pvec + pinned, NULL);
 		if (ret < 0)
 			break;
 
diff -puN drivers/gpu/drm/i915/i915_gem_userptr.c~introduce-get_user_pages_remote drivers/gpu/drm/i915/i915_gem_userptr.c
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.171106705 -0800
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c	2016-02-12 10:44:13.190107574 -0800
@@ -584,11 +584,11 @@ __i915_gem_userptr_get_pages_worker(stru
 
 		down_read(&mm->mmap_sem);
 		while (pinned < npages) {
-			ret = get_user_pages(work->task, mm,
-					     obj->userptr.ptr + pinned * PAGE_SIZE,
-					     npages - pinned,
-					     !obj->userptr.read_only, 0,
-					     pvec + pinned, NULL);
+			ret = get_user_pages_remote(work->task, mm,
+					obj->userptr.ptr + pinned * PAGE_SIZE,
+					npages - pinned,
+					!obj->userptr.read_only, 0,
+					pvec + pinned, NULL);
 			if (ret < 0)
 				break;
 
diff -puN drivers/infiniband/core/umem_odp.c~introduce-get_user_pages_remote drivers/infiniband/core/umem_odp.c
--- a/drivers/infiniband/core/umem_odp.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.173106797 -0800
+++ b/drivers/infiniband/core/umem_odp.c	2016-02-12 10:44:13.191107620 -0800
@@ -572,10 +572,10 @@ int ib_umem_odp_map_dma_pages(struct ib_
 		 * complex (and doesn't gain us much performance in most use
 		 * cases).
 		 */
-		npages = get_user_pages(owning_process, owning_mm, user_virt,
-					gup_num_pages,
-					access_mask & ODP_WRITE_ALLOWED_BIT, 0,
-					local_page_list, NULL);
+		npages = get_user_pages_remote(owning_process, owning_mm,
+				user_virt, gup_num_pages,
+				access_mask & ODP_WRITE_ALLOWED_BIT,
+				0, local_page_list, NULL);
 		up_read(&owning_mm->mmap_sem);
 
 		if (npages < 0)
diff -puN fs/exec.c~introduce-get_user_pages_remote fs/exec.c
--- a/fs/exec.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.175106888 -0800
+++ b/fs/exec.c	2016-02-12 10:44:13.192107666 -0800
@@ -198,8 +198,12 @@ static struct page *get_arg_page(struct
 			return NULL;
 	}
 #endif
-	ret = get_user_pages(current, bprm->mm, pos,
-			1, write, 1, &page, NULL);
+	/*
+	 * We are doing an exec().  'current' is the process
+	 * doing the exec and bprm->mm is the new process's mm.
+	 */
+	ret = get_user_pages_remote(current, bprm->mm, pos, 1, write,
+			1, &page, NULL);
 	if (ret <= 0)
 		return NULL;
 
diff -puN include/linux/mm.h~introduce-get_user_pages_remote include/linux/mm.h
--- a/include/linux/mm.h~introduce-get_user_pages_remote	2016-02-12 10:44:13.176106934 -0800
+++ b/include/linux/mm.h	2016-02-12 10:44:13.192107666 -0800
@@ -1225,6 +1225,10 @@ long __get_user_pages(struct task_struct
 		      unsigned long start, unsigned long nr_pages,
 		      unsigned int foll_flags, struct page **pages,
 		      struct vm_area_struct **vmas, int *nonblocking);
+long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
+			    unsigned long start, unsigned long nr_pages,
+			    int write, int force, struct page **pages,
+			    struct vm_area_struct **vmas);
 long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		    unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages,
@@ -2168,6 +2172,7 @@ static inline struct page *follow_page(s
 #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
 #define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
 #define FOLL_MLOCK	0x1000	/* lock present pages */
+#define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff -puN kernel/events/uprobes.c~introduce-get_user_pages_remote kernel/events/uprobes.c
--- a/kernel/events/uprobes.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.178107026 -0800
+++ b/kernel/events/uprobes.c	2016-02-12 10:44:13.193107711 -0800
@@ -299,7 +299,7 @@ int uprobe_write_opcode(struct mm_struct
 
 retry:
 	/* Read the page with vaddr into memory */
-	ret = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
+	ret = get_user_pages_remote(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
 	if (ret <= 0)
 		return ret;
 
@@ -1700,7 +1700,13 @@ static int is_trap_at_addr(struct mm_str
 	if (likely(result == 0))
 		goto out;
 
-	result = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
+	/*
+	 * The NULL 'tsk' here ensures that any faults that occur here
+	 * will not be accounted to the task.  'mm' *is* current->mm,
+	 * but we treat this as a 'remote' access since it is
+	 * essentially a kernel access to the memory.
+	 */
+	result = get_user_pages_remote(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
 	if (result < 0)
 		return result;
 
diff -puN mm/gup.c~introduce-get_user_pages_remote mm/gup.c
--- a/mm/gup.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.180107117 -0800
+++ b/mm/gup.c	2016-02-12 10:44:13.194107757 -0800
@@ -870,7 +870,7 @@ long get_user_pages_unlocked(struct task
 EXPORT_SYMBOL(get_user_pages_unlocked);
 
 /*
- * get_user_pages() - pin user pages in memory
+ * get_user_pages_remote() - pin user pages in memory
  * @tsk:	the task_struct to use for page fault accounting, or
  *		NULL if faults are not to be recorded.
  * @mm:		mm_struct of target mm
@@ -924,12 +924,29 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
  * should use get_user_pages because it cannot pass
  * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.
  */
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, unsigned long nr_pages, int write,
-		int force, struct page **pages, struct vm_area_struct **vmas)
+long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages,
+		int write, int force, struct page **pages,
+		struct vm_area_struct **vmas)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				       pages, vmas, NULL, false, FOLL_TOUCH);
+				       pages, vmas, NULL, false,
+				       FOLL_TOUCH | FOLL_REMOTE);
+}
+EXPORT_SYMBOL(get_user_pages_remote);
+
+/*
+ * This is the same as get_user_pages_remote() for the time
+ * being.
+ */
+long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages,
+		int write, int force, struct page **pages,
+		struct vm_area_struct **vmas)
+{
+	return __get_user_pages_locked(tsk, mm, start, nr_pages,
+				       write, force, pages, vmas, NULL, false,
+				       FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages);
 
diff -puN mm/memory.c~introduce-get_user_pages_remote mm/memory.c
--- a/mm/memory.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.182107208 -0800
+++ b/mm/memory.c	2016-02-12 10:44:13.195107803 -0800
@@ -3664,7 +3664,7 @@ static int __access_remote_vm(struct tas
 		void *maddr;
 		struct page *page = NULL;
 
-		ret = get_user_pages(tsk, mm, addr, 1,
+		ret = get_user_pages_remote(tsk, mm, addr, 1,
 				write, 1, &page, &vma);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
diff -puN mm/process_vm_access.c~introduce-get_user_pages_remote mm/process_vm_access.c
--- a/mm/process_vm_access.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.183107254 -0800
+++ b/mm/process_vm_access.c	2016-02-12 10:44:13.195107803 -0800
@@ -98,9 +98,14 @@ static int process_vm_rw_single_vec(unsi
 		int pages = min(nr_pages, max_pages_per_loop);
 		size_t bytes;
 
-		/* Get the pages we're interested in */
-		pages = get_user_pages_unlocked(task, mm, pa, pages,
-						vm_write, 0, process_pages);
+		/*
+		 * Get the pages we're interested in.  We must
+		 * add FOLL_REMOTE because task/mm might not
+		 * current/current->mm
+		 */
+		pages = __get_user_pages_unlocked(task, mm, pa, pages,
+						  vm_write, 0, process_pages,
+						  FOLL_REMOTE);
 		if (pages <= 0)
 			return -EFAULT;
 
diff -puN security/tomoyo/domain.c~introduce-get_user_pages_remote security/tomoyo/domain.c
--- a/security/tomoyo/domain.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.185107346 -0800
+++ b/security/tomoyo/domain.c	2016-02-12 10:44:13.196107848 -0800
@@ -874,7 +874,14 @@ bool tomoyo_dump_page(struct linux_binpr
 	}
 	/* Same with get_arg_page(bprm, pos, 0) in fs/exec.c */
 #ifdef CONFIG_MMU
-	if (get_user_pages(current, bprm->mm, pos, 1, 0, 1, &page, NULL) <= 0)
+	/*
+	 * This is called at execve() time in order to dig around
+	 * in the argv/environment of the new proceess
+	 * (represented by bprm).  'current' is the process doing
+	 * the execve().
+	 */
+	if (get_user_pages_remote(current, bprm->mm, pos, 1,
+				0, 1, &page, NULL) <= 0)
 		return false;
 #else
 	page = bprm->page[pos / PAGE_SIZE];
diff -puN virt/kvm/async_pf.c~introduce-get_user_pages_remote virt/kvm/async_pf.c
--- a/virt/kvm/async_pf.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.187107437 -0800
+++ b/virt/kvm/async_pf.c	2016-02-12 10:44:13.196107848 -0800
@@ -79,7 +79,13 @@ static void async_pf_execute(struct work
 
 	might_sleep();
 
-	get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL);
+	/*
+	 * This work is run asynchromously to the task which owns
+	 * mm and might be done in another context, so we must
+	 * use FOLL_REMOTE.
+	 */
+	__get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL, FOLL_REMOTE);
+
 	kvm_async_page_present_sync(vcpu, apf);
 
 	spin_lock(&vcpu->async_pf.lock);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
