Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 41C276B0071
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 10:04:42 -0500 (EST)
Date: Wed, 19 Dec 2012 16:04:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v2] mm: limit mmu_gather batching to fix soft lockups on
 !CONFIG_PREEMPT
Message-ID: <20121219150423.GA12888@dhcp22.suse.cz>
References: <1355847088-1207-1-git-send-email-mhocko@suse.cz>
 <20121218140219.45867ddd.akpm@linux-foundation.org>
 <20121218235042.GA10350@dhcp22.suse.cz>
 <20121218160030.baf723aa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121218160030.baf723aa.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue 18-12-12 16:00:30, Andrew Morton wrote:
> On Wed, 19 Dec 2012 00:50:42 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Tue 18-12-12 14:02:19, Andrew Morton wrote:
> > > On Tue, 18 Dec 2012 17:11:28 +0100
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > Since e303297 (mm: extended batches for generic mmu_gather) we are batching
> > > > pages to be freed until either tlb_next_batch cannot allocate a new batch or we
> > > > are done.
> > > > 
> > > > This works just fine most of the time but we can get in troubles with
> > > > non-preemptible kernel (CONFIG_PREEMPT_NONE or CONFIG_PREEMPT_VOLUNTARY) on
> > > > large machines where too aggressive batching might lead to soft lockups during
> > > > process exit path (exit_mmap) because there are no scheduling points down the
> > > > free_pages_and_swap_cache path and so the freeing can take long enough to
> > > > trigger the soft lockup.
> > > > 
> > > > The lockup is harmless except when the system is setup to panic on
> > > > softlockup which is not that unusual.
> > > > 
> > > > The simplest way to work around this issue is to explicitly cond_resched per
> > > > batch in tlb_flush_mmu (1020 pages on x86_64).
> > > > 
> > > > ...
> > > >
> > > > --- a/mm/memory.c
> > > > +++ b/mm/memory.c
> > > > @@ -239,6 +239,7 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
> > > >  	for (batch = &tlb->local; batch; batch = batch->next) {
> > > >  		free_pages_and_swap_cache(batch->pages, batch->nr);
> > > >  		batch->nr = 0;
> > > > +		cond_resched();
> > > >  	}
> > > >  	tlb->active = &tlb->local;
> > > >  }
> > > 
> > > tlb_flush_mmu() has a large number of callsites (or callsites which
> > > call callers, etc), many in arch code.  It's not at all obvious that
> > > tlb_flush_mmu() is never called from under spinlock?
> > 
> > free_pages_and_swap_cache calls lru_add_drain which in turn calls
> > put_cpu (aka preempt_enable) which is a scheduling point for
> > CONFIG_PREEMPT.
> 
> No, that inference doesn't work.  Because preempt_enable() inside
> spinlock is OK - it will not call schedule() because
> current->preempt_count is still elevated (by spin_lock).

Bahh, you are right. I was checking the callsites when patching our
internal kernel and it was really tedious so I thought this would be
easier to show.
Now when thinking about it some more it would be much safer to not
cond_resched unconditionally because this has a potential to blow up at
random places/archs. It sounds much more appropriate to kill the problem
where it started - an unbounded amount of batches. What do you think
about the following?
---
