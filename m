Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 6D44F6B005D
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 05:24:43 -0500 (EST)
Date: Thu, 20 Dec 2012 10:24:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm: limit mmu_gather batching to fix soft lockups on
 !CONFIG_PREEMPT
Message-ID: <20121220102438.GA10819@suse.de>
References: <1355847088-1207-1-git-send-email-mhocko@suse.cz>
 <20121218140219.45867ddd.akpm@linux-foundation.org>
 <20121218235042.GA10350@dhcp22.suse.cz>
 <20121218160030.baf723aa.akpm@linux-foundation.org>
 <20121219150423.GA12888@dhcp22.suse.cz>
 <20121219131316.7d13fcb1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121219131316.7d13fcb1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, Dec 19, 2012 at 01:13:16PM -0800, Andrew Morton wrote:
> On Wed, 19 Dec 2012 16:04:37 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Since e303297 (mm: extended batches for generic mmu_gather) we are batching
> > pages to be freed until either tlb_next_batch cannot allocate a new batch or we
> > are done.
> > 
> > This works just fine most of the time but we can get in troubles with
> > non-preemptible kernel (CONFIG_PREEMPT_NONE or CONFIG_PREEMPT_VOLUNTARY)
> > on large machines where too aggressive batching might lead to soft
> > lockups during process exit path (exit_mmap) because there are no
> > scheduling points down the free_pages_and_swap_cache path and so the
> > freeing can take long enough to trigger the soft lockup.
> > 
> > The lockup is harmless except when the system is setup to panic on
> > softlockup which is not that unusual.
> > 
> > The simplest way to work around this issue is to limit the maximum
> > number of batches in a single mmu_gather for !CONFIG_PREEMPT kernels.
> > Let's use 1G of resident memory for the limit for now. This shouldn't
> > make the batching less effective and it shouldn't trigger lockups as
> > well because freeing 262144 should be OK.
> > 
> > ...
> >
> > diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
> > index ed6642a..5843f59 100644
> > --- a/include/asm-generic/tlb.h
> > +++ b/include/asm-generic/tlb.h
> > @@ -78,6 +78,19 @@ struct mmu_gather_batch {
> >  #define MAX_GATHER_BATCH	\
> >  	((PAGE_SIZE - sizeof(struct mmu_gather_batch)) / sizeof(void *))
> >  
> > +/*
> > + * Limit the maximum number of mmu_gather batches for non-preemptible kernels
> > + * to reduce a risk of soft lockups on huge machines when a lot of memory is
> > + * zapped during unmapping.
> > + * 1GB of resident memory should be safe to free up at once even without
> > + * explicit preemption point.
> > + */
> > +#if defined(CONFIG_PREEMPT_COUNT)
> > +#define MAX_GATHER_BATCH_COUNT	(UINT_MAX)
> > +#else
> > +#define MAX_GATHER_BATCH_COUNT	(((1UL<<(30-PAGE_SHIFT))/MAX_GATHER_BATCH))
> 
> Geeze.  I spent waaaaay too long staring at that expression trying to
> work out "how many pages is in a batch" and gave up.
> 

1G.

> Realistically, I don't think we need to worry about CONFIG_PREEMPT here
> - if we just limit the thing to, say, 64k pages per batch then that
> will be OK for preemptible and non-preemptible kernels.  The
> performance difference between "64k" and "infinite" will be miniscule
> and unmeasurable.
> 

That was my fault due to a private conversation. Michal originally had
a fixed counter that was commented to be related to address space size
on x86-64. I felt if it was based on address space size then it should be
expressed in terms of PAGE_SIZE. It really is about the number of TLB flush
operations though and a fixed counter works. I'm happy either way but the
comment should not mention address space size if it's a fixed counter.

> Also, the batch count should be independent of PAGE_SIZE.  Because
> PAGE_SIZE can vary by a factor of 16 and you don't want to fix the
> problem on 4k page size but leave it broken on 64k page size.
> 
> Also, while the patch might prevent softlockup warnings, the kernel
> will still exhibit large latency glitches and those are undesirable.
> 
> Also, does this patch actually work?  It doesn't add a scheduling
> point.  It assumes that by returning zero from tlb_next_batch(), the
> process will back out to some point where it hits a cond_resched()?
> 

I expected it to work for two reasons.

1. returning here hits the cond_resched() in zap_pmd_range()
2. The original soft lockup was in tlb_finish_mmu and this patch should
   limit the amount of work that thing has to do

I didn't test it though.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
