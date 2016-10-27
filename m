Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65E0B6B027B
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 16:34:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i128so17525515wme.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 13:34:13 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id e5si10713104wjt.179.2016.10.27.13.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 13:34:12 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id b80so4377172wme.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 13:34:12 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH v2 1/2] mm: add locked parameter to get_user_pages_remote()
Date: Thu, 27 Oct 2016 21:34:02 +0100
Message-Id: <20161027203403.31708-2-lstoakes@gmail.com>
In-Reply-To: <20161027203403.31708-1-lstoakes@gmail.com>
References: <20161027203403.31708-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-rdma@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, Lorenzo Stoakes <lstoakes@gmail.com>

This patch adds an int *locked parameter to get_user_pages_remote() to allow
VM_FAULT_RETRY faulting behaviour similar to get_user_pages_[un]locked().

It additionally clears the way for __get_user_pages_unlocked() to be unexported
as its sole remaining useful characteristic was to allow for VM_FAULT_RETRY
behaviour when faulting in pages.

It should not introduce any functional changes, however it does allow for
subsequent changes to get_user_pages_remote() callers to take advantage of
VM_FAULT_RETRY.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
v2: updated description

 drivers/gpu/drm/etnaviv/etnaviv_gem.c   |  2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c |  2 +-
 drivers/infiniband/core/umem_odp.c      |  2 +-
 fs/exec.c                               |  2 +-
 include/linux/mm.h                      |  2 +-
 kernel/events/uprobes.c                 |  4 ++--
 mm/gup.c                                | 12 ++++++++----
 mm/memory.c                             |  2 +-
 security/tomoyo/domain.c                |  2 +-
 9 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index 0370b84..0c69a97f 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -763,7 +763,7 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 	down_read(&mm->mmap_sem);
 	while (pinned < npages) {
 		ret = get_user_pages_remote(task, mm, ptr, npages - pinned,
-					    flags, pvec + pinned, NULL);
+					    flags, pvec + pinned, NULL, NULL);
 		if (ret < 0)
 			break;

diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index c6f780f..836b525 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -522,7 +522,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 					 obj->userptr.ptr + pinned * PAGE_SIZE,
 					 npages - pinned,
 					 flags,
-					 pvec + pinned, NULL);
+					 pvec + pinned, NULL, NULL);
 				if (ret < 0)
 					break;

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 1f0fe32..6b079a3 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -578,7 +578,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 		 */
 		npages = get_user_pages_remote(owning_process, owning_mm,
 				user_virt, gup_num_pages,
-				flags, local_page_list, NULL);
+				flags, local_page_list, NULL, NULL);
 		up_read(&owning_mm->mmap_sem);

 		if (npages < 0)
diff --git a/fs/exec.c b/fs/exec.c
index 4e497b9..2cf049d 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -209,7 +209,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 	 * doing the exec and bprm->mm is the new process's mm.
 	 */
 	ret = get_user_pages_remote(current, bprm->mm, pos, 1, gup_flags,
-			&page, NULL);
+			&page, NULL, NULL);
 	if (ret <= 0)
 		return NULL;

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d7..cc15445 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1274,7 +1274,7 @@ extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas);
+			    struct vm_area_struct **vmas, int *locked);
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas);
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index f9ec9ad..215871b 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -301,7 +301,7 @@ int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &old_page,
-			&vma);
+			&vma, NULL);
 	if (ret <= 0)
 		return ret;

@@ -1712,7 +1712,7 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
 	 * essentially a kernel access to the memory.
 	 */
 	result = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &page,
-			NULL);
+			NULL, NULL);
 	if (result < 0)
 		return result;

diff --git a/mm/gup.c b/mm/gup.c
index ec4f827..0567851 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -920,6 +920,9 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
  *		only intends to ensure the pages are faulted in.
  * @vmas:	array of pointers to vmas corresponding to each page.
  *		Or NULL if the caller does not require them.
+ * @locked:	pointer to lock flag indicating whether lock is held and
+ *		subsequently whether VM_FAULT_RETRY functionality can be
+ *		utilised. Lock must initially be held.
  *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
@@ -963,10 +966,10 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas)
+		struct vm_area_struct **vmas, int *locked)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
-				       NULL, false,
+				       locked, true,
 				       gup_flags | FOLL_TOUCH | FOLL_REMOTE);
 }
 EXPORT_SYMBOL(get_user_pages_remote);
@@ -974,8 +977,9 @@ EXPORT_SYMBOL(get_user_pages_remote);
 /*
  * This is the same as get_user_pages_remote(), just with a
  * less-flexible calling convention where we assume that the task
- * and mm being operated on are the current task's.  We also
- * obviously don't pass FOLL_REMOTE in here.
+ * and mm being operated on are the current task's and don't allow
+ * passing of a locked parameter.  We also obviously don't pass
+ * FOLL_REMOTE in here.
  */
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
diff --git a/mm/memory.c b/mm/memory.c
index e18c57b..2f3949b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3883,7 +3883,7 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		struct page *page = NULL;

 		ret = get_user_pages_remote(tsk, mm, addr, 1,
-				gup_flags, &page, &vma);
+				gup_flags, &page, &vma, NULL);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
 			break;
diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
index 682b73a..838ffa7 100644
--- a/security/tomoyo/domain.c
+++ b/security/tomoyo/domain.c
@@ -881,7 +881,7 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 	 * the execve().
 	 */
 	if (get_user_pages_remote(current, bprm->mm, pos, 1,
-				FOLL_FORCE, &page, NULL) <= 0)
+				FOLL_FORCE, &page, NULL, NULL) <= 0)
 		return false;
 #else
 	page = bprm->page[pos / PAGE_SIZE];
--
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
