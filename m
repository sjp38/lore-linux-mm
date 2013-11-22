Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id A204D6B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 13:49:45 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id gq1so1733650obb.32
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 10:49:45 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id bx5si22461622oec.143.2013.11.22.10.49.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 10:49:44 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 22 Nov 2013 11:49:43 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2A2743E40044
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 11:49:40 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAMGlqRM36503680
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 17:47:52 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAMIqXYT001630
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 11:52:35 -0700
Date: Fri, 22 Nov 2013 10:49:37 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131122184937.GX4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131120214402.GM4138@linux.vnet.ibm.com>
 <1384991514.11046.504.camel@schen9-DESK>
 <20131121045333.GO4138@linux.vnet.ibm.com>
 <CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
 <20131121225208.GJ4138@linux.vnet.ibm.com>
 <CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
 <20131122040856.GK4138@linux.vnet.ibm.com>
 <CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
 <20131122062314.GN4138@linux.vnet.ibm.com>
 <20131122151600.GA14988@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131122151600.GA14988@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 04:16:00PM +0100, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Thu, Nov 21, 2013 at 08:25:59PM -0800, Linus Torvalds wrote:
> >
> > [...]
> > 
> > > I do care deeply about reality, particularly of architectures that 
> > > actually matter. To me, a spinlock in some theoretical case is 
> > > uninteresting, but a efficient spinlock implementation on a real 
> > > architecture is a big deal that matters a lot.
> > 
> > Agreed, reality and efficiency are the prime concerns.  Theory 
> > serves reality and efficiency, but definitely not the other way 
> > around.
> > 
> > But if we want locking primitives that don't rely solely on atomic 
> > instructions (such as the queued locks that people have been putting 
> > forward), we are going to need to wade through a fair bit of theory 
> > to make sure that they actually work on real hardware.  Subtle bugs 
> > in locking primitives is a type of reality that I think we can both 
> > agree that we should avoid.
> > 
> > Or am I missing your point?
> 
> I think one point Linus wanted to make that it's not true that Linux 
> has to offer a barrier and locking model that panders to the weakest 
> (and craziest!) memory ordering model amongst all the possible Linux 
> platforms - theoretical or real metal.
> 
> Instead what we want to do is to consciously, intelligently _pick_ a 
> sane, maintainable memory model and offer primitives for that - at 
> least as far as generic code is concerned. Each architecture can map 
> those primitives to the best of its abilities.
> 
> Because as we increase abstraction, as we allow more and more complex 
> memory ordering details, so does maintainability and robustness 
> decrease. So there's a very real crossover point at which point 
> increased smarts will actually hurt our code in real life.
> 
> [ Same goes for compilers, we draw a line: for example we generally
>   turn off strict aliasing optimizations, or we turn off NULL pointer
>   check elimination optimizations. ]
> 
> I'm not saying this to not discuss theoretical complexities - I'm just 
> saying that the craziest memory ordering complexities are probably 
> best dealt with by agreeing not to use them ;-)

Thank you for the explanation, Ingo!  I do agree with these principles.

That said, I remain really confused.  My best guess is that you are
advising me to ask Peter to stiffen up smp_store_release() so that
it preserves the guarantee that unlock+lock provides a full barrier,
thus allowing it to be used in the queued spinlocks as well as in its
original circular-buffer use case.  But even that doesn't completely
fit because that was the direction I was going beforehand.

You see, my problem is not the "crazy ordering" DEC Alpha, Itanium,
PowerPC, or even ARM.  It is really obvious what instructions to use in
a stiffened-up smp_store_release() for those guys: "mb" for DEC Alpha,
"st.rel" for Itanium, "sync" for PowerPC, and "dmb" for ARM.  Believe it
or not, my problem is instead with good old tightly ordered x86.

We -could- just put an mfence into x86's smp_store_release() and
be done with it, but it currently looks like we get the effect of
a full memory barrier without it, at least in the special case of
the high-contention queued-lock handoff.  To repeat, it looks like we
preserve the full-memory-barrier property of unlock+lock for x86 -even-
-though- the queued-lock high-contention handoff code contains neither
atomic instructions nor memory-barrier instructions.  This is a bit
surprising to me, to say the least.  Hence my digging into the theory
to check it -- after all, we cannot prove it correct by testing it.

Here are some other things that you and Linus might be trying to tell me:

o	Just say "no" to queued locks.  (I am OK with this.  NAKs are
	after all easier than beating my head against memory models.)

o	Don't add store-after-conditional control dependencies to
	Documentation/memory-barriers.txt because it is too complicated.
	(I am OK with this, I suppose -- but some people really want to
	rely on them.)

o	Just add general control dependencies, because that is what
	people expect.	(I have more trouble with this because there
	is a -lot- of work needed in many projects to make this happen,
	including on ARM, but some work on x86 as well.)

Anything I am missing here?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
