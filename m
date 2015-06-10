Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id EB11A6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 04:51:37 -0400 (EDT)
Received: by wifx6 with SMTP id x6so39852129wif.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:51:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx5si8323525wib.35.2015.06.10.01.51.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 01:51:36 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:51:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
Message-ID: <20150610085130.GA26425@suse.de>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-3-git-send-email-mgorman@suse.de>
 <20150610074704.GA18049@gmail.com>
 <20150610081432.GY26425@suse.de>
 <20150610082107.GA23575@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150610082107.GA23575@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 10, 2015 at 10:21:07AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Wed, Jun 10, 2015 at 09:47:04AM +0200, Ingo Molnar wrote:
> > > 
> > > * Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > --- a/include/linux/sched.h
> > > > +++ b/include/linux/sched.h
> > > > @@ -1289,6 +1289,18 @@ enum perf_event_task_context {
> > > >  	perf_nr_task_contexts,
> > > >  };
> > > >  
> > > > +/* Track pages that require TLB flushes */
> > > > +struct tlbflush_unmap_batch {
> > > > +	/*
> > > > +	 * Each bit set is a CPU that potentially has a TLB entry for one of
> > > > +	 * the PFNs being flushed. See set_tlb_ubc_flush_pending().
> > > > +	 */
> > > > +	struct cpumask cpumask;
> > > > +
> > > > +	/* True if any bit in cpumask is set */
> > > > +	bool flush_required;
> > > > +};
> > > > +
> > > >  struct task_struct {
> > > >  	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
> > > >  	void *stack;
> > > > @@ -1648,6 +1660,10 @@ struct task_struct {
> > > >  	unsigned long numa_pages_migrated;
> > > >  #endif /* CONFIG_NUMA_BALANCING */
> > > >  
> > > > +#ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
> > > > +	struct tlbflush_unmap_batch *tlb_ubc;
> > > > +#endif
> > > 
> > > Please embedd this constant size structure in task_struct directly so that the 
> > > whole per task allocation overhead goes away:
> > > 
> > 
> > That puts a structure (72 bytes in the config I used) within the task struct 
> > even when it's not required. On a lightly loaded system direct reclaim will not 
> > be active and for some processes, it'll never be active. It's very wasteful.
> 
> For certain values of 'very'.
> 
>  - 72 bytes suggests that you have NR_CPUS set to 512 or so? On a kernel sized to 
>    such large systems with 1000 active tasks we are talking about about +72K of 
>    RAM...
> 

The NR_CPUS is based on the openSUSE 13.1 distro config so yes, it's large but I also
expect it to be a common configuration.

>  - Furthermore, by embedding it it gets packed better with neighboring task_struct 
>    fields, while by allocating it dynamically it's a separate cache line wasted.
> 

A separate cache line that is only used during direct reclaim when the
process is taking a large hit anyway

>  - Plus by allocating it separately you spend two cachelines on it: each slab will 
>    be at least cacheline aligned, and 72 bytes will allocate 128 bytes. So when 
>    this gets triggered you've just wasted some more RAM.
> 
>  - I mean, if it had dynamic size, or was arguably huge. But this is just a 
>    cpumask and a boolean!
> 

It gets larger with enterprise configs.

>  - The cpumask will be dynamic if you increase the NR_CPUS count any more than 
>    that - in which case embedding the structure is the right choice again.
> 

Enterprise configurations are larger. The most recent one I checked defined
NR_CPUS as 8192. If it's embedded in the structure, it means that we need
to call cpumask_clear on every fork even if it's never used. That adds
constant overhead to a fast path to avoid an allocation and a few cache
misses in a direct reclaim path. Are you certain you want that trade-off?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
