Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CF40F6B005C
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 12:10:30 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so9048709pab.26
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 09:10:30 -0800 (PST)
Received: from psmtp.com ([74.125.245.141])
        by mx.google.com with SMTP id fk10si14504268pab.0.2013.11.05.09.10.28
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 09:10:29 -0800 (PST)
Subject: Re: [PATCH 4/4] MCS Lock: Make mcs_spinlock.h includable in other
 files
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20131105112212.GO28601@twins.programming.kicks-ass.net>
References: <cover.1383604526.git.tim.c.chen@linux.intel.com>
	 <1383608233.11046.263.camel@schen9-DESK>
	 <20131105101538.GA26895@mudshark.cambridge.arm.com>
	 <20131105112212.GO28601@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Nov 2013 09:10:25 -0800
Message-ID: <1383671425.11046.275.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul
 E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>

On Tue, 2013-11-05 at 12:22 +0100, Peter Zijlstra wrote:
> On Tue, Nov 05, 2013 at 10:15:38AM +0000, Will Deacon wrote:
> > Hello,
> > 
> > On Mon, Nov 04, 2013 at 11:37:13PM +0000, Tim Chen wrote:
> > > The following changes are made to enable mcs_spinlock.h file to be
> > > widely included in other files without causing problem:
> > > 
> > > 1) Include a number of prerequisite header files and define
> > >    arch_mutex_cpu_relax(), if not previously defined.
> > > 2) Separate out mcs_spin_lock() into a mcs_spinlock.c file.
> > > 3) Make mcs_spin_unlock() an inlined function.
> > 
> > [...]
> > 
> > > +void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> > > +{
> > > +	struct mcs_spinlock *prev;
> > > +
> > > +	/* Init node */
> > > +	node->locked = 0;
> > > +	node->next   = NULL;
> > > +
> > > +	prev = xchg(lock, node);
> > > +	if (likely(prev == NULL)) {
> > > +		/* Lock acquired */
> > > +		node->locked = 1;
> > > +		return;
> > > +	}
> > > +	ACCESS_ONCE(prev->next) = node;
> > > +	smp_wmb();
> > > +	/* Wait until the lock holder passes the lock down */
> > > +	while (!ACCESS_ONCE(node->locked))
> > > +		arch_mutex_cpu_relax();
> > > +}
> > 
> > You have the barrier in a different place than the version in the header
> > file; is this intentional?
> > 
> > Also, why is an smp_wmb() sufficient (as opposed to a full smp_mb()?). Are
> > there restrictions on the types of access that can occur in the critical
> > section?
> 
> Oh, good spot. I missed it because it doesn't actually remove the one in
> the header, why is that?
> 

Good catch.  I merged an older version of Waiman's patch.  I'll correct
this and update with the patch series with the newer one that should
only call the mcs_spin_lock in the header file.

Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
