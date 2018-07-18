Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA5A76B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:10:06 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id q77-v6so3205795itc.2
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:10:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 199-v6sor1123961itv.112.2018.07.18.11.10.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 11:10:05 -0700 (PDT)
MIME-Version: 1.0
References: <1531906876-13451-1-git-send-email-joro@8bytes.org> <1531906876-13451-8-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-8-git-send-email-joro@8bytes.org>
From: Brian Gerst <brgerst@gmail.com>
Date: Wed, 18 Jul 2018 14:09:53 -0400
Message-ID: <CAMzpN2gqxu7rgVj8rfweanLNgHBci+nqZMqEYpvgRUd1828umQ@mail.gmail.com>
Subject: Re: [PATCH 07/39] x86/entry/32: Enter the kernel via trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, dhgutteridge@sympatico.ca, Joerg Roedel <jroedel@suse.de>

On Wed, Jul 18, 2018 at 5:41 AM Joerg Roedel <joro@8bytes.org> wrote:
>
> From: Joerg Roedel <jroedel@suse.de>
>
> Use the entry-stack as a trampoline to enter the kernel. The
> entry-stack is already in the cpu_entry_area and will be
> mapped to userspace when PTI is enabled.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/entry/entry_32.S        | 119 ++++++++++++++++++++++++++++++++-------
>  arch/x86/include/asm/switch_to.h |  14 ++++-
>  arch/x86/kernel/asm-offsets.c    |   1 +
>  arch/x86/kernel/cpu/common.c     |   5 +-
>  arch/x86/kernel/process.c        |   2 -
>  arch/x86/kernel/process_32.c     |   2 -
>  6 files changed, 115 insertions(+), 28 deletions(-)
>
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 7251c4f..fea49ec 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -154,7 +154,7 @@
>
>  #endif /* CONFIG_X86_32_LAZY_GS */
>
> -.macro SAVE_ALL pt_regs_ax=%eax
> +.macro SAVE_ALL pt_regs_ax=%eax switch_stacks=0
>         cld
>         PUSH_GS
>         pushl   %fs
> @@ -173,6 +173,12 @@
>         movl    $(__KERNEL_PERCPU), %edx
>         movl    %edx, %fs
>         SET_KERNEL_GS %edx
> +
> +       /* Switch to kernel stack if necessary */
> +.if \switch_stacks > 0
> +       SWITCH_TO_KERNEL_STACK
> +.endif
> +
>  .endm
>
>  /*
> @@ -269,6 +275,73 @@
>  .Lend_\@:
>  #endif /* CONFIG_X86_ESPFIX32 */
>  .endm
> +
> +
> +/*
> + * Called with pt_regs fully populated and kernel segments loaded,
> + * so we can access PER_CPU and use the integer registers.
> + *
> + * We need to be very careful here with the %esp switch, because an NMI
> + * can happen everywhere. If the NMI handler finds itself on the
> + * entry-stack, it will overwrite the task-stack and everything we
> + * copied there. So allocate the stack-frame on the task-stack and
> + * switch to it before we do any copying.
> + */
> +.macro SWITCH_TO_KERNEL_STACK
> +
> +       ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
> +
> +       /* Are we on the entry stack? Bail out if not! */
> +       movl    PER_CPU_VAR(cpu_entry_area), %ecx
> +       addl    $CPU_ENTRY_AREA_entry_stack + SIZEOF_entry_stack, %ecx
> +       subl    %esp, %ecx      /* ecx = (end of entry_stack) - esp */
> +       cmpl    $SIZEOF_entry_stack, %ecx
> +       jae     .Lend_\@
> +
> +       /* Load stack pointer into %esi and %edi */
> +       movl    %esp, %esi
> +       movl    %esi, %edi
> +
> +       /* Move %edi to the top of the entry stack */
> +       andl    $(MASK_entry_stack), %edi
> +       addl    $(SIZEOF_entry_stack), %edi
> +
> +       /* Load top of task-stack into %edi */
> +       movl    TSS_entry2task_stack(%edi), %edi
> +
> +       /* Bytes to copy */
> +       movl    $PTREGS_SIZE, %ecx
> +
> +#ifdef CONFIG_VM86
> +       testl   $X86_EFLAGS_VM, PT_EFLAGS(%esi)
> +       jz      .Lcopy_pt_regs_\@
> +
> +       /*
> +        * Stack-frame contains 4 additional segment registers when
> +        * coming from VM86 mode
> +        */
> +       addl    $(4 * 4), %ecx
> +
> +.Lcopy_pt_regs_\@:
> +#endif
> +
> +       /* Allocate frame on task-stack */
> +       subl    %ecx, %edi
> +
> +       /* Switch to task-stack */
> +       movl    %edi, %esp
> +
> +       /*
> +        * We are now on the task-stack and can safely copy over the
> +        * stack-frame
> +        */
> +       shrl    $2, %ecx

This shift can be removed if you divide the constants by 4 above.
Ditto on the exit path in the next patch.

--
Brian Gerst
