Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3C06B000C
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:30:38 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id w17-v6so8506453wrt.0
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:30:38 -0700 (PDT)
Received: from thoth.sbs.de (thoth.sbs.de. [192.35.17.2])
        by mx.google.com with ESMTPS id a66-v6si1696731wmh.121.2018.10.12.11.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 11:30:36 -0700 (PDT)
Subject: Re: [PATCH 10/39] x86/entry/32: Handle Entry from Kernel-Mode on
 Entry-Stack
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
 <1531906876-13451-11-git-send-email-joro@8bytes.org>
From: Jan Kiszka <jan.kiszka@siemens.com>
Message-ID: <97421241-2bc4-c3f1-4128-95b3e8a230d1@siemens.com>
Date: Fri, 12 Oct 2018 20:29:47 +0200
MIME-Version: 1.0
In-Reply-To: <1531906876-13451-11-git-send-email-joro@8bytes.org>
Content-Type: multipart/mixed;
 boundary="------------06497A68E357BF1BFAC77813"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>

This is a multi-part message in MIME format.
--------------06497A68E357BF1BFAC77813
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 18.07.18 11:40, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> It can happen that we enter the kernel from kernel-mode and
> on the entry-stack. The most common way this happens is when
> we get an exception while loading the user-space segment
> registers on the kernel-to-userspace exit path.
> 
> The segment loading needs to be done after the entry-stack
> switch, because the stack-switch needs kernel %fs for
> per_cpu access.
> 
> When this happens, we need to make sure that we leave the
> kernel with the entry-stack again, so that the interrupted
> code-path runs on the right stack when switching to the
> user-cr3.
> 
> We do this by detecting this condition on kernel-entry by
> checking CS.RPL and %esp, and if it happens, we copy over
> the complete content of the entry stack to the task-stack.
> This needs to be done because once we enter the exception
> handlers we might be scheduled out or even migrated to a
> different CPU, so that we can't rely on the entry-stack
> contents. We also leave a marker in the stack-frame to
> detect this condition on the exit path.
> 
> On the exit path the copy is reversed, we copy all of the
> remaining task-stack back to the entry-stack and switch
> to it.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>   arch/x86/entry/entry_32.S | 116 +++++++++++++++++++++++++++++++++++++++++++++-
>   1 file changed, 115 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 7635925..9d6eceb 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -294,6 +294,9 @@
>    * copied there. So allocate the stack-frame on the task-stack and
>    * switch to it before we do any copying.
>    */
> +
> +#define CS_FROM_ENTRY_STACK	(1 << 31)
> +
>   .macro SWITCH_TO_KERNEL_STACK
>   
>   	ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
> @@ -316,6 +319,16 @@
>   	/* Load top of task-stack into %edi */
>   	movl	TSS_entry2task_stack(%edi), %edi
>   
> +	/*
> +	 * Clear unused upper bits of the dword containing the word-sized CS
> +	 * slot in pt_regs in case hardware didn't clear it for us.
> +	 */
> +	andl	$(0x0000ffff), PT_CS(%esp)
> +
> +	/* Special case - entry from kernel mode via entry stack */
> +	testl	$SEGMENT_RPL_MASK, PT_CS(%esp)
> +	jz	.Lentry_from_kernel_\@
> +
>   	/* Bytes to copy */
>   	movl	$PTREGS_SIZE, %ecx
>   
> @@ -329,8 +342,8 @@
>   	 */
>   	addl	$(4 * 4), %ecx
>   
> -.Lcopy_pt_regs_\@:
>   #endif
> +.Lcopy_pt_regs_\@:
>   
>   	/* Allocate frame on task-stack */
>   	subl	%ecx, %edi
> @@ -346,6 +359,56 @@
>   	cld
>   	rep movsl
>   
> +	jmp .Lend_\@
> +
> +.Lentry_from_kernel_\@:
> +
> +	/*
> +	 * This handles the case when we enter the kernel from
> +	 * kernel-mode and %esp points to the entry-stack. When this
> +	 * happens we need to switch to the task-stack to run C code,
> +	 * but switch back to the entry-stack again when we approach
> +	 * iret and return to the interrupted code-path. This usually
> +	 * happens when we hit an exception while restoring user-space
> +	 * segment registers on the way back to user-space.
> +	 *
> +	 * When we switch to the task-stack here, we can't trust the
> +	 * contents of the entry-stack anymore, as the exception handler
> +	 * might be scheduled out or moved to another CPU. Therefore we
> +	 * copy the complete entry-stack to the task-stack and set a
> +	 * marker in the iret-frame (bit 31 of the CS dword) to detect
> +	 * what we've done on the iret path.
> +	 *
> +	 * On the iret path we copy everything back and switch to the
> +	 * entry-stack, so that the interrupted kernel code-path
> +	 * continues on the same stack it was interrupted with.
> +	 *
> +	 * Be aware that an NMI can happen anytime in this code.
> +	 *
> +	 * %esi: Entry-Stack pointer (same as %esp)
> +	 * %edi: Top of the task stack
> +	 */
> +
> +	/* Calculate number of bytes on the entry stack in %ecx */
> +	movl	%esi, %ecx
> +
> +	/* %ecx to the top of entry-stack */
> +	andl	$(MASK_entry_stack), %ecx
> +	addl	$(SIZEOF_entry_stack), %ecx
> +
> +	/* Number of bytes on the entry stack to %ecx */
> +	sub	%esi, %ecx
> +
> +	/* Mark stackframe as coming from entry stack */
> +	orl	$CS_FROM_ENTRY_STACK, PT_CS(%esp)
> +
> +	/*
> +	 * %esi and %edi are unchanged, %ecx contains the number of
> +	 * bytes to copy. The code at .Lcopy_pt_regs_\@ will allocate
> +	 * the stack-frame on task-stack and copy everything over
> +	 */
> +	jmp .Lcopy_pt_regs_\@
> +
>   .Lend_\@:
>   .endm
>   
> @@ -404,6 +467,56 @@
>   .endm
>   
>   /*
> + * This macro handles the case when we return to kernel-mode on the iret
> + * path and have to switch back to the entry stack.
> + *
> + * See the comments below the .Lentry_from_kernel_\@ label in the
> + * SWITCH_TO_KERNEL_STACK macro for more details.
> + */
> +.macro PARANOID_EXIT_TO_KERNEL_MODE
> +
> +	/*
> +	 * Test if we entered the kernel with the entry-stack. Most
> +	 * likely we did not, because this code only runs on the
> +	 * return-to-kernel path.
> +	 */
> +	testl	$CS_FROM_ENTRY_STACK, PT_CS(%esp)
> +	jz	.Lend_\@
> +
> +	/* Unlikely slow-path */
> +
> +	/* Clear marker from stack-frame */
> +	andl	$(~CS_FROM_ENTRY_STACK), PT_CS(%esp)
> +
> +	/* Copy the remaining task-stack contents to entry-stack */
> +	movl	%esp, %esi
> +	movl	PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %edi
> +
> +	/* Bytes on the task-stack to ecx */
> +	movl	PER_CPU_VAR(cpu_tss_rw + TSS_sp1), %ecx
> +	subl	%esi, %ecx
> +
> +	/* Allocate stack-frame on entry-stack */
> +	subl	%ecx, %edi
> +
> +	/*
> +	 * Save future stack-pointer, we must not switch until the
> +	 * copy is done, otherwise the NMI handler could destroy the
> +	 * contents of the task-stack we are about to copy.
> +	 */
> +	movl	%edi, %ebx
> +
> +	/* Do the copy */
> +	shrl	$2, %ecx
> +	cld
> +	rep movsl
> +
> +	/* Safe to switch to entry-stack now */
> +	movl	%ebx, %esp
> +
> +.Lend_\@:
> +.endm
> +/*
>    * %eax: prev task
>    * %edx: next task
>    */
> @@ -764,6 +877,7 @@ restore_all:
>   
>   restore_all_kernel:
>   	TRACE_IRQS_IRET
> +	PARANOID_EXIT_TO_KERNEL_MODE
>   	RESTORE_REGS 4
>   	jmp	.Lirq_return
>   
> 

I've bisected down a boot breakage on Intel Quark board (config attached) to 
this commit (b92a165df17e, I additionally had to apply d1b47a7c9efc). The kernel 
prints out nothing if this is in.

The board is an Siemens IOT2000, I will check if this can also be triggered on a 
similar Galileo Gen2. Qemu does not like to reproduce it, unfortunately.

The commit look unsuspicious at first glance - maybe it is just changing some 
layout in an unfortunate way. Any ideas?

Thanks,
Jan

-- 
Siemens AG, Corporate Technology, CT RDA IOT SES-DE
Corporate Competence Center Embedded Linux

--------------06497A68E357BF1BFAC77813
Content-Type: application/x-xz;
 name=".config.xz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename=".config.xz"

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
--------------06497A68E357BF1BFAC77813--
