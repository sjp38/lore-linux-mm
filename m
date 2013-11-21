Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 087106B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 12:26:04 -0500 (EST)
Received: by mail-oa0-f52.google.com with SMTP id h16so62457oag.11
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 09:26:04 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id mx9si19885041obc.67.2013.11.21.09.26.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 09:26:03 -0800 (PST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 21 Nov 2013 10:26:03 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 026031FF001B
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 10:25:43 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rALFOEZq35651810
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 16:24:14 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rALHSrXh015076
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 10:28:55 -0700
Date: Thu, 21 Nov 2013 09:25:58 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131121172558.GA27927@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
 <1384911463.11046.454.camel@schen9-DESK>
 <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
 <20131121110308.GC10022@twins.programming.kicks-ass.net>
 <20131121125616.GI3694@twins.programming.kicks-ass.net>
 <20131121132041.GS4138@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20131121132041.GS4138@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 05:20:41AM -0800, Paul E. McKenney wrote:
> On Thu, Nov 21, 2013 at 01:56:16PM +0100, Peter Zijlstra wrote:
> > On Thu, Nov 21, 2013 at 12:03:08PM +0100, Peter Zijlstra wrote:
> > > On Wed, Nov 20, 2013 at 09:14:00AM -0800, Paul E. McKenney wrote:
> > > > > Hmm, so in the following case:
> > > > > 
> > > > >   Access A
> > > > >   unlock()	/* release semantics */
> > > > >   lock()	/* acquire semantics */
> > > > >   Access B
> > > > > 
> > > > > A cannot pass beyond the unlock() and B cannot pass the before the lock().
> > > > > 
> > > > > I agree that accesses between the unlock and the lock can be move across both
> > > > > A and B, but that doesn't seem to matter by my reading of the above.
> > > > > 
> > > > > What is the problematic scenario you have in mind? Are you thinking of the
> > > > > lock() moving before the unlock()? That's only permitted by RCpc afaiu,
> > > > > which I don't think any architectures supported by Linux implement...
> > > > > (ARMv8 acquire/release is RCsc).
> > > > 
> > > > If smp_load_acquire() and smp_store_release() are both implemented using
> > > > lwsync on powerpc, and if Access A is a store and Access B is a load,
> > > > then Access A and Access B can be reordered.
> > > > 
> > > > Of course, if every other architecture will be providing RCsc implementations
> > > > for smp_load_acquire() and smp_store_release(), which would not be a bad
> > > > thing, then another approach is for powerpc to use sync rather than lwsync
> > > > for one or the other of smp_load_acquire() or smp_store_release().
> > > 
> > > So which of the two would make most sense?
> > > 
> > > As per the Document, loads/stores should not be able to pass up through
> > > an ACQUIRE and loads/stores should not be able to pass down through a
> > > RELEASE.
> > > 
> > > I think PPC would match that if we use sync for smp_store_release() such
> > > that it will flush the store buffer, and thereby guarantee all stores
> > > are kept within the required section.
> > 
> > Wouldn't that also mean that TSO archs need the full barrier on
> > RELEASE?
> 
> It just might...  I was thinking not, but I do need to check.

I am still thinking not, at least for x86, given Section 8.2.2 of
"Intel(R) 64 and IA-32 Architectures Developer's Manual: Vol. 3A"
dated March 2013 from:

http://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-3a-part-1-manual.html

Also from Sewell et al. "x86-TSO: A Rigorous and Usable Programmer's
Model for x86 Multiprocessors" in 2010 CACM.

Let's apply the Intel manual to the earlier example:

	CPU 0		CPU 1			CPU 2
	-----		-----			-----
	x = 1;		r1 = SLA(lock);		y = 1;
	SSR(lock, 1);	r2 = y;			smp_mb();
						r3 = x;

	assert(!(r1 == 1 && r2 == 0 && r3 == 0));

Let's try applying this to x86:

o	Stores from a given processor are ordered, so everyone
	agrees that CPU 0's store to x happens before the store-release
	to lock.

o	Reads from a given processor are ordered, so everyone agrees
	that CPU 1's load from lock precedes its load from y.

o	Because r1 == 1, we know that CPU 0's store to lock happened
	before CPU 1's load from lock.

o	Causality (AKA transitive visibility) means that everyone
	agrees that CPU 0's store to x happens before CPU 1's load
	from y.  (This is a crucial point, so it would be good to
	have confirmation/debunking from someone who understands
	the x86 architecture better than I do.)

o	CPU 2's memory barrier prohibits CPU 2's store to y from
	being reordered with its load from x.

o	Because r2 == 0, we know that CPU 1's load from y happened
	before CPU 2's store to y.

o	At this point, it looks to me that (r1 == 1 && r2 == 0)
	implies r3 == 1.

Sewell's model plays out as follows:

o	Rule 2 never applies in this example because no processor
	is reading its own write.

o	Rules 3 and 4 force CPU 0's writes to be seen in order.

o	Rule 1 combined with the ordered-instruction nature of
	the model force CPU 1's reads to happen in order.

o	Rule 4 means that if r1 == 1, CPU 0's write to x is
	globally visible before CPU 1 loads from y.

o	The fact that r2 == 0 combined with rules 1, 3, and 4
	mean that CPU 1's load from y happens before CPU 2 makes
	its store to y visible.

o	Rule 5 means that CPU 1 cannot execute its load from x
	until it has made its store to y globally visible.

o	Therefore, when CPU 2 executes its load from x, CPU 0's
	store to x must be visible, ruling out r3 == 0, and
	preventing the assertion from firing.

The other three orderings would play out similarly.  (These are read
before lock release and read after subsequent lock acquisition, read
before lock release and write after subsequent lock acquisition, and
read before lock release and read after subsequent lock acquisition.)

But before chasing those down, is the analysis above sound?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
