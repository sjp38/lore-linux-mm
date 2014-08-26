Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id B1A2F6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 04:08:12 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id x13so14913174qcv.26
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 01:08:12 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id u78si2938895qge.85.2014.08.26.01.08.10
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 01:08:12 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH v3 0/4] fix freepage count problems in memory isolation
Date: Tue, 26 Aug 2014 17:08:14 +0900
Message-Id: <1409040498-10148-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This is version 3 patchset which is improved and minimized version of
version 1 to fix freepage accounting problem during memory isolation.
I tried different approach in version 2, but, it looks really complicated
so I change my mind to improve version 1. You can see version 1, 2 in
following links [1] [2], respectively.

IMO, this v3 is better than v2, because this is simpler than v2 so
better for maintainance and this doesn't change pageblock isolation
logic so it is much easier to backport.

This problems are found by testing my patchset [3]. There are some race
conditions on pageblock isolation and these race cause incorrect
freepage count.

Before describing bugs itself, I first explain definition of freepage.

1. pages on buddy list are counted as freepage.
2. pages on isolate migratetype buddy list are *not* counted as freepage.
3. pages on cma buddy list are counted as CMA freepage, too.

Now, I describe problems and related patch.

Patch 1: There is race conditions on getting pageblock migratetype that
it results in misplacement of freepages on buddy list, incorrect
freepage count and un-availability of freepage.

Patch 2: Freepages on pcp list could have stale cached information to
determine migratetype of buddy list to go. This causes misplacement
of freepages on buddy list and incorrect freepage count.

Patch 4: Merging between freepages on different migratetype of
pageblocks will cause freepages accouting problem. This patch fixes it.

Without patchset [3], above problem doesn't happens on my CMA allocation
test, because CMA reserved pages aren't used at all. So there is no
chance for above race.

With patchset [3], I did simple CMA allocation test and get below result.

- Virtual machine, 4 cpus, 1024 MB memory, 256 MB CMA reservation
- run kernel build (make -j16) on background
- 30 times CMA allocation(8MB * 30 = 240MB) attempts in 5 sec interval
- Result: more than 5000 freepage count are missed

With patchset [3] and this patchset, I found that no freepage count are
missed so that I conclude that problems are solved.

These problems can be possible on memory hot remove users, although
I didn't check it further.

This patchset is based on linux-next-20140826.
Please see individual patches for more information.

Thanks.

[1]: https://lkml.org/lkml/2014/7/4/79
[2]: lkml.org/lkml/2014/8/6/52
[3]: Aggressively allocate the pages on cma reserved memory
     https://lkml.org/lkml/2014/5/30/291

Joonsoo Kim (4):
  mm/page_alloc: fix incorrect isolation behavior by rechecking
    migratetype
  mm/page_alloc: add freepage on isolate pageblock to correct buddy
    list
  mm/page_alloc: move migratetype recheck logic to __free_one_page()
  mm/page_alloc: restrict max order of merging on isolated pageblock

 include/linux/mmzone.h         |    4 ++++
 include/linux/page-isolation.h |    8 ++++++++
 mm/page_alloc.c                |   28 +++++++++++++++++++---------
 mm/page_isolation.c            |    2 ++
 4 files changed, 33 insertions(+), 9 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
