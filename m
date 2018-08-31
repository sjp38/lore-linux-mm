Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2496B57DB
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 12:24:36 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w11-v6so6261369plq.8
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 09:24:36 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o12-v6si8977548pls.94.2018.08.31.09.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 09:24:35 -0700 (PDT)
Message-ID: <1535732418.3789.7.camel@intel.com>
Subject: Re: [RFC PATCH v3 06/24] x86/cet: Control protection exception
 handler
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 31 Aug 2018 09:20:18 -0700
In-Reply-To: <CAG48ez0jvsDw189=YoCCa8tmJUENeUd_ypcP5bYJ+eLMPCYCOQ@mail.gmail.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180830143904.3168-7-yu-cheng.yu@intel.com>
	 <CAG48ez0jvsDw189=YoCCa8tmJUENeUd_ypcP5bYJ+eLMPCYCOQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromium.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Fri, 2018-08-31 at 17:01 +0200, Jann Horn wrote:

> Is there a reason why all the code in this patch isn't #ifdef'ed
> away
> on builds that don't support CET? It looks like the CET handler is
> hooked up to the IDT conditionally, but the handler code is always
> built?

Yes, in idt.c, it should have been:

#ifdef CONFIG_X86_64
	INTG(X86_TRAP_CP,		control_protection),
#endif

I will fix it.

> > +dotraplinkage void
> > +do_control_protection(struct pt_regs *regs, long error_code)
> > +{
> > +A A A A A A A struct task_struct *tsk;
> > +
> > +A A A A A A A RCU_LOCKDEP_WARN(!rcu_is_watching(), "entry code didn't
> > wake RCU");
> > +A A A A A A A if (notify_die(DIE_TRAP, "control protection fault", regs,
> > +A A A A A A A A A A A A A A A A A A A A A A error_code, X86_TRAP_CP, SIGSEGV) ==
> > NOTIFY_STOP)
> > +A A A A A A A A A A A A A A A return;
> > +A A A A A A A cond_local_irq_enable(regs);
> > +
> > +A A A A A A A if (!user_mode(regs))
> > +A A A A A A A A A A A A A A A die("kernel control protection fault", regs,
> > error_code);
> > +
> > +A A A A A A A if (!static_cpu_has(X86_FEATURE_SHSTK) &&
> > +A A A A A A A A A A A !static_cpu_has(X86_FEATURE_IBT))
> > +A A A A A A A A A A A A A A A WARN_ONCE(1, "CET is disabled but got control "
> > +A A A A A A A A A A A A A A A A A A A A A A A A A "protection fault\n");
> > +
> > +A A A A A A A tsk = current;
> > +A A A A A A A tsk->thread.error_code = error_code;
> > +A A A A A A A tsk->thread.trap_nr = X86_TRAP_CP;
> > +
> > +A A A A A A A if (show_unhandled_signals && unhandled_signal(tsk,
> > SIGSEGV) &&
> > +A A A A A A A A A A A printk_ratelimit()) {
> > +A A A A A A A A A A A A A A A unsigned int max_err;
> > +
> > +A A A A A A A A A A A A A A A max_err = ARRAY_SIZE(control_protection_err) - 1;
> > +A A A A A A A A A A A A A A A if ((error_code < 0) || (error_code > max_err))
> > +A A A A A A A A A A A A A A A A A A A A A A A error_code = 0;
> > +A A A A A A A A A A A A A A A pr_info("%s[%d] control protection ip:%lx sp:%lx
> > error:%lx(%s)",
> > +A A A A A A A A A A A A A A A A A A A A A A A tsk->comm, task_pid_nr(tsk),
> > +A A A A A A A A A A A A A A A A A A A A A A A regs->ip, regs->sp, error_code,
> > +A A A A A A A A A A A A A A A A A A A A A A A control_protection_err[error_code]);
> > +A A A A A A A A A A A A A A A print_vma_addr(" in ", regs->ip);
> Shouldn't this be using KERN_CONT, like other callers of
> print_vma_addr(), to get the desired output?

I will change it.
