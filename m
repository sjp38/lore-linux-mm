Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 846A56B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:03:41 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 70-v6so18234439plc.1
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:03:41 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c10-v6si21592234pll.275.2018.07.12.16.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:03:40 -0700 (PDT)
Message-ID: <1531436398.2965.18.camel@intel.com>
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 12 Jul 2018 15:59:58 -0700
In-Reply-To: <bbb487cc-ac1c-f734-eee3-2463a0ba7efc@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-19-yu-cheng.yu@intel.com>
	 <bbb487cc-ac1c-f734-eee3-2463a0ba7efc@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-07-10 at 16:48 -0700, Dave Hansen wrote:
> > 
> > +/*
> > + * WRUSS is a kernel instrcution and but writes to user
> > + * shadow stack memory.A A When a fault occurs, both
> > + * X86_PF_USER and X86_PF_SHSTK are set.
> > + */
> > +static int is_wruss(struct pt_regs *regs, unsigned long error_code)
> > +{
> > +	return (((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
> > +		(X86_PF_USER | X86_PF_SHSTK)) && !user_mode(regs));
> > +}
> I thought X86_PF_USER was set based on the mode in which the fault
> occurred.A A Does this mean that the architecture of this bit is different
> now?

Yes.

> That seems like something we need to call out if so.A A It also means we
> need to update the SDM because some of the text is wrong.

It needs to mention the WRUSS case.

> 
> > 
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
> This needs commenting about why is_wruss() is special.

Ok.
