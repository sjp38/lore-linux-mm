Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60C3B6B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:41:04 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q197so16288052iod.17
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:41:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 102sor7559316iom.177.2018.03.05.08.41.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 08:41:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1520245563-8444-12-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org> <1520245563-8444-12-git-send-email-joro@8bytes.org>
From: Brian Gerst <brgerst@gmail.com>
Date: Mon, 5 Mar 2018 11:41:01 -0500
Message-ID: <CAMzpN2h3xkhw_A4VeeA47=oykKgxXeumHM-q0QpaA8+fwFVRjw@mail.gmail.com>
Subject: Re: [PATCH 11/34] x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Mon, Mar 5, 2018 at 5:25 AM, Joerg Roedel <joro@8bytes.org> wrote:
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
>  arch/x86/entry/entry_32.S | 110 +++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 109 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index bb0bd896..3a84945 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -299,6 +299,9 @@
>   * copied there. So allocate the stack-frame on the task-stack and
>   * switch to it before we do any copying.
>   */
> +
> +#define CS_FROM_ENTRY_STACK    (1 << 31)
> +
>  .macro SWITCH_TO_KERNEL_STACK
>
>         ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
> @@ -320,6 +323,10 @@
>         /* Load top of task-stack into %edi */
>         movl    TSS_entry_stack(%edi), %edi
>
> +       /* Special case - entry from kernel mode via entry stack */
> +       testl   $SEGMENT_RPL_MASK, PT_CS(%esp)
> +       jz      .Lentry_from_kernel_\@
> +
>         /* Bytes to copy */
>         movl    $PTREGS_SIZE, %ecx
>
> @@ -333,8 +340,8 @@
>          */
>         addl    $(4 * 4), %ecx
>
> -.Lcopy_pt_regs_\@:
>  #endif
> +.Lcopy_pt_regs_\@:
>
>         /* Allocate frame on task-stack */
>         subl    %ecx, %edi
> @@ -350,6 +357,56 @@
>         cld
>         rep movsl
>
> +       jmp .Lend_\@
> +
> +.Lentry_from_kernel_\@:
> +
> +       /*
> +        * This handles the case when we enter the kernel from
> +        * kernel-mode and %esp points to the entry-stack. When this
> +        * happens we need to switch to the task-stack to run C code,
> +        * but switch back to the entry-stack again when we approach
> +        * iret and return to the interrupted code-path. This usually
> +        * happens when we hit an exception while restoring user-space
> +        * segment registers on the way back to user-space.
> +        *
> +        * When we switch to the task-stack here, we can't trust the
> +        * contents of the entry-stack anymore, as the exception handler
> +        * might be scheduled out or moved to another CPU. Therefore we
> +        * copy the complete entry-stack to the task-stack and set a
> +        * marker in the iret-frame (bit 31 of the CS dword) to detect
> +        * what we've done on the iret path.

We don't need to worry about preemption changing the entry stack.  The
faults that IRET or segment loads can generate just run the exception
fixup handler and return.  Interrupts were disabled when the fault
occurred, so the kernel cannot be preempted.  The other case to watch
is #DB on SYSENTER, but that simply returns and doesn't sleep either.

We can keep the same process as the existing debug/NMI handlers -
leave the current exception pt_regs on the entry stack and just switch
to the task stack for the call to the handler.  Then switch back to
the entry stack and continue.  No copying needed.

> +        *
> +        * On the iret path we copy everything back and switch to the
> +        * entry-stack, so that the interrupted kernel code-path
> +        * continues on the same stack it was interrupted with.
> +        *
> +        * Be aware that an NMI can happen anytime in this code.
> +        *
> +        * %esi: Entry-Stack pointer (same as %esp)
> +        * %edi: Top of the task stack
> +        */
> +
> +       /* Calculate number of bytes on the entry stack in %ecx */
> +       movl    %esi, %ecx
> +
> +       /* %ecx to the top of entry-stack */
> +       andl    $(MASK_entry_stack), %ecx
> +       addl    $(SIZEOF_entry_stack), %ecx
> +
> +       /* Number of bytes on the entry stack to %ecx */
> +       sub     %esi, %ecx
> +
> +       /* Mark stackframe as coming from entry stack */
> +       orl     $CS_FROM_ENTRY_STACK, PT_CS(%esp)

Not all 32-bit processors will zero-extend segment pushes.  You will
need to explicitly clear the bit in the case where we didn't switch
CR3.

> +
> +       /*
> +        * %esi and %edi are unchanged, %ecx contains the number of
> +        * bytes to copy. The code at .Lcopy_pt_regs_\@ will allocate
> +        * the stack-frame on task-stack and copy everything over
> +        */
> +       jmp .Lcopy_pt_regs_\@
> +
>  .Lend_\@:
>  .endm
>
> @@ -408,6 +465,56 @@
>  .endm
>
>  /*
> + * This macro handles the case when we return to kernel-mode on the iret
> + * path and have to switch back to the entry stack.
> + *
> + * See the comments below the .Lentry_from_kernel_\@ label in the
> + * SWITCH_TO_KERNEL_STACK macro for more details.
> + */
> +.macro PARANOID_EXIT_TO_KERNEL_MODE
> +
> +       /*
> +        * Test if we entered the kernel with the entry-stack. Most
> +        * likely we did not, because this code only runs on the
> +        * return-to-kernel path.
> +        */
> +       testl   $CS_FROM_ENTRY_STACK, PT_CS(%esp)
> +       jz      .Lend_\@
> +
> +       /* Unlikely slow-path */
> +
> +       /* Clear marker from stack-frame */
> +       andl    $(~CS_FROM_ENTRY_STACK), PT_CS(%esp)
> +
> +       /* Copy the remaining task-stack contents to entry-stack */
> +       movl    %esp, %esi
> +       movl    PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %edi
> +
> +       /* Bytes on the task-stack to ecx */
> +       movl    PER_CPU_VAR(cpu_current_top_of_stack), %ecx
> +       subl    %esi, %ecx
> +
> +       /* Allocate stack-frame on entry-stack */
> +       subl    %ecx, %edi
> +
> +       /*
> +        * Save future stack-pointer, we must not switch until the
> +        * copy is done, otherwise the NMI handler could destroy the
> +        * contents of the task-stack we are about to copy.
> +        */
> +       movl    %edi, %ebx
> +
> +       /* Do the copy */
> +       shrl    $2, %ecx
> +       cld
> +       rep movsl
> +
> +       /* Safe to switch to entry-stack now */
> +       movl    %ebx, %esp
> +
> +.Lend_\@:
> +.endm
> +/*
>   * %eax: prev task
>   * %edx: next task
>   */
> @@ -765,6 +872,7 @@ restore_all:
>
>  restore_all_kernel:
>         TRACE_IRQS_IRET
> +       PARANOID_EXIT_TO_KERNEL_MODE
>         RESTORE_REGS 4
>         jmp     .Lirq_return
>
> --
> 2.7.4
>

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
