Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 67D4A6B00D0
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 12:20:10 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id k14so1603261wgh.22
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 09:20:09 -0800 (PST)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id fw4si18079711wjb.97.2013.11.25.09.20.09
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 09:20:09 -0800 (PST)
Date: Mon, 25 Nov 2013 17:18:23 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131125171823.GA28201@mudshark.cambridge.arm.com>
References: <20131122203738.GC4138@linux.vnet.ibm.com>
 <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
 <20131122215208.GD4138@linux.vnet.ibm.com>
 <CA+55aFzS2yd-VbJB5t14mP8NZG8smB1BQaYCw3Zo19FWQL92vA@mail.gmail.com>
 <20131123002542.GF4138@linux.vnet.ibm.com>
 <CA+55aFy8kx1qaWszc9nrbUaqFu7GfTtDkpzPBeE2g2U6RZjYkA@mail.gmail.com>
 <20131123013654.GG4138@linux.vnet.ibm.com>
 <CA+55aFxQy8afgf6geqJOEHmsJ=ME-6CXrrPfj=aggH7u_jEEZA@mail.gmail.com>
 <CA+55aFzr7=N=_t03Luzxg2Ln9_h+M9Ud5spLi7FH+5j7ynkPUg@mail.gmail.com>
 <20131125120902.GY10022@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131125120902.GY10022@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

Hi Peter, Linus,

On Mon, Nov 25, 2013 at 12:09:02PM +0000, Peter Zijlstra wrote:
> On Sat, Nov 23, 2013 at 12:39:53PM -0800, Linus Torvalds wrote:
> > On Sat, Nov 23, 2013 at 12:21 PM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> > >
> > > And as far as I can tell, the above gives you: A < B < C < D < E < F <
> > > A. Which doesn't look possible.
> > 
> > Hmm.. I guess technically all of those cases aren't "strictly
> > precedes" as much as "cannot have happened in the opposite order". So
> > the "<" might be "<=". Which I guess *is* possible: "it all happened
> > at the same time". And then the difference between your suggested
> > "lwsync" and "sync" in the unlock path on CPU0 basically approximating
> > the difference between "A <= B" and "A < B"..
> > 
> > Ho humm.
> 
> But remember, there's an actual full proper barrier between E and F, so
> at best you'd end up with something like:
> 
>   A <= B <= C <= D <= E < F <= A
> 
> Which is still an impossibility.
> 
> I'm hoping others will explain things, as I'm very much on shaky ground
> myself wrt transitivity.

The transitivity issues come about by having multiple, valid copies of the
same data at a given moment in time (hence the term `multi-copy atomicity',
where all of these copies appear to be updated at once).

Now, I'm not familiar with the Power memory model and the implementation
intricacies between lwsync and sync, but I think a better way to think
about this is to think of the cacheline state changes being broadcast as
asynchronous requests, rather than necessarily responding to snoops from a
canonical source.

So, in Paul's example, the upgrade requests on X and lock (shared -> invalid)
may have reached CPU1, but not CPU2 by the time CPU2 reads X and therefore
reads 0 from its shared line. It really depends on the multi-copy semantics
you give to the different barrier instructions.

The other thing worth noting is that exclusive access instructions (e.g.
ldrex and strex on ARM) may interact differently with barriers than conventional
accesses, so lighter weight barriers can sometimes be acceptable for things
like locks and atomics.

Does that help at all?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
