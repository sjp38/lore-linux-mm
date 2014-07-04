Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id A8C466B0031
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 11:33:36 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so1827429wes.21
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 08:33:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u4si39546895wjy.175.2014.07.04.08.33.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Jul 2014 08:33:34 -0700 (PDT)
Message-ID: <53B6C947.1070603@suse.cz>
Date: Fri, 04 Jul 2014 17:33:27 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] fix freepage count problems due to memory isolation
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
> Hello,

Hi Joonsoo,

please CC me on further updates, this is relevant to me.

> This patchset aims at fixing problems due to memory isolation found by
> testing my patchset [1].
> 
> These are really subtle problems so I can be wrong. If you find what I am
> missing, please let me know.
> 
> Before describing bugs itself, I first explain definition of freepage.
> 
> 1. pages on buddy list are counted as freepage.
> 2. pages on isolate migratetype buddy list are *not* counted as freepage.

I think the second point is causing us a lot of trouble. And I wonder if it's really
justified! We already have some is_migrate_isolate() checks in the fast path and now you
would add more, mostly just to keep this accounting correct.

So the question is, does it have to be correct? And (admiteddly not after a completely
exhaustive analysis) I think the answer is, surprisingly, that it doesn't :)

Well I of course don't mean that the freepage accounts could go random completely, but
what if we allowed them to drift a bit, limiting both the max error and the timeframe
where errors are possible? After all, watermarks checking is already racy so I don't think
it would be hurt that much.

Now if we look at what both CMA and memory hot-remove does is:

1. Mark a MAX_ORDER-aligned buch of pageblocks as MIGRATE_ISOLATE through
start_isolate_page_range(). As part of this, all free pages in that area are
moved on the isolate freelist through move_freepages_block().

2. Try to migrate away all non-free pages in the range. Also drain pcplists and lru_add
caches.

3. Check if everything was successfully isolated by test_pages_isolated(). Restart and/or
undo pageblock isolation if not.

So my idea is to throw away all special-casing of is_migrate_isolate() in the buddy
allocator, which would therefore account free pages on the isolate freelist as normal free
pages.
The accounting of isolated pages would be instead done only on the top level of CMA/hot
remove in the three steps outlined above, which would be modified as follows:

1. Calculate N as the target number of pages to be isolated. Perform the actions of step 1
as usual. Calculate X as the number of pages that move_freepages_block() has moved.
Subtract X from freepages (this is the same as it is done now), but also *remember the
value of X*

2. Migrate and drain pcplists as usual. The new free pages will either end up correctly on
isolate freelist, or not. We don't care, they will be accounted as freepages either way.
This is where some inaccuracy in accounted freepages would build up.

3. If test_pages_isolated() checks pass, subtract (N - X) from freepages. The result is
that we have a isolated range of N pages that nobody can steal now as everything is on
isolate freelist and is MAX_ORDER aligned. And we have in total subtracted N pages (first
X, then N-X). So the accounting matches reality.

If we have to undo, we undo the isolation and as part of this, we use
move_freepages_block() to move pages from isolate freelist to the normal ones. But we
don't care how many pages were moved. We simply add the remembered value of X to the
number of freepages, undoing the change from step 1. Again, the accounting matches reality.


The final point is that if we do this per MAX_ORDER blocks, the error in accounting cannot
be ever larger than 4MB and will be visible only during time a single MAX_ORDER block is
handled.

As a possible improvement, we can assume during phase 2 that every page freed by migration
will end up correctly on isolate free list. So we create M free pages by migration, and
subtract M from freepage account. Then in phase 3 we either subtract (N - X - M), or add X
+ M in the undo case. (Ideally, if we succeed, X + M should be equal to N, but due to
pages on pcplists and the possible races it will be less). I think with this improvement,
any error would be negligible.

Thoughts?

> 3. pages on cma buddy list are counted as CMA freepage, too.
> 4. pages for guard are *not* counted as freepage.
> 
> Now, I describe problems and related patch.
> 
> 1. Patch 2: If guard page are cleared and merged into isolate buddy list,
> we should not add freepage count.
> 
> 2. Patch 3: When the page return back from pcp to buddy, we should
> account it to freepage counter. In this case, we should check the
> pageblock migratetype of the page and should insert the page into
> appropriate buddy list. Although we checked it in current code, we
> didn't insert the page into appropriate buddy list so that freepage
> counting can be wrong.
> 
> 3. Patch 4: There is race condition so that some freepages could be
> on isolate buddy list. If so, we can't use this page until next isolation
> attempt on this pageblock.
> 
> 4. Patch 5: There is race condition that page on isolate pageblock
> can go into non-isolate buddy list. If so, buddy allocator would
> merge pages on non-isolate buddy list and isolate buddy list, respectively,
> and freepage count will be wrong.
> 
> 5. Patch 9: move_freepages(_block) returns *not* number of moved pages.
> Instead, it returns number of pages linked in that migratetype buddy list.
> So accouting with this return value makes freepage count wrong.
> 
> 6. Patch 10: buddy allocator would merge pages on non-isolate buddy list
> and isolate buddy list, respectively. This leads to freepage counting
> problem so fix it by stopping merging in this case.
> 
> Without patchset [1], above problem doesn't happens on my CMA allocation
> test, because CMA reserved pages aren't used at all. So there is no
> chance for above race.
> 
> With patchset [1], I did simple CMA allocation test and get below result.
> 
> - Virtual machine, 4 cpus, 1024 MB memory, 256 MB CMA reservation
> - run kernel build (make -j16) on background
> - 30 times CMA allocation(8MB * 30 = 240MB) attempts in 5 sec interval
> - Result: more than 5000 freepage count are missed
> 
> With patchset [1] and this patchset, I found that no freepage count are
> missed so that I conclude that problems are solved.
> 
> These problems can be possible on memory hot remove users, although
> I didn't check it further.
> 
> Other patches are either for the base to fix these problems or for
> simple clean-up. Please see individual patches for more information.
> 
> This patchset is based on linux-next-20140703.
> 
> Thanks.
> 
> [1]: Aggressively allocate the pages on cma reserved memory
>      https://lkml.org/lkml/2014/5/30/291
> 
> 
> Joonsoo Kim (10):
>   mm/page_alloc: remove unlikely macro on free_one_page()
>   mm/page_alloc: correct to clear guard attribute in DEBUG_PAGEALLOC
>   mm/page_alloc: handle page on pcp correctly if it's pageblock is
>     isolated
>   mm/page_alloc: carefully free the page on isolate pageblock
>   mm/page_alloc: optimize and unify pageblock migratetype check in free
>     path
>   mm/page_alloc: separate freepage migratetype interface
>   mm/page_alloc: store migratetype of the buddy list into freepage
>     correctly
>   mm/page_alloc: use get_onbuddy_migratetype() to get buddy list type
>   mm/page_alloc: fix possible wrongly calculated freepage counter
>   mm/page_alloc: Stop merging pages on non-isolate and isolate buddy
>     list
> 
>  include/linux/mm.h             |   30 +++++++--
>  include/linux/mmzone.h         |    5 ++
>  include/linux/page-isolation.h |    8 +++
>  mm/page_alloc.c                |  138 +++++++++++++++++++++++++++++-----------
>  mm/page_isolation.c            |   18 ++----
>  5 files changed, 147 insertions(+), 52 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
