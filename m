Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A436B6B026C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 11:46:57 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g6-v6so5626609plq.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 08:46:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x32-v6si53142311pld.435.2018.06.07.08.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 08:46:56 -0700 (PDT)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0EB342089C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 15:46:56 +0000 (UTC)
Received: by mail-it0-f49.google.com with SMTP id l6-v6so13257604iti.2
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 08:46:56 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143705.3531-1-yu-cheng.yu@intel.com> <20180607143705.3531-2-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143705.3531-2-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 08:46:43 -0700
Message-ID: <CALCETrVbQDyvgf5XE+a0UrTVMuhb2X=bSbp1BjGp2FAvbpSm-Q@mail.gmail.com>
Subject: Re: [PATCH 1/9] x86/cet: Control protection exception handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 7:40 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> A control protection exception is triggered when a control flow transfer
> attempt violated shadow stack or indirect branch tracking constraints.
> For example, the return address for a RET instruction differs from the
> safe copy on the shadow stack; or a JMP instruction arrives at a non-
> ENDBR instruction.
>
> The control protection exception handler works in a similar way as the
> general protection fault handler.
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/entry/entry_32.S    |  5 ++++
>  arch/x86/entry/entry_64.S    |  2 +-
>  arch/x86/include/asm/traps.h |  3 +++
>  arch/x86/kernel/idt.c        |  1 +
>  arch/x86/kernel/traps.c      | 61 ++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 71 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index bef8e2b202a8..14b63ef0d7d8 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -1070,6 +1070,11 @@ ENTRY(general_protection)
>         jmp     common_exception
>  END(general_protection)
>
> +ENTRY(control_protection)
> +       pushl   $do_control_protection
> +       jmp     common_exception
> +END(control_protection)

Ugh, you're seriously supporting this on 32-bit?  Please test double
fault handling very carefully -- the CET interaction with task
switches is so gross that I didn't even bother reading the spec except
to let the architects know that they were a but nuts to support it at
all.

> +
>  #ifdef CONFIG_KVM_GUEST
>  ENTRY(async_page_fault)
>         ASM_CLAC
> diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
> index 3166b9674429..5230f705d229 100644
> --- a/arch/x86/entry/entry_64.S
> +++ b/arch/x86/entry/entry_64.S
> @@ -999,7 +999,7 @@ idtentry spurious_interrupt_bug             do_spurious_interrupt_bug       has_error_code=0
>  idtentry coprocessor_error             do_coprocessor_error            has_error_code=0
>  idtentry alignment_check               do_alignment_check              has_error_code=1
>  idtentry simd_coprocessor_error                do_simd_coprocessor_error       has_error_code=0
> -
> +idtentry control_protection            do_control_protection           has_error_code=1
> diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
> index 03f3d7695dac..4e8769a19aaf 100644
> --- a/arch/x86/kernel/traps.c
> +++ b/arch/x86/kernel/traps.c

> +/*
> + * When a control protection exception occurs, send a signal
> + * to the responsible application.  Currently, control
> + * protection is only enabled for the user mode.  This
> + * exception should not come from the kernel mode.
> + */
> +dotraplinkage void
> +do_control_protection(struct pt_regs *regs, long error_code)
> +{
> +       struct task_struct *tsk;
> +
> +       RCU_LOCKDEP_WARN(!rcu_is_watching(), "entry code didn't wake RCU");
> +       cond_local_irq_enable(regs);
> +
> +       tsk = current;
> +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
> +           !cpu_feature_enabled(X86_FEATURE_IBT)) {

static_cpu_has(), please.  But your handling here is odd -- I think
that we should at least warn if we get #CP with CET disable.

> +               goto exit;
> +       }
> +
> +       if (!user_mode(regs)) {
> +               tsk->thread.error_code = error_code;
> +               tsk->thread.trap_nr = X86_TRAP_CP;

I realize you copied this from elsewhere in the file, but please
either delete these assignments to error_code and trap_nr or at least
hoist them out of the if block.

> +               if (notify_die(DIE_TRAP, "control protection fault", regs,
> +                              error_code, X86_TRAP_CP, SIGSEGV) != NOTIFY_STOP)

Does this notify_die() check serve any purpose at all?  Removing all
the old ones would be a project, but let's try not to add new callers.

> +                       die("control protection fault", regs, error_code);
> +               return;
> +       }
> +
> +       tsk->thread.error_code = error_code;
> +       tsk->thread.trap_nr = X86_TRAP_CP;
> +
> +       if (show_unhandled_signals && unhandled_signal(tsk, SIGSEGV) &&
> +           printk_ratelimit()) {
> +               unsigned int max_idx, err_idx;
> +
> +               max_idx = ARRAY_SIZE(control_protection_err) - 1;
> +               err_idx = min((unsigned int)error_code - 1, max_idx);

What if error_code == 0?  Is that also invalid?

> +               pr_info("%s[%d] control protection ip:%lx sp:%lx error:%lx(%s)",
> +                       tsk->comm, task_pid_nr(tsk),
> +                       regs->ip, regs->sp, error_code,
> +                       control_protection_err[err_idx]);
> +               print_vma_addr(" in ", regs->ip);
> +               pr_cont("\n");
> +       }
> +
> +exit:
> +       force_sig_info(SIGSEGV, SEND_SIG_PRIV, tsk);

This is definitely wrong for the feature-disabled, !user_mode case.

Also, are you planning on enabling CET for kernel code too?
