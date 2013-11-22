Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 610796B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 23:09:05 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id m1so822444oag.31
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 20:09:05 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id n6si20836008oeq.108.2013.11.21.20.09.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 20:09:04 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 21 Nov 2013 21:09:03 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 04C0B1FF001C
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 21:08:42 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAM27Dio36634816
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 03:07:13 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAM4Brj5025998
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 21:11:55 -0700
Date: Thu, 21 Nov 2013 20:08:56 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131122040856.GK4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131120171400.GI4138@linux.vnet.ibm.com>
 <1384973026.11046.465.camel@schen9-DESK>
 <20131120190616.GL4138@linux.vnet.ibm.com>
 <1384979767.11046.489.camel@schen9-DESK>
 <20131120214402.GM4138@linux.vnet.ibm.com>
 <1384991514.11046.504.camel@schen9-DESK>
 <20131121045333.GO4138@linux.vnet.ibm.com>
 <CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
 <20131121225208.GJ4138@linux.vnet.ibm.com>
 <CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 04:09:49PM -0800, Linus Torvalds wrote:
> On Thu, Nov 21, 2013 at 2:52 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > Actually, the weakest forms of locking only guarantee a consistent view
> > of memory if you are actually holding the lock.  Not "a" lock, but "the"
> > lock.
> 
> I don't think we necessarily support any architecture that does that,
> though. And afaik, it's almost impossible to actually do sanely in
> hardware with any sane cache coherency, so..

It is not the architecture that matters here, it is just a definition of
what ordering guarantees the locking primitives provide, independent of
the architecture.  In the Linux kernel, we just happen to have picked
a strongly ordered definition of locking.  And we have probably made
the right choice.  But there really are environments where unlock+lock
does -not- provide a full memory barrier.  If you never refer to any
lock-protected memory without holding the lock, this difference doesn't
matter to you -- there will be nothing you can do to detect the difference
under this restriction.  Of course, if you want to scale, you -will-
find yourself accessing lock-protected memory without holding locks, so
in the Linux kernel, this difference in unlock+lock ordering semantics
really does matter.

> So realistically, I think we only really need to worry about memory
> ordering that is tied to cache coherency protocols, where even locking
> rules tend to be about memory ordering (although extended rules like
> acquire/release rather than the broken pure barrier model).
> 
> Do you know any actual architecture where this isn't the case?

You can implement something that acts like a lock (just not like a
-Linux- -kernel- lock) but where unlock+lock does not provide a full
barrier on architectures that provide weak memory barriers.  And there
are software environments that provide these weaker locks.  Which does
-not- necessarily mean that the Linux kernel should do this, of course!

???

OK, part of the problem is that this discussion has spanned at least
three different threads over the past week or so.  I will try to
summarize.  Others can correct me if I blow it.

a.	We found out that some of the circular-buffer code is unsafe.
	I first insisted on inserting a full memory barrier, but it was
	eventually determined that weaker memory barriers could suffice.
	This was the thread where I proposed the smp_tmb(), which name you
	(quite rightly) objected to.  This proposal eventually morphed
	into smp_load_acquire() and smp_store_release().

b.	For circular buffers, you need really minimal ordering semantics
	out of smp_load_acquire() and smp_store_release().  In particular,
	on powerpc, the lwsync instruction suffices.  Peter therefore came
	up with an implementation matching those weak semantics.

c.	In a couple of threads involving MCS lock, I complained about
	insufficient barriers, again suggesting adding smp_mb().  (Almost
	seems like a theme here...)  Someone noted that ARM64's shiny new
	load-acquire and store-release instructions sufficed (which does
	appear to be true).  Tim therefore came up with an implementation
	based on Peter's smp_load_acquire() and smp_store_release().

	The smp_store_release() is used when the lock holder hands off
	to the next in the queue, and the smp_load_acquire() is used when
	the next in the queue notices that the lock has been handed off.
	So we really are talking about the unlock+lock case!!!

d.	Unfortunately (or fortunately, depending on your viewpoint),
	locking as defined by the Linux kernel requires stronger
	smp_load_acquire() and smp_store_release() semantics than are
	required by the circular buffer.  In particular, the weaker
	smp_load_acquire() and smp_store_release() semantics provided by
	the original powerpc implementation do not provide a full memory
	barrier for the unlock+lock handoff on the queue.  I (finally)
	noticed this and complained.

e.	The question then was "how to fix this?"  There are a number
	of ways, namely these guys from two emails ago plus one more:

> > So the three fixes I know of at the moment are:
> >
> > 1.      Upgrade smp_store_release()'s PPC implementation from lwsync
> >         to sync.

		We are going down this path.  I produced what I believe
		to be a valid proof that the x86 versions do provide
		a full barrier for unlock+lock, which Peter will check
		tomorrow (Friday) morning.  Itanium is trivial (famous
		last words), ARM is also trivial (again, famous last
		words), and if x86 works, then so does s390.  And so on.

		My alleged proof for x86 is here, should anyone else
		like to take a crack at it:

		http://www.spinics.net/lists/linux-mm/msg65462.html

> >         What about ARM?  ARM platforms that have the load-acquire and
> >         store-release instructions could use them, but other ARM
> >         platforms have to use dmb.  ARM avoids PPC's lwsync issue
> >         because it has no equivalent to lwsync.
> >
> > 2.      Place an explicit smp_mb() into the MCS-lock queued handoff
> >         code.

		This would allow unlock+lock to be a full memory barrier,
		but would allow the weaker and cheaper semantics for
		smp_load_acquire() and smp_store_release.

> > 3.      Remove the requirement that "unlock+lock" be a full memory
> >         barrier.

		This would allow cheaper locking primitives on some
		architectures, but would require more care when
		making unlocked accesses to variables protected by
		locks.

4.	Have two parallel APIs, smp_store_release_weak(),
	smp_store_release(), and so on.  My reaction to this
	is "just say no".  It is not like we exactly have a
	shortage of memory-barrier APIs at the moment.

> > We have been leaning towards #1, but before making any hard decision
> > on this we are looking more closely at what the situation is on other
> > architectures.
> 
> So I might be inclined to lean towards #1 simply because of test coverage.

Another reason is "Who knows what code in the Linux kernel might be
relying on unlock+lock providing a full barrier?"

> We have no sane test coverage of weakly ordered models. Sure, ARM may
> be weakly ordered (with saner acquire/release in ARM64), but
> realistically, no existing ARM platforms actually gives us any
> reasonable test *coverage* for things like this, despite having tons
> of chips out there running Linux. Very few people debug problems in
> that world. The PPC people probably have much better testing and are
> more likely to figure out the bugs, but don't have the pure number of
> machines. So x86 tends to still remain the main platform where serious
> testing gets done.

We clearly need something like rcutorture, but for locking.  No two
ways about it.  But we need that regardless of whether or not we
change the ordering semantics of unlock+lock.

> That said, I'd still be perfectly happy with #3, since - unlike, say,
> the PCI ordering issues with drivers - at least people *can* try to
> think about this somewhat analytically, even if it's ripe for
> confusion and subtle mistakes. And I still think you got the ordering
> wrong, and should be talking about "lock+unlock" rather than
> "unlock+lock".

No, I really am talking about unlock+lock.  The MCS queue handoff is an
unlock followed by a lock, and that is what got weakened to no longer
imply a full memory barrier on all architectures when the MCS patch
started using smp_load_acquire() and smp_store_release().

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
