Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id D88ED6B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 03:48:35 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id um1so4194607pbc.20
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 00:48:35 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id yd9si6427500pab.263.2014.01.10.00.48.33
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 00:48:34 -0800 (PST)
Date: Fri, 10 Jan 2014 17:48:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/7] improve robustness on handling migratetype
Message-ID: <20140110084854.GA22058@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140109092720.GM27046@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140109092720.GM27046@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 09, 2014 at 09:27:20AM +0000, Mel Gorman wrote:
> On Thu, Jan 09, 2014 at 04:04:40PM +0900, Joonsoo Kim wrote:
> > Hello,
> > 
> > I found some weaknesses on handling migratetype during code review and
> > testing CMA.
> > 
> > First, we don't have any synchronization method on get/set pageblock
> > migratetype. When we change migratetype, we hold the zone lock. So
> > writer-writer race doesn't exist. But while someone changes migratetype,
> > others can get migratetype. This may introduce totally unintended value
> > as migratetype. Although I haven't heard of any problem report about
> > that, it is better to protect properly.
> > 
> 
> This is deliberate. The migratetypes for the majority of users are advisory
> and aimed for fragmentation avoidance. It was important that the cost of
> that be kept as low as possible and the general case is that migration types
> change very rarely. In many cases, the zone lock is held. In other cases,
> such as splitting free pages, the cost is simply not justified.
> 
> I doubt there is any amount of data you could add in support that would
> justify hammering the free fast paths (which call get_pageblock_type).

Hello, Mel.

There is a possibility that we can get unintended value such as 6 as migratetype
if reader-writer (get/set pageblock_migratetype) race happends. It can be
possible, because we read the value without any synchronization method. And
this migratetype, 6, has no place in buddy freelist, so array index overrun can
be possible and the system can break, although I haven't heard that it occurs.

I think that my solution is too expensive. However, I think that we need
solution. aren't we? Do you have any better idea?

> 
> > Second, (get/set)_freepage_migrate isn't used properly. I guess that it
> > would be introduced for per cpu page(pcp) performance, but, it is also
> > used by memory isolation, now. For that case, the information isn't
> > enough to use, so we need to fix it.
> > 
> > Third, there is the problem on buddy allocator. It doesn't consider
> > migratetype when merging buddy, so pages from cma or isolate region can
> > be moved to other migratetype freelist. It makes CMA failed over and over.
> > To prevent it, the buddy allocator should consider migratetype if
> > CMA/ISOLATE is enabled.
> 
> Without loioing at the patches, this is likely to add some cost to the
> page free fast path -- heavy cost if it's a pageblock lookup and lighter
> cost if you are using cached page information which is potentially stale.
> Why not force CMA regions to be aligned on MAX_ORDER_NR_PAGES boundary
> instead to avoid any possibility of merging issues?
> 

There was my mistake. CMA region is aligned on MAX_ORDER_NR_PAGES, so it
can't happed. Sorry for noise.

> > This patchset is aimed at fixing these problems and based on v3.13-rc7.
> > 
> >   mm/page_alloc: synchronize get/set pageblock
> 
> cost with no justification.
> 
> >   mm/cma: fix cma free page accounting
> 
> sounds like it would be a fix but unrelated to the leader and should be
> seperated out on its own

Yes, it is not related to this topic and it is wrong patch as Laura
pointed out, so I will drop it.

> >   mm/page_alloc: move set_freepage_migratetype() to better place
> 
> Very vague. If this does something useful then it could do with a better
> subject.

Okay.

> >   mm/isolation: remove invalid check condition
> 
> Looks harmless.
> 
> >   mm/page_alloc: separate interface to set/get migratetype of freepage
> >   mm/page_alloc: store freelist migratetype to the page on buddy
> >     properly
> 
> Potentially sounds useful
> 

I made these two patches for last patch to reduce performance effect of it.
In case of dropping last patch, it is better to remove the last callsite
using freelist migratetype to know the buddy freelist type. I will do respin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
