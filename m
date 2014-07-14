Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A6B456B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 02:16:44 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1808448pdb.41
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 23:16:44 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qi10si8372783pbc.198.2014.07.13.23.16.41
        for <linux-mm@kvack.org>;
        Sun, 13 Jul 2014 23:16:43 -0700 (PDT)
Date: Mon, 14 Jul 2014 15:22:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 00/10] fix freepage count problems due to memory isolation
Message-ID: <20140714062222.GA11317@js1304-P5Q-DELUXE>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
 <53B6C947.1070603@suse.cz>
 <20140707044932.GA29236@js1304-P5Q-DELUXE>
 <53BAAFA5.9070403@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BAAFA5.9070403@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, Lisa Du <cldu@marvell.com>, linux-kernel@vger.kernel.org

On Mon, Jul 07, 2014 at 04:33:09PM +0200, Vlastimil Babka wrote:
> On 07/07/2014 06:49 AM, Joonsoo Kim wrote:
> >Ccing Lisa, because there was bug report it may be related this
> >topic last Saturday.
> >
> >http://www.spinics.net/lists/linux-mm/msg75741.html
> >
> >On Fri, Jul 04, 2014 at 05:33:27PM +0200, Vlastimil Babka wrote:
> >>On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
> >>>Hello,
> >>
> >>Hi Joonsoo,
> >>
> >>please CC me on further updates, this is relevant to me.
> >
> >Hello, Vlastimil.
> >
> >Sorry for missing you. :)
> >
> >>
> >>>This patchset aims at fixing problems due to memory isolation found by
> >>>testing my patchset [1].
> >>>
> >>>These are really subtle problems so I can be wrong. If you find what I am
> >>>missing, please let me know.
> >>>
> >>>Before describing bugs itself, I first explain definition of freepage.
> >>>
> >>>1. pages on buddy list are counted as freepage.
> >>>2. pages on isolate migratetype buddy list are *not* counted as freepage.
> >>
> >>I think the second point is causing us a lot of trouble. And I wonder if it's really
> >>justified! We already have some is_migrate_isolate() checks in the fast path and now you
> >>would add more, mostly just to keep this accounting correct.
> >
> >It's not just for keeping accouting correct. There is another
> >purpose for is_migrate_isolate(). It forces freed pages to go into
> >isolate buddy list. Without it, freed pages would go into other
> >buddy list and will be used soon. So memory isolation can't work well
> >without is_migrate_isolate() checks and success rate could decrease.
> 
> Well I think that could be solved also by doing a lru/pcplists drain
> right after marking pageblock as MIGRATETYPE_ISOLATE. After that
> moment, anything newly put on pcplists should observe the new
> migratetype and go to the correct pcplists. As putting stuff on
> pcplists is done with disabled interrupts, and draining is done by
> IPI, I think it should work correctly if we put the migratetype
> determination under the disabled irq part in free_hot_cold_page().

Hello, sorry for late.

Yes, this can close the race on migratetype buddy list, but, there is
a problem. See the below.

