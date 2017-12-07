Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C790B6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 02:03:35 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id m6so3518348wrf.1
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 23:03:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k11sor2299682wrh.82.2017.12.06.23.03.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 23:03:33 -0800 (PST)
Date: Thu, 7 Dec 2017 08:03:30 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 4/4] x86/boot/compressed/64: Handle 5-level paging boot
 if kernel is above 4G
Message-ID: <20171207070330.dreqarxi4jvipqa7@gmail.com>
References: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
 <20171205135942.24634-5-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205135942.24634-5-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> This patch addresses a shortcoming in current boot process on machines
> that supports 5-level paging.

s/in current boot process
 /in the current boot process

> If a bootloader enables 64-bit mode with 4-level paging, we might need to
> switch over to 5-level paging. The switching requires disabling paging.
> It works fine if kernel itself is loaded below 4G.

s/The switching requires disabling paging.
 /The switching requires the disabling of paging.

> But if the bootloader put the kernel above 4G (not sure if anybody does
> this), we would loose control as soon as paging is disabled as code
> becomes unreachable.

Same suggestion for this paragraph as for the previous patch.

> This patch implements a trampoline in lower memory to handle this
> situation.
> 
> We only need the memory for very short time, until main kernel image
> would setup its own page tables.

s/We only need the memory for very short time
 /We only need this memory for a very short time

s/until main kernel image would setup its own page tables.
 /until the main kernel image sets up its own page tables.

> We go through trampoline even if we don't have to: if we're already in
> 5-level paging mode or if we don't need to switch to it. This way the
> trampoline gets tested on every boot.

s/We go through trampoline
 /We go through the trampoline

>  	/*
>  	 * At this point we are in long mode with 4-level paging enabled,
> +	 * but we might want to enable 5-level paging.
>  	 *
> +	 * The problem is that we cannot do it directly. Setting CR.LA57
> +	 * in the long mode would trigger #GP. So we need to switch off
> +	 * long mode and paging first.

s/Setting CR.LA57 in the long mode
 /Setting CR.LA57 in long mode

Also, why only say 'CR', why not 'CR4'?

> +	 *
> +	 * We also need a trampoline in lower memory to switch over from
> +	 * 4- to 5-level paging for cases when bootloader put kernel above
> +	 * 4G, but didn't enable 5-level paging for us.

s/for cases when bootloader put kernel above 4G
 /for cases when the bootloader puts the kernel above 4G

> +	 *
> +	 * For the trampoline, we need top page table in lower memory as
> +	 * we don't have a way to load 64-bit value into CR3 from 32-bit
> +	 * mode.

s/we need top page table in lower memory
 /we need the top page table to reside in lower memory

s/load 64-bit value into CR3 from 32-bit mode
 /load 64-bit values into CR3 in 32-bit mode

> +	 *
> +	 * We go though the trampoline even if we don't have to: if we're
> +	 * already in 5-level paging mode or if we don't need to switch to
> +	 * it. This way the trampoline code gets tested on every boot.

>  	/*
> +	 * Load address of trampoline_return into RDI.
> +	 * It will be used by trampoline to return to main code.

s/Load address of trampoline_return
 /Load the address of trampoline_return

s/It will be used by trampoline to return to main code
 /It will be used by the trampoline to return to the main code

> +trampoline_return:
> +	/* Restore stack, 32-bit trampoline uses own stack */
> +	leaq	boot_stack_end(%rbx), %rsp

This phrasing would be a bit clearer:

	/* Restore the stack, the 32-bit trampoline uses its own stack */

> +/*
> + * This is 32-bit trampoline that will be copied over to low memory.

s/This is 32-bit trampoline that will be
 /This is the 32-bit trampoline that will be

> + *
> + * RDI contains return address (might be above 4G).

s/RDI contains return address (might be above 4G)
 /RDI contains the return address (might be above 4G)

> + * ECX contains the base address of trampoline memory.

s/of trampoline memory
 /of the trampoline memory

> +	/* For 5-level paging, point CR3 to trampoline's new top level page table */

s/point CR3 to trampoline's new top level page table
 /point CR3 to the trampoline's new top level page table

> +	testl	$1, %ecx
> +	jz	1f
> +	leal	TRAMPOLINE_32BIT_PGTABLE_OFF (%edx), %eax

BTW., could you please spell out 'OFFSET'? 'OFF' reminds me of the ON/OFF pattern. 
The constant is hopelessly long anyway ;-)

Also:

s/TRAMPOLINE_32BIT_PGTABLE_OFF (%edx)
 /TRAMPOLINE_32BIT_PGTABLE_OFF(%edx)

(This applies to the rest of the patch as well.)

> -	/* Enable PAE and LA57 mode */
> +	/* Enable PAE and LA57 (if required) modes */

A bit more clarity:

s/modes
 /paging modes

> +	/* Calculate address of paging_enabled once we are in trampoline */

Please use the same function name reference as I suggested for the previous patch.

s/once we are in trampoline
 /once we are executing in the trampoline

>  	/* Prepare stack for far return to Long Mode */

s/Prepare stack
 /Prepare the stack

>  	/* Enable paging back */

s/Enable paging back
 /Enable paging again

> +	.code64
> +paging_enabled:
> +	/* Return from the trampoline */
> +	jmp	*%rdi
> +
> +	/*
> +	 * Bound size of trampoline code.
> +	 * It would fail to compile if code of the trampoline would grow
> +	 * beyond TRAMPOLINE_32BIT_CODE_SIZE bytes.

How about:

	 * The trampoline code has a size limit.
	 * Make sure we fail to compile if the trampoline code grows
	 * beyond TRAMPOLINE_32BIT_CODE_SIZE bytes.

?

> +	.code32
>  no_longmode:
>  	/* This isn't an x86-64 CPU so hang */

While at it:

s/This isn't an x86-64 CPU so hang
 /This isn't an x86-64 CPU, so hang intentionally, we cannot continue:

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
