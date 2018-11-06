Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 233236B038C
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 13:55:50 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id c16-v6so12141463wrr.8
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 10:55:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x9-v6sor1829747wmh.17.2018.11.06.10.55.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 10:55:48 -0800 (PST)
MIME-Version: 1.0
References: <20181011151523.27101-1-yu-cheng.yu@intel.com> <20181011151523.27101-22-yu-cheng.yu@intel.com>
 <ee5a93f7-ed42-dcc5-0e55-e73ac2637e84@intel.com>
In-Reply-To: <ee5a93f7-ed42-dcc5-0e55-e73ac2637e84@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 6 Nov 2018 10:55:36 -0800
Message-ID: <CALCETrVfQ8oumNUx6jCFDm0JOD+7qPjaeYvC6pGyodMBcf0VRw@mail.gmail.com>
Subject: Re: [PATCH v5 21/27] x86/cet/shstk: Introduce WRUSS instruction
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Tue, Nov 6, 2018 at 10:43 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 10/11/18 8:15 AM, Yu-cheng Yu wrote:
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -1305,6 +1305,15 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
> >               error_code |= X86_PF_USER;
> >               flags |= FAULT_FLAG_USER;
> >       } else {
> > +             /*
> > +              * WRUSS is a kernel instruction and but writes
> > +              * to user shadow stack.  When a fault occurs,
> > +              * both X86_PF_USER and X86_PF_SHSTK are set.
> > +              * Clear X86_PF_USER here.
> > +              */
> > +             if ((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
> > +                 (X86_PF_USER | X86_PF_SHSTK))
> > +                     error_code &= ~X86_PF_USER;
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

I'm going to send a patch set in the next day or two that cleans it up
further and is probably good preparation for WRUSS.
