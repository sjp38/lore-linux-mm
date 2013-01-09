Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 81C6D6B007D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 20:28:41 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id bg2so680963pad.32
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 17:28:40 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 8/8] mm: remove free_area_cache
Date: Tue,  8 Jan 2013 17:28:15 -0800
Message-Id: <1357694895-520-9-git-send-email-walken@google.com>
In-Reply-To: <1357694895-520-1-git-send-email-walken@google.com>
References: <1357694895-520-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

Since all architectures have been converted to use vm_unmapped_area(),
there is no remaining use for the free_area_cache.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 arch/arm/mm/mmap.c               |    2 --
 arch/arm64/mm/mmap.c             |    2 --
 arch/mips/mm/mmap.c              |    2 --
 arch/powerpc/mm/mmap_64.c        |    2 --
 arch/s390/mm/mmap.c              |    4 ----
 arch/sparc/kernel/sys_sparc_64.c |    2 --
 arch/tile/mm/mmap.c              |    2 --
 arch/x86/ia32/ia32_aout.c        |    2 --
 arch/x86/mm/mmap.c               |    2 --
 fs/binfmt_aout.c                 |    2 --
 fs/binfmt_elf.c                  |    2 --
 include/linux/mm_types.h         |    3 ---
 include/linux/sched.h            |    2 --
 kernel/fork.c                    |    4 ----
 mm/mmap.c                        |   28 ----------------------------
 mm/nommu.c                       |    4 ----
 mm/util.c                        |    1 -
 17 files changed, 0 insertions(+), 66 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index 10062ceadd1c..0c6356255fe3 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -181,11 +181,9 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (mmap_is_legacy()) {
 		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
 		mm->get_unmapped_area = arch_get_unmapped_area;
-		mm->unmap_area = arch_unmap_area;
 	} else {
 		mm->mmap_base = mmap_base(random_factor);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
 
diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index 7c7be7855638..8ed6cb1a900f 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -90,11 +90,9 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (mmap_is_legacy()) {
 		mm->mmap_base = TASK_UNMAPPED_BASE;
 		mm->get_unmapped_area = arch_get_unmapped_area;
-		mm->unmap_area = arch_unmap_area;
 	} else {
 		mm->mmap_base = mmap_base();
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
 EXPORT_SYMBOL_GPL(arch_pick_mmap_layout);
diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index d9be7540a6be..f4e63c29d044 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -158,11 +158,9 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (mmap_is_legacy()) {
 		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
 		mm->get_unmapped_area = arch_get_unmapped_area;
-		mm->unmap_area = arch_unmap_area;
 	} else {
 		mm->mmap_base = mmap_base(random_factor);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
 
diff --git a/arch/powerpc/mm/mmap_64.c b/arch/powerpc/mm/mmap_64.c
index 67a42ed0d2fc..cb8bdbe4972f 100644
--- a/arch/powerpc/mm/mmap_64.c
+++ b/arch/powerpc/mm/mmap_64.c
@@ -92,10 +92,8 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (mmap_is_legacy()) {
 		mm->mmap_base = TASK_UNMAPPED_BASE;
 		mm->get_unmapped_area = arch_get_unmapped_area;
-		mm->unmap_area = arch_unmap_area;
 	} else {
 		mm->mmap_base = mmap_base();
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
diff --git a/arch/s390/mm/mmap.c b/arch/s390/mm/mmap.c
index c59a5efa58b1..f2a462625c9e 100644
--- a/arch/s390/mm/mmap.c
+++ b/arch/s390/mm/mmap.c
@@ -91,11 +91,9 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (mmap_is_legacy()) {
 		mm->mmap_base = TASK_UNMAPPED_BASE;
 		mm->get_unmapped_area = arch_get_unmapped_area;
-		mm->unmap_area = arch_unmap_area;
 	} else {
 		mm->mmap_base = mmap_base();
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
 
@@ -173,11 +171,9 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (mmap_is_legacy()) {
 		mm->mmap_base = TASK_UNMAPPED_BASE;
 		mm->get_unmapped_area = s390_get_unmapped_area;
-		mm->unmap_area = arch_unmap_area;
 	} else {
 		mm->mmap_base = mmap_base();
 		mm->get_unmapped_area = s390_get_unmapped_area_topdown;
-		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
 
diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index 708bc29d36a8..f3c169f9d3a1 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -290,7 +290,6 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	    sysctl_legacy_va_layout) {
 		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
 		mm->get_unmapped_area = arch_get_unmapped_area;
-		mm->unmap_area = arch_unmap_area;
 	} else {
 		/* We know it's 32-bit */
 		unsigned long task_size = STACK_TOP32;
@@ -302,7 +301,6 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 
 		mm->mmap_base = PAGE_ALIGN(task_size - gap - random_factor);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
 
diff --git a/arch/tile/mm/mmap.c b/arch/tile/mm/mmap.c
index f96f4cec602a..d67d91ebf63e 100644
--- a/arch/tile/mm/mmap.c
+++ b/arch/tile/mm/mmap.c
@@ -66,10 +66,8 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (!is_32bit || rlimit(RLIMIT_STACK) == RLIM_INFINITY) {
 		mm->mmap_base = TASK_UNMAPPED_BASE;
 		mm->get_unmapped_area = arch_get_unmapped_area;
-		mm->unmap_area = arch_unmap_area;
 	} else {
 		mm->mmap_base = mmap_base(mm);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index a703af19c281..3b3558577642 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -309,8 +309,6 @@ static int load_aout_binary(struct linux_binprm *bprm)
 		(current->mm->start_data = N_DATADDR(ex));
 	current->mm->brk = ex.a_bss +
 		(current->mm->start_brk = N_BSSADDR(ex));
-	current->mm->free_area_cache = TASK_UNMAPPED_BASE;
-	current->mm->cached_hole_size = 0;
 
 	retval = setup_arg_pages(bprm, IA32_STACK_TOP, EXSTACK_DEFAULT);
 	if (retval < 0) {
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 845df6835f9f..62c29a5bfe26 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -115,10 +115,8 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	if (mmap_is_legacy()) {
 		mm->mmap_base = mmap_legacy_base();
 		mm->get_unmapped_area = arch_get_unmapped_area;
-		mm->unmap_area = arch_unmap_area;
 	} else {
 		mm->mmap_base = mmap_base();
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index 6043567b95c2..692e75ca6415 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -256,8 +256,6 @@ static int load_aout_binary(struct linux_binprm * bprm)
 		(current->mm->start_data = N_DATADDR(ex));
 	current->mm->brk = ex.a_bss +
 		(current->mm->start_brk = N_BSSADDR(ex));
-	current->mm->free_area_cache = current->mm->mmap_base;
-	current->mm->cached_hole_size = 0;
 
 	retval = setup_arg_pages(bprm, STACK_TOP, EXSTACK_DEFAULT);
 	if (retval < 0) {
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 0c42cdbabecf..e2087dea9c1e 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -730,8 +730,6 @@ static int load_elf_binary(struct linux_binprm *bprm)
 
 	/* Do this so that we can load the interpreter, if need be.  We will
 	   change some of these later */
-	current->mm->free_area_cache = current->mm->mmap_base;
-	current->mm->cached_hole_size = 0;
 	retval = setup_arg_pages(bprm, randomize_stack_top(STACK_TOP),
 				 executable_stack);
 	if (retval < 0) {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f8f5162a3571..e50eb047ea8a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -329,12 +329,9 @@ struct mm_struct {
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
 				unsigned long pgoff, unsigned long flags);
-	void (*unmap_area) (struct mm_struct *mm, unsigned long addr);
 #endif
 	unsigned long mmap_base;		/* base of mmap area */
 	unsigned long task_size;		/* size of task vm space */
-	unsigned long cached_hole_size; 	/* if non-zero, the largest hole below free_area_cache */
-	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
 	unsigned long highest_vm_end;		/* highest vma end address */
 	pgd_t * pgd;
 	atomic_t mm_users;			/* How many users with user space? */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 206bb089c06b..fa7e0a60ebe9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -366,8 +366,6 @@ extern unsigned long
 arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 			  unsigned long len, unsigned long pgoff,
 			  unsigned long flags);
-extern void arch_unmap_area(struct mm_struct *, unsigned long);
-extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
 #else
 static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index a31b823b3c2d..bdf61755ef4a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -364,8 +364,6 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
-	mm->free_area_cache = oldmm->mmap_base;
-	mm->cached_hole_size = ~0UL;
 	mm->map_count = 0;
 	cpumask_clear(mm_cpumask(mm));
 	mm->mm_rb = RB_ROOT;
@@ -539,8 +537,6 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm->nr_ptes = 0;
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
-	mm->free_area_cache = TASK_UNMAPPED_BASE;
-	mm->cached_hole_size = ~0UL;
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index f54b235f29a9..532f447879d4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1800,15 +1800,6 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 }
 #endif	
 
-void arch_unmap_area(struct mm_struct *mm, unsigned long addr)
-{
-	/*
-	 * Is this a new hole at the lowest possible address?
-	 */
-	if (addr >= TASK_UNMAPPED_BASE && addr < mm->free_area_cache)
-		mm->free_area_cache = addr;
-}
-
 /*
  * This mmap-allocator allocates new areas top-down from below the
  * stack's low limit (the base):
@@ -1865,19 +1856,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 }
 #endif
 
-void arch_unmap_area_topdown(struct mm_struct *mm, unsigned long addr)
-{
-	/*
-	 * Is this a new hole at the highest possible address?
-	 */
-	if (addr > mm->free_area_cache)
-		mm->free_area_cache = addr;
-
-	/* dont allow allocations above current base */
-	if (mm->free_area_cache > mm->mmap_base)
-		mm->free_area_cache = mm->mmap_base;
-}
-
 unsigned long
 get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
@@ -2276,7 +2254,6 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct vm_area_struct **insertion_point;
 	struct vm_area_struct *tail_vma = NULL;
-	unsigned long addr;
 
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	vma->vm_prev = NULL;
@@ -2293,11 +2270,6 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else
 		mm->highest_vm_end = prev ? prev->vm_end : 0;
 	tail_vma->vm_next = NULL;
-	if (mm->unmap_area == arch_unmap_area)
-		addr = prev ? prev->vm_end : mm->mmap_base;
-	else
-		addr = vma ?  vma->vm_start : mm->mmap_base;
-	mm->unmap_area(mm, addr);
 	mm->mmap_cache = NULL;		/* Kill the cache. */
 }
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 79c3cac87afa..b5535ff2f9d1 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1852,10 +1852,6 @@ unsigned long arch_get_unmapped_area(struct file *file, unsigned long addr,
 	return -ENOMEM;
 }
 
-void arch_unmap_area(struct mm_struct *mm, unsigned long addr)
-{
-}
-
 void unmap_mapping_range(struct address_space *mapping,
 			 loff_t const holebegin, loff_t const holelen,
 			 int even_cows)
diff --git a/mm/util.c b/mm/util.c
index c55e26b17d93..4c19aa6a1b43 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -293,7 +293,6 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 {
 	mm->mmap_base = TASK_UNMAPPED_BASE;
 	mm->get_unmapped_area = arch_get_unmapped_area;
-	mm->unmap_area = arch_unmap_area;
 }
 #endif
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
