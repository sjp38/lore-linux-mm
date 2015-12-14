Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id F06B86B026F
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:37 -0500 (EST)
Received: by pfnn128 with SMTP id n128so110002576pfn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id t74si18779133pfa.170.2015.12.14.11.06.24
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:24 -0800 (PST)
Subject: [PATCH 25/32] mm, multi-arch: pass a protection key in to calc_vm_flag_bits()
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:23 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190623.2A4A3AA1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-api@vger.kernel.org, linux-arch@vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This plumbs a protection key through calc_vm_flag_bits().  We
could have done this in calc_vm_prot_bits(), but I did not feel
super strongly which way to go.  It was pretty arbitrary which
one to use.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
---

 b/arch/powerpc/include/asm/mman.h  |    5 +++--
 b/drivers/char/agp/frontend.c      |    2 +-
 b/drivers/staging/android/ashmem.c |    4 ++--
 b/include/linux/mman.h             |    6 +++---
 b/mm/mmap.c                        |    2 +-
 b/mm/mprotect.c                    |    2 +-
 b/mm/nommu.c                       |    2 +-
 7 files changed, 12 insertions(+), 11 deletions(-)

diff -puN arch/powerpc/include/asm/mman.h~pkeys-70-calc_vm_prot_bits arch/powerpc/include/asm/mman.h
--- a/arch/powerpc/include/asm/mman.h~pkeys-70-calc_vm_prot_bits	2015-12-14 10:42:50.063128373 -0800
+++ b/arch/powerpc/include/asm/mman.h	2015-12-14 10:42:50.076128955 -0800
@@ -18,11 +18,12 @@
  * This file is included by linux/mman.h, so we can't use cacl_vm_prot_bits()
  * here.  How important is the optimization?
  */
-static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot)
+static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot,
+		unsigned long pkey)
 {
 	return (prot & PROT_SAO) ? VM_SAO : 0;
 }
-#define arch_calc_vm_prot_bits(prot) arch_calc_vm_prot_bits(prot)
+#define arch_calc_vm_prot_bits(prot, pkey) arch_calc_vm_prot_bits(prot, pkey)
 
 static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
 {
diff -puN drivers/char/agp/frontend.c~pkeys-70-calc_vm_prot_bits drivers/char/agp/frontend.c
--- a/drivers/char/agp/frontend.c~pkeys-70-calc_vm_prot_bits	2015-12-14 10:42:50.064128418 -0800
+++ b/drivers/char/agp/frontend.c	2015-12-14 10:42:50.076128955 -0800
@@ -156,7 +156,7 @@ static pgprot_t agp_convert_mmap_flags(i
 {
 	unsigned long prot_bits;
 
-	prot_bits = calc_vm_prot_bits(prot) | VM_SHARED;
+	prot_bits = calc_vm_prot_bits(prot, 0) | VM_SHARED;
 	return vm_get_page_prot(prot_bits);
 }
 
diff -puN drivers/staging/android/ashmem.c~pkeys-70-calc_vm_prot_bits drivers/staging/android/ashmem.c
--- a/drivers/staging/android/ashmem.c~pkeys-70-calc_vm_prot_bits	2015-12-14 10:42:50.066128507 -0800
+++ b/drivers/staging/android/ashmem.c	2015-12-14 10:42:50.077129000 -0800
@@ -372,8 +372,8 @@ static int ashmem_mmap(struct file *file
 	}
 
 	/* requested protection bits must match our allowed protection mask */
-	if (unlikely((vma->vm_flags & ~calc_vm_prot_bits(asma->prot_mask)) &
-		     calc_vm_prot_bits(PROT_MASK))) {
+	if (unlikely((vma->vm_flags & ~calc_vm_prot_bits(asma->prot_mask, 0)) &
+		     calc_vm_prot_bits(PROT_MASK, 0))) {
 		ret = -EPERM;
 		goto out;
 	}
diff -puN include/linux/mman.h~pkeys-70-calc_vm_prot_bits include/linux/mman.h
--- a/include/linux/mman.h~pkeys-70-calc_vm_prot_bits	2015-12-14 10:42:50.068128597 -0800
+++ b/include/linux/mman.h	2015-12-14 10:42:50.077129000 -0800
@@ -35,7 +35,7 @@ static inline void vm_unacct_memory(long
  */
 
 #ifndef arch_calc_vm_prot_bits
-#define arch_calc_vm_prot_bits(prot) 0
+#define arch_calc_vm_prot_bits(prot, pkey) 0
 #endif
 
 #ifndef arch_vm_get_page_prot
@@ -70,12 +70,12 @@ static inline int arch_validate_prot(uns
  * Combine the mmap "prot" argument into "vm_flags" used internally.
  */
 static inline unsigned long
-calc_vm_prot_bits(unsigned long prot)
+calc_vm_prot_bits(unsigned long prot, unsigned long pkey)
 {
 	return _calc_vm_trans(prot, PROT_READ,  VM_READ ) |
 	       _calc_vm_trans(prot, PROT_WRITE, VM_WRITE) |
 	       _calc_vm_trans(prot, PROT_EXEC,  VM_EXEC) |
-	       arch_calc_vm_prot_bits(prot);
+	       arch_calc_vm_prot_bits(prot, pkey);
 }
 
 /*
diff -puN mm/mmap.c~pkeys-70-calc_vm_prot_bits mm/mmap.c
--- a/mm/mmap.c~pkeys-70-calc_vm_prot_bits	2015-12-14 10:42:50.069128642 -0800
+++ b/mm/mmap.c	2015-12-14 10:42:50.078129045 -0800
@@ -1309,7 +1309,7 @@ unsigned long do_mmap(struct file *file,
 	 * to. we assume access permissions have been handled by the open
 	 * of the memory object, so we don't do any here.
 	 */
-	vm_flags |= calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
+	vm_flags |= calc_vm_prot_bits(prot, 0) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
 	if (flags & MAP_LOCKED)
diff -puN mm/mprotect.c~pkeys-70-calc_vm_prot_bits mm/mprotect.c
--- a/mm/mprotect.c~pkeys-70-calc_vm_prot_bits	2015-12-14 10:42:50.071128731 -0800
+++ b/mm/mprotect.c	2015-12-14 10:42:50.078129045 -0800
@@ -373,7 +373,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 	if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
 		prot |= PROT_EXEC;
 
-	vm_flags = calc_vm_prot_bits(prot);
+	vm_flags = calc_vm_prot_bits(prot, 0);
 
 	down_write(&current->mm->mmap_sem);
 
diff -puN mm/nommu.c~pkeys-70-calc_vm_prot_bits mm/nommu.c
--- a/mm/nommu.c~pkeys-70-calc_vm_prot_bits	2015-12-14 10:42:50.073128821 -0800
+++ b/mm/nommu.c	2015-12-14 10:42:50.079129090 -0800
@@ -1090,7 +1090,7 @@ static unsigned long determine_vm_flags(
 {
 	unsigned long vm_flags;
 
-	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags);
+	vm_flags = calc_vm_prot_bits(prot, 0) | calc_vm_flag_bits(flags);
 	/* vm_flags |= mm->def_flags; */
 
 	if (!(capabilities & NOMMU_MAP_DIRECT)) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
