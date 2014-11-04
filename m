Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C4E476B00DD
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 02:52:20 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so13994223pab.32
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 23:52:20 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ap8si17387390pad.85.2014.11.03.23.52.17
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 23:52:19 -0800 (PST)
Date: Tue, 4 Nov 2014 16:53:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] (CMA_AGGRESSIVE) Make CMA memory be more aggressive
 about allocation
Message-ID: <20141104075330.GB23102@bbox>
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
 <543F8812.2020002@codeaurora.org>
 <5450FD15.4000708@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5450FD15.4000708@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, rjw@rjwysocki.net, len.brown@intel.com, pavel@ucw.cz, m.szyprowski@samsung.com, akpm@linux-foundation.org, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, nasa4836@gmail.com, ddstreet@ieee.org, hughd@google.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, keescook@chromium.org, atomlin@redhat.com, raistlin@linux.it, axboe@fb.com, paulmck@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, k.khlebnikov@samsung.com, msalter@redhat.com, deller@gmx.de, tangchen@cn.fujitsu.com, ben@decadent.org.uk, akinobu.mita@gmail.com, sasha.levin@oracle.com, vdavydov@parallels.com, suleiman@google.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

Hello,

On Wed, Oct 29, 2014 at 03:43:33PM +0100, Vlastimil Babka wrote:
> On 10/16/2014 10:55 AM, Laura Abbott wrote:
> >On 10/15/2014 8:35 PM, Hui Zhu wrote:
> >
> >It's good to see another proposal to fix CMA utilization. Do you have
> >any data about the success rate of CMA contiguous allocation after
> >this patch series? I played around with a similar approach of using
> >CMA for MIGRATE_MOVABLE allocations and found that although utilization
> >did increase, contiguous allocations failed at a higher rate and were
> >much slower. I see what this series is trying to do with avoiding
> >allocation from CMA pages when a contiguous allocation is progress.
> >My concern is that there would still be problems with contiguous
> >allocation after all the MIGRATE_MOVABLE fallback has happened.
> 
> Hi,
> 
> did anyone try/suggest the following idea?
> 
> - keep CMA as fallback to MOVABLE as is is now, i.e. non-agressive
> - when UNMOVABLE (RECLAIMABLE also?) allocation fails and CMA
> pageblocks have space, don't OOM immediately, but first try to
> migrate some MOVABLE pages to CMA pageblocks, to make space for the
> UNMOVABLE allocation in non-CMA pageblocks
> - this should keep CMA pageblocks free as long as possible and
> useful for CMA allocations, but without restricting the non-MOVABLE
> allocations even though there is free memory (but in CMA pageblocks)
> - the fact that a MOVABLE page could be successfully migrated to CMA
> pageblock, means it was not pinned or otherwise non-migratable, so
> there's a good chance it can be migrated back again if CMA
> pageblocks need to be used by CMA allocation

I suggested exactly same idea long time ago.

> - it's more complex, but I guess we have most of the necessary
> infrastructure in compaction already :)

I agree but still, it doesn't solve reclaim problem(ie, VM doesn't
need to reclaim CMA pages when memory pressure of unmovable pages
happens). Of course, we could make VM be aware of that via introducing
new flag of __isolate_lru_page.

However, I'd like to think CMA design from the beginning.
It made page allocation logic complicated, even very fragile as we
had recently and now we need to add new logics to migrate like you said.
As well, we need to fix reclaim path, too.

It makes mm complicated day by day even though it doesn't do the role
enough well(ie, big latency and frequent allocation failure) so I really
want to stop making the mess bloated.

Long time ago, when I saw Joonsoo's CMA agressive allocation patchset
(ie, roundrobin allocation between CMA and normal movable pages)
it was good to me at a first glance but it needs tweak of allocation
path and doesn't solve reclaim path, either. Yes, reclaim path could
be solved by another patch but I want to solve it altogether.

At that time, I suggested big surgery to Joonsoo in offline that
let's move CMA allocation with movable zone allocation. With it,
we could make allocation/reclaim path simple but thing is we should
make VM be aware of overlapping MOVABLE zone which means some of pages
in the zone could be part of another zones but I think we already have
logics to handle it when I read comment in isolate_freepages so I think
the design should work.

A thing you guys might worry is bigger CMA latency because it makes
CMA memory usage ratio higher than the approach you mentioned but
anyone couldn't guarantee it once memory is fully utilized.
In addition, we have used fair zone allocator policy so it makes
round robin allocation automatically so I believe it should be way
to go.

> 
> Thoughts?
> Vlastimil
> 
> >Thanks,
> >Laura
> >
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
