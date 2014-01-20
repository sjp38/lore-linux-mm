Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 712A96B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:44:00 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so2185467pbc.40
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 08:44:00 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qv10si2061303pbb.52.2014.01.20.08.43.58
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 08:43:59 -0800 (PST)
Subject: Re: [PATCH v7 5/6] MCS Lock: allow architectures to hook in to
 contended paths
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20140120141157.GC9868@mudshark.cambridge.arm.com>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
	 <1389917311.3138.15.camel@schen9-DESK>
	 <20140120121948.GD31570@twins.programming.kicks-ass.net>
	 <20140120141157.GC9868@mudshark.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jan 2014 08:43:45 -0800
Message-ID: <1390236225.3138.21.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, 2014-01-20 at 14:11 +0000, Will Deacon wrote:
> On Mon, Jan 20, 2014 at 12:19:48PM +0000, Peter Zijlstra wrote:
> > On Thu, Jan 16, 2014 at 04:08:31PM -0800, Tim Chen wrote:
> > > +#ifndef arch_mcs_spin_lock_contended
> > > +/*
> > > + * Using smp_load_acquire() provides a memory barrier that ensures
> > > + * subsequent operations happen after the lock is acquired.
> > > + */
> > > +#define arch_mcs_spin_lock_contended(l)					\
> > > +	while (!(smp_load_acquire(l))) {				\
> > > +		arch_mutex_cpu_relax();					\
> > > +	}
> > > +#endif
> > 
> > I think that wants to be:
> > 
> > #define arch_mcs_spin_lock_contended(l)				\
> > do {								\
> > 	while (!smp_load_acquire(l))				\
> > 		arch_mutex_cpu_relax();				\
> > } while (0)
> > 
> > So that we properly eat the ';' in: arch_mcs_spin_lock_contended(l);.
> 
> Yeah, that's better.
> 
> Tim: are you happy making that change please?
> 
> Will

Sure, will do.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
