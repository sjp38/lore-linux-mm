Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA8E728024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:45:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y13so5839843pfl.16
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:45:50 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g21si2679389plo.236.2018.01.16.14.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 14:45:49 -0800 (PST)
Received: from mail-it0-f47.google.com (mail-it0-f47.google.com [209.85.214.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CF06E21783
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:45:48 +0000 (UTC)
Received: by mail-it0-f47.google.com with SMTP id w14so6159456itc.3
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:45:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-3-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-3-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 16 Jan 2018 14:45:27 -0800
Message-ID: <CALCETrUqJ8Vga5pGWUuOox5cw6ER-4MhZXLb-4JPyh+Txsp4tg@mail.gmail.com>
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Use the sysenter stack as a trampoline stack to enter the
> kernel. The sysenter stack is already in the cpu_entry_area
> and will be mapped to userspace when PTI is enabled.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/entry/entry_32.S        | 89 +++++++++++++++++++++++++++++++++++-----
>  arch/x86/include/asm/switch_to.h |  6 +--
>  arch/x86/kernel/asm-offsets_32.c |  4 +-
>  arch/x86/kernel/cpu/common.c     |  5 ++-
>  arch/x86/kernel/process.c        |  2 -
>  arch/x86/kernel/process_32.c     |  6 +++
>  6 files changed, 91 insertions(+), 21 deletions(-)
>
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index eb8c5615777b..5a7bdb73be9f 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -222,6 +222,47 @@
>  .endm
>
>  /*
> + * Switch from the entry-trampline stack to the kernel stack of the
> + * running task.
> + *
> + * nr_regs is the number of dwords to push from the entry stack to the
> + * task stack. If it is > 0 it expects an irq frame at the bottom of the
> + * stack.
> + *
> + * check_user != 0 it will add a check to only switch stacks if the
> + * kernel entry was from user-space.
> + */
> +.macro SWITCH_TO_KERNEL_STACK nr_regs=0 check_user=0

How about marking nr_regs with :req to force everyone to be explicit?

> +
> +       .if \check_user > 0 && \nr_regs > 0
> +       testb $3, (\nr_regs - 4)*4(%esp)                /* CS */
> +       jz .Lend_\@
> +       .endif
> +
> +       pushl %edi
> +       movl  %esp, %edi
> +
> +       /*
> +        * TSS_sysenter_stack is the offset from the bottom of the
> +        * entry-stack
> +        */
> +       movl  TSS_sysenter_stack + ((\nr_regs + 1) * 4)(%esp), %esp

This is incomprehensible.  You're adding what appears to be the offset
of sysenter_stack within the TSS to something based on esp and
dereferencing that to get the new esp.  That't not actually what
you're doing, but please change asm_offsets.c (as in my previous
email) to avoid putting serious arithmetic in it and then do the
arithmetic right here so that it's possible to follow what's going on.

> +
> +       /* Copy the registers over */
> +       .if \nr_regs > 0
> +       i = 0
> +       .rept \nr_regs
> +       pushl (\nr_regs - i) * 4(%edi)
> +       i = i + 1
> +       .endr
> +       .endif
> +
> +       mov (%edi), %edi
> +
> +.Lend_\@:
> +.endm
> +
> +/*
>   * %eax: prev task
>   * %edx: next task
>   */
> @@ -401,7 +442,9 @@ ENTRY(xen_sysenter_target)
>   * 0(%ebp) arg6
>   */
>  ENTRY(entry_SYSENTER_32)
> -       movl    TSS_sysenter_stack(%esp), %esp
> +       /* Kernel stack is empty */
> +       SWITCH_TO_KERNEL_STACK

This would be more readable if you put nr_regs in here.

> +
>  .Lsysenter_past_esp:
>         pushl   $__USER_DS              /* pt_regs->ss */
>         pushl   %ebp                    /* pt_regs->sp (stashed in bp) */
> @@ -521,6 +564,10 @@ ENDPROC(entry_SYSENTER_32)
>  ENTRY(entry_INT80_32)
>         ASM_CLAC
>         pushl   %eax                    /* pt_regs->orig_ax */
> +
> +       /* Stack layout: ss, esp, eflags, cs, eip, orig_eax */
> +       SWITCH_TO_KERNEL_STACK nr_regs=6 check_user=1
> +

Why check_user?

> @@ -655,6 +702,10 @@ END(irq_entries_start)
>  common_interrupt:
>         ASM_CLAC
>         addl    $-0x80, (%esp)                  /* Adjust vector into the [-256, -1] range */
> +
> +       /* Stack layout: ss, esp, eflags, cs, eip, vector */
> +       SWITCH_TO_KERNEL_STACK nr_regs=6 check_user=1

LGTM.

>  ENTRY(nmi)
>         ASM_CLAC
> +
> +       /* Stack layout: ss, esp, eflags, cs, eip */
> +       SWITCH_TO_KERNEL_STACK nr_regs=5 check_user=1

This is wrong, I think.  If you get an nmi in kernel mode but while
still on the sysenter stack, you blow up.  IIRC we have some crazy
code already to handle this (for nmi and #DB), and maybe that's
already adequate or can be made adequate, but at the very least this
needs a big comment explaining why it's okay.

> diff --git a/arch/x86/include/asm/switch_to.h b/arch/x86/include/asm/switch_to.h
> index eb5f7999a893..20e5f7ab8260 100644
> --- a/arch/x86/include/asm/switch_to.h
> +++ b/arch/x86/include/asm/switch_to.h
> @@ -89,13 +89,9 @@ static inline void refresh_sysenter_cs(struct thread_struct *thread)
>  /* This is used when switching tasks or entering/exiting vm86 mode. */
>  static inline void update_sp0(struct task_struct *task)
>  {
> -       /* On x86_64, sp0 always points to the entry trampoline stack, which is constant: */
> -#ifdef CONFIG_X86_32
> -       load_sp0(task->thread.sp0);
> -#else
> +       /* sp0 always points to the entry trampoline stack, which is constant: */
>         if (static_cpu_has(X86_FEATURE_XENPV))
>                 load_sp0(task_top_of_stack(task));
> -#endif
>  }
>
>  #endif /* _ASM_X86_SWITCH_TO_H */
> diff --git a/arch/x86/kernel/asm-offsets_32.c b/arch/x86/kernel/asm-offsets_32.c
> index 654229bac2fc..7270dd834f4b 100644
> --- a/arch/x86/kernel/asm-offsets_32.c
> +++ b/arch/x86/kernel/asm-offsets_32.c
> @@ -47,9 +47,11 @@ void foo(void)
>         BLANK();
>
>         /* Offset from the sysenter stack to tss.sp0 */
> -       DEFINE(TSS_sysenter_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
> +       DEFINE(TSS_sysenter_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp1) -
>                offsetofend(struct cpu_entry_area, entry_stack_page.stack));



>
> +       OFFSET(TSS_sp1, tss_struct, x86_tss.sp1);
> +
>  #ifdef CONFIG_CC_STACKPROTECTOR
>         BLANK();
>         OFFSET(stack_canary_offset, stack_canary, canary);
> diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
> index ef29ad001991..20a71c914e59 100644
> --- a/arch/x86/kernel/cpu/common.c
> +++ b/arch/x86/kernel/cpu/common.c
> @@ -1649,11 +1649,12 @@ void cpu_init(void)
>         enter_lazy_tlb(&init_mm, curr);
>
>         /*
> -        * Initialize the TSS.  Don't bother initializing sp0, as the initial
> -        * task never enters user mode.
> +        * Initialize the TSS.  sp0 points to the entry trampoline stack
> +        * regardless of what task is running.
>          */
>         set_tss_desc(cpu, &get_cpu_entry_area(cpu)->tss.x86_tss);
>         load_TR_desc();
> +       load_sp0((unsigned long)(cpu_entry_stack(cpu) + 1));

It's high time we unified the 32-bit and 64-bit versions of the code.
This isn't necessarily needed for your series, though.

> diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
> index 5224c6099184..452eeac00b80 100644
> --- a/arch/x86/kernel/process_32.c
> +++ b/arch/x86/kernel/process_32.c
> @@ -292,6 +292,12 @@ __switch_to(struct task_struct *prev_p, struct task_struct *next_p)
>         this_cpu_write(cpu_current_top_of_stack,
>                        (unsigned long)task_stack_page(next_p) +
>                        THREAD_SIZE);
> +       /*
> +        * TODO: Find a way to let cpu_current_top_of_stack point to
> +        * cpu_tss_rw.x86_tss.sp1. Doing so now results in stack corruption with
> +        * iret exceptions.
> +        */
> +       this_cpu_write(cpu_tss_rw.x86_tss.sp1, next_p->thread.sp0);

Do you know what the issue is?

As a general comment, the interaction between this patch and vm86 is a
bit scary.  In vm86 mode, the kernel gets entered with extra stuff on
the stack, which may screw up all your offsets.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
