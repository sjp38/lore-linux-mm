Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14D276B4FF8
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:26:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l65-v6so5256571pge.17
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:26:43 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id z16-v6si6847783pgi.252.2018.08.30.09.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 09:26:42 -0700 (PDT)
Message-ID: <1535646146.26689.11.camel@intel.com>
Subject: Re: [RFC PATCH v3 19/24] x86/cet/shstk: Introduce WRUSS instruction
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 30 Aug 2018 09:22:26 -0700
In-Reply-To: <CALCETrW78UKt6AQJeN8GkhtxjuASnH1PV5QSpzQtDz9-2d3Asw@mail.gmail.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180830143904.3168-20-yu-cheng.yu@intel.com>
	 <CAG48ez3uZrC-9uJ0uMoVPTtxRXRN8D+3zs5FknZD2woTT6mazg@mail.gmail.com>
	 <CALCETrW78UKt6AQJeN8GkhtxjuASnH1PV5QSpzQtDz9-2d3Asw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Jann Horn <jannh@google.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Thu, 2018-08-30 at 08:55 -0700, Andy Lutomirski wrote:
> On Thu, Aug 30, 2018 at 8:39 AM, Jann Horn <jannh@google.com> wrote:
> > 
> > On Thu, Aug 30, 2018 at 4:44 PM Yu-cheng Yu <yu-cheng.yu@intel.com
> > > wrote:
> > > 
> > > 
> > > WRUSS is a new kernel-mode instruction but writes directly
> > > to user shadow stack memory.A A This is used to construct
> > > a return address on the shadow stack for the signal
> > > handler.
> > > 
> > > This instruction can fault if the user shadow stack is
> > > invalid shadow stack memory.A A In that case, the kernel does
> > > fixup.
> > > 
> > > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > [...]
> > > 
> > > +static inline int write_user_shstk_64(unsigned long addr,
> > > unsigned long val)
> > > +{
> > > +A A A A A A A int err = 0;
> > > +
> > > +A A A A A A A asm volatile("1: wrussq %1, (%0)\n"
> > > +A A A A A A A A A A A A A A A A A A A A "2:\n"
> > > +A A A A A A A A A A A A A A A A A A A A _ASM_EXTABLE_HANDLE(1b, 2b,
> > > ex_handler_wruss)
> > > +A A A A A A A A A A A A A A A A A A A A :
> > > +A A A A A A A A A A A A A A A A A A A A : "r" (addr), "r" (val));
> > > +
> > > +A A A A A A A return err;
> > > +}
> > What's up with "err"? You set it to zero, and then you return it,
> > but
> > nothing can ever set it to non-zero, right?
> > 
> > > 
> > > +__visible bool ex_handler_wruss(const struct
> > > exception_table_entry *fixup,
> > > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A struct pt_regs *regs, int
> > > trapnr)
> > > +{
> > > +A A A A A A A regs->ip = ex_fixup_addr(fixup);
> > > +A A A A A A A regs->ax = -1;
> > > +A A A A A A A return true;
> > > +}
> > And here you just write into regs->ax, but your "asm volatile"
> > doesn't
> > reserve that register. This looks wrong to me.
> > 
> > I think you probably want to add something like an explicit
> > `"+&a"(err)` output to the asm statements.
> We require asm goto support these days.A A How about using that?A A You
> won't even need a special exception handler.
> 
> Also, please change the BUG to WARN in the you-did-it-wrong 32-bit
> case.A A And return -EFAULT.
> 
> --Andy

I will look into that.

Yu-cheng
