Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6EF6B0255
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 18:27:24 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id yy13so2130865pab.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 15:27:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id f62si4713494pff.83.2016.02.02.15.27.20
        for <linux-mm@kvack.org>;
        Tue, 02 Feb 2016 15:27:20 -0800 (PST)
Message-Id: <60a2882d50eac8d2760ce58213053f633b30ae0d.1454455138.git.tony.luck@intel.com>
In-Reply-To: <cover.1454455138.git.tony.luck@intel.com>
References: <cover.1454455138.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Fri, 8 Jan 2016 13:18:03 -0800
Subject: [PATCH v9 3/4] x86, mce: Add __mcsafe_copy()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

Make use of the EXTABLE_FAULT exception table entries. This routine
returns a structure to indicate the result of the copy:

struct mcsafe_ret {
        u64 trapnr;
        u64 remain;
};

If the copy is successful, then both 'trapnr' and 'remain' are zero.

If we faulted during the copy, then 'trapnr' will say which type
of trap (X86_TRAP_PF or X86_TRAP_MC) and 'remain' says how many
bytes were not copied.

Note that this is probably the first of several copy functions.
We can make new ones for non-temporal cache handling etc.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/x86/include/asm/string_64.h |   8 +++
 arch/x86/kernel/x8664_ksyms_64.c |   2 +
 arch/x86/lib/memcpy_64.S         | 134 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 144 insertions(+)

diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
index ff8b9a17dc4b..5b24039463a4 100644
--- a/arch/x86/include/asm/string_64.h
+++ b/arch/x86/include/asm/string_64.h
@@ -78,6 +78,14 @@ int strcmp(const char *cs, const char *ct);
 #define memset(s, c, n) __memset(s, c, n)
 #endif
 
+struct mcsafe_ret {
+	u64 trapnr;
+	u64 remain;
+};
+
+struct mcsafe_ret __mcsafe_copy(void *dst, const void __user *src, size_t cnt);
+extern void __mcsafe_copy_end(void);
+
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_X86_STRING_64_H */
diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
index a0695be19864..fff245462a8c 100644
--- a/arch/x86/kernel/x8664_ksyms_64.c
+++ b/arch/x86/kernel/x8664_ksyms_64.c
@@ -37,6 +37,8 @@ EXPORT_SYMBOL(__copy_user_nocache);
 EXPORT_SYMBOL(_copy_from_user);
 EXPORT_SYMBOL(_copy_to_user);
 
+EXPORT_SYMBOL_GPL(__mcsafe_copy);
+
 EXPORT_SYMBOL(copy_page);
 EXPORT_SYMBOL(clear_page);
 
diff --git a/arch/x86/lib/memcpy_64.S b/arch/x86/lib/memcpy_64.S
index 16698bba87de..f576acad485e 100644
--- a/arch/x86/lib/memcpy_64.S
+++ b/arch/x86/lib/memcpy_64.S
@@ -177,3 +177,137 @@ ENTRY(memcpy_orig)
 .Lend:
 	retq
 ENDPROC(memcpy_orig)
+
+#ifndef CONFIG_UML
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
+23:	xorq %rax, %rax
+	xorq %rdx, %rdx
+	/* copy successful. return 0 */
+	ret
+
+	.section .fixup,"ax"
+	/*
+	 * machine check handler loaded %rax with trap number
+	 * We just need to make sure %edx has the number of
+	 * bytes remaining
+	 */
+30:
+	add %ecx,%edx
+	ret
+31:
+	shl $6,%ecx
+	add %ecx,%edx
+	ret
+32:
+	shl $6,%ecx
+	lea -8(%ecx,%edx),%edx
+	ret
+33:
+	shl $6,%ecx
+	lea -16(%ecx,%edx),%edx
+	ret
+34:
+	shl $6,%ecx
+	lea -24(%ecx,%edx),%edx
+	ret
+35:
+	shl $6,%ecx
+	lea -32(%ecx,%edx),%edx
+	ret
+36:
+	shl $6,%ecx
+	lea -40(%ecx,%edx),%edx
+	ret
+37:
+	shl $6,%ecx
+	lea -48(%ecx,%edx),%edx
+	ret
+38:
+	shl $6,%ecx
+	lea -56(%ecx,%edx),%edx
+	ret
+39:
+	lea (%rdx,%rcx,8),%rdx
+	ret
+40:
+	mov %ecx,%edx
+	ret
+	.previous
+
+	_ASM_EXTABLE_FAULT(0b,30b)
+	_ASM_EXTABLE_FAULT(1b,31b)
+	_ASM_EXTABLE_FAULT(2b,32b)
+	_ASM_EXTABLE_FAULT(3b,33b)
+	_ASM_EXTABLE_FAULT(4b,34b)
+	_ASM_EXTABLE_FAULT(9b,35b)
+	_ASM_EXTABLE_FAULT(10b,36b)
+	_ASM_EXTABLE_FAULT(11b,37b)
+	_ASM_EXTABLE_FAULT(12b,38b)
+	_ASM_EXTABLE_FAULT(18b,39b)
+	_ASM_EXTABLE_FAULT(21b,40b)
+#endif
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
