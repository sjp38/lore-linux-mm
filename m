Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 114C06B00DA
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 12:56:27 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id o6so4736051oag.33
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 09:56:26 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id ds9si29095176obc.112.2013.11.25.09.56.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 09:56:26 -0800 (PST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 25 Nov 2013 10:56:25 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 2EECF1FF0025
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:56:04 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAPFsZWU44105866
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:54:35 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAPHxGOE021728
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:59:19 -0700
Date: Mon, 25 Nov 2013 09:56:16 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131125175616.GQ4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
 <20131122215208.GD4138@linux.vnet.ibm.com>
 <CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
 <20131123002542.GF4138@linux.vnet.ibm.com>
 <CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
 <20131123013654.GG4138@linux.vnet.ibm.com>
 <CA+55aFxQy8afgf6geqJOEHmsJ=ME-6CXrrPfj=aggH7u_jEEZA@mail.gmail.com>
 <CA+55aFzr7=N=_t03Luzxg2Ln9_h+M9Ud5spLi7FH+5j7ynkPUg@mail.gmail.com>
 <20131125120902.GY10022@twins.programming.kicks-ass.net>
 <20131125171823.GA28201@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131125171823.GA28201@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Nov 25, 2013 at 05:18:23PM +0000, Will Deacon wrote:
> Hi Peter, Linus,
> 
> On Mon, Nov 25, 2013 at 12:09:02PM +0000, Peter Zijlstra wrote:
> > On Sat, Nov 23, 2013 at 12:39:53PM -0800, Linus Torvalds wrote:
> > > On Sat, Nov 23, 2013 at 12:21 PM, Linus Torvalds
> > > <torvalds@linux-foundation.org> wrote:
> > > >
> > > > And as far as I can tell, the above gives you: A < B < C < D < E < F <
> > > > A. Which doesn't look possible.
> > > 
> > > Hmm.. I guess technically all of those cases aren't "strictly
> > > precedes" as much as "cannot have happened in the opposite order". So
> > > the "<" might be "<=". Which I guess *is* possible: "it all happened
> > > at the same time". And then the difference between your suggested
> > > "lwsync" and "sync" in the unlock path on CPU0 basically approximating
> > > the difference between "A <= B" and "A < B"..
> > > 
> > > Ho humm.
> > 
> > But remember, there's an actual full proper barrier between E and F, so
> > at best you'd end up with something like:
> > 
> >   A <= B <= C <= D <= E < F <= A
> > 
> > Which is still an impossibility.
> > 
> > I'm hoping others will explain things, as I'm very much on shaky ground
> > myself wrt transitivity.
> 
> The transitivity issues come about by having multiple, valid copies of the
> same data at a given moment in time (hence the term `multi-copy atomicity',
> where all of these copies appear to be updated at once).
> 
> Now, I'm not familiar with the Power memory model and the implementation
> intricacies between lwsync and sync, but I think a better way to think
> about this is to think of the cacheline state changes being broadcast as
> asynchronous requests, rather than necessarily responding to snoops from a
> canonical source.
> 
> So, in Paul's example, the upgrade requests on X and lock (shared -> invalid)
> may have reached CPU1, but not CPU2 by the time CPU2 reads X and therefore
> reads 0 from its shared line. It really depends on the multi-copy semantics
> you give to the different barrier instructions.

Exactly!  ;-)

> The other thing worth noting is that exclusive access instructions (e.g.
> ldrex and strex on ARM) may interact differently with barriers than conventional
> accesses, so lighter weight barriers can sometimes be acceptable for things
> like locks and atomics.
> 
> Does that help at all?

The differences between ldrex/strex and larx/stcx cannot come into play
in this example because there are only normal loads and stores, no atomic
instructions.

							Thanx, Paul

> Will
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
