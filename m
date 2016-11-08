Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 665566B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 06:10:04 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so58772653wms.7
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 03:10:04 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id h8si34914918wjx.21.2016.11.08.03.10.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 03:10:03 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id A6FB598F1A
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 11:10:02 +0000 (UTC)
Date: Tue, 8 Nov 2016 11:03:51 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC][PATCH] mm: merge as soon as possible when pcp alloc/free
Message-ID: <20161108110351.GA3614@techsingularity.net>
References: <581D9103.1000202@huawei.com>
 <20161107154532.e3573bc08324e24aad6d1e26@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161107154532.e3573bc08324e24aad6d1e26@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 07, 2016 at 03:45:32PM -0800, Andrew Morton wrote:
> On Sat, 5 Nov 2016 15:57:55 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
> > Usually the memory of android phones is very small, so after a long
> > running, the fragment is very large. Kernel stack which called by
> > alloc_thread_stack_node() usually alloc 16K memory, and it failed
> > frequently.
> > 
> > However we have CONFIG_VMAP_STACK now, but it do not support arm64,
> > and maybe it has some regression because of vmalloc, it need to
> > find an area and create page table dynamically, this will take a short
> > time.
> > 
> > I think we can merge as soon as possible when pcp alloc/free to reduce
> > fragment. The pcp page is hot page, so free it will cause cache miss,
> > I use perf to test it, but it seems the regression is not so much, maybe
> > it need to test more. Any reply is welcome.
> 
> per-cpu pages may not be worth the effort on such systems - probably
> benefit is small.  I discussed this with Mel a few years ago and I
> think he did some testing, but I forget the results?
> 

I'm still on holidays so not in the position to review closely but in
general, aggressively merging per-cpu pages is expected to be a bust and
offset heavily by increased contention on zone lock. A batch free early in
the lifetime of the system is going to hit such a heuristic aggressively
even if fragmentation overall is fine.

> Anyway, if per-cpu pages are causing problems then perhaps we should
> have a Kconfig option which simply eliminates them: free these pages
> direct into the buddy.  If the resulting code is clean-looking and the
> performance testing on small systems shows decent results then that
> should address the issues you're seeing.

I know for a fact that deleting the per-cpu allocator works but overall
performance fell down a hole when there were multiple parallel allocation
requests (multiple processes faulting for example). There were prototype
patches that used per-socket locks to minimise costs of cache misses but it
never improved the performance of the page allocator while having similar
properties in terms of fragmentation.

In general, my view is that the latency reduction of the page allocator
went too far since 3.0 which had the strongest protection against
fragmentation. It's now too willing to mix pageblocks together in the
name of latency, mostly done in the name of THP and fragmentation simply
degrades far faster than it used to. Tackling it from the per-cpu
allocator is the wrong direction IMO.

Overall, there is a definite lack of workloads that routinely create
fragmentation in a manner that is reproducible, representative and
measurable. A lot of the patches are vague hand waving and it's not a good
enough basis for merging patches. I know the stress high-alloc workload
exists which was fine in 3.0, but not fine today with larger memory sizes,
the existance of SLUB high-order allocations and a much more aggressive
mix of THP allocations. Ideally that point would be addressed first as a
basis for further work.

After that, one approach would be to review control of pageblocks and be more
willing to protect pageblocks by migrating movable pages out of pageblocks
that MIGRATE_UNMOVABLE and MIGRATE_RECLAIMABLE steals even if it's deferred
to kswapd with the view to avoiding further fragmentation. Back in 3.0, an
unreleased prototype existed for that but the fragmentation protection was so
strong, it had no benefit. I don't have the prototype any more unfortunately.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
