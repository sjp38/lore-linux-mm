Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DED26B0007
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 14:18:40 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id f34so16309804qtb.4
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 11:18:40 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m20si7208092qkm.391.2018.02.27.11.18.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 11:18:39 -0800 (PST)
Subject: Re: [PATCH 12/31] x86/entry/32: Add PTI cr3 switch to non-NMI
 entry/exit points
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-13-git-send-email-joro@8bytes.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <afd5bae9-f53e-a225-58f1-4ba2422044e3@redhat.com>
Date: Tue, 27 Feb 2018 14:18:36 -0500
MIME-Version: 1.0
In-Reply-To: <1518168340-9392-13-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On 02/09/2018 04:25 AM, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Add unconditional cr3 switches between user and kernel cr3
> to all non-NMI entry and exit points.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/entry/entry_32.S | 59 ++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 58 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 9693485..b5ef003 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -328,6 +328,25 @@
>  #endif /* CONFIG_X86_ESPFIX32 */
>  .endm
>  
> +/* Unconditionally switch to user cr3 */
> +.macro SWITCH_TO_USER_CR3 scratch_reg:req
> +	ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
> +
> +	movl	%cr3, \scratch_reg
> +	orl	$PTI_SWITCH_MASK, \scratch_reg
> +	movl	\scratch_reg, %cr3
> +.Lend_\@:
> +.endm
> +
> +/* Unconditionally switch to kernel cr3 */
> +.macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
> +	ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
> +	movl	%cr3, \scratch_reg
> +	andl	$(~PTI_SWITCH_MASK), \scratch_reg
> +	movl	\scratch_reg, %cr3
> +.Lend_\@:
> +.endm
> +
>  
>  /*
>   * Called with pt_regs fully populated and kernel segments loaded,
> @@ -343,6 +362,8 @@
>  
>  	ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
>  
> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
> +
>  	/* Are we on the entry stack? Bail out if not! */
>  	movl	PER_CPU_VAR(cpu_entry_area), %edi
>  	addl	$CPU_ENTRY_AREA_entry_stack, %edi
> @@ -637,6 +658,18 @@ ENTRY(xen_sysenter_target)
>   * 0(%ebp) arg6
>   */
>  ENTRY(entry_SYSENTER_32)
> +	/*
> +	 * On entry-stack with all userspace-regs live - save and
> +	 * restore eflags and %eax to use it as scratch-reg for the cr3
> +	 * switch.
> +	 */
> +	pushfl
> +	pushl	%eax
> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
> +	popl	%eax
> +	popfl
> +
> +	/* Stack empty again, switch to task stack */
>  	movl	TSS_entry_stack(%esp), %esp
>  
>  .Lsysenter_past_esp:
> @@ -691,6 +724,10 @@ ENTRY(entry_SYSENTER_32)
>  	movl	PT_OLDESP(%esp), %ecx	/* pt_regs->sp */
>  1:	mov	PT_FS(%esp), %fs
>  	PTGS_TO_GS
> +
> +	/* Segments are restored - switch to user cr3 */
> +	SWITCH_TO_USER_CR3 scratch_reg=%eax
> +
>  	popl	%ebx			/* pt_regs->bx */
>  	addl	$2*4, %esp		/* skip pt_regs->cx and pt_regs->dx */
>  	popl	%esi			/* pt_regs->si */
> @@ -778,7 +815,23 @@ restore_all:
>  .Lrestore_all_notrace:
>  	CHECK_AND_APPLY_ESPFIX
>  .Lrestore_nocheck:
> -	RESTORE_REGS 4				# skip orig_eax/error_code
> +	/*
> +	 * First restore user segments. This can cause exceptions, so we
> +	 * run it with kernel cr3.
> +	 */
> +	RESTORE_SEGMENTS
> +
> +	/*
> +	 * Segments are restored - no more exceptions from here on except on
> +	 * iret, but that handled safely.
> +	 */
> +	SWITCH_TO_USER_CR3 scratch_reg=%eax
> +
> +	/* Restore rest */
> +	RESTORE_INT_REGS
> +
> +	/* Unwind stack to the iret frame */
> +	RESTORE_SKIP_SEGMENTS 4			# skip orig_eax/error_code
>  .Lirq_return:
>  	INTERRUPT_RETURN
>  
> @@ -1139,6 +1192,10 @@ ENTRY(debug)
>  
>  	SAVE_ALL
>  	ENCODE_FRAME_POINTER
> +
> +	/* Make sure we are running on kernel cr3 */
> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
> +
>  	xorl	%edx, %edx			# error code 0
>  	movl	%esp, %eax			# pt_regs pointer
>  

The debug exception calls ret_from_exception on exit. If coming from
userspace, the C function prepare_exit_to_usermode() will be called.
With the PTI-32 code, it means that function will be called with the
entry stack instead of the task stack. This can be problematic as macro
like current won't work anymore.

-Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
