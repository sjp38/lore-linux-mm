Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 50EAB6B0269
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:50:52 -0400 (EDT)
Received: by iofh134 with SMTP id h134so237965006iof.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:50:52 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id lg2si42353578pbc.60.2015.09.16.10.50.48
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:50:48 -0700 (PDT)
Subject: [PATCH 19/26] [NEWSYSCALL] mm, multi-arch: pass a protection key in to calc_vm_flag_bits()
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:09 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174909.D46AC05A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


This plumbs a protection key through calc_vm_flag_bits().
We could of done this in calc_vm_prot_bits(), but I did not
feel super strongly which way to go.  It was pretty arbitrary
which one to use.

---

 b/arch/powerpc/include/asm/mman.h  |    5 +++--
 b/drivers/char/agp/frontend.c      |    2 +-
 b/drivers/staging/android/ashmem.c |    7 ++++---
 b/include/linux/mman.h             |    6 +++---
 b/mm/mmap.c                        |    2 +-
 b/mm/mprotect.c                    |    2 +-
 b/mm/nommu.c                       |    2 +-
 7 files changed, 14 insertions(+), 12 deletions(-)

diff -puN arch/powerpc/include/asm/mman.h~pkeys-84-calc_vm_prot_bits arch/powerpc/include/asm/mman.h
--- a/arch/powerpc/include/asm/mman.h~pkeys-84-calc_vm_prot_bits	2015-09-16 10:48:19.704348642 -0700
+++ b/arch/powerpc/include/asm/mman.h	2015-09-16 10:48:19.717349232 -0700
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
diff -puN drivers/char/agp/frontend.c~pkeys-84-calc_vm_prot_bits drivers/char/agp/frontend.c
--- a/drivers/char/agp/frontend.c~pkeys-84-calc_vm_prot_bits	2015-09-16 10:48:19.706348733 -0700
+++ b/drivers/char/agp/frontend.c	2015-09-16 10:48:19.718349277 -0700
@@ -156,7 +156,7 @@ static pgprot_t agp_convert_mmap_flags(i
 {
 	unsigned long prot_bits;
 
-	prot_bits = calc_vm_prot_bits(prot) | VM_SHARED;
+	prot_bits = calc_vm_prot_bits(prot, 0) | VM_SHARED;
 	return vm_get_page_prot(prot_bits);
 }
 
diff -puN drivers/staging/android/ashmem.c~pkeys-84-calc_vm_prot_bits drivers/staging/android/ashmem.c
--- a/drivers/staging/android/ashmem.c~pkeys-84-calc_vm_prot_bits	2015-09-16 10:48:19.707348778 -0700
+++ b/drivers/staging/android/ashmem.c	2015-09-16 10:48:19.718349277 -0700
@@ -351,7 +351,8 @@ out:
 	return ret;
 }
 
-static inline vm_flags_t calc_vm_may_flags(unsigned long prot)
+static inline vm_flags_t calc_vm_may_flags(unsigned long prot,
+		unsigned long pkey)
 {
 	return _calc_vm_trans(prot, PROT_READ,  VM_MAYREAD) |
 	       _calc_vm_trans(prot, PROT_WRITE, VM_MAYWRITE) |
@@ -372,8 +373,8 @@ static int ashmem_mmap(struct file *file
 	}
 
 	/* requested protection bits must match our allowed protection mask */
-	if (unlikely((vma->vm_flags & ~calc_vm_prot_bits(asma->prot_mask)) &
-		     calc_vm_prot_bits(PROT_MASK))) {
+	if (unlikely((vma->vm_flags & ~calc_vm_prot_bits(asma->prot_mask, 0)) &
+		     calc_vm_prot_bits(PROT_MASK, 0))) {
 		ret = -EPERM;
 		goto out;
 	}
diff -puN include/linux/mman.h~pkeys-84-calc_vm_prot_bits include/linux/mman.h
--- a/include/linux/mman.h~pkeys-84-calc_vm_prot_bits	2015-09-16 10:48:19.709348869 -0700
+++ b/include/linux/mman.h	2015-09-16 10:48:19.719349322 -0700
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
diff -puN mm/mmap.c~pkeys-84-calc_vm_prot_bits mm/mmap.c
--- a/mm/mmap.c~pkeys-84-calc_vm_prot_bits	2015-09-16 10:48:19.711348959 -0700
+++ b/mm/mmap.c	2015-09-16 10:48:19.720349367 -0700
@@ -1311,7 +1311,7 @@ unsigned long do_mmap(struct file *file,
 	 * to. we assume access permissions have been handled by the open
 	 * of the memory object, so we don't do any here.
 	 */
-	vm_flags |= calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
+	vm_flags |= calc_vm_prot_bits(prot, 0) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
 	if (flags & MAP_LOCKED)
diff -puN mm/mprotect.c~pkeys-84-calc_vm_prot_bits mm/mprotect.c
--- a/mm/mprotect.c~pkeys-84-calc_vm_prot_bits	2015-09-16 10:48:19.712349005 -0700
+++ b/mm/mprotect.c	2015-09-16 10:48:19.720349367 -0700
@@ -373,7 +373,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 	if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
 		prot |= PROT_EXEC;
 
-	vm_flags = calc_vm_prot_bits(prot);
+	vm_flags = calc_vm_prot_bits(prot, 0);
 
 	down_write(&current->mm->mmap_sem);
 
diff -puN mm/nommu.c~pkeys-84-calc_vm_prot_bits mm/nommu.c
--- a/mm/nommu.c~pkeys-84-calc_vm_prot_bits	2015-09-16 10:48:19.714349096 -0700
+++ b/mm/nommu.c	2015-09-16 10:48:19.721349413 -0700
@@ -1084,7 +1084,7 @@ static unsigned long determine_vm_flags(
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
