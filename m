Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 85C8C6B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 20:14:57 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so9946981pdj.22
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:14:57 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ag4si15827499pac.77.2014.07.21.17.14.54
        for <linux-mm@kvack.org>;
        Mon, 21 Jul 2014 17:14:55 -0700 (PDT)
Date: Tue, 22 Jul 2014 09:15:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] CMA/HOTPLUG: clear buffer-head lru before page migration
Message-ID: <20140722001545.GC15912@bbox>
References: <53C8C290.90503@lge.com>
 <20140721025047.GA7707@bbox>
 <53CCB02A.7070301@lge.com>
 <20140721073651.GA15912@bbox>
 <20140721130146.GO10544@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140721130146.GO10544@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Gioh Kim <gioh.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, '?????????' <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ????????? <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>, linux-fsdevel@vger.kernel.org

Hello Mel,

On Mon, Jul 21, 2014 at 02:01:46PM +0100, Mel Gorman wrote:
> On Mon, Jul 21, 2014 at 04:36:51PM +0900, Minchan Kim wrote:
> 
> I'm not reviewing this in detail at all, didn't even look at the patch
> but two things popped out at me during the discussion.
> 
> > > >Anyway, why cannot CMA have the cost without affecting other subsystem?
> > > >I mean it's okay for CMA to consume more time to shoot out the bh
> > > >instead of simple all bh_lru invalidation because big order allocation is
> > > >kinds of slow thing in the VM and everybody already know that and even
> > > >sometime get failed so it's okay to add more code that extremly slow path.
> > > 
> > > There are 2 reasons to invalidate entire bh_lru.
> > > 
> > > 1. I think CMA allocation is very rare so that invalidaing bh_lru affects the system little.
> > > How do you think about it? My platform does not call CMA allocation often.
> > > Is the CMA allocation or Memory-Hotplug called often?
> > 
> > It depends on usecase and you couldn't assume anyting because we couldn't
> > ask every people in the world. "Please ask to us whenever you try to use CMA".
> > 
> > The key point is how the patch is maintainable.
> > If it's too complicate to maintain, maybe we could go with simple solution
> > but if it's not too complicate, we can go with more smart thing to consider
> > other cases in future. Why not?
> > 
> > Another point is that how user can detect where the regression is from.
> > If we cannot notice the regression, it's not a good idea to go with simple
> > version.
> > 
> 
> The buffer LRU avoids a lookup of a radix tree. If the LRU hit rate is
> low then the performance penalty of repeated radix tree lookups is
> severe but the cost of missing one hot lookup because CMA invalidate it
> is not.
> 
> The real cost to be concerned with is the cost of performing the
> invalidation not the fact a lookup in the LRU was missed. It's because
> the cost of invalidation is high that this is being pushed to CMA because
> for CMA an allocation failure can be a functional failure and not just a
> performance problem.
> 
> > > 
> > > 2. Adding code in drop_buffers() can affect the system more that adding code in alloc_contig_range()
> > > because the drop_buffers does not have a way to distinguish migrate type.
> > > Even-though the lmbech results that it has almost the same performance.
> > > But I am afraid that it can be changed.
> > > As you said if bh_lru size can be changed it affects more than now.
> > > SO I do not want to touch non-CMA related code.
> > 
> > I'm not saying to add hook in drop_buffers.
> > What I suggest is to handle failure by bh_lrus in migrate_pages
> > because it's not a problem only in CMA.
> 
> No, please do not insert a global IPI to invalidate buffer heads in the
> general migration case. It's too expensive for either THP allocations or
> automatic NUMA migrates. The global IPI cost is justified for rare events
> where it causes functional problems if it fails to migreate -- CMA, memory
> hot-remove, memory poisoning etc.

I didn't want to add that flushing in migrate_pages *unconditionlly*.
Please, look at this patch. It fixes only CMA although it's an issue
for others. Even, it depends on retry logic of upper layer of
alloc_contig_range but even cma_alloc(ie, upper layer of alloc_contig_range)
doesn't have retry logic. :(
That's why I suggested it in migrate_pages.

Actually, I'd like to go with making migrate_pages's user blind on pcp
draining stuff by squeezing that inside migrate_pages.
IOW, current users of migrate pages don't need to be aware of per-cpu
draining. What they should know is just they should use MIGRATE_SYNC
for best effort but costly opeartion.

For implemenation, we could use retry logic in migrate_pages.

int migrate_pages(xxx)
{
        for (pass = 0; pass < 10 && retry; pass++)
                if (retry && pass > 2 && mode == MIGRATE_SYNC)
                        flush_all_of_percpu_stuff();
}

migrate_page has migrate_mode and retry logic with 'pass', even
reason if we want ot filter out MR_CMA|MEMORY_HOTPLUG|MR_MEMORY_FAILURE.
so that we could handle all of things inside migrate_pages.

Normally, MIGRATE_SYNC would be expensive operation and mostly
it is used for CMA, memory-hotplug, memory-poisoning so THP and
automatic NUMA cannot affect so I believe adding IPI to that is not
a big problem in such trouble condition(ie, retry && pass > 2).

> 
> -- 
> Mel Gorman
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
