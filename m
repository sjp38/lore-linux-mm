Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA2696B5789
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 11:02:10 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q11-v6so11282027oih.15
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 08:02:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f186-v6sor7570431oig.110.2018.08.31.08.02.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 Aug 2018 08:02:09 -0700 (PDT)
MIME-Version: 1.0
References: <20180830143904.3168-1-yu-cheng.yu@intel.com> <20180830143904.3168-7-yu-cheng.yu@intel.com>
In-Reply-To: <20180830143904.3168-7-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Fri, 31 Aug 2018 17:01:42 +0200
Message-ID: <CAG48ez0jvsDw189=YoCCa8tmJUENeUd_ypcP5bYJ+eLMPCYCOQ@mail.gmail.com>
Subject: Re: [RFC PATCH v3 06/24] x86/cet: Control protection exception handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Thu, Aug 30, 2018 at 4:43 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> A control protection exception is triggered when a control flow transfer
> attempt violated shadow stack or indirect branch tracking constraints.
> For example, the return address for a RET instruction differs from the
> safe copy on the shadow stack; or a JMP instruction arrives at a non-
> ENDBR instruction.
>
> The control protection exception handler works in a similar way as the
> general protection fault handler.

Is there a reason why all the code in this patch isn't #ifdef'ed away
on builds that don't support CET? It looks like the CET handler is
hooked up to the IDT conditionally, but the handler code is always
built?

> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/entry/entry_64.S    |  2 +-
>  arch/x86/include/asm/traps.h |  3 ++
>  arch/x86/kernel/idt.c        |  4 +++
>  arch/x86/kernel/traps.c      | 58 ++++++++++++++++++++++++++++++++++++
>  4 files changed, 66 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
> index 957dfb693ecc..5f4914e988df 100644
> --- a/arch/x86/entry/entry_64.S
> +++ b/arch/x86/entry/entry_64.S
> @@ -1000,7 +1000,7 @@ idtentry spurious_interrupt_bug           do_spurious_interrupt_bug       has_error_code=0
>  idtentry coprocessor_error             do_coprocessor_error            has_error_code=0
>  idtentry alignment_check               do_alignment_check              has_error_code=1
>  idtentry simd_coprocessor_error                do_simd_coprocessor_error       has_error_code=0
> -
> +idtentry control_protection            do_control_protection           has_error_code=1
>
>         /*
>          * Reload gs selector with exception handling
> diff --git a/arch/x86/include/asm/traps.h b/arch/x86/include/asm/traps.h
> index 3de69330e6c5..5196050ff3d5 100644
> --- a/arch/x86/include/asm/traps.h
> +++ b/arch/x86/include/asm/traps.h
> @@ -26,6 +26,7 @@ asmlinkage void invalid_TSS(void);
>  asmlinkage void segment_not_present(void);
>  asmlinkage void stack_segment(void);
>  asmlinkage void general_protection(void);
> +asmlinkage void control_protection(void);
>  asmlinkage void page_fault(void);
>  asmlinkage void async_page_fault(void);
>  asmlinkage void spurious_interrupt_bug(void);
> @@ -77,6 +78,7 @@ dotraplinkage void do_stack_segment(struct pt_regs *, long);
>  dotraplinkage void do_double_fault(struct pt_regs *, long);
>  #endif
>  dotraplinkage void do_general_protection(struct pt_regs *, long);
> +dotraplinkage void do_control_protection(struct pt_regs *, long);
>  dotraplinkage void do_page_fault(struct pt_regs *, unsigned long);
>  dotraplinkage void do_spurious_interrupt_bug(struct pt_regs *, long);
>  dotraplinkage void do_coprocessor_error(struct pt_regs *, long);
> @@ -142,6 +144,7 @@ enum {
>         X86_TRAP_AC,            /* 17, Alignment Check */
>         X86_TRAP_MC,            /* 18, Machine Check */
>         X86_TRAP_XF,            /* 19, SIMD Floating-Point Exception */
> +       X86_TRAP_CP = 21,       /* 21 Control Protection Fault */
>         X86_TRAP_IRET = 32,     /* 32, IRET Exception */
>  };
>
> diff --git a/arch/x86/kernel/idt.c b/arch/x86/kernel/idt.c
> index 01adea278a71..2d02fdd599a2 100644
> --- a/arch/x86/kernel/idt.c
> +++ b/arch/x86/kernel/idt.c
> @@ -104,6 +104,10 @@ static const __initconst struct idt_data def_idts[] = {
>  #elif defined(CONFIG_X86_32)
>         SYSG(IA32_SYSCALL_VECTOR,       entry_INT80_32),
>  #endif
> +
> +#ifdef CONFIG_X86_INTEL_CET
> +       INTG(X86_TRAP_CP,               control_protection),
> +#endif
>  };
>
>  /*
> diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
> index e6db475164ed..21a713b96148 100644
> --- a/arch/x86/kernel/traps.c
> +++ b/arch/x86/kernel/traps.c
> @@ -578,6 +578,64 @@ do_general_protection(struct pt_regs *regs, long error_code)
>  }
>  NOKPROBE_SYMBOL(do_general_protection);
>
> +static const char *control_protection_err[] =
> +{
> +       "unknown",
> +       "near-ret",
> +       "far-ret/iret",
> +       "endbranch",
> +       "rstorssp",
> +       "setssbsy",
> +};
> +
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
> +       if (notify_die(DIE_TRAP, "control protection fault", regs,
> +                      error_code, X86_TRAP_CP, SIGSEGV) == NOTIFY_STOP)
> +               return;
> +       cond_local_irq_enable(regs);
> +
> +       if (!user_mode(regs))
> +               die("kernel control protection fault", regs, error_code);
> +
> +       if (!static_cpu_has(X86_FEATURE_SHSTK) &&
> +           !static_cpu_has(X86_FEATURE_IBT))
> +               WARN_ONCE(1, "CET is disabled but got control "
> +                         "protection fault\n");
> +
> +       tsk = current;
> +       tsk->thread.error_code = error_code;
> +       tsk->thread.trap_nr = X86_TRAP_CP;
> +
> +       if (show_unhandled_signals && unhandled_signal(tsk, SIGSEGV) &&
> +           printk_ratelimit()) {
> +               unsigned int max_err;
> +
> +               max_err = ARRAY_SIZE(control_protection_err) - 1;
> +               if ((error_code < 0) || (error_code > max_err))
> +                       error_code = 0;
> +               pr_info("%s[%d] control protection ip:%lx sp:%lx error:%lx(%s)",
> +                       tsk->comm, task_pid_nr(tsk),
> +                       regs->ip, regs->sp, error_code,
> +                       control_protection_err[error_code]);
> +               print_vma_addr(" in ", regs->ip);

Shouldn't this be using KERN_CONT, like other callers of
print_vma_addr(), to get the desired output?

> +               pr_cont("\n");
> +       }
> +
> +       force_sig_info(SIGSEGV, SEND_SIG_PRIV, tsk);
