Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id F10356B005D
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 19:00:31 -0500 (EST)
Date: Tue, 18 Dec 2012 16:00:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cond_resched in tlb_flush_mmu to fix soft lockups
 on !CONFIG_PREEMPT
Message-Id: <20121218160030.baf723aa.akpm@linux-foundation.org>
In-Reply-To: <20121218235042.GA10350@dhcp22.suse.cz>
References: <1355847088-1207-1-git-send-email-mhocko@suse.cz>
	<20121218140219.45867ddd.akpm@linux-foundation.org>
	<20121218235042.GA10350@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, 19 Dec 2012 00:50:42 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 18-12-12 14:02:19, Andrew Morton wrote:
> > On Tue, 18 Dec 2012 17:11:28 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > Since e303297 (mm: extended batches for generic mmu_gather) we are batching
> > > pages to be freed until either tlb_next_batch cannot allocate a new batch or we
> > > are done.
> > > 
> > > This works just fine most of the time but we can get in troubles with
> > > non-preemptible kernel (CONFIG_PREEMPT_NONE or CONFIG_PREEMPT_VOLUNTARY) on
> > > large machines where too aggressive batching might lead to soft lockups during
> > > process exit path (exit_mmap) because there are no scheduling points down the
> > > free_pages_and_swap_cache path and so the freeing can take long enough to
> > > trigger the soft lockup.
> > > 
> > > The lockup is harmless except when the system is setup to panic on
> > > softlockup which is not that unusual.
> > > 
> > > The simplest way to work around this issue is to explicitly cond_resched per
> > > batch in tlb_flush_mmu (1020 pages on x86_64).
> > > 
> > > ...
> > >
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -239,6 +239,7 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
> > >  	for (batch = &tlb->local; batch; batch = batch->next) {
> > >  		free_pages_and_swap_cache(batch->pages, batch->nr);
> > >  		batch->nr = 0;
> > > +		cond_resched();
> > >  	}
> > >  	tlb->active = &tlb->local;
> > >  }
> > 
> > tlb_flush_mmu() has a large number of callsites (or callsites which
> > call callers, etc), many in arch code.  It's not at all obvious that
> > tlb_flush_mmu() is never called from under spinlock?
> 
> free_pages_and_swap_cache calls lru_add_drain which in turn calls
> put_cpu (aka preempt_enable) which is a scheduling point for
> CONFIG_PREEMPT.

No, that inference doesn't work.  Because preempt_enable() inside
spinlock is OK - it will not call schedule() because
current->preempt_count is still elevated (by spin_lock).

> There are more down the call chain probably. None of
> them for non-preempt kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
