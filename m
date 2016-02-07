Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 17E9A8309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 11:55:36 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so87969841wme.0
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 08:55:36 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id z132si11599812wme.43.2016.02.07.08.55.34
        for <linux-mm@kvack.org>;
        Sun, 07 Feb 2016 08:55:35 -0800 (PST)
Date: Sun, 7 Feb 2016 17:55:24 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 3/4] x86, mce: Add __mcsafe_copy()
Message-ID: <20160207165524.GF5862@pd.tnic>
References: <cover.1454618190.git.tony.luck@intel.com>
 <6b63a88e925bbc821dc87f209909c3c1166b3261.1454618190.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <6b63a88e925bbc821dc87f209909c3c1166b3261.1454618190.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>, Richard Weinberger <richard@nod.at>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Fri, Jan 08, 2016 at 01:18:03PM -0800, Tony Luck wrote:
> Make use of the EXTABLE_FAULT exception table entries. This routine
> returns a structure to indicate the result of the copy:
> 
> struct mcsafe_ret {
>         u64 trapnr;
>         u64 remain;
> };
> 
> If the copy is successful, then both 'trapnr' and 'remain' are zero.
> 
> If we faulted during the copy, then 'trapnr' will say which type
> of trap (X86_TRAP_PF or X86_TRAP_MC) and 'remain' says how many
> bytes were not copied.
> 
> Note that this is probably the first of several copy functions.
> We can make new ones for non-temporal cache handling etc.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/include/asm/string_64.h |   8 +++
>  arch/x86/kernel/x8664_ksyms_64.c |   2 +
>  arch/x86/lib/memcpy_64.S         | 134 +++++++++++++++++++++++++++++++++++++++
>  3 files changed, 144 insertions(+)
> 
> diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
> index ff8b9a17dc4b..5b24039463a4 100644
> --- a/arch/x86/include/asm/string_64.h
> +++ b/arch/x86/include/asm/string_64.h
> @@ -78,6 +78,14 @@ int strcmp(const char *cs, const char *ct);
>  #define memset(s, c, n) __memset(s, c, n)
>  #endif
>  
> +struct mcsafe_ret {
> +	u64 trapnr;
> +	u64 remain;
> +};
> +
> +struct mcsafe_ret __mcsafe_copy(void *dst, const void __user *src, size_t cnt);
> +extern void __mcsafe_copy_end(void);
> +
>  #endif /* __KERNEL__ */
>  
>  #endif /* _ASM_X86_STRING_64_H */
> diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
> index a0695be19864..fff245462a8c 100644
> --- a/arch/x86/kernel/x8664_ksyms_64.c
> +++ b/arch/x86/kernel/x8664_ksyms_64.c
> @@ -37,6 +37,8 @@ EXPORT_SYMBOL(__copy_user_nocache);
>  EXPORT_SYMBOL(_copy_from_user);
>  EXPORT_SYMBOL(_copy_to_user);
>  
> +EXPORT_SYMBOL_GPL(__mcsafe_copy);
> +
>  EXPORT_SYMBOL(copy_page);
>  EXPORT_SYMBOL(clear_page);
>  
> diff --git a/arch/x86/lib/memcpy_64.S b/arch/x86/lib/memcpy_64.S
> index 16698bba87de..f576acad485e 100644
> --- a/arch/x86/lib/memcpy_64.S
> +++ b/arch/x86/lib/memcpy_64.S
> @@ -177,3 +177,137 @@ ENTRY(memcpy_orig)
>  .Lend:
>  	retq
>  ENDPROC(memcpy_orig)
> +
> +#ifndef CONFIG_UML

So this is because we get a link failure on UML:

arch/x86/um/built-in.o:(__ex_table+0x8): undefined reference to `ex_handler_fault'
arch/x86/um/built-in.o:(__ex_table+0x14): undefined reference to `ex_handler_fault'
arch/x86/um/built-in.o:(__ex_table+0x20): undefined reference to `ex_handler_fault'
arch/x86/um/built-in.o:(__ex_table+0x2c): undefined reference to `ex_handler_fault'
arch/x86/um/built-in.o:(__ex_table+0x38): undefined reference to `ex_handler_fault'
arch/x86/um/built-in.o:(__ex_table+0x44): more undefined references to `ex_handler_fault' follow
collect2: error: ld returned 1 exit status
make: *** [vmlinux] Error 1

due to those

> +     _ASM_EXTABLE_FAULT(0b,30b)
> +     _ASM_EXTABLE_FAULT(1b,31b)
> +     _ASM_EXTABLE_FAULT(2b,32b)
> +     _ASM_EXTABLE_FAULT(3b,33b)
> +     _ASM_EXTABLE_FAULT(4b,34b)

things below and that's because ex_handler_fault() is defined in
arch/x86/mm/extable.c and UML doesn't include that file in the build. It
takes kernel/extable.c and lib/extable.c only.

