Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A8B1F6B029A
	for <linux-mm@kvack.org>; Wed,  5 May 2010 09:55:59 -0400 (EDT)
Date: Wed, 5 May 2010 14:55:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] fix count_vm_event preempt in memory compaction direct
	reclaim
Message-ID: <20100505135537.GO20979@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie> <1271797276-31358-13-git-send-email-mel@csn.ul.ie> <20100505121908.GA5835@random.random> <20100505125156.GM20979@csn.ul.ie> <20100505131112.GB5835@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100505131112.GB5835@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 03:11:12PM +0200, Andrea Arcangeli wrote:
> On Wed, May 05, 2010 at 01:51:56PM +0100, Mel Gorman wrote:
> > On Wed, May 05, 2010 at 02:19:08PM +0200, Andrea Arcangeli wrote:
> > > On Tue, Apr 20, 2010 at 10:01:14PM +0100, Mel Gorman wrote:
> > > > +		if (page) {
> > > > +			__count_vm_event(COMPACTSUCCESS);
> > > > +			return page;
> > > 
> > > ==
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > Preempt is enabled so it must use count_vm_event.
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > Andrew, this is a fix to the patch
> > mmcompaction-direct-compact-when-a-high-order-allocation-fails.patch
> 
> for Andrew: I'll generate a trivial reject to the exponential backoff.
> 
> > Thanks Andrea, well spotted.
> 
> You're welcome.
> 
> I updated current aa.git origin/master and origin/anon_vma_chain
> branches (post THP-23*).
> 

Ok.

> There's also another patch I've in my tree that you didn't picked up
> and I wonder what's the issue here.

Simple, I didn't spot it. If you pointed it out to me, I didn't take
note of it and it got lost. Sorry if you did.

> This less a bugfix because it
> seems to only affect lockdep, I don't know why lockdep forbids to call
> migrate_prep with any lock held (in this case the mmap_sem).

I haven't seen this problem. The testing I'd have been doing with compaction
were stress tests allocating huge pages but not from the fault path.

> migrate.c
> is careful to comply with it, compaction.c isn't. It's not mandatory
> to succeed for compaction, so in doubt I just commented it out.

It's not mandatory but the LRU lists should be drained so they can be properly
isolated. It'd make a slight difference to success rates as there will be
pages that cannot be isolated because they are on some pagevec.

> It'll
> also decrease the IPI load so I wasn't very concerned to re-enable it.
> 

While true, is compaction density that high under normal workloads? I guess
it would be if a scanner was constantly trying to promote pages.  If the
IPI load is out of hand, I'm ok with disabling in some cases. For example,
I'd be ok with it being skipped if it was part of a daemon doing speculative
promotion but I'd prefer it to still be used if the static hugetlbfs pool
was being resized if that was possible.

> -----
> Subject: disable migrate_prep()
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> I get trouble from lockdep if I leave it enabled:
> 
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.34-rc3 #50
> -------------------------------------------------------
> largepages/4965 is trying to acquire lock:
>  (events){+.+.+.}, at: [<ffffffff8105b788>] flush_work+0x38/0x130
> 
>  but task is already holding lock:
>   (&mm->mmap_sem){++++++}, at: [<ffffffff8141b022>] do_page_fault+0xd2/0x430
> 

Hmm, I'm not seeing where in the fault path flush_work is getting called
from. Can you point it out to me please?

We already do some IPI work in the page allocator although it happens after
direct reclaim and only for high-order pages. What happens there and what
happens in migrate_prep are very similar so if there was a problem with IPI
and fault paths, I'd have expected to see it from hugetlbfs at some stage.

> flush_work apparently wants to run free from lock and it bugs in:
> 
> 	lock_map_acquire(&cwq->wq->lockdep_map);
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -383,7 +383,9 @@ static int compact_zone(struct zone *zon
>  	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
>  	cc->free_pfn &= ~(pageblock_nr_pages-1);
>  
> +#if 0
>  	migrate_prep();
> +#endif
>  
>  	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
>  		unsigned long nr_migrate, nr_remaining;
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
