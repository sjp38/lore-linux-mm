Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D3C6A6B0009
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 06:13:54 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p187so105996131wmp.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 03:13:54 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id h16si7457274wjn.237.2015.12.22.03.13.53
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 03:13:53 -0800 (PST)
Date: Tue, 22 Dec 2015 12:13:49 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV3 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151222111349.GB3728@pd.tnic>
References: <cover.1450283985.git.tony.luck@intel.com>
 <d560d03663b6fd7a5bbeae9842934f329a7dcbdf.1450283985.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <d560d03663b6fd7a5bbeae9842934f329a7dcbdf.1450283985.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Elliott@pd.tnic, Robert <elliott@hpe.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Tue, Dec 15, 2015 at 05:30:49PM -0800, Tony Luck wrote:
> Using __copy_user_nocache() as inspiration create a memory copy
> routine for use by kernel code with annotations to allow for
> recovery from machine checks.
> 
> Notes:
> 1) We align the source address rather than the destination. This
>    means we never have to deal with a memory read that spans two
>    cache lines ... so we can provide a precise indication of
>    where the error occurred without having to re-execute at
>    a byte-by-byte level to find the exact spot like the original
>    did.
> 2) We 'or' BIT(63) into the return because this is the first
>    in a series of machine check safe functions. Some will copy
>    from user addresses, so may need to indicate an invalid user
>    address instead of a machine check.
> 3) This code doesn't play any cache games. Future functions can
>    use non-temporal loads/stores to meet needs of different callers.
> 4) Provide helpful macros to decode the return value.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/include/asm/mcsafe_copy.h |  11 +++
>  arch/x86/kernel/x8664_ksyms_64.c   |   5 ++
>  arch/x86/lib/Makefile              |   1 +
>  arch/x86/lib/mcsafe_copy.S         | 142 +++++++++++++++++++++++++++++++++++++
>  4 files changed, 159 insertions(+)
>  create mode 100644 arch/x86/include/asm/mcsafe_copy.h
>  create mode 100644 arch/x86/lib/mcsafe_copy.S
> 
> diff --git a/arch/x86/include/asm/mcsafe_copy.h b/arch/x86/include/asm/mcsafe_copy.h
> new file mode 100644
> index 000000000000..d4dbd5a667a3
> --- /dev/null
> +++ b/arch/x86/include/asm/mcsafe_copy.h
> @@ -0,0 +1,11 @@
> +#ifndef _ASM_X86_MCSAFE_COPY_H
> +#define _ASM_X86_MCSAFE_COPY_H
> +
> +u64 mcsafe_memcpy(void *dst, const void *src, unsigned size);
> +
> +#define	COPY_MCHECK_ERRBIT	BIT(63)

What happened to the landing pads Andy was talking about? They sound
like cleaner design than that bit 63...

> +#define COPY_HAD_MCHECK(ret)	((ret) & COPY_MCHECK_ERRBIT)
> +#define COPY_MCHECK_REMAIN(ret)	((ret) & ~COPY_MCHECK_ERRBIT)
> +
> +#endif /* _ASM_MCSAFE_COPY_H */

This should all be in arch/x86/include/asm/string_64.h I guess. You can
save yourself the #include-ing.

> diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
> index a0695be19864..afab8b25dbc0 100644
> --- a/arch/x86/kernel/x8664_ksyms_64.c
> +++ b/arch/x86/kernel/x8664_ksyms_64.c
> @@ -37,6 +37,11 @@ EXPORT_SYMBOL(__copy_user_nocache);
>  EXPORT_SYMBOL(_copy_from_user);
>  EXPORT_SYMBOL(_copy_to_user);
>  
> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +#include <asm/mcsafe_copy.h>
> +EXPORT_SYMBOL(mcsafe_memcpy);
> +#endif
> +
>  EXPORT_SYMBOL(copy_page);
>  EXPORT_SYMBOL(clear_page);
>  
> diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
> index f2587888d987..82bb0bf46b6b 100644
> --- a/arch/x86/lib/Makefile
> +++ b/arch/x86/lib/Makefile
> @@ -21,6 +21,7 @@ lib-y += usercopy_$(BITS).o usercopy.o getuser.o putuser.o
>  lib-y += memcpy_$(BITS).o
>  lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
>  lib-$(CONFIG_INSTRUCTION_DECODER) += insn.o inat.o
> +lib-$(CONFIG_MCE_KERNEL_RECOVERY) += mcsafe_copy.o
>  
>  obj-y += msr.o msr-reg.o msr-reg-export.o
>  
> diff --git a/arch/x86/lib/mcsafe_copy.S b/arch/x86/lib/mcsafe_copy.S
> new file mode 100644
> index 000000000000..059b3a9642eb
> --- /dev/null
> +++ b/arch/x86/lib/mcsafe_copy.S

