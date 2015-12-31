Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EFC6C6B0008
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 19:13:43 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 78so212067697pfw.2
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 16:13:43 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 20si35739921pfk.200.2016.01.04.16.13.43
        for <linux-mm@kvack.org>;
        Mon, 04 Jan 2016 16:13:43 -0800 (PST)
Message-Id: <5b0243c5df825ad0841f4bb5584cd15d3f013f09.1451952351.git.tony.luck@intel.com>
In-Reply-To: <cover.1451952351.git.tony.luck@intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Thu, 31 Dec 2015 11:43:43 -0800
Subject: [PATCH v7 3/3] x86, mce: Add __mcsafe_copy()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

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

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/x86/Kconfig                 |  10 +++
 arch/x86/include/asm/string_64.h |  10 +++
 arch/x86/kernel/x8664_ksyms_64.c |   4 ++
 arch/x86/lib/memcpy_64.S         | 136 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 160 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 96d058a87100..42d26b4d1ec4 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1001,6 +1001,16 @@ config X86_MCE_INJECT
 	  If you don't know what a machine check is and you don't do kernel
 	  QA it is safe to say n.
 
+config MCE_KERNEL_RECOVERY
+	bool "Recovery from machine checks in special kernel memory copy functions"
+	default n
+	depends on X86_MCE && X86_64
+	---help---
+	  This option provides a new memory copy function mcsafe_memcpy()
+	  that is annotated to allow the machine check handler to return
+	  to an alternate code path to return an error to the caller instead
+	  of crashing the system. Say yes if you have a driver that uses this.
+
 config X86_THERMAL_VECTOR
 	def_bool y
 	depends on X86_MCE_INTEL
diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
index ff8b9a17dc4b..16a8f0e56e4a 100644
--- a/arch/x86/include/asm/string_64.h
+++ b/arch/x86/include/asm/string_64.h
@@ -78,6 +78,16 @@ int strcmp(const char *cs, const char *ct);
 #define memset(s, c, n) __memset(s, c, n)
 #endif
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+struct mcsafe_ret {
+	u64 trapnr;
+	u64 remain;
+};
+
+struct mcsafe_ret __mcsafe_copy(void *dst, const void __user *src, size_t cnt);
+extern void __mcsafe_copy_end(void);
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
index 16698bba87de..e5b1acad8b1e 100644
--- a/arch/x86/lib/memcpy_64.S
+++ b/arch/x86/lib/memcpy_64.S
@@ -177,3 +177,139 @@ ENTRY(memcpy_orig)
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
+23:	xorq %rax, %rax
+	xorq %rdx, %rdx
+	sfence
+	/* copy successful. return 0 */
+	ret
+
+	.section .fixup,"ax"
+	/* fixups for machine check */
+30:
+	add %ecx,%edx
+	jmp 100f
+31:
+	shl $6,%ecx
+	add %ecx,%edx
+	jmp 100f
+32:
+	shl $6,%ecx
+	lea -8(%ecx,%edx),%edx
+	jmp 100f
+33:
+	shl $6,%ecx
+	lea -16(%ecx,%edx),%edx
+	jmp 100f
+34:
+	shl $6,%ecx
+	lea -24(%ecx,%edx),%edx
+	jmp 100f
+35:
+	shl $6,%ecx
+	lea -32(%ecx,%edx),%edx
+	jmp 100f
+36:
+	shl $6,%ecx
+	lea -40(%ecx,%edx),%edx
+	jmp 100f
+37:
+	shl $6,%ecx
+	lea -48(%ecx,%edx),%edx
+	jmp 100f
+38:
+	shl $6,%ecx
+	lea -56(%ecx,%edx),%edx
+	jmp 100f
+39:
+	lea (%rdx,%rcx,8),%rdx
+	jmp 100f
+40:
+	mov %ecx,%edx
+100:
+	sfence
+
+	/* %rax set the fault number in fixup_exception() */
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
+ENDPROC(__mcsafe_copy)
+#endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
