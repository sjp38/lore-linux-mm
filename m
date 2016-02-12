Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7755F828F3
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 16:02:34 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fy10so12781860pac.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:02:34 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id fd8si22102135pab.235.2016.02.12.13.02.21
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 13:02:22 -0800 (PST)
Subject: [PATCH 20/33] mm: do not enforce PKEY permissions on "foreign" mm access
From: Dave Hansen <dave@sr71.net>
Date: Fri, 12 Feb 2016 13:02:21 -0800
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
In-Reply-To: <20160212210152.9CAD15B0@viggo.jf.intel.com>
Message-Id: <20160212210220.9EC8AC72@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-arch@vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

We try to enforce protection keys in software the same way that we
do in hardware.  (See long example below).

But, we only want to do this when accessing our *own* process's
memory.  If GDB set PKRU[6].AD=1 (disable access to PKEY 6), then
tried to PTRACE_POKE a target process which just happened to have
some mprotect_pkey(pkey=6) memory, we do *not* want to deny the
debugger access to that memory.  PKRU is fundamentally a
thread-local structure and we do not want to enforce it on access
to _another_ thread's data.

This gets especially tricky when we have workqueues or other
delayed-work mechanisms that might run in a random process's context.
We can check that we only enforce pkeys when operating on our *own* mm,
but delayed work gets performed when a random user context is active.
We might end up with a situation where a delayed-work gup fails when
running randomly under its "own" task but succeeds when running under
another process.  We want to avoid that.

To avoid that, we use the new GUP flag: FOLL_REMOTE and add a
fault flag: FAULT_FLAG_REMOTE.  They indicate that we are
walking an mm which is not guranteed to be the same as
current->mm and should not be subject to protection key
enforcement.

Thanks to Jerome Glisse for pointing out this scenario.

*** Why do we enforce protection keys in software?? ***

Imagine that we disabled access to the memory pointer to by 'buf'.
The, we implemented sys_write() like this:

	sys_read(fd, buf, len...)
	{
		struct page *page = follow_page(buf);
		void *buf_mapped = kmap(page);
		memcpy(buf_mapped, fd_data, len);
		...
	}

This writes to 'buf' via a *kernel* mapping, without a protection
key.  While this implementation does the same thing:

	sys_read(fd, buf, len...)
	{
		copy_to_user(buf, fd_data, len);
		...
	}

but would hit a protection key fault because the userspace 'buf'
mapping has a protection key set.

To provide consistency, and to make key-protected memory work
as much like mprotect()ed memory as possible, we try to enforce
the same protections as the hardware would when the *kernel* walks
the page tables (and other mm structures).

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-arch@vger.kernel.org
---

 b/arch/powerpc/include/asm/mmu_context.h   |    3 ++-
 b/arch/s390/include/asm/mmu_context.h      |    3 ++-
 b/arch/unicore32/include/asm/mmu_context.h |    3 ++-
 b/arch/x86/include/asm/mmu_context.h       |    5 +++--
 b/drivers/iommu/amd_iommu_v2.c             |    1 +
 b/include/asm-generic/mm_hooks.h           |    3 ++-
 b/include/linux/mm.h                       |    1 +
 b/mm/gup.c                                 |   15 ++++++++++-----
 b/mm/ksm.c                                 |   10 ++++++++--
 b/mm/memory.c                              |    3 ++-
 10 files changed, 33 insertions(+), 14 deletions(-)

