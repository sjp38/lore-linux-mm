Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1CAD46B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 04:14:39 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so29603734wgb.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:14:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dj6si8128144wib.22.2015.06.10.01.14.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 01:14:37 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:14:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
Message-ID: <20150610081432.GY26425@suse.de>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-3-git-send-email-mgorman@suse.de>
 <20150610074704.GA18049@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150610074704.GA18049@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 10, 2015 at 09:47:04AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1289,6 +1289,18 @@ enum perf_event_task_context {
> >  	perf_nr_task_contexts,
> >  };
> >  
> > +/* Track pages that require TLB flushes */
> > +struct tlbflush_unmap_batch {
> > +	/*
> > +	 * Each bit set is a CPU that potentially has a TLB entry for one of
> > +	 * the PFNs being flushed. See set_tlb_ubc_flush_pending().
> > +	 */
> > +	struct cpumask cpumask;
> > +
> > +	/* True if any bit in cpumask is set */
> > +	bool flush_required;
> > +};
> > +
> >  struct task_struct {
> >  	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
> >  	void *stack;
> > @@ -1648,6 +1660,10 @@ struct task_struct {
> >  	unsigned long numa_pages_migrated;
> >  #endif /* CONFIG_NUMA_BALANCING */
> >  
> > +#ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
> > +	struct tlbflush_unmap_batch *tlb_ubc;
> > +#endif
> 
> Please embedd this constant size structure in task_struct directly so that the 
> whole per task allocation overhead goes away:
> 

That puts a structure (72 bytes in the config I used) within the task struct
even when it's not required. On a lightly loaded system direct reclaim
will not be active and for some processes, it'll never be active. It's
very wasteful.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
