Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6CD6B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:31:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v25-v6so13393747pfm.11
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:31:26 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p9-v6si5884905pgk.645.2018.07.13.16.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 16:31:24 -0700 (PDT)
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3FE20208CE
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 23:31:24 +0000 (UTC)
Received: by mail-wr1-f47.google.com with SMTP id j5-v6so20014335wrr.8
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:31:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1531308586-29340-11-git-send-email-joro@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-11-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 13 Jul 2018 16:31:02 -0700
Message-ID: <CALCETrUg_4q8a2Tt_Z+GtVuBwj3Ct3=j7M-YhiK06=XjxOG82A@mail.gmail.com>
Subject: Re: [PATCH 10/39] x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Wed, Jul 11, 2018 at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
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
>  arch/x86/entry/entry_32.S | 116 +++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 115 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 3d1a114..b3af76e 100644
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
> @@ -320,6 +323,16 @@
>         /* Load top of task-stack into %edi */
>         movl    TSS_entry_stack(%edi), %edi
>
> +       /*
> +        * Clear upper bits of the CS slot in pt_regs in case hardware
> +        * didn't clear it for us
> +        */
> +       andl    $(0x0000ffff), PT_CS(%esp)

The comment is highly confusing, give that the upper bits aren't part
of the slot any more:

commit 385eca8f277c4c34f361a4c3a088fd876d29ae21
Author: Andy Lutomirski <luto@kernel.org>
Date:   Fri Jul 28 06:00:30 2017 -0700

    x86/asm/32: Make pt_regs's segment registers be 16 bits

What you're really doing is keeping it available for an extra flag.
Please update the comment as such.  But see below.

> +
> +       /* Special case - entry from kernel mode via entry stack */
> +       testl   $SEGMENT_RPL_MASK, PT_CS(%esp)
> +       jz      .Lentry_from_kernel_\@
> +
>         /* Bytes to copy */
>         movl    $PTREGS_SIZE, %ecx
>
> @@ -333,8 +346,8 @@
>          */
>         addl    $(4 * 4), %ecx
>
> -.Lcopy_pt_regs_\@:
>  #endif
> +.Lcopy_pt_regs_\@:
>
>         /* Allocate frame on task-stack */
>         subl    %ecx, %edi
> @@ -350,6 +363,56 @@
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
> @@ -408,6 +471,56 @@
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

I'm confused.  Why do we need any special handling here at all?  How
could we end up with the contents of the stack frame we interrupted in
a corrupt state?

I guess I don't understand why this patch is needed.
