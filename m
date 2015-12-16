Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 797A16B02E2
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 19:17:11 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so37921859pfb.0
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 16:17:11 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id w79si12139788pfa.124.2015.12.24.16.17.10
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 16:17:10 -0800 (PST)
Message-Id: <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
In-Reply-To: <20151224214632.GF4128@pd.tnic>
From: Tony Luck <tony.luck@intel.com>
Date: Tue, 15 Dec 2015 17:30:49 -0800
Subject: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover from
 machine checks
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

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
2) We 'or' BIT(63) into the return if the copy failed because of
   a machine check. If we failed during a copy from user space
   because the user provided a bad address, then we just return
   then number of bytes not copied like other copy_from_user
   functions.
3) This code doesn't play any cache games. Future functions can
   use non-temporal loads/stores to meet needs of different callers.
4) Provide helpful macros to decode the return value.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
Boris: This version has all the return options coded.
	return 0; /* SUCCESS */
	return remain_bytes | (1ul << 63); /* failed because of machine check */
	return remain_bytes; /* failed because of invalid source address */

 arch/x86/include/asm/string_64.h |   8 ++
 arch/x86/kernel/x8664_ksyms_64.c |   4 +
 arch/x86/lib/memcpy_64.S         | 202 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 214 insertions(+)

diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
index ff8b9a17dc4b..4359ebb86b86 100644
--- a/arch/x86/include/asm/string_64.h
+++ b/arch/x86/include/asm/string_64.h
@@ -78,6 +78,14 @@ int strcmp(const char *cs, const char *ct);
 #define memset(s, c, n) __memset(s, c, n)
 #endif
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+u64 __mcsafe_copy(void *dst, const void __user *src, unsigned size);
+
+#define	COPY_MCHECK_ERRBIT	BIT(63)
+#define COPY_HAD_MCHECK(ret)	((ret) & COPY_MCHECK_ERRBIT)
+#define COPY_MCHECK_REMAIN(ret)	((ret) & ~COPY_MCHECK_ERRBIT)
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_X86_STRING_64_H */
diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
index a0695be19864..3d42d0ef3333 100644
--- a/arch/x86/kernel/x8664_ksyms_64.c
+++ b/arch/x86/kernel/x8664_ksyms_64.c
@@ -37,6 +37,10 @@ EXPORT_SYMBOL(__copy_user_nocache);
 EXPORT_SYMBOL(_copy_from_user);
 EXPORT_SYMBOL(_copy_to_user);
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+EXPORT_SYMBOL(__mcsafe_copy);
+#endif
+
 EXPORT_SYMBOL(copy_page);
 EXPORT_SYMBOL(clear_page);
 
diff --git a/arch/x86/lib/memcpy_64.S b/arch/x86/lib/memcpy_64.S
index 16698bba87de..23aac781ce59 100644
--- a/arch/x86/lib/memcpy_64.S
+++ b/arch/x86/lib/memcpy_64.S
@@ -177,3 +177,205 @@ ENTRY(memcpy_orig)
 .Lend:
 	retq
 ENDPROC(memcpy_orig)
+
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+/*
+ * __mcsafe_copy - memory copy with machine check exception handling
+ * Note that we only catch machine checks when reading the source addresses.
+ * Writes to target are posted and don't generate machine checks.
+ */
+ENTRY(__mcsafe_copy)
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
+	/* copy successful. return 0 */
+	ret
+
+	.section .fixup,"ax"
+	/* fixups for machine check */
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
+	mov %ecx,%edx
+100:
+	sfence
+	/*
+	 * copy failed because of machine check on source address
+	 * return value is number of bytes NOT copied plus we set
+	 * bit 63 to distinguish this from the page fault case below.
+	 */
+	mov %edx,%eax
+	bts $63,%rax
+	ret
+
+	/* fixups for page fault */
+130:
+	addl %ecx,%edx
+	jmp 200f
+131:
+	shll $6,%ecx
+	addl %ecx,%edx
+	jmp 200f
+132:
+	shll $6,%ecx
+	leal -8(%ecx,%edx),%edx
+	jmp 200f
+133:
+	shll $6,%ecx
+	leal -16(%ecx,%edx),%edx
+	jmp 200f
+134:
+	shll $6,%ecx
+	leal -24(%ecx,%edx),%edx
+	jmp 200f
+135:
+	shll $6,%ecx
+	leal -32(%ecx,%edx),%edx
+	jmp 200f
+136:
+	shll $6,%ecx
+	leal -40(%ecx,%edx),%edx
+	jmp 200f
+137:
+	shll $6,%ecx
+	leal -48(%ecx,%edx),%edx
+	jmp 200f
+138:
+	shll $6,%ecx
+	leal -56(%ecx,%edx),%edx
+	jmp 200f
+139:
+	lea (%rdx,%rcx,8),%rdx
+	jmp 200f
+140:
+	mov %ecx,%edx
+200:
+	sfence
+	/*
+	 * copy failed because of page fault on source address
+	 * return value is number of bytes NOT copied.
+	 */
+	mov %edx,%eax
+	ret
+	.previous
+
+	_ASM_EXTABLE(0b,130b)
+	_ASM_EXTABLE(1b,131b)
+	_ASM_EXTABLE(2b,132b)
+	_ASM_EXTABLE(3b,133b)
+	_ASM_EXTABLE(4b,134b)
+	_ASM_EXTABLE(9b,135b)
+	_ASM_EXTABLE(10b,136b)
+	_ASM_EXTABLE(11b,137b)
+	_ASM_EXTABLE(12b,138b)
+	_ASM_EXTABLE(18b,139b)
+	_ASM_EXTABLE(21b,140b)
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
+ENDPROC(__mcsafe_copy)
+#endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
