Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80D896B000A
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 12:26:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e7-v6so4751520pfi.8
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:26:56 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m12-v6si15430606pll.461.2018.06.07.09.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 09:26:54 -0700 (PDT)
Message-ID: <1528388623.4636.19.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 1/9] x86/cet: Control protection exception handler
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 09:23:43 -0700
In-Reply-To: <CALCETrVbQDyvgf5XE+a0UrTVMuhb2X=bSbp1BjGp2FAvbpSm-Q@mail.gmail.com>
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
	 <20180607143705.3531-2-yu-cheng.yu@intel.com>
	 <CALCETrVbQDyvgf5XE+a0UrTVMuhb2X=bSbp1BjGp2FAvbpSm-Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 08:46 -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:40 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >

...

> > diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> > index bef8e2b202a8..14b63ef0d7d8 100644
> > --- a/arch/x86/entry/entry_32.S
> > +++ b/arch/x86/entry/entry_32.S
> > @@ -1070,6 +1070,11 @@ ENTRY(general_protection)
> >         jmp     common_exception
> >  END(general_protection)
> >
> > +ENTRY(control_protection)
> > +       pushl   $do_control_protection
> > +       jmp     common_exception
> > +END(control_protection)
> 
> Ugh, you're seriously supporting this on 32-bit?  Please test double
> fault handling very carefully -- the CET interaction with task
> switches is so gross that I didn't even bother reading the spec except
> to let the architects know that they were a but nuts to support it at
> all.
> 

I will remove this.

...

> > diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
> > index 03f3d7695dac..4e8769a19aaf 100644
> > --- a/arch/x86/kernel/traps.c
> > +++ b/arch/x86/kernel/traps.c
> 
> > +/*
> > + * When a control protection exception occurs, send a signal
> > + * to the responsible application.  Currently, control
> > + * protection is only enabled for the user mode.  This
> > + * exception should not come from the kernel mode.
> > + */
> > +dotraplinkage void
> > +do_control_protection(struct pt_regs *regs, long error_code)
> > +{
> > +       struct task_struct *tsk;
> > +
> > +       RCU_LOCKDEP_WARN(!rcu_is_watching(), "entry code didn't wake RCU");
> > +       cond_local_irq_enable(regs);
> > +
> > +       tsk = current;
> > +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
> > +           !cpu_feature_enabled(X86_FEATURE_IBT)) {
> 
> static_cpu_has(), please.  But your handling here is odd -- I think
> that we should at least warn if we get #CP with CET disable.

I will fix it.

> 
> > +               goto exit;
> > +       }
> > +
> > +       if (!user_mode(regs)) {
> > +               tsk->thread.error_code = error_code;
> > +               tsk->thread.trap_nr = X86_TRAP_CP;
> 
> I realize you copied this from elsewhere in the file, but please
> either delete these assignments to error_code and trap_nr or at least
> hoist them out of the if block.

I will fix it.

> 
> > +               if (notify_die(DIE_TRAP, "control protection fault", regs,
> > +                              error_code, X86_TRAP_CP, SIGSEGV) != NOTIFY_STOP)
> 
> Does this notify_die() check serve any purpose at all?  Removing all
> the old ones would be a project, but let's try not to add new callers.

OK.

> 
> > +                       die("control protection fault", regs, error_code);
> > +               return;
> > +       }
> > +
> > +       tsk->thread.error_code = error_code;
> > +       tsk->thread.trap_nr = X86_TRAP_CP;
> > +
> > +       if (show_unhandled_signals && unhandled_signal(tsk, SIGSEGV) &&
> > +           printk_ratelimit()) {
> > +               unsigned int max_idx, err_idx;
> > +
> > +               max_idx = ARRAY_SIZE(control_protection_err) - 1;
> > +               err_idx = min((unsigned int)error_code - 1, max_idx);
> 
> What if error_code == 0?  Is that also invalid?

The error code is between 1 and 5 inclusive.  I thought if it is 0, then
err_idx would become max_idx here.  I can change it to:

if (error_code == 0)
	error_code = max_idx;

Or, add some comments for this case.

> 
> > +               pr_info("%s[%d] control protection ip:%lx sp:%lx error:%lx(%s)",
> > +                       tsk->comm, task_pid_nr(tsk),
> > +                       regs->ip, regs->sp, error_code,
> > +                       control_protection_err[err_idx]);
> > +               print_vma_addr(" in ", regs->ip);
> > +               pr_cont("\n");
> > +       }
> > +
> > +exit:
> > +       force_sig_info(SIGSEGV, SEND_SIG_PRIV, tsk);
> 
> This is definitely wrong for the feature-disabled, !user_mode case.
> 

I will fix it.

> Also, are you planning on enabling CET for kernel code too?

Yes, kernel protection will be enabled later.
