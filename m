Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DC81D8309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 11:49:44 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id g62so105706334wme.0
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 08:49:44 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id y91si11524928wmh.107.2016.02.07.08.49.43
        for <linux-mm@kvack.org>;
        Sun, 07 Feb 2016 08:49:43 -0800 (PST)
Date: Sun, 7 Feb 2016 17:49:33 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 3/4] x86, mce: Add __mcsafe_copy()
Message-ID: <20160207164933.GE5862@pd.tnic>
References: <cover.1454618190.git.tony.luck@intel.com>
 <6b63a88e925bbc821dc87f209909c3c1166b3261.1454618190.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <6b63a88e925bbc821dc87f209909c3c1166b3261.1454618190.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
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

...

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
> +/*
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

You can save yourself this MOV here in what is, I'm assuming, the
general likely case where @src is aligned and do:

        /* check for bad alignment of source */
        testl $7, %esi
        /* already aligned? */
        jz 102f

        movl %esi,%ecx
        subl $8,%ecx
        negl %ecx
        subl %ecx,%edx
0:      movb (%rsi),%al
        movb %al,(%rdi)
        incq %rsi
        incq %rdi
        decl %ecx
        jnz 0b

> +	andl $7,%ecx
> +	jz 102f				/* already aligned */

Please move side-comments over the line they're referring to.

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

Please add a \n after the JMPs for better readability - those blocks are
dense as it is. They could use some comments too.

> +1:	movq (%rsi),%r8
> +2:	movq 1*8(%rsi),%r9
> +3:	movq 2*8(%rsi),%r10
> +4:	movq 3*8(%rsi),%r11
> +	mov %r8,(%rdi)
> +	mov %r9,1*8(%rdi)
> +	mov %r10,2*8(%rdi)
> +	mov %r11,3*8(%rdi)

You can say "movq" too here, for consistency.

> +9:	movq 4*8(%rsi),%r8
> +10:	movq 5*8(%rsi),%r9
> +11:	movq 6*8(%rsi),%r10
> +12:	movq 7*8(%rsi),%r11

Why aren't we pushing %r12-%r15 on the stack after the "jz 17f" above
and using them too and thus copying a whole cacheline in one go?

We would need to restore them when we're done with the cacheline-wise
shuffle, of course.

> +	mov %r8,4*8(%rdi)
> +	mov %r9,5*8(%rdi)
> +	mov %r10,6*8(%rdi)
> +	mov %r11,7*8(%rdi)
> +	leaq 64(%rsi),%rsi
> +	leaq 64(%rdi),%rdi
> +	decl %ecx
> +	jnz 1b

...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