diff -puN arch/powerpc/include/asm/mmu_context.h~pkeys-14-gup-fault-foreign-flag arch/powerpc/include/asm/mmu_context.h
--- a/arch/powerpc/include/asm/mmu_context.h~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.650540035 -0800
+++ b/arch/powerpc/include/asm/mmu_context.h	2016-02-12 10:44:22.668540858 -0800
@@ -148,7 +148,8 @@ static inline void arch_bprm_mm_init(str
 {
 }
 
-static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
+		bool write, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN arch/s390/include/asm/mmu_context.h~pkeys-14-gup-fault-foreign-flag arch/s390/include/asm/mmu_context.h
--- a/arch/s390/include/asm/mmu_context.h~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.652540127 -0800
+++ b/arch/s390/include/asm/mmu_context.h	2016-02-12 10:44:22.669540904 -0800
@@ -130,7 +130,8 @@ static inline void arch_bprm_mm_init(str
 {
 }
 
-static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
+		bool write, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN arch/unicore32/include/asm/mmu_context.h~pkeys-14-gup-fault-foreign-flag arch/unicore32/include/asm/mmu_context.h
--- a/arch/unicore32/include/asm/mmu_context.h~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.654540218 -0800
+++ b/arch/unicore32/include/asm/mmu_context.h	2016-02-12 10:44:22.669540904 -0800
@@ -97,7 +97,8 @@ static inline void arch_bprm_mm_init(str
 {
 }
 
-static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
+		bool write, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN arch/x86/include/asm/mmu_context.h~pkeys-14-gup-fault-foreign-flag arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.655540264 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2016-02-12 10:44:22.669540904 -0800
@@ -322,10 +322,11 @@ static inline bool vma_is_foreign(struct
 	return false;
 }
 
-static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
+		bool write, bool foreign)
 {
 	/* allow access if the VMA is not one from this process */
-	if (vma_is_foreign(vma))
+	if (foreign || vma_is_foreign(vma))
 		return true;
 	return __pkru_allows_pkey(vma_pkey(vma), write);
 }
diff -puN drivers/iommu/amd_iommu_v2.c~pkeys-14-gup-fault-foreign-flag drivers/iommu/amd_iommu_v2.c
--- a/drivers/iommu/amd_iommu_v2.c~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.657540355 -0800
+++ b/drivers/iommu/amd_iommu_v2.c	2016-02-12 10:44:22.670540949 -0800
@@ -526,6 +526,7 @@ static void do_fault(struct work_struct
 		flags |= FAULT_FLAG_USER;
 	if (fault->flags & PPR_FAULT_WRITE)
 		flags |= FAULT_FLAG_WRITE;
+	flags |= FAULT_FLAG_REMOTE;
 
 	down_read(&mm->mmap_sem);
 	vma = find_extend_vma(mm, address);
diff -puN include/asm-generic/mm_hooks.h~pkeys-14-gup-fault-foreign-flag include/asm-generic/mm_hooks.h
--- a/include/asm-generic/mm_hooks.h~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.658540401 -0800
+++ b/include/asm-generic/mm_hooks.h	2016-02-12 10:44:22.670540949 -0800
@@ -26,7 +26,8 @@ static inline void arch_bprm_mm_init(str
 {
 }
 
-static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
+		bool write, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN include/linux/mm.h~pkeys-14-gup-fault-foreign-flag include/linux/mm.h
--- a/include/linux/mm.h~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.660540492 -0800
+++ b/include/linux/mm.h	2016-02-12 10:44:22.671540995 -0800
@@ -251,6 +251,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x20	/* Second try */
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
+#define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
diff -puN mm/gup.c~pkeys-14-gup-fault-foreign-flag mm/gup.c
--- a/mm/gup.c~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.662540584 -0800
+++ b/mm/gup.c	2016-02-12 10:44:22.672541041 -0800
@@ -365,6 +365,8 @@ static int faultin_page(struct task_stru
 		return -ENOENT;
 	if (*flags & FOLL_WRITE)
 		fault_flags |= FAULT_FLAG_WRITE;
+	if (*flags & FOLL_REMOTE)
+		fault_flags |= FAULT_FLAG_REMOTE;
 	if (nonblocking)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 	if (*flags & FOLL_NOWAIT)
@@ -415,11 +417,13 @@ static int faultin_page(struct task_stru
 static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 {
 	vm_flags_t vm_flags = vma->vm_flags;
+	int write = (gup_flags & FOLL_WRITE);
+	int foreign = (gup_flags & FOLL_REMOTE);
 
 	if (vm_flags & (VM_IO | VM_PFNMAP))
 		return -EFAULT;
 
-	if (gup_flags & FOLL_WRITE) {
+	if (write) {
 		if (!(vm_flags & VM_WRITE)) {
 			if (!(gup_flags & FOLL_FORCE))
 				return -EFAULT;
@@ -445,7 +449,7 @@ static int check_vma_flags(struct vm_are
 		if (!(vm_flags & VM_MAYREAD))
 			return -EFAULT;
 	}
-	if (!arch_vma_access_permitted(vma, (gup_flags & FOLL_WRITE)))
+	if (!arch_vma_access_permitted(vma, write, foreign))
 		return -EFAULT;
 	return 0;
 }
@@ -615,7 +619,8 @@ EXPORT_SYMBOL(__get_user_pages);
 
 bool vma_permits_fault(struct vm_area_struct *vma, unsigned int fault_flags)
 {
-	bool write = !!(fault_flags & FAULT_FLAG_WRITE);
+	bool write   = !!(fault_flags & FAULT_FLAG_WRITE);
+	bool foreign = !!(fault_flags & FAULT_FLAG_REMOTE);
 	vm_flags_t vm_flags = write ? VM_WRITE : VM_READ;
 
 	if (!(vm_flags & vma->vm_flags))
@@ -623,9 +628,9 @@ bool vma_permits_fault(struct vm_area_st
 
 	/*
 	 * The architecture might have a hardware protection
-	 * mechanism other than read/write that can deny access
+	 * mechanism other than read/write that can deny access.
 	 */
-	if (!arch_vma_access_permitted(vma, write))
+	if (!arch_vma_access_permitted(vma, write, foreign))
 		return false;
 
 	return true;
diff -puN mm/ksm.c~pkeys-14-gup-fault-foreign-flag mm/ksm.c
--- a/mm/ksm.c~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.663540630 -0800
+++ b/mm/ksm.c	2016-02-12 10:44:22.673541087 -0800
@@ -359,6 +359,10 @@ static inline bool ksm_test_exit(struct
  * in case the application has unmapped and remapped mm,addr meanwhile.
  * Could a ksm page appear anywhere else?  Actually yes, in a VM_PFNMAP
  * mmap of /dev/mem or /dev/kmem, where we would not want to touch it.
+ *
+ * FAULT_FLAG/FOLL_REMOTE are because we do this outside the context
+ * of the process that owns 'vma'.  We also do not want to enforce
+ * protection keys here anyway.
  */
 static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 {
@@ -367,12 +371,14 @@ static int break_ksm(struct vm_area_stru
 
 	do {
 		cond_resched();
-		page = follow_page(vma, addr, FOLL_GET | FOLL_MIGRATION);
+		page = follow_page(vma, addr,
+				FOLL_GET | FOLL_MIGRATION | FOLL_REMOTE);
 		if (IS_ERR_OR_NULL(page))
 			break;
 		if (PageKsm(page))
 			ret = handle_mm_fault(vma->vm_mm, vma, addr,
-							FAULT_FLAG_WRITE);
+							FAULT_FLAG_WRITE |
+							FAULT_FLAG_REMOTE);
 		else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
diff -puN mm/memory.c~pkeys-14-gup-fault-foreign-flag mm/memory.c
--- a/mm/memory.c~pkeys-14-gup-fault-foreign-flag	2016-02-12 10:44:22.665540721 -0800
+++ b/mm/memory.c	2016-02-12 10:44:22.674541132 -0800
@@ -3358,7 +3358,8 @@ static int __handle_mm_fault(struct mm_s
 	pmd_t *pmd;
 	pte_t *pte;
 
-	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE))
+	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
+					    flags & FAULT_FLAG_REMOTE))
 		return VM_FAULT_SIGSEGV;
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
