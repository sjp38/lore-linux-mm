Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38BDF6B0038
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 19:08:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id m63so5273588pfk.20
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 16:08:07 -0700 (PDT)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id j6si12867078plk.810.2017.10.12.16.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 16:08:06 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20171009160924.68032-1-kirill.shutemov@linux.intel.com>
	<af75f8aa-471d-34c5-8009-4009a8273989@intel.com>
	<20171009170900.gyl5sizwnd54ridc@node.shutemov.name>
Date: Thu, 12 Oct 2017 18:07:36 -0500
In-Reply-To: <20171009170900.gyl5sizwnd54ridc@node.shutemov.name> (Kirill
	A. Shutemov's message of "Mon, 9 Oct 2017 20:09:00 +0300")
Message-ID: <87k200vubr.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH, RFC] x86/boot/compressed/64: Handle 5-level paging boot if kernel is above 4G
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Mon, Oct 09, 2017 at 09:54:53AM -0700, Dave Hansen wrote:
>> On 10/09/2017 09:09 AM, Kirill A. Shutemov wrote:
>> > Apart from trampoline itself we also need place to store top level page
>> > table in lower memory as we don't have a way to load 64-bit value into
>> > CR3 from 32-bit mode. We only really need 8-bytes there as we only use
>> > the very first entry of the page table.
>> 
>> Oh, and this is why you have to move "lvl5_pgtable" out of the kernel image?
>
> Right. I initialize the new location of top level page table directly.

So just a quick note.  I have a fuzzy memory of people loading their
kernels above 4G physical because they did not have any memory below
4G.

That might be a very specialized case if my memory is correct because
cpu startup has to have a trampoline below 1MB.  So I don't know how
that works.  But I do seem to remember someone mentioning it.

Is there really no way to switch to 5 level paging other than to drop to
32bit mode and disable paging?    The x86 architecture does some very
bizarre things so I can believe it but that seems like a lot of work to
get somewhere.

Eric


