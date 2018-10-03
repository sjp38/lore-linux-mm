Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 299926B026D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:21:48 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id e3-v6so5810785pld.13
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:21:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id y30-v6si1987932pgk.13.2018.10.03.09.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 09:21:47 -0700 (PDT)
Message-ID: <9c93e864e5996862cb5fdb66d4140faa634cbc47.camel@intel.com>
Subject: Re: [RFC PATCH v4 06/27] x86/cet: Control protection exception
 handler
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 03 Oct 2018 09:11:34 -0700
In-Reply-To: <20181003103959.GB7111@asgard.redhat.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-7-yu-cheng.yu@intel.com>
	 <20181003103959.GB7111@asgard.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugene Syromiatnikov <esyr@redhat.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-10-03 at 12:39 +0200, Eugene Syromiatnikov wrote:
> On Fri, Sep 21, 2018 at 08:03:30AM -0700, Yu-cheng Yu wrote:
> > +dotraplinkage void
> > +do_control_protection(struct pt_regs *regs, long error_code)
> > +{
> > +	struct task_struct *tsk;
> > +
> > +	RCU_LOCKDEP_WARN(!rcu_is_watching(), "entry code didn't wake RCU");
> > +	if (notify_die(DIE_TRAP, "control protection fault", regs,
> > +		       error_code, X86_TRAP_CP, SIGSEGV) == NOTIFY_STOP)
> > +		return;
> > +	cond_local_irq_enable(regs);
> > +
> > +	if (!user_mode(regs))
> > +		die("kernel control protection fault", regs, error_code);
> > +
> > +	if (!static_cpu_has(X86_FEATURE_SHSTK) &&
> > +	    !static_cpu_has(X86_FEATURE_IBT))
> > +		WARN_ONCE(1, "CET is disabled but got control "
> > +			  "protection fault\n");
> > +
> > +	tsk = current;
> > +	tsk->thread.error_code = error_code;
> > +	tsk->thread.trap_nr = X86_TRAP_CP;
> > +
> > +	if (show_unhandled_signals && unhandled_signal(tsk, SIGSEGV) &&
> > +	    printk_ratelimit()) {
> > +		unsigned int max_err;
> > +
> > +		max_err = ARRAY_SIZE(control_protection_err) - 1;
> > +		if ((error_code < 0) || (error_code > max_err))
> > +			error_code = 0;
> > +		pr_info("%s[%d] control protection ip:%lx sp:%lx
> > error:%lx(%s)",
> > +			tsk->comm, task_pid_nr(tsk),
> > +			regs->ip, regs->sp, error_code,
> > +			control_protection_err[error_code]);
> > +		print_vma_addr(KERN_CONT " in ", regs->ip);
> > +		pr_cont("\n");
> > +	}
> > +
> > +	force_sig_info(SIGSEGV, SEND_SIG_PRIV, tsk);
> 
> That way, no information is provided to userspace (both application and
> debugger), which is rather unfortunate. It would be nice if a new SEGV_*
> code was added at least, and CET error (with error code constant provided
> in UAPI) is passed via si_errno. (Having ip/sp/*ssp would be even
> better, but I'm not exactly sure about ramifications of providing this
> kind of information to user space).

Ok, I will add that.

Yu-cheng