> 
> >And, I just added three more is_migrate_isolate() in the fast
> >path, but, two checks are in same *unlikely* branch and I can remove
> >another one easily. Therefore it's not quite problem I guess. (It even
> >does no-op if MEMORY_ISOLATION is disabled.)
> >Moreover, I removed one unconditional get_pageblock_migratetype() in
> >free_pcppages_bulk() so, in performance point or view, freepath would
> >be improved.
> 
> I haven't checked the individual patches yet, but I'll try.
> 
> >>
> >>So the question is, does it have to be correct? And (admiteddly not after a completely
> >>exhaustive analysis) I think the answer is, surprisingly, that it doesn't :)
> >>
> >>Well I of course don't mean that the freepage accounts could go random completely, but
> >>what if we allowed them to drift a bit, limiting both the max error and the timeframe
> >>where errors are possible? After all, watermarks checking is already racy so I don't think
> >>it would be hurt that much.
> >
> >I understand your suggestion. I once thought like as you, but give up
> >that idea. Watermark checking is already racy, but, it's *only*
> >protection to prevent memory allocation. After passing that check,
> >there is no mean to prevent us from allocating memory. So it should
> >be accurate as much as possible. If we allow someone to get the
> >memory without considering memory isolation, free memory could be in
> >really low state and system could be broken occasionally.
> 
> It would definitely require more thorough review, but I think with
> the pcplists draining changes outlined above, there shouldn't be any
> more inaccuracy happening.
> 
> >>
> >>Now if we look at what both CMA and memory hot-remove does is:
> >>
> >>1. Mark a MAX_ORDER-aligned buch of pageblocks as MIGRATE_ISOLATE through
> >>start_isolate_page_range(). As part of this, all free pages in that area are
> >>moved on the isolate freelist through move_freepages_block().
> >>
> >>2. Try to migrate away all non-free pages in the range. Also drain pcplists and lru_add
> >>caches.
> >>
> >>3. Check if everything was successfully isolated by test_pages_isolated(). Restart and/or
> >>undo pageblock isolation if not.
> >>
> >>So my idea is to throw away all special-casing of is_migrate_isolate() in the buddy
> >>allocator, which would therefore account free pages on the isolate freelist as normal free
> >>pages.
> >>The accounting of isolated pages would be instead done only on the top level of CMA/hot
> >>remove in the three steps outlined above, which would be modified as follows:
> >>
> >>1. Calculate N as the target number of pages to be isolated. Perform the actions of step 1
> >>as usual. Calculate X as the number of pages that move_freepages_block() has moved.
> >>Subtract X from freepages (this is the same as it is done now), but also *remember the
> >>value of X*
> >>
> >>2. Migrate and drain pcplists as usual. The new free pages will either end up correctly on
> >>isolate freelist, or not. We don't care, they will be accounted as freepages either way.
> >>This is where some inaccuracy in accounted freepages would build up.
> >>
> >>3. If test_pages_isolated() checks pass, subtract (N - X) from freepages. The result is
> >>that we have a isolated range of N pages that nobody can steal now as everything is on
> >>isolate freelist and is MAX_ORDER aligned. And we have in total subtracted N pages (first
> >>X, then N-X). So the accounting matches reality.
> >>
> >>If we have to undo, we undo the isolation and as part of this, we use
> >>move_freepages_block() to move pages from isolate freelist to the normal ones. But we
> >>don't care how many pages were moved. We simply add the remembered value of X to the
> >>number of freepages, undoing the change from step 1. Again, the accounting matches reality.
> >>
> >>
> >>The final point is that if we do this per MAX_ORDER blocks, the error in accounting cannot
> >>be ever larger than 4MB and will be visible only during time a single MAX_ORDER block is
> >>handled.
> >
> >The 4MB error in accounting looks serious for me. min_free_kbytes is
> >4MB in 1GB system. So this 4MB error would makes all things broken in
> >such systems. Moreover, there are some ARCH having larger
> >pageblock_order than MAX_ORDER. In this case, the error will be larger
> >than 4MB.
> >
> >In addition, I have a plan to extend CMA to work in parallel. It means
> >that there could be parallel memory isolation users rather than just
> >one user at the same time, so, we cannot easily bound the error under
> >some degree.
> 
> OK. I had thought that the error would be much smaller in practice,
> but probably due to how buddy merging works, it would be enough if
> just the very last freed page in the MAX_ORDER block was misplaced,
> and that would trigger a cascading merge that will end with single
> page at MAX_ORDER size becoming misplaced. So let's probably forget
> this approach.
> 
> >>As a possible improvement, we can assume during phase 2 that every page freed by migration
> >>will end up correctly on isolate free list. So we create M free pages by migration, and
> >>subtract M from freepage account. Then in phase 3 we either subtract (N - X - M), or add X
> >>+ M in the undo case. (Ideally, if we succeed, X + M should be equal to N, but due to
> >>pages on pcplists and the possible races it will be less). I think with this improvement,
> >>any error would be negligible.
> >>
> >>Thoughts?
> >
> >Thanks for suggestion. :)
> >It is really good topic to think deeply.
> >
> >For now, I'd like to fix these problems without side-effect as you
> >suggested. Your suggestion changes the meaning of freepage that
> >isolated pages are included in nr_freepage and there could be possible
> >regression in success rate of memory hotplug and CMA. Possibly, it
> >is the way we have to go, but, IMHO, it isn't the time to go. Before
> >going that way, we should fix current implementation first so that
> >fixes can be backported to old kernel if someone needs.
> 
> Adding the extra pcplist drains and reordering
> get_pageblock_migratetype() under disabled IRQ's should be small
> enough to be backportable and not bring any regressions to success
> rates. There will be some cost for the extra drains, but paid only
> when the memory isolation actually happens. Extending the scope of
> disabled irq's would affect fast path somewhat, but I guess less
> than extra checks?

