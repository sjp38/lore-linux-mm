Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 820BB6B005D
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 18:50:46 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so677563eek.34
        for <linux-mm@kvack.org>; Tue, 18 Dec 2012 15:50:44 -0800 (PST)
Date: Wed, 19 Dec 2012 00:50:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: cond_resched in tlb_flush_mmu to fix soft lockups on
 !CONFIG_PREEMPT
Message-ID: <20121218235042.GA10350@dhcp22.suse.cz>
References: <1355847088-1207-1-git-send-email-mhocko@suse.cz>
 <20121218140219.45867ddd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121218140219.45867ddd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue 18-12-12 14:02:19, Andrew Morton wrote:
> On Tue, 18 Dec 2012 17:11:28 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Since e303297 (mm: extended batches for generic mmu_gather) we are batching
> > pages to be freed until either tlb_next_batch cannot allocate a new batch or we
> > are done.
> > 
> > This works just fine most of the time but we can get in troubles with
> > non-preemptible kernel (CONFIG_PREEMPT_NONE or CONFIG_PREEMPT_VOLUNTARY) on
> > large machines where too aggressive batching might lead to soft lockups during
> > process exit path (exit_mmap) because there are no scheduling points down the
> > free_pages_and_swap_cache path and so the freeing can take long enough to
> > trigger the soft lockup.
> > 
> > The lockup is harmless except when the system is setup to panic on
> > softlockup which is not that unusual.
> > 
> > The simplest way to work around this issue is to explicitly cond_resched per
> > batch in tlb_flush_mmu (1020 pages on x86_64).
> > 
> > ...
> >
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -239,6 +239,7 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
> >  	for (batch = &tlb->local; batch; batch = batch->next) {
> >  		free_pages_and_swap_cache(batch->pages, batch->nr);
> >  		batch->nr = 0;
> > +		cond_resched();
> >  	}
> >  	tlb->active = &tlb->local;
> >  }
> 
> tlb_flush_mmu() has a large number of callsites (or callsites which
> call callers, etc), many in arch code.  It's not at all obvious that
> tlb_flush_mmu() is never called from under spinlock?

free_pages_and_swap_cache calls lru_add_drain which in turn calls
put_cpu (aka preempt_enable) which is a scheduling point for
CONFIG_PREEMPT. There are more down the call chain probably. None of
them for non-preempt kernel.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
