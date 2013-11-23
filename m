Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD966B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 19:25:48 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id va2so2048662obc.21
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 16:25:48 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id co8si22997378oec.47.2013.11.22.16.25.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 16:25:47 -0800 (PST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 22 Nov 2013 17:25:46 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 6380E3E4003F
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 17:25:45 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAMMNjqs63439050
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 23:23:45 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAN0ScZO019374
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 17:28:40 -0700
Date: Fri, 22 Nov 2013 16:25:42 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131123002542.GF4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131122062314.GN4138@linux.vnet.ibm.com>
 <20131122151600.GA14988@gmail.com>
 <20131122184937.GX4138@linux.vnet.ibm.com>
 <CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
 <20131122200620.GA4138@linux.vnet.ibm.com>
 <CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
 <20131122203738.GC4138@linux.vnet.ibm.com>
 <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
 <20131122215208.GD4138@linux.vnet.ibm.com>
 <CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 02:19:15PM -0800, Linus Torvalds wrote:
> On Fri, Nov 22, 2013 at 1:52 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > You seem to be assuming that the unlock+lock rule applies only when the
> > unlock and the lock are executed by the same CPU.  This is not always
> > the case.  For example, when the unlock and lock are operating on the
> > same lock variable, the critical sections must appear to be ordered from
> > the perspective of some other CPU, even when that CPU is not holding
> > any lock.
> 
> Umm. Isn't that pretty much *guaranteed* by any cache-coherent locking scheme.

No, there really are exceptions.  In fact, one such exception showed up
a few days ago on this very list, which is why I started complaining.

> The unlock - by virtue of being an unlock - means that all ops within
> the first critical region must be visible in the cache coherency
> protocol before the unlock is visible. Same goes for the lock on the
> other CPU wrt the memory accesses within that locked region.
> 
> IOW, I'd argue that any locking model that depends on cache coherency
> - as opposed to some magic external locks independent of cache
> coherenecy - *has* to follow the rules in that section as far as I can
> see. Or it's not a locking model at all, and lets the cache accesses
> leak outside of the critical section.

Start with Tim Chen's most recent patches for MCS locking, the ones that
do the lock handoff using smp_store_release() and smp_load_acquire().
Add to that Peter Zijlstra's patch that uses PowerPC lwsync for both
smp_store_release() and smp_load_acquire().  Run the resulting lock
at high contention, so that all lock handoffs are done via the queue.
Then you will have something that acts like a lock from the viewpoint
of CPU holding that lock, but which does -not- guarantee that an
unlock+lock acts like a full memory barrier if the unlock and lock run
on two different CPUs, and if the observer is running on a third CPU.

Easy fix -- make powerpc'd smp_store_release() use sync instead of lwsync.
Slows down the PowerPC circular-buffer implementation a bit, but I believe
that this is fixable separately.  More on that later.

And if you, the Intel guys, and the AMD guys all say that the x86 code
path does the right thing, then I won't argue, especially since the
formalisms seem to agree.  Quite surprising to me, but if that is the
way it works, well and good.  That said, I will check a few other CPU
families for completeness.

> Btw, you can see the difference in the very next section, where you
> have *non-cache-coherent* (IO) accesses. So once you have different
> rules for the data and the lock accesses, you can get different
> results. And yes, there have been broken SMP models (historically)
> where locking was "separate" from the memory system, and you could get
> coherence only by taking the right lock. But I really don't think we
> care about such locking models (for memory - again, IO accesses are
> different, exactly because locking and data are in different "ordering
> domains").

Yes, MMIO accesses add another set of rules.  I have not been talking
about MMIO accesses, however.

> IOW, I don't think you *can* violate that "locks vs memory accesses"
> model with any system where locking is in the same ordering domain as
> the data (ie we lock by using cache coherency). And locking using
> cache coherency is imnsho the only valid model for SMP. No?

No, I have not been considering trying to make these locks work in the
absence of cache coherence.  Not that crazy, not today, anyway.

But even with cache coherence, you really can create a lock that
acts like a lock from the viewpoint of CPUs holding that lock, but
which violates the "locks vs memory accesses" model.  For example, the
combination of Tim's most recent MCS lock patches with Peter's most recent
smp_store_release()/smp_load_acquire() patch that I called out above.

Sheesh, and I haven't even started reviewing the qrwlock...  :-/

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