Your approach would close the race on migratetype buddy list. But,
I'm not sure how we can count number of freepages correctly. IIUC,
unlike my approach, this approach allows merging between isolate buddy
list and normal buddy list and it would results in miscounting number of
freepages. You probably think that move_freepages_block() could fixup
all the situation, but, I don't think so.

After applying your approach,

CPU1                                    CPU2
set_migratetype_isolate()               - free_one_page()
  - lock
  - set_pageblock_migratetype()
  - unlock
  - drain...
                                        - lock
                                        - __free_one_page() with MIGRATE_ISOLATE
                                        - merged with normal page and linked with 
                                        isolate buddy list
                                        - skip to count freepage, because of
                                        MIGRATE_ISOLATE
                                        - unlock
  - lock
  - move_freepages_block()    
    try to fixup freepages count
  - unlock

We want to fixup counting in move_freepages_block(), but, we can't
because we don't have enough information whether this page is already
accounted on number of freepage or not. Could you help me to find out
the whole mechanism of your approach?

And, IIUC, your approach can remove only one get_pageblock_migratetype()
in free_pcppages_bulk(). free_hot_cold_page() and free_one_page()
should have is_migrate_isolate() branches to free the page to correct
list and count number of freepage correctly. Additionally, it extends
scope of disabled irq. So it doesn't look much better than mine,
because my approach also removes get_pageblock_migratetype() in
free_pcppages_bulk(). 

Please let me know what I am missing. :)

Thanks.

