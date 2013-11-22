Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f44.google.com (mail-qe0-f44.google.com [209.85.128.44])
	by kanga.kvack.org (Postfix) with ESMTP id 06B426B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 10:59:05 -0500 (EST)
Received: by mail-qe0-f44.google.com with SMTP id nd7so483462qeb.3
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 07:59:05 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id a8si10326356qch.88.2013.11.22.07.59.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Nov 2013 07:59:03 -0800 (PST)
Date: Fri, 22 Nov 2013 16:58:35 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131122155835.GR3866@twins.programming.kicks-ass.net>
References: <1384911463.11046.454.camel@schen9-DESK>
 <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
 <20131121110308.GC10022@twins.programming.kicks-ass.net>
 <20131121125616.GI3694@twins.programming.kicks-ass.net>
 <20131121132041.GS4138@linux.vnet.ibm.com>
 <20131121172558.GA27927@linux.vnet.ibm.com>
 <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
 <20131121221859.GH4138@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131121221859.GH4138@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 02:18:59PM -0800, Paul E. McKenney wrote:
> > > Let's apply the Intel manual to the earlier example:
> > >
> > >	CPU 0		CPU 1			CPU 2
> > >	-----		-----			-----
> > >	x = 1;		r1 = SLA(lock);		y = 1;
> > >	SSR(lock, 1);	r2 = y;			smp_mb();
> > >						r3 = x;
> > >
> > >	assert(!(r1 == 1 && r2 == 0 && r3 == 0));
> > >
> > > Let's try applying this to x86:
> > >
> > > o	Stores from a given processor are ordered, so everyone
> > >	agrees that CPU 0's store to x happens before the store-release
> > >	to lock.
> > >
> > > o	Reads from a given processor are ordered, so everyone agrees
> > >	that CPU 1's load from lock precedes its load from y.
> > >
> > > o	Because r1 == 1, we know that CPU 0's store to lock happened
> > >	before CPU 1's load from lock.
> > >
> > > o	Causality (AKA transitive visibility) means that everyone
> > >	agrees that CPU 0's store to x happens before CPU 1's load
> > >	from y.  (This is a crucial point, so it would be good to
> > >	have confirmation/debunking from someone who understands
> > >	the x86 architecture better than I do.)
> > >
> > > o	CPU 2's memory barrier prohibits CPU 2's store to y from
> > >	being reordered with its load from x.
> > >
> > > o	Because r2 == 0, we know that CPU 1's load from y happened
> > >	before CPU 2's store to y.
> > >
> > > o	At this point, it looks to me that (r1 == 1 && r2 == 0)
> > >	implies r3 == 1.

Agreed, and I now fully appreciate the transitive point. I can't say if
x86 does in fact do this, but I can agree that rules in the SDM support
your logic.

> > > Sewell's model plays out as follows:

I have problems with these rules, for instance:

> > > o	Rules 3 and 4 force CPU 0's writes to be seen in order.

Nothing in those rules state the store buffer is a strict FIFO, it might
be suggested by rule 4's use of 'oldest', but being a pendant the text
as given doesn't disallow store reordering in the store buffer.

Suppose an address a was written to two times, a store buffer might
simply update the entry for the first write with the new value. The
entry would still become oldest at some point and get flushed.

(Note the above is ambiguous in if the entry's time stamp is updated or
not -- also note that both cases violate TSO and therefore it doesn't
matter.)

That violates FIFO (and TSO) but not the definitions.

Similarly its not at all clear from rule 2 that reads are not
re-ordered.

So I'll ignore this section for now.


OK, so reading back a little he does describe the abstract machine and
does say the store buffer is FIFO, but what use are rules if you first
need more 'rules'.

Rules should be self supporting.

> > I _think_ so.. but its late. I'm also struggling to find where lwsync
> > goes bad in this story, because as you say lwsync does all except flush
> > the store buffer, which sounds like TSO.. but clearly is not quite the
> > same.
> > 
> > For one TSO has multi-copy atomicity, whereas ARM/PPC do not have this.
> 
> At least PPC lwsync does not have multi-copy atomicity. 

Right, which is why it lacks transitivity.

> The heavier sync
> instruction does.  Last I checked, ARM did not have a direct replacment
> for lwsync, though it does have something sort of like eieio.
> 
> But yes, we were trying to use lwsync for both smp_load_acquire() and
> smp_store_release(), which does not provide exactly the same guarantees
> that TSO does.  Though it does come close in many cases.

Right, and this lack of transitivity is what kills it.

> > The explanation of lwsync given in 3.3 of 'A Tutorial Introduction to
> > the ARM and POWER Relaxed Memory Models'
> > 
> >   http://www.cl.cam.ac.uk/~pes20/ppc-supplemental/test7.pdf
> > 
> > Leaves me slightly puzzled as to the exact differences between the 2 WW
> > variants.
> 
> The WW at the top of the page is discussing the ARM "dmb" instruction
> and the PPC "sync" instruction, both of which are full barriers, and
> both of which can therefore be thought of as flushing the store buffer.
> 
> In contrast, the WW at the bottom of the page is discussing the PPC
> lwsync instruction, which most definitely is not guaranteed to flush
> the write buffer.

Right, my complaint was that from the two definitions given the factual
difference in behaviour was not clear to me.

I knew that upgrading the SSR's lwsync to sync would 'fix' the thing,
and that is exactly the WW case, but given these two definitions I was
at a loss to find the hole.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
