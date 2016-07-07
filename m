Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 72B7D6B025F
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 08:47:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 143so33623014pfx.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 05:47:27 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id vo6si4037710pab.224.2016.07.07.05.47.24
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 05:47:24 -0700 (PDT)
Subject: [PATCH 3/9] x86, pkeys: make mprotect_key() mask off additional vm_flags
From: Dave Hansen <dave@sr71.net>
Date: Thu, 07 Jul 2016 05:47:23 -0700
References: <20160707124719.3F04C882@viggo.jf.intel.com>
In-Reply-To: <20160707124719.3F04C882@viggo.jf.intel.com>
Message-Id: <20160707124723.90B7635A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, arnd@arndb.de, mgorman@techsingularity.net, hughd@google.com, viro@zeniv.linux.org.uk


From: Dave Hansen <dave.hansen@linux.intel.com>

Today, mprotect() takes 4 bits of data: PROT_READ/WRITE/EXEC/NONE.
Three of those bits: READ/WRITE/EXEC get translated directly in to
vma->vm_flags by calc_vm_prot_bits().  If a bit is unset in
mprotect()'s 'prot' argument then it must be cleared in vma->vm_flags
during the mprotect() call.

We do this clearing today by first calculating the VMA flags we
want set, then clearing the ones we do not want to inherit from
the original VMA:

	vm_flags = calc_vm_prot_bits(prot, key);
	...
	newflags = vm_flags;
	newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));

However, we *also* want to mask off the original VMA's vm_flags in
which we store the protection key.

To do that, this patch adds a new macro:

	ARCH_VM_PKEY_FLAGS

which allows the architecture to specify additional bits that it would
like cleared.  We use that to ensure that the VM_PKEY_BIT* bits get
cleared.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: mgorman@techsingularity.net
Cc: hughd@google.com
Cc: viro@zeniv.linux.org.uk
---

 b/arch/x86/include/asm/pkeys.h |    2 ++
 b/include/linux/pkeys.h        |    1 +
 b/mm/mprotect.c                |   11 ++++++++++-
 3 files changed, 13 insertions(+), 1 deletion(-)

diff -puN arch/x86/include/asm/pkeys.h~pkeys-112-mask-off-correct-vm_flags arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-112-mask-off-correct-vm_flags	2016-07-07 05:47:00.500788624 -0700
+++ b/arch/x86/include/asm/pkeys.h	2016-07-07 05:47:00.507788941 -0700
@@ -38,4 +38,6 @@ static inline int arch_override_mprotect
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
 
+#define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
+
 #endif /*_ASM_X86_PKEYS_H */
diff -puN include/linux/pkeys.h~pkeys-112-mask-off-correct-vm_flags include/linux/pkeys.h
--- a/include/linux/pkeys.h~pkeys-112-mask-off-correct-vm_flags	2016-07-07 05:47:00.501788669 -0700
+++ b/include/linux/pkeys.h	2016-07-07 05:47:00.508788987 -0700
@@ -16,6 +16,7 @@
 #define execute_only_pkey(mm) (0)
 #define arch_override_mprotect_pkey(vma, prot, pkey) (0)
 #define PKEY_DEDICATED_EXECUTE_ONLY 0
+#define ARCH_VM_PKEY_FLAGS 0
 #endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 /*
diff -puN mm/mprotect.c~pkeys-112-mask-off-correct-vm_flags mm/mprotect.c
--- a/mm/mprotect.c~pkeys-112-mask-off-correct-vm_flags	2016-07-07 05:47:00.503788760 -0700
+++ b/mm/mprotect.c	2016-07-07 05:47:00.509789032 -0700
@@ -411,6 +411,7 @@ static int do_mprotect_pkey(unsigned lon
 		prev = vma;
 
 	for (nstart = start ; ; ) {
+		unsigned long mask_off_old_flags;
 		unsigned long newflags;
 		int new_vma_pkey;
 
@@ -420,9 +421,17 @@ static int do_mprotect_pkey(unsigned lon
 		if (rier && (vma->vm_flags & VM_MAYEXEC))
 			prot |= PROT_EXEC;
 
+		/*
+		 * Each mprotect() call explicitly passes r/w/x permissions.
+		 * If a permission is not passed to mprotect(), it must be
+		 * cleared from the VMA.
+		 */
+		mask_off_old_flags = VM_READ | VM_WRITE | VM_EXEC |
+					ARCH_VM_PKEY_FLAGS;
+
 		new_vma_pkey = arch_override_mprotect_pkey(vma, prot, pkey);
 		newflags = calc_vm_prot_bits(prot, new_vma_pkey);
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