> 
> >Interestingly,
> >on last Saturday, Lisa Du reported CMA accounting bugs.
> >
> >http://www.spinics.net/lists/linux-mm/msg75741.html
> >
> >I don't look at it in detail, but, maybe it is related to these
> >problems and we should fix it without side-effect.
> >
> >So, in conclusion, I think that your suggestion is beyond the scope of
> >this patchset because of following two reasons.
> >
> >1. I'd like to fix these problems without side-effect(possible
> >regression in success rate of memory hotplug and CMA, and nr_freepage
> >meanging change) due to backport possibility.
> >2. nr_freepage without considering memory isolation is somewhat dangerous
> >and not suitable for some systems.
> >
> >If you have any objection, please let me know. But, I will go on
> >a vacation for a week so I can't answer your further comments
> >for a week. I will reply them next week. :)
> >
> >Thanks.
> >
> >>>3. pages on cma buddy list are counted as CMA freepage, too.
> >>>4. pages for guard are *not* counted as freepage.
> >>>
> >>>Now, I describe problems and related patch.
> >>>
> >>>1. Patch 2: If guard page are cleared and merged into isolate buddy list,
> >>>we should not add freepage count.
> >>>
> >>>2. Patch 3: When the page return back from pcp to buddy, we should
> >>>account it to freepage counter. In this case, we should check the
> >>>pageblock migratetype of the page and should insert the page into
> >>>appropriate buddy list. Although we checked it in current code, we
> >>>didn't insert the page into appropriate buddy list so that freepage
> >>>counting can be wrong.
> >>>
> >>>3. Patch 4: There is race condition so that some freepages could be
> >>>on isolate buddy list. If so, we can't use this page until next isolation
> >>>attempt on this pageblock.
> >>>
> >>>4. Patch 5: There is race condition that page on isolate pageblock
> >>>can go into non-isolate buddy list. If so, buddy allocator would
> >>>merge pages on non-isolate buddy list and isolate buddy list, respectively,
> >>>and freepage count will be wrong.
> >>>
> >>>5. Patch 9: move_freepages(_block) returns *not* number of moved pages.
> >>>Instead, it returns number of pages linked in that migratetype buddy list.
> >>>So accouting with this return value makes freepage count wrong.
> >>>
> >>>6. Patch 10: buddy allocator would merge pages on non-isolate buddy list
> >>>and isolate buddy list, respectively. This leads to freepage counting
> >>>problem so fix it by stopping merging in this case.
> >>>
> >>>Without patchset [1], above problem doesn't happens on my CMA allocation
> >>>test, because CMA reserved pages aren't used at all. So there is no
> >>>chance for above race.
> >>>
> >>>With patchset [1], I did simple CMA allocation test and get below result.
> >>>
> >>>- Virtual machine, 4 cpus, 1024 MB memory, 256 MB CMA reservation
> >>>- run kernel build (make -j16) on background
> >>>- 30 times CMA allocation(8MB * 30 = 240MB) attempts in 5 sec interval
> >>>- Result: more than 5000 freepage count are missed
> >>>
> >>>With patchset [1] and this patchset, I found that no freepage count are
> >>>missed so that I conclude that problems are solved.
> >>>
> >>>These problems can be possible on memory hot remove users, although
> >>>I didn't check it further.
> >>>
> >>>Other patches are either for the base to fix these problems or for
> >>>simple clean-up. Please see individual patches for more information.
> >>>
> >>>This patchset is based on linux-next-20140703.
> >>>
> >>>Thanks.
> >>>
> >>>[1]: Aggressively allocate the pages on cma reserved memory
> >>>      https://lkml.org/lkml/2014/5/30/291
> >>>
> >>>
> >>>Joonsoo Kim (10):
> >>>   mm/page_alloc: remove unlikely macro on free_one_page()
> >>>   mm/page_alloc: correct to clear guard attribute in DEBUG_PAGEALLOC
> >>>   mm/page_alloc: handle page on pcp correctly if it's pageblock is
> >>>     isolated
> >>>   mm/page_alloc: carefully free the page on isolate pageblock
> >>>   mm/page_alloc: optimize and unify pageblock migratetype check in free
> >>>     path
> >>>   mm/page_alloc: separate freepage migratetype interface
> >>>   mm/page_alloc: store migratetype of the buddy list into freepage
> >>>     correctly
> >>>   mm/page_alloc: use get_onbuddy_migratetype() to get buddy list type
> >>>   mm/page_alloc: fix possible wrongly calculated freepage counter
> >>>   mm/page_alloc: Stop merging pages on non-isolate and isolate buddy
> >>>     list
> >>>
> >>>  include/linux/mm.h             |   30 +++++++--
> >>>  include/linux/mmzone.h         |    5 ++
> >>>  include/linux/page-isolation.h |    8 +++
> >>>  mm/page_alloc.c                |  138 +++++++++++++++++++++++++++++-----------
> >>>  mm/page_isolation.c            |   18 ++----
> >>>  5 files changed, 147 insertions(+), 52 deletions(-)
> >>>
> >>
> >>--
> >>To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >>the body to majordomo@kvack.org.  For more info on Linux MM,
> >>see: http://www.linux-mm.org/ .
> >>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
