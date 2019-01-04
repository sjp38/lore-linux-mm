Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB9C68E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:49:52 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id g7so27599900plp.10
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 09:49:52 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k18si13717865pfd.241.2019.01.04.09.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 09:49:51 -0800 (PST)
From: Dave Hansen <dave.hansen@linux.intel.com>
Subject: [PATCH 3/5] mm: remove MPX hooks from generic code
Date: Fri,  4 Jan 2019 09:49:41 -0800
Message-Id: <1546624183-26543-4-git-send-email-dave.hansen@linux.intel.com>
In-Reply-To: <1546624183-26543-1-git-send-email-dave.hansen@linux.intel.com>
References: <1546624183-26543-1-git-send-email-dave.hansen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>

MPX is being removed from the kernel due to a lack of support
in the toolchain going forward (gcc).

There are two hooks into the generic mm code that MPX uses: one
for ~munmap() and the other at execve() time.  Remove them,
eliminating MPX from generic mm code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 arch/x86/include/asm/mmu_context.h | 31 -------------------------------
 fs/exec.c                          |  1 -
 include/asm-generic/mm_hooks.h     | 11 -----------
 mm/mmap.c                          |  6 ------
 4 files changed, 49 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 0ca5061..61363e7 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -12,7 +12,6 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
-#include <asm/mpx.h>
 
 extern atomic64_t last_mm_ctx_id;
 
@@ -253,36 +252,6 @@ static inline bool is_64bit_mm(struct mm_struct *mm)
 }
 #endif
 
-static inline void arch_bprm_mm_init(struct mm_struct *mm,
-		struct vm_area_struct *vma)
-{
-	mpx_mm_init(mm);
-}
-
-static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
-			      unsigned long start, unsigned long end)
-{
-	/*
-	 * mpx_notify_unmap() goes and reads a rarely-hot
-	 * cacheline in the mm_struct.  That can be expensive
-	 * enough to be seen in profiles.
-	 *
-	 * The mpx_notify_unmap() call and its contents have been
-	 * observed to affect munmap() performance on hardware
-	 * where MPX is not present.
-	 *
-	 * The unlikely() optimizes for the fast case: no MPX
-	 * in the CPU, or no MPX use in the process.  Even if
-	 * we get this wrong (in the unlikely event that MPX
-	 * is widely enabled on some system) the overhead of
-	 * MPX itself (reading bounds tables) is expected to
-	 * overwhelm the overhead of getting this unlikely()
-	 * consistently wrong.
-	 */
-	if (unlikely(cpu_feature_enabled(X86_FEATURE_MPX)))
-		mpx_notify_unmap(mm, vma, start, end);
-}
-
 /*
  * We only want to enforce protection keys on the current process
  * because we effectively have no access to PKRU for other
diff --git a/fs/exec.c b/fs/exec.c
index fc281b7..cb99ea5 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -317,7 +317,6 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 		goto err;
 
 	mm->stack_vm = mm->total_vm = 1;
-	arch_bprm_mm_init(mm, vma);
 	up_write(&mm->mmap_sem);
 	bprm->p = vma->vm_end - sizeof(void *);
 	return 0;
diff --git a/include/asm-generic/mm_hooks.h b/include/asm-generic/mm_hooks.h
index 8ac4e68..40038d0 100644
--- a/include/asm-generic/mm_hooks.h
+++ b/include/asm-generic/mm_hooks.h
@@ -17,17 +17,6 @@ static inline void arch_exit_mmap(struct mm_struct *mm)
 {
 }
 
-static inline void arch_unmap(struct mm_struct *mm,
-			struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
-{
-}
-
-static inline void arch_bprm_mm_init(struct mm_struct *mm,
-				     struct vm_area_struct *vma)
-{
-}
-
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 		bool write, bool execute, bool foreign)
 {
diff --git a/mm/mmap.c b/mm/mmap.c
index f901065..ca9f43c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2813,12 +2813,6 @@ int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	/* Detach vmas from rbtree */
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
 
-	/*
-	 * mpx unmap needs to be called with mmap_sem held for write.
-	 * It is safe to call it before unmap_region().
-	 */
-	arch_unmap(mm, vma, start, end);
-
 	if (downgrade)
 		downgrade_write(&mm->mmap_sem);
 
-- 
2.7.4
