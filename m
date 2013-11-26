Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 326EC6B0036
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 05:00:23 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id i13so4182490qae.10
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 02:00:22 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id k3si10596454qao.186.2013.11.26.02.00.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Nov 2013 02:00:21 -0800 (PST)
Date: Tue, 26 Nov 2013 10:59:45 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131126095945.GI10022@twins.programming.kicks-ass.net>
References: <20131121172558.GA27927@linux.vnet.ibm.com>
 <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
 <20131121221859.GH4138@linux.vnet.ibm.com>
 <20131122155835.GR3866@twins.programming.kicks-ass.net>
 <20131122182632.GW4138@linux.vnet.ibm.com>
 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
 <20131125173540.GK3694@twins.programming.kicks-ass.net>
 <20131125180250.GR4138@linux.vnet.ibm.com>
 <20131125182715.GG10022@twins.programming.kicks-ass.net>
 <20131125235252.GA4138@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131125235252.GA4138@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Nov 25, 2013 at 03:52:52PM -0800, Paul E. McKenney wrote:
> On Mon, Nov 25, 2013 at 07:27:15PM +0100, Peter Zijlstra wrote:
> > On Mon, Nov 25, 2013 at 10:02:50AM -0800, Paul E. McKenney wrote:
> > > And if the two locks are different, then the guarantee applies only
> > > when the unlock and lock are on the same CPU, in which case, as Linus
> > > noted, the xchg() on entry to the slow path does the job for use.
> > 
> > But in that case we rely on the fact that the thing is part of a
> > composite and we should no longer call it load_acquire, because frankly
> > it doesn't have acquire semantics anymore because the read can escape
> > out.
> 
> Actually, load-acquire and store-release are only required to provide
> ordering in the threads/CPUs doing the load-acquire/store-release
> operations.  It is just that we require something stronger than minimal
> load-acquire/store-release to make a Linux-kernel lock.

I suspect we're talking past one another here; but our Document
describes ACQUIRE/RELEASE semantics such that

  RELEASE
  ACQUIRE

matches a full barrier, regardless on whether it is the same lock or
not.

If you now want to weaken this definition, then that needs consideration
because we actually rely on things like

spin_unlock(l1);
spin_lock(l2);

being full barriers.

Now granted, for lock operations we have actual atomic ops in between
which would cure x86, but it would leave us confused with the barrier
semantics.

So please; either: 

A) we have the strong ACQUIRE/RELEASE semantics as currently described;
   and therefore any RELEASE+ACQUIRE pair must form a full barrier; and
   our propose primitives are non-compliant and needs strengthening.

B) we go fudge about with the definitions.

But given the current description of our ACQUIRE barrier, we simply
cannot claim the proposed primitives are good on x86 IMO.

Also, instead of the smp_store_release() I would argue that
smp_load_acquire() is the one that needs the full buffer, even on PPC.

Because our ACQUIRE dis-allows loads/stores leaking out upwards, and
both TSO and PPC lwsync allow just that, so the smp_load_acquire() is
the one that needs the full barrier.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
