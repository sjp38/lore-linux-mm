Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8266B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 10:16:05 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id d7so861669bkh.3
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 07:16:04 -0800 (PST)
Received: from mail-bk0-x22a.google.com (mail-bk0-x22a.google.com [2a00:1450:4008:c01::22a])
        by mx.google.com with ESMTPS id t8si5895872bkp.126.2013.11.22.07.16.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 07:16:04 -0800 (PST)
Received: by mail-bk0-f42.google.com with SMTP id w11so857025bkz.15
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 07:16:04 -0800 (PST)
Date: Fri, 22 Nov 2013 16:16:00 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131122151600.GA14988@gmail.com>
References: <1384979767.11046.489.camel@schen9-DESK>
 <20131120214402.GM4138@linux.vnet.ibm.com>
 <1384991514.11046.504.camel@schen9-DESK>
 <20131121045333.GO4138@linux.vnet.ibm.com>
 <CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
 <20131121225208.GJ4138@linux.vnet.ibm.com>
 <CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
 <20131122040856.GK4138@linux.vnet.ibm.com>
 <CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
 <20131122062314.GN4138@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131122062314.GN4138@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> On Thu, Nov 21, 2013 at 08:25:59PM -0800, Linus Torvalds wrote:
>
> [...]
> 
> > I do care deeply about reality, particularly of architectures that 
> > actually matter. To me, a spinlock in some theoretical case is 
> > uninteresting, but a efficient spinlock implementation on a real 
> > architecture is a big deal that matters a lot.
> 
> Agreed, reality and efficiency are the prime concerns.  Theory 
> serves reality and efficiency, but definitely not the other way 
> around.
> 
> But if we want locking primitives that don't rely solely on atomic 
> instructions (such as the queued locks that people have been putting 
> forward), we are going to need to wade through a fair bit of theory 
> to make sure that they actually work on real hardware.  Subtle bugs 
> in locking primitives is a type of reality that I think we can both 
> agree that we should avoid.
> 
> Or am I missing your point?

I think one point Linus wanted to make that it's not true that Linux 
has to offer a barrier and locking model that panders to the weakest 
(and craziest!) memory ordering model amongst all the possible Linux 
platforms - theoretical or real metal.

Instead what we want to do is to consciously, intelligently _pick_ a 
sane, maintainable memory model and offer primitives for that - at 
least as far as generic code is concerned. Each architecture can map 
those primitives to the best of its abilities.

Because as we increase abstraction, as we allow more and more complex 
memory ordering details, so does maintainability and robustness 
decrease. So there's a very real crossover point at which point 
increased smarts will actually hurt our code in real life.

[ Same goes for compilers, we draw a line: for example we generally
  turn off strict aliasing optimizations, or we turn off NULL pointer
  check elimination optimizations. ]

I'm not saying this to not discuss theoretical complexities - I'm just 
saying that the craziest memory ordering complexities are probably 
best dealt with by agreeing not to use them ;-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
