Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 08D8E828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:46 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so44985232pab.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:46 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id os9si3522969pab.169.2016.01.29.10.17.19
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:17:19 -0800 (PST)
Subject: [PATCH 25/31] mm, multi-arch: pass a protection key in to calc_vm_flag_bits()
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:17:18 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181718.3A3D9E79@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-api@vger.kernel.org, linux-arch@vger.kernel.org


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
--- a/arch/powerpc/include/asm/mman.h~pkeys-70-calc_vm_prot_bits	2016-01-28 15:52:27.723741498 -0800
+++ b/arch/powerpc/include/asm/mman.h	2016-01-28 15:52:27.736742094 -0800
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
--- a/drivers/char/agp/frontend.c~pkeys-70-calc_vm_prot_bits	2016-01-28 15:52:27.725741589 -0800
+++ b/drivers/char/agp/frontend.c	2016-01-28 15:52:27.737742140 -0800
@@ -156,7 +156,7 @@ static pgprot_t agp_convert_mmap_flags(i
 {
 	unsigned long prot_bits;
 
-	prot_bits = calc_vm_prot_bits(prot) | VM_SHARED;
+	prot_bits = calc_vm_prot_bits(prot, 0) | VM_SHARED;
 	return vm_get_page_prot(prot_bits);
 }
 
diff -puN drivers/staging/android/ashmem.c~pkeys-70-calc_vm_prot_bits drivers/staging/android/ashmem.c
--- a/drivers/staging/android/ashmem.c~pkeys-70-calc_vm_prot_bits	2016-01-28 15:52:27.726741635 -0800
+++ b/drivers/staging/android/ashmem.c	2016-01-28 15:52:27.737742140 -0800
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
--- a/include/linux/mman.h~pkeys-70-calc_vm_prot_bits	2016-01-28 15:52:27.728741727 -0800
+++ b/include/linux/mman.h	2016-01-28 15:52:27.738742186 -0800
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
--- a/mm/mmap.c~pkeys-70-calc_vm_prot_bits	2016-01-28 15:52:27.730741819 -0800
+++ b/mm/mmap.c	2016-01-28 15:52:27.739742231 -0800
@@ -1303,7 +1303,7 @@ unsigned long do_mmap(struct file *file,
 	 * to. we assume access permissions have been handled by the open
 	 * of the memory object, so we don't do any here.
 	 */
-	vm_flags |= calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
+	vm_flags |= calc_vm_prot_bits(prot, 0) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
 	if (flags & MAP_LOCKED)
diff -puN mm/mprotect.c~pkeys-70-calc_vm_prot_bits mm/mprotect.c
--- a/mm/mprotect.c~pkeys-70-calc_vm_prot_bits	2016-01-28 15:52:27.731741865 -0800
+++ b/mm/mprotect.c	2016-01-28 15:52:27.739742231 -0800
@@ -378,7 +378,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 	if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
 		prot |= PROT_EXEC;
 
-	vm_flags = calc_vm_prot_bits(prot);
+	vm_flags = calc_vm_prot_bits(prot, 0);
 
 	down_write(&current->mm->mmap_sem);
 
diff -puN mm/nommu.c~pkeys-70-calc_vm_prot_bits mm/nommu.c
--- a/mm/nommu.c~pkeys-70-calc_vm_prot_bits	2016-01-28 15:52:27.733741956 -0800
+++ b/mm/nommu.c	2016-01-28 15:52:27.740742277 -0800
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
