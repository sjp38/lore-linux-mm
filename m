Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 151F08E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 16:51:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 3-v6so4858102plq.6
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:51:23 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s59-v6si7990654plb.341.2018.09.14.13.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 13:51:21 -0700 (PDT)
Message-ID: <1536958012.12990.14.camel@intel.com>
Subject: Re: [RFC PATCH v3 19/24] x86/cet/shstk: Introduce WRUSS instruction
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 14 Sep 2018 13:46:52 -0700
In-Reply-To: <CALCETrV_aDasfkd6LD1cT11Hs1dO064uHjROLQPyhQfy_iuS8w@mail.gmail.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180830143904.3168-20-yu-cheng.yu@intel.com>
	 <CAG48ez3uZrC-9uJ0uMoVPTtxRXRN8D+3zs5FknZD2woTT6mazg@mail.gmail.com>
	 <CALCETrW78UKt6AQJeN8GkhtxjuASnH1PV5QSpzQtDz9-2d3Asw@mail.gmail.com>
	 <1535646146.26689.11.camel@intel.com> <1535752180.31230.4.camel@intel.com>
	 <CALCETrV_aDasfkd6LD1cT11Hs1dO064uHjROLQPyhQfy_iuS8w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Jann Horn <jannh@google.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Fri, 2018-08-31 at 15:16 -0700, Andy Lutomirski wrote:
> On Fri, Aug 31, 2018 at 2:49 PM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > 
> > On Thu, 2018-08-30 at 09:22 -0700, Yu-cheng Yu wrote:
> > > 
> > > On Thu, 2018-08-30 at 08:55 -0700, Andy Lutomirski wrote:
> > > > 
> > > > 
> > > > On Thu, Aug 30, 2018 at 8:39 AM, Jann Horn <jannh@google.com>
> > > > wrote:
> > > > > 
> > > > > 
> > > > > 
> > > > > On Thu, Aug 30, 2018 at 4:44 PM Yu-cheng Yu <yu-cheng.yu@intel.c
> > > > > om
> > > > > > 
> > > > > > 
> > > > > > wrote:
> > > > > > 
> > > > > > 
> > > > > > WRUSS is a new kernel-mode instruction but writes directly
> > > > > > to user shadow stack memory.A A This is used to construct
> > > > > > a return address on the shadow stack for the signal
> > > > > > handler.
> > > > > > 
> > > > > > This instruction can fault if the user shadow stack is
> > > > > > invalid shadow stack memory.A A In that case, the kernel does
> > > > > > fixup.
> > > > > > 
> > > > > > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > > > > [...]
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > +static inline int write_user_shstk_64(unsigned long addr,
> > > > > > unsigned long val)
> > > > > > +{
> > > > > > +A A A A A A A int err = 0;
> > > > > > +
> > > > > > +A A A A A A A asm volatile("1: wrussq %1, (%0)\n"
> > > > > > +A A A A A A A A A A A A A A A A A A A A "2:\n"
> > > > > > +A A A A A A A A A A A A A A A A A A A A _ASM_EXTABLE_HANDLE(1b, 2b,
> > > > > > ex_handler_wruss)
> > > > > > +A A A A A A A A A A A A A A A A A A A A :
> > > > > > +A A A A A A A A A A A A A A A A A A A A : "r" (addr), "r" (val));
> > > > > > +
> > > > > > +A A A A A A A return err;
> > > > > > +}
> > > > > What's up with "err"? You set it to zero, and then you return
> > > > > it,
> > > > > but
> > > > > nothing can ever set it to non-zero, right?
> > > > > 
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > +__visible bool ex_handler_wruss(const struct
> > > > > > exception_table_entry *fixup,
> > > > > > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A struct pt_regs *regs, int
> > > > > > trapnr)
> > > > > > +{
> > > > > > +A A A A A A A regs->ip = ex_fixup_addr(fixup);
> > > > > > +A A A A A A A regs->ax = -1;
> > > > > > +A A A A A A A return true;
> > > > > > +}
> > > > > And here you just write into regs->ax, but your "asm volatile"
> > > > > doesn't
> > > > > reserve that register. This looks wrong to me.
> > > > > 
> > > > > I think you probably want to add something like an explicit
> > > > > `"+&a"(err)` output to the asm statements.
> > > > We require asm goto support these days.A A How about using
> > > > that?A A You
> > > > won't even need a special exception handler.
> > Maybe something like this?A A It looks simple now.
> > 
> > static inline int write_user_shstk_64(unsigned long addr, unsigned
> > long val)
> > {
> > A A A A A A A A asm_volatile_goto("wrussq %1, (%0)\n"
> > A A A A A A A A A A A A A A A A A A A A A "jmp %l[ok]\n"
> > A A A A A A A A A A A A A A A A A A A A A ".section .fixup,\"ax\"n"
> > A A A A A A A A A A A A A A A A A A A A A "jmp %l[fail]\n"
> > A A A A A A A A A A A A A A A A A A A A A ".previous\n"
> > A A A A A A A A A A A A A A A A A A A A A :: "r" (addr), "r" (val)
> > A A A A A A A A A A A A A A A A A A A A A :: ok, fail);
> > ok:
> > A A A A A A A A return 0;
> > fail:
> > A A A A A A A A return -1;
> > }
> > 
> I think you can get rid of 'jmp %l[ok]' and the ok label and just fall
> through.A A And you don't need an explicit jmp to fail -- just set the
> _EX_HANDLER entry to land on the fail label.

Thanks! A This now looks simple and much better.

Yu-cheng



+static inline int write_user_shstk_64(unsigned long addr, unsigned long val)
+{
+	asm_volatile_goto("1: wrussq %1, (%0)\n"
+			A A _ASM_EXTABLE(1b, %l[fail])
+			A A :: "r" (addr), "r" (val)
+			A A :: fail);
+	return 0;
+fail:
+	return -1;
+}
