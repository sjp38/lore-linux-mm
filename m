Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4BF26B0007
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 06:39:43 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f20-v6so4585998qta.16
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 03:39:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i17-v6si592033qvj.89.2018.10.03.03.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 03:39:42 -0700 (PDT)
Date: Wed, 3 Oct 2018 12:39:59 +0200
From: Eugene Syromiatnikov <esyr@redhat.com>
Subject: Re: [RFC PATCH v4 06/27] x86/cet: Control protection exception
 handler
Message-ID: <20181003103959.GB7111@asgard.redhat.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-7-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921150351.20898-7-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 08:03:30AM -0700, Yu-cheng Yu wrote:

> diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
> index e6db475164ed..873765adc244 100644
> --- a/arch/x86/kernel/traps.c
> +++ b/arch/x86/kernel/traps.c
> @@ -578,6 +578,64 @@ do_general_protection(struct pt_regs *regs, long error_code)
>  }
>  NOKPROBE_SYMBOL(do_general_protection);
>  
> +static const char *control_protection_err[] =
> +{
> +	"unknown",
> +	"near-ret",
> +	"far-ret/iret",
> +	"endbranch",
> +	"rstorssp",
> +	"setssbsy",
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
> +	struct task_struct *tsk;
> +
> +	RCU_LOCKDEP_WARN(!rcu_is_watching(), "entry code didn't wake RCU");
> +	if (notify_die(DIE_TRAP, "control protection fault", regs,
> +		       error_code, X86_TRAP_CP, SIGSEGV) == NOTIFY_STOP)
> +		return;
> +	cond_local_irq_enable(regs);
> +
> +	if (!user_mode(regs))
> +		die("kernel control protection fault", regs, error_code);
> +
> +	if (!static_cpu_has(X86_FEATURE_SHSTK) &&
> +	    !static_cpu_has(X86_FEATURE_IBT))
> +		WARN_ONCE(1, "CET is disabled but got control "
> +			  "protection fault\n");
> +
> +	tsk = current;
> +	tsk->thread.error_code = error_code;
> +	tsk->thread.trap_nr = X86_TRAP_CP;
> +
> +	if (show_unhandled_signals && unhandled_signal(tsk, SIGSEGV) &&
> +	    printk_ratelimit()) {
> +		unsigned int max_err;
> +
> +		max_err = ARRAY_SIZE(control_protection_err) - 1;
> +		if ((error_code < 0) || (error_code > max_err))
> +			error_code = 0;
> +		pr_info("%s[%d] control protection ip:%lx sp:%lx error:%lx(%s)",
> +			tsk->comm, task_pid_nr(tsk),
> +			regs->ip, regs->sp, error_code,
> +			control_protection_err[error_code]);
> +		print_vma_addr(KERN_CONT " in ", regs->ip);
> +		pr_cont("\n");
> +	}
> +
> +	force_sig_info(SIGSEGV, SEND_SIG_PRIV, tsk);

That way, no information is provided to userspace (both application and
debugger), which is rather unfortunate. It would be nice if a new SEGV_*
code was added at least, and CET error (with error code constant provided
in UAPI) is passed via si_errno. (Having ip/sp/*ssp would be even
better, but I'm not exactly sure about ramifications of providing this
kind of information to user space).
