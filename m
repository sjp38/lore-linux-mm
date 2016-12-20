Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDDC6B0363
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 18:36:44 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id k201so33474936qke.6
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 15:36:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c14si13562114qtc.42.2016.12.20.15.36.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 15:36:43 -0800 (PST)
Date: Tue, 20 Dec 2016 17:36:40 -0600
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: x86: warning in unwind_get_return_address
Message-ID: <20161220233640.pc4goscldmpkvtqa@treble>
References: <CAAeHK+yqC-S=fQozuBF4xu+d+e=ikwc_ipn-xUGnmfnWsjUtoA@mail.gmail.com>
 <20161220210144.u47znzx6qniecuvv@treble>
 <CAAeHK+z7O-byXDL4AMZP5TdeWHSbY-K69cbN6EeYo5eAtvJ0ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAAeHK+z7O-byXDL4AMZP5TdeWHSbY-K69cbN6EeYo5eAtvJ0ng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Kostya Serebryany <kcc@google.com>, syzkaller <syzkaller@googlegroups.com>

On Tue, Dec 20, 2016 at 11:35:23PM +0100, Andrey Konovalov wrote:
> On Tue, Dec 20, 2016 at 10:01 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> > On Tue, Dec 20, 2016 at 03:43:27PM +0100, Andrey Konovalov wrote:
> >> Hi,
> >>
> >> I've got the following warning while running the syzkaller fuzzer:
> >>
> >> WARNING: unrecognized kernel stack return address ffffffffa0000001 at
> >> ffff88006377fa18 in a.out:4467
> >>
> >> By adding a BUG() to unwind_get_return_address() I was able to capture
> >> the stack trace (see below). Looks like unwind_get_return_address()
> >> gets called when KASAN tries to unwind the stack to save the stack
> >> trace.
> >>
> >> A reproducer is attached. CONFIG_KASAN=y is most likely needed for it to work.
> >
> > Hi Andrey,
> >
> > I've tried with your reproducer but it didn't recreate.  Can you try
> > again with the following patch from the tip tree, instead of your BUG()
> > patch?
> >
> >   http://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/patch/?id=8b5e99f02264130782a10ba5c0c759797fb064ee
> >
> > That will dump the stack data, which should give more clues about what
> > went wrong.
> 
> Hi Josh,
> 
> Sure, here it is:

Thanks.  Looking at the stack trace, my guess is that an interrupt hit
while running in generated BPF code, and the unwinder got confused
because regs->ip points to the generated code.  I may need to disable
that warning until we figure out a better solution.

Can you share your .config file?

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
