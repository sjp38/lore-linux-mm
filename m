Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E3C9C6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 12:23:45 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id o64so15172922pfb.3
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 09:23:45 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id t2si6401157pfa.163.2015.12.16.09.23.44
        for <linux-mm@kvack.org>;
        Wed, 16 Dec 2015 09:23:45 -0800 (PST)
Message-Id: <d560d03663b6fd7a5bbeae9842934f329a7dcbdf.1450283985.git.tony.luck@intel.com>
In-Reply-To: <cover.1450283985.git.tony.luck@intel.com>
References: <cover.1450283985.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Tue, 15 Dec 2015 17:30:49 -0800
Subject: [PATCHV3 3/3] x86, ras: Add mcsafe_memcpy() function to recover from machine checks
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Elliott@kvack.org, "Robert (Persistent Memory)" <elliott@hpe.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

Using __copy_user_nocache() as inspiration create a memory copy
routine for use by kernel code with annotations to allow for
recovery from machine checks.

Notes:
1) We align the source address rather than the destination. This
   means we never have to deal with a memory read that spans two
   cache lines ... so we can provide a precise indication of
   where the error occurred without having to re-execute at
   a byte-by-byte level to find the exact spot like the original
   did.
2) We 'or' BIT(63) into the return because this is the first
   in a series of machine check safe functions. Some will copy
   from user addresses, so may need to indicate an invalid user
   address instead of a machine check.
3) This code doesn't play any cache games. Future functions can
   use non-temporal loads/stores to meet needs of different callers.
4) Provide helpful macros to decode the return value.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/x86/include/asm/mcsafe_copy.h |  11 +++
 arch/x86/kernel/x8664_ksyms_64.c   |   5 ++
 arch/x86/lib/Makefile              |   1 +
 arch/x86/lib/mcsafe_copy.S         | 142 +++++++++++++++++++++++++++++++++++++
 4 files changed, 159 insertions(+)
 create mode 100644 arch/x86/include/asm/mcsafe_copy.h
 create mode 100644 arch/x86/lib/mcsafe_copy.S

diff --git a/arch/x86/include/asm/mcsafe_copy.h b/arch/x86/include/asm/mcsafe_copy.h
new file mode 100644
index 000000000000..d4dbd5a667a3
--- /dev/null
+++ b/arch/x86/include/asm/mcsafe_copy.h
@@ -0,0 +1,11 @@
+#ifndef _ASM_X86_MCSAFE_COPY_H
+#define _ASM_X86_MCSAFE_COPY_H
+
+u64 mcsafe_memcpy(void *dst, const void *src, unsigned size);
+
+#define	COPY_MCHECK_ERRBIT	BIT(63)
+#define COPY_HAD_MCHECK(ret)	((ret) & COPY_MCHECK_ERRBIT)
+#define COPY_MCHECK_REMAIN(ret)	((ret) & ~COPY_MCHECK_ERRBIT)
+
+#endif /* _ASM_MCSAFE_COPY_H */
+
diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
index a0695be19864..afab8b25dbc0 100644
--- a/arch/x86/kernel/x8664_ksyms_64.c
+++ b/arch/x86/kernel/x8664_ksyms_64.c
@@ -37,6 +37,11 @@ EXPORT_SYMBOL(__copy_user_nocache);
 EXPORT_SYMBOL(_copy_from_user);
 EXPORT_SYMBOL(_copy_to_user);
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+#include <asm/mcsafe_copy.h>
+EXPORT_SYMBOL(mcsafe_memcpy);
+#endif
+
 EXPORT_SYMBOL(copy_page);
 EXPORT_SYMBOL(clear_page);
 
diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
index f2587888d987..82bb0bf46b6b 100644
--- a/arch/x86/lib/Makefile
+++ b/arch/x86/lib/Makefile
@@ -21,6 +21,7 @@ lib-y += usercopy_$(BITS).o usercopy.o getuser.o putuser.o
 lib-y += memcpy_$(BITS).o
 lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
 lib-$(CONFIG_INSTRUCTION_DECODER) += insn.o inat.o
+lib-$(CONFIG_MCE_KERNEL_RECOVERY) += mcsafe_copy.o
 
 obj-y += msr.o msr-reg.o msr-reg-export.o
 
