Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C7E146B003D
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 03:11:23 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so2916610pab.14
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:11:23 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id gz1si109508pbd.106.2014.08.06.00.11.18
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 00:11:19 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 0/8] fix freepage count problems in memory isolation
Date: Wed,  6 Aug 2014 16:18:26 +0900
Message-Id: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

This patchset aims at fixing problems during memory isolation found by
testing my patchset [1].

These are really subtle problems so I can be wrong. If you find what I am
missing, please let me know.

Before describing bugs itself, I first explain definition of freepage.

1. pages on buddy list are counted as freepage.
2. pages on isolate migratetype buddy list are *not* counted as freepage.
3. pages on cma buddy list are counted as CMA freepage, too.
4. pages for guard are *not* counted as freepage.

Now, I describe problems and related patch.

Patch 1: If guard page are cleared and merged into isolate buddy list,
we should not add freepage count.

Patch 4: There is race conditions that results in misplacement of free
pages on buddy list. Then, it results in incorrect freepage count and
un-availability of freepage.

Patch 5: To count freepage correctly, we should prevent freepage from
being added to buddy list in some period of isolation. Without it, we
cannot be sure if the freepage is counted or not and miscount number
of freepage.

Patch 7: In spite of above fixes, there is one more condition for
incorrect freepage count. pageblock isolation could be done in pageblock
unit  so we can't prevent freepage from merging with page on next
pageblock. To fix it, start_isolate_page_range() and
undo_isolate_page_range() is modified to process whole range at one go.
With this change, if input parameter of start_isolate_page_range() and
undo_isolate_page_range() is properly aligned, there is no condition for
incorrect merging.

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

This patchset is based on linux-next-20140728.
Please see individual patches for more information.

Thanks.

[1]: Aggressively allocate the pages on cma reserved memory
     https://lkml.org/lkml/2014/5/30/291

Joonsoo Kim (8):
  mm/page_alloc: correct to clear guard attribute in DEBUG_PAGEALLOC
  mm/isolation: remove unstable check for isolated page
  mm/page_alloc: fix pcp high, batch management
  mm/isolation: close the two race problems related to pageblock
    isolation
  mm/isolation: change pageblock isolation logic to fix freepage
    counting bugs
  mm/isolation: factor out pre/post logic on
    set/unset_migratetype_isolate()
  mm/isolation: fix freepage counting bug on
    start/undo_isolat_page_range()
  mm/isolation: remove useless race handling related to pageblock
    isolation

 include/linux/page-isolation.h |    2 +
 mm/internal.h                  |    5 +
 mm/page_alloc.c                |  223 +++++++++++++++++-------------
 mm/page_isolation.c            |  292 +++++++++++++++++++++++++++++++---------
 4 files changed, 368 insertions(+), 154 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