You probably should add that function to arch/x86/lib/memcpy_64.S where
we keep all those memcpy variants instead of a separate file.

> @@ -0,0 +1,142 @@
> +/*
> + * Copyright (C) 2015 Intel Corporation
> + * Author: Tony Luck
> + *
> + * This software may be redistributed and/or modified under the terms of
> + * the GNU General Public License ("GPL") version 2 only as published by the
> + * Free Software Foundation.
> + */
> +
> +#include <linux/linkage.h>
> +#include <asm/asm.h>
> +
> +/*
> + * mcsafe_memcpy - memory copy with machine check exception handling
> + * Note that we only catch machine checks when reading the source addresses.
> + * Writes to target are posted and don't generate machine checks.
> + */
> +ENTRY(mcsafe_memcpy)
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
> +23:	xorl %eax,%eax
> +	sfence
> +	ret
> +
> +	.section .fixup,"ax"
> +30:
> +	addl %ecx,%edx
> +	jmp 100f
> +31:
> +	shll $6,%ecx
> +	addl %ecx,%edx
> +	jmp 100f
> +32:
> +	shll $6,%ecx
> +	leal -8(%ecx,%edx),%edx
> +	jmp 100f
> +33:
> +	shll $6,%ecx
> +	leal -16(%ecx,%edx),%edx
> +	jmp 100f
> +34:
> +	shll $6,%ecx
> +	leal -24(%ecx,%edx),%edx
> +	jmp 100f
> +35:
> +	shll $6,%ecx
> +	leal -32(%ecx,%edx),%edx
> +	jmp 100f
> +36:
> +	shll $6,%ecx
> +	leal -40(%ecx,%edx),%edx
> +	jmp 100f
> +37:
> +	shll $6,%ecx
> +	leal -48(%ecx,%edx),%edx
> +	jmp 100f
> +38:
> +	shll $6,%ecx
> +	leal -56(%ecx,%edx),%edx
> +	jmp 100f
> +39:
> +	lea (%rdx,%rcx,8),%rdx
> +	jmp 100f
> +40:
> +	movl %ecx,%edx
> +100:
> +	sfence
> +	movabsq	$0x8000000000000000, %rax
> +	orq %rdx,%rax

I think you want to write this as:

	mov %rdx, %rax
	bts $63, %rax

It cuts down instruction bytes by almost half and it is a bit more
readable:

  5c:   48 b8 00 00 00 00 00    movabs $0x8000000000000000,%rax
  63:   00 00 80
  66:   48 09 d0                or     %rdx,%rax

  5c:   48 89 d0                mov    %rdx,%rax
  5f:   48 0f ba e8 3f          bts    $0x3f,%rax


> +	ret

Also, you can drop the "l" suffix - default operand size is 32-bit in
long mode:

        .section .fixup,"ax"
30:
        add %ecx,%edx
        jmp 100f
31:
        shl $6,%ecx
        add %ecx,%edx
        jmp 100f
32:
        shl $6,%ecx
        lea -8(%ecx,%edx),%edx
        jmp 100f
33:
        shl $6,%ecx
        lea -16(%ecx,%edx),%edx
        jmp 100f
34:
        shl $6,%ecx
        lea -24(%ecx,%edx),%edx
        jmp 100f
35:
        shl $6,%ecx
        lea -32(%ecx,%edx),%edx
        jmp 100f
36:
        shl $6,%ecx
        lea -40(%ecx,%edx),%edx
        jmp 100f
37:
        shl $6,%ecx
        lea -48(%ecx,%edx),%edx
        jmp 100f
38:
        shl $6,%ecx
        lea -56(%ecx,%edx),%edx
        jmp 100f
39:
        lea (%rdx,%rcx,8),%rdx
        jmp 100f
40:
        mov %ecx,%edx
100:

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
