Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 162B36B000C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 11:10:35 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z21-v6so7531239plo.13
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:10:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o15-v6si11349029pgq.236.2018.07.11.08.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 08:10:33 -0700 (PDT)
Message-ID: <1531321615.13297.9.camel@intel.com>
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 08:06:55 -0700
In-Reply-To: <20180711094448.GZ2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-19-yu-cheng.yu@intel.com>
	 <20180711094448.GZ2476@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 11:44 +0200, Peter Zijlstra wrote:
> On Tue, Jul 10, 2018 at 03:26:30PM -0700, Yu-cheng Yu wrote:
> > 
> > WRUSS is a new kernel-mode instruction but writes directly
> > to user shadow stack memory.A A This is used to construct
> > a return address on the shadow stack for the signal
> > handler.
> > 
> > This instruction can fault if the user shadow stack is
> > invalid shadow stack memory.A A In that case, the kernel does
> > fixup.
> > 
> > 
> > +static inline int write_user_shstk_64(unsigned long addr, unsigned
> > long val)
> > +{
> > +	int err = 0;
> > +
> > +	asm volatile("1: wrussq %[val], (%[addr])\n"
> > +		A A A A A "xor %[err], %[err]\n"
> this XOR is superfluous, you already cleared @err above.

I will fix it.

> 
> > 
> > +		A A A A A "2:\n"
> > +		A A A A A ".section .fixup,\"ax\"\n"
> > +		A A A A A "3: mov $-1, %[err]; jmp 2b\n"
> > +		A A A A A ".previous\n"
> > +		A A A A A _ASM_EXTABLE(1b, 3b)
> > +		A A A A A : [err] "=a" (err)
> > +		A A A A A : [val] "S" (val), [addr] "D" (addr));
> > +
> > +	return err;
> > +}
> > +#endif /* CONFIG_X86_INTEL_CET */
> > +
> > A #define nop() asm volatile ("nop")
> What happened to:
> 
> A  https://lkml.kernel.org/r/1528729376.4526.0.camel@2b52.sc.intel.com

Yes, I put that in once and realized we only need to skip the
instruction and return err. A Do you think we still need a handler for
that?

Yu-cheng
