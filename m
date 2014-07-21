Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id B2AB76B0038
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 09:01:51 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id q58so7560586wes.18
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 06:01:50 -0700 (PDT)
Received: from gir.skynet.ie (gir.skynet.ie. [193.1.99.77])
        by mx.google.com with ESMTPS id m5si20451241wiz.9.2014.07.21.06.01.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 06:01:49 -0700 (PDT)
Date: Mon, 21 Jul 2014 14:01:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] CMA/HOTPLUG: clear buffer-head lru before page migration
Message-ID: <20140721130146.GO10544@csn.ul.ie>
References: <53C8C290.90503@lge.com>
 <20140721025047.GA7707@bbox>
 <53CCB02A.7070301@lge.com>
 <20140721073651.GA15912@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140721073651.GA15912@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Gioh Kim <gioh.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, '?????????' <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ????????? <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>, linux-fsdevel@vger.kernel.org

On Mon, Jul 21, 2014 at 04:36:51PM +0900, Minchan Kim wrote:

I'm not reviewing this in detail at all, didn't even look at the patch
but two things popped out at me during the discussion.

> > >Anyway, why cannot CMA have the cost without affecting other subsystem?
> > >I mean it's okay for CMA to consume more time to shoot out the bh
> > >instead of simple all bh_lru invalidation because big order allocation is
> > >kinds of slow thing in the VM and everybody already know that and even
> > >sometime get failed so it's okay to add more code that extremly slow path.
> > 
> > There are 2 reasons to invalidate entire bh_lru.
> > 
> > 1. I think CMA allocation is very rare so that invalidaing bh_lru affects the system little.
> > How do you think about it? My platform does not call CMA allocation often.
> > Is the CMA allocation or Memory-Hotplug called often?
> 
> It depends on usecase and you couldn't assume anyting because we couldn't
> ask every people in the world. "Please ask to us whenever you try to use CMA".
> 
> The key point is how the patch is maintainable.
> If it's too complicate to maintain, maybe we could go with simple solution
> but if it's not too complicate, we can go with more smart thing to consider
> other cases in future. Why not?
> 
> Another point is that how user can detect where the regression is from.
> If we cannot notice the regression, it's not a good idea to go with simple
> version.
> 

The buffer LRU avoids a lookup of a radix tree. If the LRU hit rate is
low then the performance penalty of repeated radix tree lookups is
severe but the cost of missing one hot lookup because CMA invalidate it
is not.

The real cost to be concerned with is the cost of performing the
invalidation not the fact a lookup in the LRU was missed. It's because
the cost of invalidation is high that this is being pushed to CMA because
for CMA an allocation failure can be a functional failure and not just a
performance problem.

> > 
> > 2. Adding code in drop_buffers() can affect the system more that adding code in alloc_contig_range()
> > because the drop_buffers does not have a way to distinguish migrate type.
> > Even-though the lmbech results that it has almost the same performance.
> > But I am afraid that it can be changed.
> > As you said if bh_lru size can be changed it affects more than now.
> > SO I do not want to touch non-CMA related code.
> 
> I'm not saying to add hook in drop_buffers.
> What I suggest is to handle failure by bh_lrus in migrate_pages
> because it's not a problem only in CMA.

No, please do not insert a global IPI to invalidate buffer heads in the
general migration case. It's too expensive for either THP allocations or
automatic NUMA migrates. The global IPI cost is justified for rare events
where it causes functional problems if it fails to migreate -- CMA, memory
hot-remove, memory poisoning etc.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
