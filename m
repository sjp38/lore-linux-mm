Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 754BE6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 09:13:50 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id x13so6808126wgg.21
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 06:13:49 -0800 (PST)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id cc14si940682wib.54.2014.01.20.06.13.48
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 06:13:48 -0800 (PST)
Date: Mon, 20 Jan 2014 14:11:57 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v7 5/6] MCS Lock: allow architectures to hook in to
 contended paths
Message-ID: <20140120141157.GC9868@mudshark.cambridge.arm.com>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917311.3138.15.camel@schen9-DESK>
 <20140120121948.GD31570@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140120121948.GD31570@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Jan 20, 2014 at 12:19:48PM +0000, Peter Zijlstra wrote:
> On Thu, Jan 16, 2014 at 04:08:31PM -0800, Tim Chen wrote:
> > +#ifndef arch_mcs_spin_lock_contended
> > +/*
> > + * Using smp_load_acquire() provides a memory barrier that ensures
> > + * subsequent operations happen after the lock is acquired.
> > + */
> > +#define arch_mcs_spin_lock_contended(l)					\
> > +	while (!(smp_load_acquire(l))) {				\
> > +		arch_mutex_cpu_relax();					\
> > +	}
> > +#endif
> 
> I think that wants to be:
> 
> #define arch_mcs_spin_lock_contended(l)				\
> do {								\
> 	while (!smp_load_acquire(l))				\
> 		arch_mutex_cpu_relax();				\
> } while (0)
> 
> So that we properly eat the ';' in: arch_mcs_spin_lock_contended(l);.

Yeah, that's better.

Tim: are you happy making that change please?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
