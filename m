Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F67D6B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 09:30:24 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l24so2412608wre.18
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:30:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r2sor5089517wra.0.2017.10.18.06.30.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 06:30:22 -0700 (PDT)
Date: Wed, 18 Oct 2017 15:30:19 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171018133019.cwfhnt46pvhirt57@gmail.com>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <alpine.DEB.2.20.1710181519580.1925@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710181519580.1925@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Byungchul Park <byungchul.park@lge.com>, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com


* Thomas Gleixner <tglx@linutronix.de> wrote:

> On Wed, 18 Oct 2017, Byungchul Park wrote:
> >  #ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +#ifdef CONFIG_CROSSRELEASE_STACK_TRACE
> >  #define MAX_XHLOCK_TRACE_ENTRIES 5
> > +#else
> > +#define MAX_XHLOCK_TRACE_ENTRIES 1
> > +#endif
> >  
> >  /*
> >   * This is for keeping locks waiting for commit so that true dependencies
> > diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> > index e36e652..5c2ddf2 100644
> > --- a/kernel/locking/lockdep.c
> > +++ b/kernel/locking/lockdep.c
> > @@ -4863,8 +4863,13 @@ static void add_xhlock(struct held_lock *hlock)
> >  	xhlock->trace.nr_entries = 0;
> >  	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
> >  	xhlock->trace.entries = xhlock->trace_entries;
> > +#ifdef CONFIG_CROSSRELEASE_STACK_TRACE
> >  	xhlock->trace.skip = 3;
> >  	save_stack_trace(&xhlock->trace);
> > +#else
> > +	xhlock->trace.nr_entries = 1;
> > +	xhlock->trace.entries[0] = hlock->acquire_ip;
> > +#endif
> 
> Hmm. Would it be possible to have this switchable at boot time via a
> command line parameter? So in case of a splat with no stack trace, one
> could just reboot and set something like 'lockdep_fullstack' on the kernel
> command line to get the full data without having to recompile the kernel.

Yeah, and I'd suggest keeping the Kconfig option to default-enable that boot 
option as well - i.e. let's have both.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
