Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5E75C6B0110
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 13:21:40 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id xa7so5588583pbc.10
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 10:21:40 -0800 (PST)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id xp9si14181453pab.26.2013.11.11.10.21.37
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 10:21:38 -0800 (PST)
Date: Mon, 11 Nov 2013 19:20:59 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 4/4] MCS Lock: Barrier corrections
Message-ID: <20131111182059.GC21461@twins.programming.kicks-ass.net>
References: <cover.1383935697.git.tim.c.chen@linux.intel.com>
 <1383940358.11046.417.camel@schen9-DESK>
 <20131111181049.GL28302@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131111181049.GL28302@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Nov 11, 2013 at 06:10:49PM +0000, Will Deacon wrote:
> > +	/*
> > +	 * Wait until the lock holder passes the lock down.
> > +	 * Using smp_load_acquire() provides a memory barrier that
> > +	 * ensures subsequent operations happen after the lock is acquired.
> > +	 */
> > +	while (!(smp_load_acquire(&node->locked)))
> >  		arch_mutex_cpu_relax();

> Thinking more about that, the real issue here is that arch_mutex_cpu_relax()
> doesn't have a corresponding hook on the unlock side. On ARM, for example,
> we can enter a low-power state using the wfe instruction, but that requires
> the unlocker to wake up the core when the lock is released.

That said, it would be ever so awesome if we could come to some sort of
conclusion on control dependencies here.

I _know_ C/C++ doesn't do them, but at the end of the day the compiler
still generates ASM and as long as we're relatively certain there's a
loop there (there has to be, right? :-), we could maybe rely on it
anyway.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
