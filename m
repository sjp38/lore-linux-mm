Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id EFC896B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 04:27:30 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id u57so2310652wes.1
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:27:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j47si2663415eeo.116.2014.01.09.01.27.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 01:27:30 -0800 (PST)
Date: Thu, 9 Jan 2014 09:27:20 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/7] improve robustness on handling migratetype
Message-ID: <20140109092720.GM27046@suse.de>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Thu, Jan 09, 2014 at 04:04:40PM +0900, Joonsoo Kim wrote:
> Hello,
> 
> I found some weaknesses on handling migratetype during code review and
> testing CMA.
> 
> First, we don't have any synchronization method on get/set pageblock
> migratetype. When we change migratetype, we hold the zone lock. So
> writer-writer race doesn't exist. But while someone changes migratetype,
> others can get migratetype. This may introduce totally unintended value
> as migratetype. Although I haven't heard of any problem report about
> that, it is better to protect properly.
> 

This is deliberate. The migratetypes for the majority of users are advisory
and aimed for fragmentation avoidance. It was important that the cost of
that be kept as low as possible and the general case is that migration types
change very rarely. In many cases, the zone lock is held. In other cases,
such as splitting free pages, the cost is simply not justified.

I doubt there is any amount of data you could add in support that would
justify hammering the free fast paths (which call get_pageblock_type).

> Second, (get/set)_freepage_migrate isn't used properly. I guess that it
> would be introduced for per cpu page(pcp) performance, but, it is also
> used by memory isolation, now. For that case, the information isn't
> enough to use, so we need to fix it.
> 
> Third, there is the problem on buddy allocator. It doesn't consider
> migratetype when merging buddy, so pages from cma or isolate region can
> be moved to other migratetype freelist. It makes CMA failed over and over.
> To prevent it, the buddy allocator should consider migratetype if
> CMA/ISOLATE is enabled.

Without loioing at the patches, this is likely to add some cost to the
page free fast path -- heavy cost if it's a pageblock lookup and lighter
cost if you are using cached page information which is potentially stale.
Why not force CMA regions to be aligned on MAX_ORDER_NR_PAGES boundary
instead to avoid any possibility of merging issues?

> This patchset is aimed at fixing these problems and based on v3.13-rc7.
> 
>   mm/page_alloc: synchronize get/set pageblock

cost with no justification.

>   mm/cma: fix cma free page accounting

sounds like it would be a fix but unrelated to the leader and should be
seperated out on its own

>   mm/page_alloc: move set_freepage_migratetype() to better place

Very vague. If this does something useful then it could do with a better
subject.

>   mm/isolation: remove invalid check condition

Looks harmless.

>   mm/page_alloc: separate interface to set/get migratetype of freepage
>   mm/page_alloc: store freelist migratetype to the page on buddy
>     properly

Potentially sounds useful

>   mm/page_alloc: don't merge MIGRATE_(CMA|ISOLATE) pages on buddy
> 

Sounds unnecessary if CMA regions were MAX_ORDER_NR_PAGES aligned and
then the free paths would be unaffected for everybody.

I didn't look at the patches because it felt like cost without any supporting
justification for the patches. Superficially it looks like patch 1 needs to
go away and the last patch could be done without affected !CMA users. The
rest are potentially useful but there should have been some supporting
data on how it helps CMA with some backup showing that the page allocation
paths are not impacted as a result.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