Richi, what's the usual way to address that in UML? I.e., make an
x86-only symbol visible to the UML build too? Define a dummy one, just
so that it builds?

> + * __mcsafe_copy - memory copy with machine check exception handling
> + * Note that we only catch machine checks when reading the source addresses.
> + * Writes to target are posted and don't generate machine checks.
> + */
> +ENTRY(__mcsafe_copy)
> +	cmpl $8,%edx
> +	jb 20f		/* less then 8 bytes, go to byte copy loop */
> +
> +	/* check for bad alignment of source */
> +	movl %esi,%ecx
> +	andl $7,%ecx
> +	jz 102f				/* already aligned */
> +	subl $8,%ecx
> +	negl %ecx
> +	subl %ecx,%edx
> +0:	movb (%rsi),%al
> +	movb %al,(%rdi)
> +	incq %rsi
> +	incq %rdi
> +	decl %ecx
> +	jnz 0b
> +102:
> +	movl %edx,%ecx
> +	andl $63,%edx
> +	shrl $6,%ecx
> +	jz 17f
> +1:	movq (%rsi),%r8
> +2:	movq 1*8(%rsi),%r9
> +3:	movq 2*8(%rsi),%r10
> +4:	movq 3*8(%rsi),%r11
> +	mov %r8,(%rdi)
> +	mov %r9,1*8(%rdi)
> +	mov %r10,2*8(%rdi)
> +	mov %r11,3*8(%rdi)
> +9:	movq 4*8(%rsi),%r8
> +10:	movq 5*8(%rsi),%r9
> +11:	movq 6*8(%rsi),%r10
> +12:	movq 7*8(%rsi),%r11
> +	mov %r8,4*8(%rdi)
> +	mov %r9,5*8(%rdi)
> +	mov %r10,6*8(%rdi)
> +	mov %r11,7*8(%rdi)
> +	leaq 64(%rsi),%rsi
> +	leaq 64(%rdi),%rdi
> +	decl %ecx
> +	jnz 1b
> +17:	movl %edx,%ecx
> +	andl $7,%edx
> +	shrl $3,%ecx
> +	jz 20f
> +18:	movq (%rsi),%r8
> +	mov %r8,(%rdi)
> +	leaq 8(%rsi),%rsi
> +	leaq 8(%rdi),%rdi
> +	decl %ecx
> +	jnz 18b
> +20:	andl %edx,%edx
> +	jz 23f
> +	movl %edx,%ecx
> +21:	movb (%rsi),%al
> +	movb %al,(%rdi)
> +	incq %rsi
> +	incq %rdi
> +	decl %ecx
> +	jnz 21b
> +23:	xorq %rax, %rax
> +	xorq %rdx, %rdx
> +	/* copy successful. return 0 */
> +	ret
> +
> +	.section .fixup,"ax"
> +	/*
> +	 * machine check handler loaded %rax with trap number
> +	 * We just need to make sure %edx has the number of
> +	 * bytes remaining
> +	 */
> +30:
> +	add %ecx,%edx
> +	ret
> +31:
> +	shl $6,%ecx
> +	add %ecx,%edx
> +	ret
> +32:
> +	shl $6,%ecx
> +	lea -8(%ecx,%edx),%edx
> +	ret
> +33:
> +	shl $6,%ecx
> +	lea -16(%ecx,%edx),%edx
> +	ret
> +34:
> +	shl $6,%ecx
> +	lea -24(%ecx,%edx),%edx
> +	ret
> +35:
> +	shl $6,%ecx
> +	lea -32(%ecx,%edx),%edx
> +	ret
> +36:
> +	shl $6,%ecx
> +	lea -40(%ecx,%edx),%edx
> +	ret
> +37:
> +	shl $6,%ecx
> +	lea -48(%ecx,%edx),%edx
> +	ret
> +38:
> +	shl $6,%ecx
> +	lea -56(%ecx,%edx),%edx
> +	ret
> +39:
> +	lea (%rdx,%rcx,8),%rdx
> +	ret
> +40:
> +	mov %ecx,%edx
> +	ret
> +	.previous
> +
> +	_ASM_EXTABLE_FAULT(0b,30b)
> +	_ASM_EXTABLE_FAULT(1b,31b)
> +	_ASM_EXTABLE_FAULT(2b,32b)
> +	_ASM_EXTABLE_FAULT(3b,33b)
> +	_ASM_EXTABLE_FAULT(4b,34b)
> +	_ASM_EXTABLE_FAULT(9b,35b)
> +	_ASM_EXTABLE_FAULT(10b,36b)
> +	_ASM_EXTABLE_FAULT(11b,37b)
> +	_ASM_EXTABLE_FAULT(12b,38b)
> +	_ASM_EXTABLE_FAULT(18b,39b)
> +	_ASM_EXTABLE_FAULT(21b,40b)
> +#endif
> -- 
> 2.5.0

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