>
>> > diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
>> > index cefe4958fda9..049a289342bd 100644
>> > --- a/arch/x86/boot/compressed/head_64.S
>> > +++ b/arch/x86/boot/compressed/head_64.S
>> > @@ -288,6 +288,22 @@ ENTRY(startup_64)
>> >  	leaq	boot_stack_end(%rbx), %rsp
>> >  
>> >  #ifdef CONFIG_X86_5LEVEL
>> > +/*
>> > + * We need trampoline in lower memory switch from 4- to 5-level paging for
>> > + * cases when bootloader put kernel above 4G, but didn't enable 5-level paging
>> > + * for us.
>> > + *
>> > + * Here we use MBR memory to store trampoline code.
>> > + *
>> > + * We also have to have top page table in lower memory as we don't have a way
>> > + * to load 64-bit value into CR3 from 32-bit mode. We only need 8-bytes there
>> > + * as we only use the very first entry of the page table.
>> > + *
>> > + * Here we use 0x7000 as top-level page table.
>> > + */
>> > +#define LVL5_TRAMPOLINE	0x7c00
>> > +#define LVL5_PGTABLE	0x7000
>> > +
>> >  	/* Preserve RBX across CPUID */
>> >  	movq	%rbx, %r8
>> >  
>> > @@ -323,29 +339,37 @@ ENTRY(startup_64)
>> >  	 * long mode would trigger #GP. So we need to switch off long mode
>> >  	 * first.
>> >  	 *
>> > -	 * NOTE: This is not going to work if bootloader put us above 4G
>> > -	 * limit.
>> > +	 * We use trampoline in lower memory to handle situation when
>> > +	 * bootloader put the kernel image above 4G.
>> >  	 *
>> >  	 * The first step is go into compatibility mode.
>> >  	 */
>> >  
>> > -	/* Clear additional page table */
>> > -	leaq	lvl5_pgtable(%rbx), %rdi
>> > -	xorq	%rax, %rax
>> > -	movq	$(PAGE_SIZE/8), %rcx
>> > -	rep	stosq
>> > +	/* Copy trampoline code in place */
>> > +	movq	%rsi, %r9
>> > +	leaq	lvl5_trampoline(%rip), %rsi
>> > +	movq	$LVL5_TRAMPOLINE, %rdi
>> > +	movq	$(lvl5_trampoline_end - lvl5_trampoline), %rcx
>> > +	rep	movsb
>> > +	movq	%r9, %rsi
>> 
>> This needs to get more heavily commented, like the use of r9 to stash
>> %rsi.  Why do you do that, btw?  I don't see it getting reused at first
>> glance.
>
> %rsi holds pointer to real_mode_data. It need to be preserved.
>
> I'll add more comments.
>
>> I think it will also be really nice to differentate "lvl5_trampoline"
>> from "LVL5_TRAMPOLINE".  Maybe add "src" and "dst" to them or something.
>
> Makes sense. Thanks.
>
>> >  	/*
>> > -	 * Setup current CR3 as the first and only entry in a new top level
>> > +	 * Setup current CR3 as the first and the only entry in a new top level
>> >  	 * page table.
>> >  	 */
>> >  	movq	%cr3, %rdi
>> >  	leaq	0x7 (%rdi), %rax
>> > -	movq	%rax, lvl5_pgtable(%rbx)
>> > +	movq	%rax, LVL5_PGTABLE
>> > +
>> > +	/*
>> > +	 * Load address of lvl5 into RDI.
>> > +	 * It will be used to return address from trampoline.
>> > +	 */
>> > +	leaq	lvl5(%rip), %rdi
>> 
>> Is there a reason to do a 'lea' here instead of just shoving the address
>> in directly?  Is this a shorter instruction or something?
>
> This code can be loaded anywhere in memory and we need to calculate
> absolute address of the label here.
> AFAIK, "lea <label>(%rip), <register>" is idiomatic way to do this.
>
>> >  	/* Switch to compatibility mode (CS.L = 0 CS.D = 1) via far return */
>> >  	pushq	$__KERNEL32_CS
>> > -	leaq	compatible_mode(%rip), %rax
>> > +	movq	$LVL5_TRAMPOLINE, %rax
>> >  	pushq	%rax
>> >  	lretq
>> >  lvl5:
>> > @@ -488,9 +512,9 @@ relocated:
>> >   */
>> >  	jmp	*%rax
>> >  
>> > -	.code32
>> >  #ifdef CONFIG_X86_5LEVEL
>> > -compatible_mode:
>> > +	.code32
>> > +lvl5_trampoline:
>> >  	/* Setup data and stack segments */
>> >  	movl	$__KERNEL_DS, %eax
>> >  	movl	%eax, %ds
>> > @@ -502,7 +526,7 @@ compatible_mode:
>> >  	movl	%eax, %cr0
>> >  
>> >  	/* Point CR3 to 5-level paging */
>> > -	leal	lvl5_pgtable(%ebx), %eax
>> > +	movl	$LVL5_PGTABLE, %eax
>> >  	movl	%eax, %cr3
>> >  
>> >  	/* Enable PAE and LA57 mode */
>> > @@ -510,14 +534,9 @@ compatible_mode:
>> >  	orl	$(X86_CR4_PAE | X86_CR4_LA57), %eax
>> >  	movl	%eax, %cr4
>> >  
>> > -	/* Calculate address we are running at */
>> > -	call	1f
>> > -1:	popl	%edi
>> > -	subl	$1b, %edi
>> > -
>> >  	/* Prepare stack for far return to Long Mode */
>> >  	pushl	$__KERNEL_CS
>> > -	leal	lvl5(%edi), %eax
>> > +	movl	$(lvl5_enabled - lvl5_trampoline + LVL5_TRAMPOLINE), %eax
>> 
>> This loads the trampoline address of "lvl5_enabled", right?  That'd be
>> handy to spell out explicitly.
>
> Yep, will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
