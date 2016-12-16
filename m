Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 664656B026F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:11 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id k201so69988062qke.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:11 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u57si3829805qtc.171.2016.12.16.10.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:36:10 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 13/14] sparc64 mm: add shared context support to mmap() and shmat() APIs
Date: Fri, 16 Dec 2016 10:35:36 -0800
Message-Id: <1481913337-9331-14-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Add new mmap(MAP_SHAREDCTX) and shm(SHM_SHAREDCTX) flags to specify
desire for shared context mappings.  This only works on HUGETLB
mappings.  In addition, the mappings must be SHARED and at a FIXED
address otherwize EINVAL will be returned.

Also, populate the sparc specific hooks to mmap and shmat that perform
shared context processing.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/include/asm/hugetlb.h        |  4 +++
 arch/sparc/include/asm/mman.h           |  6 ++++
 arch/sparc/include/asm/mmu_context_64.h | 62 ++++++++++++++++++++++++++++++++-
 arch/sparc/include/uapi/asm/mman.h      |  1 +
 arch/sparc/kernel/sys_sparc_64.c        | 17 +++++++++
 arch/sparc/mm/init_64.c                 | 36 +++++++++++++++++++
 include/uapi/linux/shm.h                |  1 +
 7 files changed, 126 insertions(+), 1 deletion(-)

diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index dcbf985..13157b3 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -78,4 +78,8 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 			    unsigned long end, unsigned long floor,
 			    unsigned long ceiling);
 
+#if defined(CONFIG_SHARED_MMU_CTX)
+void huge_get_shared_ctx(struct mm_struct *mm, unsigned long addr);
+#endif
+
 #endif /* _ASM_SPARC64_HUGETLB_H */
diff --git a/arch/sparc/include/asm/mman.h b/arch/sparc/include/asm/mman.h
index 59bb593..cbe384e 100644
--- a/arch/sparc/include/asm/mman.h
+++ b/arch/sparc/include/asm/mman.h
@@ -6,5 +6,11 @@
 #ifndef __ASSEMBLY__
 #define arch_mmap_check(addr,len,flags)	sparc_mmap_check(addr,len)
 int sparc_mmap_check(unsigned long addr, unsigned long len);
+
+#if defined(CONFIG_SHARED_MMU_CTX)
+#define arch_shmat_check(file, shmflg, flags) \
+				sparc_shmat_check(file, shmflg, flags)
+int sparc_shmat_check(struct file *file, int shmflg, unsigned long *flags);
+#endif
 #endif
 #endif /* __SPARC_MMAN_H__ */
diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
index 46c2c7e..8ab05f2 100644
--- a/arch/sparc/include/asm/mmu_context_64.h
+++ b/arch/sparc/include/asm/mmu_context_64.h
@@ -7,7 +7,6 @@
 
 #include <linux/spinlock.h>
 #include <asm/spitfire.h>
-#include <asm-generic/mm_hooks.h>
 
 static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 {
@@ -24,6 +23,13 @@ void put_shared_context(struct mm_struct *mm);
 void set_mm_shared_ctx(struct mm_struct *mm, struct shared_mmu_ctx *ctx);
 void destroy_shared_context(struct mm_struct *mm);
 void set_vma_shared_ctx(struct vm_area_struct *vma);
+void sparc64_exit_mmap(struct mm_struct *mm);
+void sparc64_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long start, unsigned long end);
+unsigned long sparc64_pre_mmap_flags(struct file *file, unsigned long flags,
+					vm_flags_t *vm_flags);
+void sparc64_post_mmap(struct mm_struct *mm, unsigned long addr,
+					vm_flags_t vm_flags);
 #endif
 #ifdef CONFIG_SMP
 void smp_new_mmu_context_version(void);
@@ -208,6 +214,60 @@ static inline void activate_mm(struct mm_struct *active_mm, struct mm_struct *mm
 	spin_unlock_irqrestore(&mm->context.lock, flags);
 }
 
