Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF256B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 04:19:49 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so4820121pde.32
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 01:19:49 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ly10si2858844pab.211.2014.08.07.01.19.46
        for <linux-mm@kvack.org>;
        Thu, 07 Aug 2014 01:19:48 -0700 (PDT)
Date: Thu, 7 Aug 2014 17:19:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 5/8] mm/isolation: change pageblock isolation logic to
 fix freepage counting bugs
Message-ID: <20140807081945.GA2427@js1304-P5Q-DELUXE>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1407309517-3270-9-git-send-email-iamjoonsoo.kim@lge.com>
 <53E245D4.9080506@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53E245D4.9080506@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 06, 2014 at 05:12:20PM +0200, Vlastimil Babka wrote:
> On 08/06/2014 09:18 AM, Joonsoo Kim wrote:
> >Overall design of changed pageblock isolation logic is as following.
> 
> I'll reply here since the overall design part is described in this
> patch (would be worth to have it in cover letter as well IMHO).
> 
> >1. ISOLATION
> >- check pageblock is suitable for pageblock isolation.
> >- change migratetype of pageblock to MIGRATE_ISOLATE.
> >- disable pcp list.
> 
> Is it needed to disable the pcp list? Shouldn't drain be enough?
> After the drain you already are sure that future freeing will see
> MIGRATE_ISOLATE and skip pcp list anyway, so why disable it
> completely?

Yes, it is needed. Until we move freepages from normal buddy list
to isolate buddy list, freepages could be allocated by others. In this
case, they could be moved to pcp list. When it is flushed from pcp list
to buddy list, we need to check whether it is on isolate migratetype
pageblock or not. But, we don't want that hook in free_pcppages_bulk()
because it is page allocator's normal freepath. To remove it, we shoule
disable the pcp list here.

> 
> >- drain pcp list.
> >- pcp couldn't have any freepage at this point.
> >- synchronize all cpus to see correct migratetype.
> 
> This synchronization should already happen through the drain, no?

Yes, this line should be removed. Now synchronization is complete
through the drain. It is leftover from not submitted implementation attempt.

> >- freed pages on this pageblock will be handled specially and
> >not added to buddy list from here. With this way, there is no
> >possibility of merging pages on different buddy list.
> >- move freepages on normal buddy list to isolate buddy list.
> 
> Is there any advantage of moving the pages to isolate buddy list at
> this point, when we already have the new PageIsolated marking? Maybe
> not right now, but could this be later replaced by just splitting
> and marking PageIsolated the pages from normal buddy list? I guess
> memory hot-remove does not benefit from having buddy-merged pages
> and CMA probably also doesn't?

At least, we need to detach freepages on this pageblock from buddy
list to prevent futher allocation of these pages. In this case, moving
looks more simple approach to me.

> >There is no page on isolate buddy list so move_freepages_block()
> >returns number of moved freepages correctly.
> >- enable pcp list.
> >
> >2. TEST-ISOLATION
> >- activates freepages marked as PageIsolated() and add to isolate
> >buddy list.
> >- test if pageblock is properly isolated.
> >
> >3. UNDO-ISOLATION
> >- move freepages from isolate buddy list to normal buddy list.
> >There is no page on normal buddy list so move_freepages_block()
> >return number of moved freepages correctly.
> >- change migratetype of pageblock to normal migratetype
> >- synchronize all cpus.
> >- activate isolated freepages and add to normal buddy list.
> 
> The lack of pcp list deactivation in the undo part IMHO suggests
> that it is indeed not needed.

It is different situation. When UNDO, pages would be on isolate buddy
list so moving from buddy list to pcp list couldn't be possible and
then pcp list deactivation isn't needed.

> >With this patch, most of freepage counting bugs are solved and
> >exceptional handling for freepage count is done in pageblock isolation
> >logic rather than allocator.
> 
> \o/

:)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
