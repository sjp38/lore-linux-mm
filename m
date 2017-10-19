Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B12A56B0253
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 22:00:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 15so5434287pgc.21
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 19:00:45 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 1si5634251plp.418.2017.10.18.19.00.43
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 19:00:44 -0700 (PDT)
Date: Thu, 19 Oct 2017 11:00:33 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171019020033.GG32368@X58A-UD3R>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <alpine.DEB.2.20.1710181519580.1925@nanos>
 <20171018133019.cwfhnt46pvhirt57@gmail.com>
 <alpine.DEB.2.20.1710181533260.1925@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710181533260.1925@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

On Wed, Oct 18, 2017 at 03:36:05PM +0200, Thomas Gleixner wrote:
> On Wed, 18 Oct 2017, Ingo Molnar wrote:
> > * Thomas Gleixner <tglx@linutronix.de> wrote:
> > 
> > > On Wed, 18 Oct 2017, Byungchul Park wrote:
> > > >  #ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > > > +#ifdef CONFIG_CROSSRELEASE_STACK_TRACE
> > > >  #define MAX_XHLOCK_TRACE_ENTRIES 5
> > > > +#else
> > > > +#define MAX_XHLOCK_TRACE_ENTRIES 1
> > > > +#endif
> > > >  
> > > >  /*
> > > >   * This is for keeping locks waiting for commit so that true dependencies
> > > > diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> > > > index e36e652..5c2ddf2 100644
> > > > --- a/kernel/locking/lockdep.c
> > > > +++ b/kernel/locking/lockdep.c
> > > > @@ -4863,8 +4863,13 @@ static void add_xhlock(struct held_lock *hlock)
> > > >  	xhlock->trace.nr_entries = 0;
> > > >  	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
> > > >  	xhlock->trace.entries = xhlock->trace_entries;
> > > > +#ifdef CONFIG_CROSSRELEASE_STACK_TRACE
> > > >  	xhlock->trace.skip = 3;
> > > >  	save_stack_trace(&xhlock->trace);
> > > > +#else
> > > > +	xhlock->trace.nr_entries = 1;
> > > > +	xhlock->trace.entries[0] = hlock->acquire_ip;
> > > > +#endif
> > > 
> > > Hmm. Would it be possible to have this switchable at boot time via a
> > > command line parameter? So in case of a splat with no stack trace, one
> > > could just reboot and set something like 'lockdep_fullstack' on the kernel
> > > command line to get the full data without having to recompile the kernel.
> > 
> > Yeah, and I'd suggest keeping the Kconfig option to default-enable that boot 
> > option as well - i.e. let's have both.
> 
> That makes sense. Like we have with debug objects:
> DEBUG_OBJECTS_ENABLE_DEFAULT.

Thank you very much for the suggestion. I will work for it.

> Which reminds me that I wanted to convert them to static_key so they are
> zero overhead when disabled. Sigh, why are todo lists growth only?
> 
> Thanks,
> 
> 	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
