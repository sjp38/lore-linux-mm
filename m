Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B5D8C6B0255
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:55:00 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so219650082pac.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:55:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yc7si42254618pab.182.2015.09.16.10.49.12
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:13 -0700 (PDT)
Subject: [PATCH 24/26] [HIJACKPROT] x86, pkeys: mask off pkeys bits in mprotect()
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:12 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174912.18B301D4@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


This is a quick hack that puts very x86-specific bits in to
mprotect.c.  I will fix this up properly if we decide to go
forward with the PROT_* scheme for the user ABI for setting up
protection keys.

---

 b/arch/x86/include/uapi/asm/mman.h |    9 +++++----
 b/mm/mprotect.c                    |   13 ++++++++++++-
 2 files changed, 17 insertions(+), 5 deletions(-)

diff -puN arch/x86/include/uapi/asm/mman.h~pkeys-82-mprotect-flag-copy arch/x86/include/uapi/asm/mman.h
--- a/arch/x86/include/uapi/asm/mman.h~pkeys-82-mprotect-flag-copy	2015-09-16 09:45:54.977451221 -0700
+++ b/arch/x86/include/uapi/asm/mman.h	2015-09-16 09:45:54.982451448 -0700
@@ -24,10 +24,11 @@
 		((vm_flags) & VM_PKEY_BIT3 ? _PAGE_PKEY_BIT3 : 0))
 
 #define arch_calc_vm_prot_bits(prot) (	\
-		((prot) & PROT_PKEY0 ? VM_PKEY_BIT0 : 0) |	\
-		((prot) & PROT_PKEY1 ? VM_PKEY_BIT1 : 0) |	\
-		((prot) & PROT_PKEY2 ? VM_PKEY_BIT2 : 0) |	\
-		((prot) & PROT_PKEY3 ? VM_PKEY_BIT3 : 0))
+		(!boot_cpu_has(X86_FEATURE_OSPKE) ? 0 :			\
+			((prot) & PROT_PKEY0 ? VM_PKEY_BIT0 : 0) |	\
+			((prot) & PROT_PKEY1 ? VM_PKEY_BIT1 : 0) |	\
+			((prot) & PROT_PKEY2 ? VM_PKEY_BIT2 : 0) |	\
+			((prot) & PROT_PKEY3 ? VM_PKEY_BIT3 : 0)))
 
 #ifndef arch_validate_prot
 /*
diff -puN mm/mprotect.c~pkeys-82-mprotect-flag-copy mm/mprotect.c
--- a/mm/mprotect.c~pkeys-82-mprotect-flag-copy	2015-09-16 09:45:54.978451266 -0700
+++ b/mm/mprotect.c	2015-09-16 09:45:54.982451448 -0700
@@ -344,6 +344,15 @@ fail:
 	return error;
 }
 
+static unsigned long vm_flags_unaffected_by_mprotect(unsigned long vm_flags)
+{
+	unsigned long mask_off = VM_READ | VM_WRITE | VM_EXEC;
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	mask_off |= VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3;
+#endif
+	return vm_flags & ~mask_off;
+}
+
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
@@ -407,8 +416,10 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 
 		/* Here we know that vma->vm_start <= nstart < vma->vm_end. */
 
+		/* Set the vm_flags from the PROT_* bits passed to mprotect */
 		newflags = vm_flags;
-		newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
+		/* Copy over all other VMA flags unaffected by mprotect */
+		newflags |= vm_flags_unaffected_by_mprotect(vma->vm_flags);
 
 		/* newflags >> 4 shift VM_MAY% in place of VM_% */
 		if ((newflags & ~(newflags >> 4)) & (VM_READ | VM_WRITE | VM_EXEC)) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
