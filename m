Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5EA6B5939
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 18:16:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w18-v6so249172plp.3
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 15:16:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id bb7-v6si10651852plb.359.2018.08.31.15.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 15:16:38 -0700 (PDT)
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8416820844
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 22:16:37 +0000 (UTC)
Received: by mail-wr1-f46.google.com with SMTP id w11-v6so12463977wrc.5
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 15:16:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1535752180.31230.4.camel@intel.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com> <20180830143904.3168-20-yu-cheng.yu@intel.com>
 <CAG48ez3uZrC-9uJ0uMoVPTtxRXRN8D+3zs5FknZD2woTT6mazg@mail.gmail.com>
 <CALCETrW78UKt6AQJeN8GkhtxjuASnH1PV5QSpzQtDz9-2d3Asw@mail.gmail.com>
 <1535646146.26689.11.camel@intel.com> <1535752180.31230.4.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 31 Aug 2018 15:16:15 -0700
Message-ID: <CALCETrV_aDasfkd6LD1cT11Hs1dO064uHjROLQPyhQfy_iuS8w@mail.gmail.com>
Subject: Re: [RFC PATCH v3 19/24] x86/cet/shstk: Introduce WRUSS instruction
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Jann Horn <jannh@google.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Fri, Aug 31, 2018 at 2:49 PM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> On Thu, 2018-08-30 at 09:22 -0700, Yu-cheng Yu wrote:
>> On Thu, 2018-08-30 at 08:55 -0700, Andy Lutomirski wrote:
>> >
>> > On Thu, Aug 30, 2018 at 8:39 AM, Jann Horn <jannh@google.com>
>> > wrote:
>> > >
>> > >
>> > > On Thu, Aug 30, 2018 at 4:44 PM Yu-cheng Yu <yu-cheng.yu@intel.c
>> > > om
>> > > >
>> > > > wrote:
>> > > >
>> > > >
>> > > > WRUSS is a new kernel-mode instruction but writes directly
>> > > > to user shadow stack memory.  This is used to construct
>> > > > a return address on the shadow stack for the signal
>> > > > handler.
>> > > >
>> > > > This instruction can fault if the user shadow stack is
>> > > > invalid shadow stack memory.  In that case, the kernel does
>> > > > fixup.
>> > > >
>> > > > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
>> > > [...]
>> > > >
>> > > >
>> > > > +static inline int write_user_shstk_64(unsigned long addr,
>> > > > unsigned long val)
>> > > > +{
>> > > > +       int err = 0;
>> > > > +
>> > > > +       asm volatile("1: wrussq %1, (%0)\n"
>> > > > +                    "2:\n"
>> > > > +                    _ASM_EXTABLE_HANDLE(1b, 2b,
>> > > > ex_handler_wruss)
>> > > > +                    :
>> > > > +                    : "r" (addr), "r" (val));
>> > > > +
>> > > > +       return err;
>> > > > +}
>> > > What's up with "err"? You set it to zero, and then you return
>> > > it,
>> > > but
>> > > nothing can ever set it to non-zero, right?
>> > >
>> > > >
>> > > >
>> > > > +__visible bool ex_handler_wruss(const struct
>> > > > exception_table_entry *fixup,
>> > > > +                               struct pt_regs *regs, int
>> > > > trapnr)
>> > > > +{
>> > > > +       regs->ip = ex_fixup_addr(fixup);
>> > > > +       regs->ax = -1;
>> > > > +       return true;
>> > > > +}
>> > > And here you just write into regs->ax, but your "asm volatile"
>> > > doesn't
>> > > reserve that register. This looks wrong to me.
>> > >
>> > > I think you probably want to add something like an explicit
>> > > `"+&a"(err)` output to the asm statements.
>> > We require asm goto support these days.  How about using
>> > that?  You
>> > won't even need a special exception handler.
>
> Maybe something like this?  It looks simple now.
>
> static inline int write_user_shstk_64(unsigned long addr, unsigned
> long val)
> {
>         asm_volatile_goto("wrussq %1, (%0)\n"
>                      "jmp %l[ok]\n"
>                      ".section .fixup,\"ax\"n"
>                      "jmp %l[fail]\n"
>                      ".previous\n"
>                      :: "r" (addr), "r" (val)
>                      :: ok, fail);
> ok:
>         return 0;
> fail:
>         return -1;
> }
>

I think you can get rid of 'jmp %l[ok]' and the ok label and just fall
through.  And you don't need an explicit jmp to fail -- just set the
_EX_HANDLER entry to land on the fail label.
