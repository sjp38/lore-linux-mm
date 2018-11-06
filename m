Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0C26B0393
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 15:26:52 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d6-v6so6102661pfn.19
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 12:26:52 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f19-v6si46581496pgj.334.2018.11.06.12.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 12:26:50 -0800 (PST)
Message-ID: <26c7e2dd72efe8168b296285985eb5f025881bb1.camel@intel.com>
Subject: Re: [PATCH v5 21/27] x86/cet/shstk: Introduce WRUSS instruction
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 06 Nov 2018 12:21:38 -0800
In-Reply-To: <ee5a93f7-ed42-dcc5-0e55-e73ac2637e84@intel.com>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
	 <20181011151523.27101-22-yu-cheng.yu@intel.com>
	 <ee5a93f7-ed42-dcc5-0e55-e73ac2637e84@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-11-06 at 10:43 -0800, Dave Hansen wrote:
> On 10/11/18 8:15 AM, Yu-cheng Yu wrote:
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -1305,6 +1305,15 @@ __do_page_fault(struct pt_regs *regs, unsigned long
> > error_code,
> >  		error_code |= X86_PF_USER;
> >  		flags |= FAULT_FLAG_USER;
> >  	} else {
> > +		/*
> > +		 * WRUSS is a kernel instruction and but writes
> > +		 * to user shadow stack.  When a fault occurs,
> > +		 * both X86_PF_USER and X86_PF_SHSTK are set.
> > +		 * Clear X86_PF_USER here.
> > +		 */
> > +		if ((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
> > +		    (X86_PF_USER | X86_PF_SHSTK))
> > +			error_code &= ~X86_PF_USER;
> 
> This hunk of code basically points out that the architecture of WRUSS is
> broken for Linux.  The setting of X86_PF_USER for a ring-0 instruction
> really is a mis-feature of the architecture for us and we *undo* it in
> software which is unfortunate.  Wish I would have caught this earlier.
> 
> Andy, note that this is another case where hw_error_code and
> sw_error_code will diverge, unfortunately.
> 
> Anyway, this is going to necessitate some comment updates in the page
> fault code.  Yu-cheng, you are going to collide with some recent changes
> I made to the page fault code.  Please be careful with the context when
> you do the merge and make sure that all the new comments stay correct.

Ok.  Thanks!

Yu-cheng
