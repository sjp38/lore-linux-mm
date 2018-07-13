Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2977B6B0266
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 13:40:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k21-v6so1452322pfi.12
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 10:40:53 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t1-v6si23526453plo.241.2018.07.13.10.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 10:40:52 -0700 (PDT)
Message-ID: <1531503430.11680.2.camel@intel.com>
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 13 Jul 2018 10:37:10 -0700
In-Reply-To: <166536e2-b296-7be5-d1b7-982cf56f1f9b@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-19-yu-cheng.yu@intel.com>
	 <166536e2-b296-7be5-d1b7-982cf56f1f9b@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, 2018-07-13 at 05:12 -0700, Dave Hansen wrote:
> On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> > 
> > +static int is_wruss(struct pt_regs *regs, unsigned long error_code)
> > +{
> > +	return (((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
> > +		(X86_PF_USER | X86_PF_SHSTK)) && !user_mode(regs));
> > +}
> > +
> > A static void
> > A show_fault_oops(struct pt_regs *regs, unsigned long error_code,
> > A 		unsigned long address)
> > @@ -848,7 +859,7 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
> > A 	struct task_struct *tsk = current;
> > A 
> > A 	/* User mode accesses just cause a SIGSEGV */
> > -	if (error_code & X86_PF_USER) {
> > +	if ((error_code & X86_PF_USER) && !is_wruss(regs, error_code)) {
> > A 		/*
> > A 		A * It's possible to have interrupts off here:
> > A 		A */
> Please don't do it this way.
> 
> We have two styles of page fault:
> 1. User page faults: find a VMA, try to handle (allocate memory et al.),
> A A A kill process if we can't handle.
> 2. Kernel page faults: search for a *discrete* set of conditions that
> A A A can be handled, including faults in instructions marked in exception
> A A A tables.
> 
> X86_PF_USER *means*: do user page fault handling.A A In the places where
> the hardware doesn't set it, but we still want user page fault handling,
> we manually set it, like this where we "downgrade" an implicit
> supervisor access to a user access:
> 
> A A A A A A A A if (user_mode(regs)) {
> A A A A A A A A A A A A A A A A local_irq_enable();
> A A A A A A A A A A A A A A A A error_code |= X86_PF_USER;
> A A A A A A A A A A A A A A A A flags |= FAULT_FLAG_USER;
> 
> So, just please *clear* X86_PF_USER if !user_mode(regs) and X86_PF_SS.
> We do not want user page fault handling, thus we should not keep the bit
> set.

Agree. A I will change that.

Yu-cheng
