Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3EC6B005A
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 03:53:02 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so1584062pde.31
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 00:53:02 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id tz6si34731467pbc.165.2014.07.04.00.52.58
        for <linux-mm@kvack.org>;
        Fri, 04 Jul 2014 00:53:01 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 00/10] fix freepage count problems due to memory isolation
Date: Fri,  4 Jul 2014 16:57:45 +0900
Message-Id: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

This patchset aims at fixing problems due to memory isolation found by
testing my patchset [1].

These are really subtle problems so I can be wrong. If you find what I am
missing, please let me know.

Before describing bugs itself, I first explain definition of freepage.

1. pages on buddy list are counted as freepage.
2. pages on isolate migratetype buddy list are *not* counted as freepage.
3. pages on cma buddy list are counted as CMA freepage, too.
4. pages for guard are *not* counted as freepage.

Now, I describe problems and related patch.

1. Patch 2: If guard page are cleared and merged into isolate buddy list,
we should not add freepage count.

2. Patch 3: When the page return back from pcp to buddy, we should
account it to freepage counter. In this case, we should check the
pageblock migratetype of the page and should insert the page into
appropriate buddy list. Although we checked it in current code, we
didn't insert the page into appropriate buddy list so that freepage
counting can be wrong.

3. Patch 4: There is race condition so that some freepages could be
on isolate buddy list. If so, we can't use this page until next isolation
attempt on this pageblock.

4. Patch 5: There is race condition that page on isolate pageblock
can go into non-isolate buddy list. If so, buddy allocator would
merge pages on non-isolate buddy list and isolate buddy list, respectively,
and freepage count will be wrong.

5. Patch 9: move_freepages(_block) returns *not* number of moved pages.
Instead, it returns number of pages linked in that migratetype buddy list.
So accouting with this return value makes freepage count wrong.

6. Patch 10: buddy allocator would merge pages on non-isolate buddy list
and isolate buddy list, respectively. This leads to freepage counting
problem so fix it by stopping merging in this case.

Without patchset [1], above problem doesn't happens on my CMA allocation
test, because CMA reserved pages aren't used at all. So there is no
chance for above race.

With patchset [1], I did simple CMA allocation test and get below result.

- Virtual machine, 4 cpus, 1024 MB memory, 256 MB CMA reservation
- run kernel build (make -j16) on background
- 30 times CMA allocation(8MB * 30 = 240MB) attempts in 5 sec interval
- Result: more than 5000 freepage count are missed

With patchset [1] and this patchset, I found that no freepage count are
missed so that I conclude that problems are solved.

These problems can be possible on memory hot remove users, although
I didn't check it further.

Other patches are either for the base to fix these problems or for
simple clean-up. Please see individual patches for more information.

This patchset is based on linux-next-20140703.

Thanks.

[1]: Aggressively allocate the pages on cma reserved memory
     https://lkml.org/lkml/2014/5/30/291


Joonsoo Kim (10):
  mm/page_alloc: remove unlikely macro on free_one_page()
  mm/page_alloc: correct to clear guard attribute in DEBUG_PAGEALLOC
  mm/page_alloc: handle page on pcp correctly if it's pageblock is
    isolated
  mm/page_alloc: carefully free the page on isolate pageblock
  mm/page_alloc: optimize and unify pageblock migratetype check in free
    path
  mm/page_alloc: separate freepage migratetype interface
  mm/page_alloc: store migratetype of the buddy list into freepage
    correctly
  mm/page_alloc: use get_onbuddy_migratetype() to get buddy list type
  mm/page_alloc: fix possible wrongly calculated freepage counter
  mm/page_alloc: Stop merging pages on non-isolate and isolate buddy
    list

 include/linux/mm.h             |   30 +++++++--
 include/linux/mmzone.h         |    5 ++
 include/linux/page-isolation.h |    8 +++
 mm/page_alloc.c                |  138 +++++++++++++++++++++++++++++-----------
 mm/page_isolation.c            |   18 ++----
 5 files changed, 147 insertions(+), 52 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
