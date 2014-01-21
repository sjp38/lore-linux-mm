Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D3C9C6B003B
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:14:35 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so5014101pdj.40
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 11:14:35 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id x3si396166pbf.121.2014.01.21.11.14.33
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 11:14:34 -0800 (PST)
Subject: Re: [PATCH v8 4/6] MCS Lock: Move mcs_lock/unlock function into
 its own
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20140121190658.GA5862@gmail.com>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
	 <1390267471.3138.38.camel@schen9-DESK>
	 <20140121101915.GS31570@twins.programming.kicks-ass.net>
	 <20140121104140.GA4092@gmail.com> <1390330623.3138.56.camel@schen9-DESK>
	 <20140121190658.GA5862@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Jan 2014 11:14:31 -0800
Message-ID: <1390331671.3138.58.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, 2014-01-21 at 20:06 +0100, Ingo Molnar wrote:
> * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
> > On Tue, 2014-01-21 at 11:41 +0100, Ingo Molnar wrote:
> > > * Peter Zijlstra <peterz@infradead.org> wrote:
> > > 
> > > > On Mon, Jan 20, 2014 at 05:24:31PM -0800, Tim Chen wrote:
> > > > > +EXPORT_SYMBOL_GPL(mcs_spin_lock);
> > > > > +EXPORT_SYMBOL_GPL(mcs_spin_unlock);
> > > > 
> > > > Do we really need the EXPORTs? The only user so far is mutex and that's
> > > > core code. The other planned users are rwsems and rwlocks, for both it
> > > > would be in the slow path, which is also core code.
> > > >
> > > > We should generally only add EXPORTs once theres a need.
> > > 
> > > In fact I'd argue the hot path needs to be inlined.
> > > 
> > > We only don't inline regular locking primitives because it would blow 
> > > up the kernel's size in too many critical places.
> > > 
> > > But inlining an _internal_ locking implementation used in just a 
> > > handful of places is a no-brainer...
> > 
> > The original mspin_lock primitive from which mcs_spin_lock was 
> > derived has an explicit noinline annotation.  The comment says that 
> > it is so that perf can properly account for time spent in the lock 
> > function.  So it wasn't inlined in previous kernels when we started.
> 
> Not sure what comment that was, but it's not a valid argument: 
> profiling and measurement is in almost all cases secondary to any 
> performance considerations!
> 
> If we keep it out of line then we want to do it only if it's faster 
> that way.
> 
> > For the time being, I'll just remove the EXPORT.  If people feel 
> > that inline is the right way to go, then we'll leave the function in 
> > mcs_spin_lock.h and not create mcs_spin_lock.c.
> 
> Well, 'people' could be you, the person touching the code? This is 
> really something that is discoverable: look at the critical path in 
> the inlined and the out of line case, and compare the number of 
> instructions. This can be done based on disassembly of the affected 
> code.

Okay, will make it inline function and drop the move of
to mcs_spin_lock.c

Tim
> 
> Thanks,
> 
> 	Ingo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