diff --git a/arch/x86/lib/mcsafe_copy.S b/arch/x86/lib/mcsafe_copy.S
new file mode 100644
index 000000000000..059b3a9642eb
--- /dev/null
+++ b/arch/x86/lib/mcsafe_copy.S
@@ -0,0 +1,142 @@
+/*
+ * Copyright (C) 2015 Intel Corporation
+ * Author: Tony Luck
+ *
+ * This software may be redistributed and/or modified under the terms of
+ * the GNU General Public License ("GPL") version 2 only as published by the
+ * Free Software Foundation.
+ */
+
+#include <linux/linkage.h>
+#include <asm/asm.h>
+
+/*
+ * mcsafe_memcpy - memory copy with machine check exception handling
+ * Note that we only catch machine checks when reading the source addresses.
+ * Writes to target are posted and don't generate machine checks.
+ */
+ENTRY(mcsafe_memcpy)
+	cmpl $8,%edx
+	jb 20f		/* less then 8 bytes, go to byte copy loop */
+
+	/* check for bad alignment of source */
+	movl %esi,%ecx
+	andl $7,%ecx
+	jz 102f				/* already aligned */
+	subl $8,%ecx
+	negl %ecx
+	subl %ecx,%edx
+0:	movb (%rsi),%al
+	movb %al,(%rdi)
+	incq %rsi
+	incq %rdi
+	decl %ecx
+	jnz 0b
+102:
+	movl %edx,%ecx
+	andl $63,%edx
+	shrl $6,%ecx
+	jz 17f
+1:	movq (%rsi),%r8
+2:	movq 1*8(%rsi),%r9
+3:	movq 2*8(%rsi),%r10
+4:	movq 3*8(%rsi),%r11
+	mov %r8,(%rdi)
+	mov %r9,1*8(%rdi)
+	mov %r10,2*8(%rdi)
+	mov %r11,3*8(%rdi)
+9:	movq 4*8(%rsi),%r8
+10:	movq 5*8(%rsi),%r9
+11:	movq 6*8(%rsi),%r10
+12:	movq 7*8(%rsi),%r11
+	mov %r8,4*8(%rdi)
+	mov %r9,5*8(%rdi)
+	mov %r10,6*8(%rdi)
+	mov %r11,7*8(%rdi)
+	leaq 64(%rsi),%rsi
+	leaq 64(%rdi),%rdi
+	decl %ecx
+	jnz 1b
+17:	movl %edx,%ecx
+	andl $7,%edx
+	shrl $3,%ecx
+	jz 20f
+18:	movq (%rsi),%r8
+	mov %r8,(%rdi)
+	leaq 8(%rsi),%rsi
+	leaq 8(%rdi),%rdi
+	decl %ecx
+	jnz 18b
+20:	andl %edx,%edx
+	jz 23f
+	movl %edx,%ecx
+21:	movb (%rsi),%al
+	movb %al,(%rdi)
+	incq %rsi
+	incq %rdi
+	decl %ecx
+	jnz 21b
+23:	xorl %eax,%eax
+	sfence
+	ret
+
+	.section .fixup,"ax"
+30:
+	addl %ecx,%edx
+	jmp 100f
+31:
+	shll $6,%ecx
+	addl %ecx,%edx
+	jmp 100f
+32:
+	shll $6,%ecx
+	leal -8(%ecx,%edx),%edx
+	jmp 100f
+33:
+	shll $6,%ecx
+	leal -16(%ecx,%edx),%edx
+	jmp 100f
+34:
+	shll $6,%ecx
+	leal -24(%ecx,%edx),%edx
+	jmp 100f
+35:
+	shll $6,%ecx
+	leal -32(%ecx,%edx),%edx
+	jmp 100f
+36:
+	shll $6,%ecx
+	leal -40(%ecx,%edx),%edx
+	jmp 100f
+37:
+	shll $6,%ecx
+	leal -48(%ecx,%edx),%edx
+	jmp 100f
+38:
+	shll $6,%ecx
+	leal -56(%ecx,%edx),%edx
+	jmp 100f
+39:
+	lea (%rdx,%rcx,8),%rdx
+	jmp 100f
+40:
+	movl %ecx,%edx
+100:
+	sfence
+	movabsq	$0x8000000000000000, %rax
+	orq %rdx,%rax
+	ret
+	.previous
+
+	_ASM_MCEXTABLE(0b,30b)
+	_ASM_MCEXTABLE(1b,31b)
+	_ASM_MCEXTABLE(2b,32b)
+	_ASM_MCEXTABLE(3b,33b)
+	_ASM_MCEXTABLE(4b,34b)
+	_ASM_MCEXTABLE(9b,35b)
+	_ASM_MCEXTABLE(10b,36b)
+	_ASM_MCEXTABLE(11b,37b)
+	_ASM_MCEXTABLE(12b,38b)
+	_ASM_MCEXTABLE(18b,39b)
+	_ASM_MCEXTABLE(21b,40b)
+ENDPROC(mcsafe_memcpy)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
