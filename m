Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8346B0039
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 04:37:42 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so855611pde.37
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 01:37:41 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id a16si1086367pdj.274.2014.07.16.01.37.40
        for <linux-mm@kvack.org>;
        Wed, 16 Jul 2014 01:37:41 -0700 (PDT)
Date: Wed, 16 Jul 2014 17:43:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 00/10] fix freepage count problems due to memory isolation
Message-ID: <20140716084333.GA20359@js1304-P5Q-DELUXE>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
 <53B6C947.1070603@suse.cz>
 <20140707044932.GA29236@js1304-P5Q-DELUXE>
 <53BAAFA5.9070403@suse.cz>
 <20140714062222.GA11317@js1304-P5Q-DELUXE>
 <53C3A7A5.9060005@suse.cz>
 <20140715082828.GM11317@js1304-P5Q-DELUXE>
 <53C4E813.7020108@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53C4E813.7020108@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, Lisa Du <cldu@marvell.com>, linux-kernel@vger.kernel.org

On Tue, Jul 15, 2014 at 10:36:35AM +0200, Vlastimil Babka wrote:
> >>A non-trivial fix that comes to mind (and I might have overlooked
> >>something) is something like:
> >>
> >>- distinguish MIGRATETYPE_ISOLATING and MIGRATETYPE_ISOLATED
> >>- CPU1 first sets MIGRATETYPE_ISOLATING before the drain
> >>- when CPU2 sees MIGRATETYPE_ISOLATING, it just puts the page on
> >>special unbounded pcplist and that's it
> >>- CPU1 does the drain as usual, potentially misplacing some pages
> >>that move_freepages_block() will then fix. But no wrong merging can
> >>occur.
> >>- after move_freepages_block(), CPU1 changes MIGRATETYPE_ISOLATING
> >>to MIGRATETYPE_ISOLATED
> >>- CPU2 can then start freeing directly on isolate buddy list. There
> >>might be some pages still on the special pcplist of CPU2/CPUx but
> >>that means they won't merge yet.
> >>- CPU1 executes on all CPU's a new operation that flushes the
> >>special pcplist on isolate buddy list and merge as needed.
> >>
> >
> >Really thanks for sharing idea.
> 
> Ah, you didn't find a hole yet, good sign :D
> 
> >It looks possible but I guess that it needs more branches related to
> >pageblock isolation. Now I have a quick thought to prevent merging,
> >but, I'm not sure that it is better than current patchset. After more
> >thinking, I will post rough idea here.
> 
> I was thinking about it more and maybe it wouldn't need a new
> migratetype after all. But it would always need to free isolate
> pages on the special pcplist. That means this pcplist would be used
> not only during the call to start_isolate_page_range, but all the
> way until undo_isolate_page_range(). I don't think it's a problem
> and it simplifies things. The only way to move to isolate freelist
> is through the new isolate pcplist flush operation initiated by a
> single CPU at well defined time.
> 
> The undo would look like:
> - (migratetype is still set to MIGRATETYPE_ISOLATE, CPU2 frees
> affected pages to the special freelist)
> - CPU1 does move_freepages_block() to put pages back from isolate
> freelist to e.g. MOVABLE or CMA. At this point, nobody will put new
> pages on isolate freelist.
> - CPU1 changes migratetype of the pageblock to e.g. MOVABLE. CPU2
> and others start freeing normally. Merging can occur only on the
> MOVABLE freelist, as isolate freelist is empty and nobody puts pages
> there.
> - CPU1 flushes the isolate pcplists of all CPU's on the MOVABLE
> freelist. Merging is again correct.
> 
> I think your plan of multiple parallel CMA allocations (and thus
> multiple parallel isolations) is also possible. The isolate pcplists
> can be shared by pages coming from multiple parallel isolations. But
> the flush operation needs a pfn start/end parameters to only flush
> pages belonging to the given isolation. That might mean a bit of
> inefficient list traversing, but I don't think it's a problem.

I think that special pcplist would cause a problem if we should check
pfn range. If there are too many pages on this pcplist, move pages from
this pcplist to isolate freelist takes too long time in irq context and
system could be broken. This operation cannot be easily stopped because
it is initiated by IPI on other cpu and starter of this IPI expect that
all pages on other cpus' pcplist are moved properly when returning
from on_each_cpu().

And, if there are so many pages, serious lock contention would happen
in this case.

Anyway, my idea's key point is using PageIsolated() to distinguish
isolated page, instead of using PageBuddy(). If page is PageIsolated(),
it isn't handled as freepage although it is in buddy allocator. During free,
page with MIGRATETYPE_ISOLATE will be marked as PageIsolated() and
won't be merged and counted for freepage.

When we move pages from normal buddy list to isolate buddy
list, we check PageBuddy() and subtract number of PageBuddy() pages
from number of freepage. And, change page from PageBuddy() to PageIsolated()
since it is handled as isolated page at this point. In this way, freepage
count will be correct.

Unisolation can be done by similar approach.

I made prototype of this approach and it isn't intrusive to core
allocator compared to my previous patchset.

Make sense?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
