Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 41B576B025A
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:32:40 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so69913336pac.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:32:40 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id t67si2918676pfa.123.2015.12.11.11.32.39
        for <linux-mm@kvack.org>;
        Fri, 11 Dec 2015 11:32:39 -0800 (PST)
Message-Id: <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
In-Reply-To: <cover.1449861203.git.tony.luck@intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Thu, 10 Dec 2015 16:21:50 -0800
Subject: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover from machine checks
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

Using __copy_user_nocache() as inspiration create a memory copy
routine for use by kernel code with annotations to allow for
recovery from machine checks.

Notes:
1) Unlike the original we make no attempt to copy all the bytes
   up to the faulting address. The original achieves that by
   re-executing the failing part as a byte-by-byte copy,
   which will take another page fault. We don't want to have
   a second machine check!
2) Likewise the return value for the original indicates exactly
   how many bytes were not copied. Instead we provide the physical
   address of the fault (thanks to help from do_machine_check()
3) Provide helpful macros to decode the return value.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/x86/include/asm/uaccess_64.h |  5 +++
 arch/x86/kernel/x8664_ksyms_64.c  |  2 +
 arch/x86/lib/copy_user_64.S       | 91 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 98 insertions(+)

diff --git a/arch/x86/include/asm/uaccess_64.h b/arch/x86/include/asm/uaccess_64.h
index f2f9b39b274a..779cb0e77ecc 100644
--- a/arch/x86/include/asm/uaccess_64.h
+++ b/arch/x86/include/asm/uaccess_64.h
@@ -216,6 +216,11 @@ __copy_to_user_inatomic(void __user *dst, const void *src, unsigned size)
 extern long __copy_user_nocache(void *dst, const void __user *src,
 				unsigned size, int zerorest);
 
+extern u64 mcsafe_memcpy(void *dst, const void __user *src,
+				unsigned size);
+#define COPY_HAD_MCHECK(ret)	((ret) & BIT(63))
+#define	COPY_MCHECK_PADDR(ret)	((ret) & ~BIT(63))
+
 static inline int
 __copy_from_user_nocache(void *dst, const void __user *src, unsigned size)
 {
diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
index a0695be19864..ec988c92c055 100644
--- a/arch/x86/kernel/x8664_ksyms_64.c
+++ b/arch/x86/kernel/x8664_ksyms_64.c
@@ -37,6 +37,8 @@ EXPORT_SYMBOL(__copy_user_nocache);
 EXPORT_SYMBOL(_copy_from_user);
 EXPORT_SYMBOL(_copy_to_user);
 
+EXPORT_SYMBOL(mcsafe_memcpy);
+
 EXPORT_SYMBOL(copy_page);
 EXPORT_SYMBOL(clear_page);
 
diff --git a/arch/x86/lib/copy_user_64.S b/arch/x86/lib/copy_user_64.S
index 982ce34f4a9b..ffce93cbc9a5 100644
--- a/arch/x86/lib/copy_user_64.S
+++ b/arch/x86/lib/copy_user_64.S
@@ -319,3 +319,94 @@ ENTRY(__copy_user_nocache)
 	_ASM_EXTABLE(21b,50b)
 	_ASM_EXTABLE(22b,50b)
 ENDPROC(__copy_user_nocache)
+
+/*
+ * mcsafe_memcpy - Uncached memory copy with machine check exception handling
+ * Note that we only catch machine checks when reading the source addresses.
+ * Writes to target are posted and don't generate machine checks.
+ * This will force destination/source out of cache for more performance.
+ */
+ENTRY(mcsafe_memcpy)
+	cmpl $8,%edx
+	jb 20f		/* less then 8 bytes, go to byte copy loop */
+
+	/* check for bad alignment of destination */
+	movl %edi,%ecx
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
+	jnz 100b
+102:
+	movl %edx,%ecx
+	andl $63,%edx
+	shrl $6,%ecx
+	jz 17f
+1:	movq (%rsi),%r8
+2:	movq 1*8(%rsi),%r9
+3:	movq 2*8(%rsi),%r10
+4:	movq 3*8(%rsi),%r11
+	movnti %r8,(%rdi)
+	movnti %r9,1*8(%rdi)
+	movnti %r10,2*8(%rdi)
+	movnti %r11,3*8(%rdi)
+9:	movq 4*8(%rsi),%r8
+10:	movq 5*8(%rsi),%r9
+11:	movq 6*8(%rsi),%r10
+12:	movq 7*8(%rsi),%r11
+	movnti %r8,4*8(%rdi)
+	movnti %r9,5*8(%rdi)
+	movnti %r10,6*8(%rdi)
+	movnti %r11,7*8(%rdi)
+	leaq 64(%rsi),%rsi
+	leaq 64(%rdi),%rdi
+	decl %ecx
+	jnz 1b
+17:	movl %edx,%ecx
+	andl $7,%edx
+	shrl $3,%ecx
+	jz 20f
+18:	movq (%rsi),%r8
+	movnti %r8,(%rdi)
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
+	sfence
+	/* do_machine_check() sets %eax return value */
+	ret
+	.previous
+
+	_ASM_MCEXTABLE(0b,30b)
+	_ASM_MCEXTABLE(1b,30b)
+	_ASM_MCEXTABLE(2b,30b)
+	_ASM_MCEXTABLE(3b,30b)
+	_ASM_MCEXTABLE(4b,30b)
+	_ASM_MCEXTABLE(9b,30b)
+	_ASM_MCEXTABLE(10b,30b)
+	_ASM_MCEXTABLE(11b,30b)
+	_ASM_MCEXTABLE(12b,30b)
+	_ASM_MCEXTABLE(18b,30b)
+	_ASM_MCEXTABLE(21b,30b)
+ENDPROC(mcsafe_memcpy)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
