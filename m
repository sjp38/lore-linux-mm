Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f41.google.com (mail-vb0-f41.google.com [209.85.212.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6FD6B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 19:09:51 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id w5so376842vbf.0
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 16:09:50 -0800 (PST)
Received: from mail-vc0-x229.google.com (mail-vc0-x229.google.com [2607:f8b0:400c:c03::229])
        by mx.google.com with ESMTPS id tw10si11606730vec.44.2013.11.21.16.09.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 16:09:49 -0800 (PST)
Received: by mail-vc0-f169.google.com with SMTP id hu19so369546vcb.28
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 16:09:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131121225208.GJ4138@linux.vnet.ibm.com>
References: <20131120153123.GF4138@linux.vnet.ibm.com>
	<20131120154643.GG19352@mudshark.cambridge.arm.com>
	<20131120171400.GI4138@linux.vnet.ibm.com>
	<1384973026.11046.465.camel@schen9-DESK>
	<20131120190616.GL4138@linux.vnet.ibm.com>
	<1384979767.11046.489.camel@schen9-DESK>
	<20131120214402.GM4138@linux.vnet.ibm.com>
	<1384991514.11046.504.camel@schen9-DESK>
	<20131121045333.GO4138@linux.vnet.ibm.com>
	<CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
	<20131121225208.GJ4138@linux.vnet.ibm.com>
Date: Thu, 21 Nov 2013 16:09:49 -0800
Message-ID: <CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 2:52 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> Actually, the weakest forms of locking only guarantee a consistent view
> of memory if you are actually holding the lock.  Not "a" lock, but "the"
> lock.

I don't think we necessarily support any architecture that does that,
though. And afaik, it's almost impossible to actually do sanely in
hardware with any sane cache coherency, so..

So realistically, I think we only really need to worry about memory
ordering that is tied to cache coherency protocols, where even locking
rules tend to be about memory ordering (although extended rules like
acquire/release rather than the broken pure barrier model).

Do you know any actual architecture where this isn't the case?

> So the three fixes I know of at the moment are:
>
> 1.      Upgrade smp_store_release()'s PPC implementation from lwsync
>         to sync.
>
>         What about ARM?  ARM platforms that have the load-acquire and
>         store-release instructions could use them, but other ARM
>         platforms have to use dmb.  ARM avoids PPC's lwsync issue
>         because it has no equivalent to lwsync.
>
> 2.      Place an explicit smp_mb() into the MCS-lock queued handoff
>         code.
>
> 3.      Remove the requirement that "unlock+lock" be a full memory
>         barrier.
>
> We have been leaning towards #1, but before making any hard decision
> on this we are looking more closely at what the situation is on other
> architectures.

So I might be inclined to lean towards #1 simply because of test coverage.

We have no sane test coverage of weakly ordered models. Sure, ARM may
be weakly ordered (with saner acquire/release in ARM64), but
realistically, no existing ARM platforms actually gives us any
reasonable test *coverage* for things like this, despite having tons
of chips out there running Linux. Very few people debug problems in
that world. The PPC people probably have much better testing and are
more likely to figure out the bugs, but don't have the pure number of
machines. So x86 tends to still remain the main platform where serious
testing gets done.

That said, I'd still be perfectly happy with #3, since - unlike, say,
the PCI ordering issues with drivers - at least people *can* try to
think about this somewhat analytically, even if it's ripe for
confusion and subtle mistakes. And I still think you got the ordering
wrong, and should be talking about "lock+unlock" rather than
"unlock+lock".

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
