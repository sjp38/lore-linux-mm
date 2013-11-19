Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA146B004D
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 14:23:30 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so2347480pbb.37
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 11:23:29 -0800 (PST)
Received: from psmtp.com ([74.125.245.165])
        by mx.google.com with SMTP id xa2si12288665pab.200.2013.11.19.11.23.27
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 11:23:28 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Nov 2013 12:23:27 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 31B963E4004E
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:23:23 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAJHLO1J3998180
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 18:21:24 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAJJQEmh019751
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:26:16 -0700
Date: Tue, 19 Nov 2013 11:23:20 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 4/4] MCS Lock: Barrier corrections
Message-ID: <20131119192319.GR4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1383935697.git.tim.c.chen@linux.intel.com>
 <1383940358.11046.417.camel@schen9-DESK>
 <20131111181049.GL28302@mudshark.cambridge.arm.com>
 <20131111182059.GC21461@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131111182059.GC21461@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Nov 11, 2013 at 07:20:59PM +0100, Peter Zijlstra wrote:
> On Mon, Nov 11, 2013 at 06:10:49PM +0000, Will Deacon wrote:
> > > +	/*
> > > +	 * Wait until the lock holder passes the lock down.
> > > +	 * Using smp_load_acquire() provides a memory barrier that
> > > +	 * ensures subsequent operations happen after the lock is acquired.
> > > +	 */
> > > +	while (!(smp_load_acquire(&node->locked)))
> > >  		arch_mutex_cpu_relax();
> 
> > Thinking more about that, the real issue here is that arch_mutex_cpu_relax()
> > doesn't have a corresponding hook on the unlock side. On ARM, for example,
> > we can enter a low-power state using the wfe instruction, but that requires
> > the unlocker to wake up the core when the lock is released.
> 
> That said, it would be ever so awesome if we could come to some sort of
> conclusion on control dependencies here.
> 
> I _know_ C/C++ doesn't do them, but at the end of the day the compiler
> still generates ASM and as long as we're relatively certain there's a
> loop there (there has to be, right? :-), we could maybe rely on it
> anyway.

I believe that we will be able to rely on control dependencies leading
to stores (not loads!), but even then they are not guaranteed to provide
transitivity.  This lack of transitivity sounds problematic for locking
primitives.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