+#if defined(CONFIG_SHARED_MMU_CTX)
+/*
+ * mm_hooks only needed for CONFIG_SHARED_MMU_CTX
+ */
+static inline unsigned long arch_pre_mmap_flags(struct file *file,
+						unsigned long flags,
+						vm_flags_t *vm_flags)
+{
+	return sparc64_pre_mmap_flags(file, flags, vm_flags);
+}
+
+static inline void arch_post_mmap(struct mm_struct *mm, unsigned long addr,
+							vm_flags_t vm_flags)
+{
+	sparc64_post_mmap(mm, addr, vm_flags);
+}
+
+static inline void arch_dup_mmap(struct mm_struct *oldmm,
+				 struct mm_struct *mm)
+{
+}
+
+static inline void arch_exit_mmap(struct mm_struct *mm)
+{
+	sparc64_exit_mmap(mm);
+}
+
+static inline void arch_unmap(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	sparc64_unmap(mm, vma, start, end);
+}
+
+static inline void arch_bprm_mm_init(struct mm_struct *mm,
+				     struct vm_area_struct *vma)
+{
+}
+
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
+		bool write, bool execute, bool foreign)
+{
+	/* by default, allow everything */
+	return true;
+}
+
+static inline bool arch_pte_access_permitted(pte_t pte, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
+#else
+#include <asm-generic/mm_hooks.h>
+#endif
 #endif /* !(__ASSEMBLY__) */
 
 #endif /* !(__SPARC64_MMU_CONTEXT_H) */
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 9765896..a52c6fe 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -23,6 +23,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define	MAP_SHAREDCTX	0x80000		/* request shared cxt mapping */
 
 
 #endif /* _UAPI__SPARC_MMAN_H__ */
diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index fe8b8ee..23fa538 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -25,6 +25,7 @@
 #include <linux/random.h>
 #include <linux/export.h>
 #include <linux/context_tracking.h>
+#include <linux/hugetlb.h>
 
 #include <asm/uaccess.h>
 #include <asm/utrap.h>
@@ -444,6 +445,22 @@ int sparc_mmap_check(unsigned long addr, unsigned long len)
 	return 0;
 }
 
+int sparc_shmat_check(struct file *file, int shmflg, unsigned long *flags)
+{
+	if (shmflg & SHM_SHAREDCTX) {
+		if ((*flags & (MAP_SHARED | MAP_FIXED)) !=
+		    (unsigned long)(MAP_SHARED | MAP_FIXED))
+			return -EINVAL;
+
+		if (!is_file_hugepages(file))
+			return -EINVAL;
+
+		*flags |= MAP_SHAREDCTX;
+	}
+
+	return 0;
+}
+
 /* Linux version of mmap */
 SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 		unsigned long, prot, unsigned long, flags, unsigned long, fd,
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 25ad5bd..0637762 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -27,6 +27,7 @@
 #include <linux/memblock.h>
 #include <linux/mmzone.h>
 #include <linux/gfp.h>
+#include <linux/mman.h>
 
 #include <asm/head.h>
 #include <asm/page.h>
@@ -832,6 +833,41 @@ void set_vma_shared_ctx(struct vm_area_struct *vma)
 	atomic_inc(&mm->context.shared_ctx->refcount);
 	vma->vm_shared_mmu_ctx.ctx = mm->context.shared_ctx;
 }
+
+unsigned long sparc64_pre_mmap_flags(struct file *file, unsigned long flags,
+					vm_flags_t *vm_flags)
+{
+	if (flags & MAP_SHAREDCTX) {
+		/* Must be a shared huge page mapping */
+		if (!(flags & (MAP_SHARED | MAP_FIXED)))
+			return -EINVAL;
+		if (!(flags & MAP_HUGETLB)  &&
+		    !(file && is_file_hugepages(file)))
+			return -EINVAL;
+
+		*vm_flags |= VM_SHARED_CTX;
+	}
+
+	return 0;
+}
+
+void sparc64_post_mmap(struct mm_struct *mm, unsigned long addr,
+							vm_flags_t vm_flags)
+{
+	if (vm_flags & VM_SHARED_CTX)
+		huge_get_shared_ctx(mm, addr);
+}
+
+void sparc64_exit_mmap(struct mm_struct *mm)
+{
+	put_shared_context(mm);
+}
+
+void sparc64_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	put_shared_context(mm);
+}
 #endif
 
 static int numa_enabled = 1;
diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index 1fbf24e..3373567 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -49,6 +49,7 @@ struct shmid_ds {
 #define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
 #define	SHM_REMAP	040000	/* take-over region on attach */
 #define	SHM_EXEC	0100000	/* execution access */
+#define	SHM_SHAREDCTX	0200000	/* share context (TLB entries) if possible */
 
 /* super user shmctl commands */
 #define SHM_LOCK 	11
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
