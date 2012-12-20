Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 031FF6B0068
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 07:47:13 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id e13so1362724eaa.33
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 04:47:12 -0800 (PST)
Date: Thu, 20 Dec 2012 13:47:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: limit mmu_gather batching to fix soft lockups on
 !CONFIG_PREEMPT
Message-ID: <20121220124710.GA31912@dhcp22.suse.cz>
References: <1355847088-1207-1-git-send-email-mhocko@suse.cz>
 <20121218140219.45867ddd.akpm@linux-foundation.org>
 <20121218235042.GA10350@dhcp22.suse.cz>
 <20121218160030.baf723aa.akpm@linux-foundation.org>
 <20121219150423.GA12888@dhcp22.suse.cz>
 <20121219131316.7d13fcb1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121219131316.7d13fcb1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed 19-12-12 13:13:16, Andrew Morton wrote:
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
> Realistically, I don't think we need to worry about CONFIG_PREEMPT here
> - if we just limit the thing to, say, 64k pages per batch then that
> will be OK for preemptible and non-preemptible kernels. 

I wanted the fix to be as non-intrusive as possible so I didn't want to
touch PREEMPT (which is default in many configs) at all. I am OK to a
single limit of course.

> The performance difference between "64k" and "infinite" will be
> miniscule and unmeasurable.
> 
> Also, the batch count should be independent of PAGE_SIZE.  Because
> PAGE_SIZE can vary by a factor of 16 and you don't want to fix the
> problem on 4k page size but leave it broken on 64k page size.

MAX_GATHER_BATCH depends on the page size so I didn't want to differ
without a good reason.

> Also, while the patch might prevent softlockup warnings, the kernel
> will still exhibit large latency glitches and those are undesirable.

Not really. cond_resched is called per pmd. This patch just helps the
case where there is enough free memory to batch too much and then soft
lockup while flushing mmu_gather after the whole zapping is done because
tlb_flush_mmu is called more often.

> Also, does this patch actually work?  It doesn't add a scheduling
> point.  It assumes that by returning zero from tlb_next_batch(), the
> process will back out to some point where it hits a cond_resched()?

No, as mentioned above. cond_resched is called per pmd independently
on how much batching we do but then after free_pgtables is done we
call tlb_finish_mmu and that one needs to free all the gathered
pages. Without the limit we can have too many pages to free and that is
what triggers soft lockup. My original patch was more obvious because it
added the cond_resched but as you pointed out it could be problematic so
this patch tries to eliminate the problem in the very beginning instead.

> So I'm thinking that to address both the softlockup-detector problem
> and the large-latency-glitch problem we should do something like:
> 
> 	if (need_resched() && tlb->batch_count > 64k)
> 		return 0;

need_resched is not needed because of cond_resched in zap_pmd_range. I
am OK with a fixed limit.

> and then ensure that there's a cond_resched() at a safe point between
> batches?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
