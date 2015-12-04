Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA2A82F71
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:24 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so80181760pab.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id iw2si15475147pac.46.2015.12.03.17.15.02
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:15:02 -0800 (PST)
Subject: [PATCH 27/34] x86, pkeys: make mprotect_key() mask off additional vm_flags
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:15:02 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011502.251A0E5B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Today, mprotect() takes 4 bits of data: PROT_READ/WRITE/EXEC/NONE.
Three of those bits: READ/WRITE/EXEC get translated directly in to
vma->vm_flags by calc_vm_prot_bits().  If a bit is unset in
mprotect()'s 'prot' argument then it must be cleared in vma->vm_flags
during the mprotect() call.

We do the by first calculating the VMA flags we want set, then
clearing the ones we do not want to inherit from the original VMA:

	vm_flags = calc_vm_prot_bits(prot, key);
	...
	newflags = vm_flags;
	newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));

However, we *also* want to mask off the original VMA's vm_flags in
which we store the protection key.

To do that, this patch adds a new macro:

	ARCH_VM_FLAGS_AFFECTED_BY_MPROTECT

which allows the architecture to specify additional bits that it would
like cleared.  We use that to ensure that the VM_PKEY_BIT* bits get
cleared.

This got missed in my testing because I was always going from a pkey=0
VMA to a nonzero one.  The current code works when we only set bits
but never clear them.  I've fixed this up in my testing.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/pkeys.h |    2 ++
 b/include/linux/pkeys.h        |    1 +
 b/mm/mprotect.c                |    9 ++++++++-
 3 files changed, 11 insertions(+), 1 deletion(-)

diff -puN arch/x86/include/asm/pkeys.h~pkeys-mask-off-correct-vm_flags arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-mask-off-correct-vm_flags	2015-12-03 16:21:30.666899890 -0800
+++ b/arch/x86/include/asm/pkeys.h	2015-12-03 16:21:30.672900162 -0800
@@ -5,6 +5,8 @@
 				CONFIG_NR_PROTECTION_KEYS : 1)
 #define arch_validate_pkey(pkey) (((pkey) >= 0) && ((pkey) < arch_max_pkey()))
 
+#define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
+
 #endif /*_ASM_X86_PKEYS_H */
 
 
diff -puN include/linux/pkeys.h~pkeys-mask-off-correct-vm_flags include/linux/pkeys.h
--- a/include/linux/pkeys.h~pkeys-mask-off-correct-vm_flags	2015-12-03 16:21:30.667899935 -0800
+++ b/include/linux/pkeys.h	2015-12-03 16:21:30.672900162 -0800
@@ -7,6 +7,7 @@
 #include <asm/pkeys.h>
 #include <asm/mmu_context.h>
 #else /* ! CONFIG_ARCH_HAS_PKEYS */
+#define ARCH_VM_PKEY_FLAGS 0
 
 /*
  * This is called from mprotect_pkey().
diff -puN mm/mprotect.c~pkeys-mask-off-correct-vm_flags mm/mprotect.c
--- a/mm/mprotect.c~pkeys-mask-off-correct-vm_flags	2015-12-03 16:21:30.669900026 -0800
+++ b/mm/mprotect.c	2015-12-03 16:21:30.673900208 -0800
@@ -406,6 +406,13 @@ static int do_mprotect_pkey(unsigned lon
 
 	for (nstart = start ; ; ) {
 		unsigned long newflags;
+		/*
+		 * Each mprotect() call explicitly passes r/w/x permissions.
+		 * If a permission is not passed to mprotect(), it must be
+		 * cleared from the VMA.
+		 */
+		unsigned long mask_off_old_flags = VM_READ | VM_WRITE | VM_EXEC;
+		mask_off_old_flags |= ARCH_VM_PKEY_FLAGS;
 
 		/* Here we know that vma->vm_start <= nstart < vma->vm_end. */
 
@@ -417,7 +424,7 @@ static int do_mprotect_pkey(unsigned lon
 			newflags = calc_vm_prot_bits(prot, vma_pkey(vma));
 		else
 			newflags = calc_vm_prot_bits(prot, pkey);
-		newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
+		newflags |= (vma->vm_flags & ~mask_off_old_flags);
 
 		/* newflags >> 4 shift VM_MAY% in place of VM_% */
 		if ((newflags & ~(newflags >> 4)) & (VM_READ | VM_WRITE | VM_EXEC)) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
