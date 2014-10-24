Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id EE51382BE1
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 04:26:07 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so1057728pde.40
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 01:26:07 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id be2si3682604pbb.56.2014.10.24.01.26.05
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 01:26:06 -0700 (PDT)
Message-ID: <544A0D1A.7000703@lge.com>
Date: Fri, 24 Oct 2014 17:26:02 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 0/4] fix freepage count problems in memory isolation
References: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



2014-10-23 ?AEA 5:10, Joonsoo Kim  3/4 ' +-U:
> Changes from v3 to v4
> * Patch 1: Add code comment on nr_isolate_pageblock on struct zone (Naoya)
> 	Add one more check in free_one_page() that checks whether
> 	migratetype is MIGRATE_ISOLATE or not.
> * Patch 4: Use min() to prevent overflow of buddy merge order (Naoya)
> * Remove RFC tag
> * Add stable tag on all patches
> 
> Changes from v1, v2 to v3
> * A lot of comments that lead this patchset to right direction
> (Vlastimil and Minchan)
> 
> This is version 4 patchset which is improved and minimized version of
> version 1 to fix freepage accounting problem during memory isolation.
> I tried different approach in version 2, but, it looks really complicated
> so I change my mind to improve version 1. You can see version 1, 2 in
> following links [1] [2], respectively.
> 
> IMO, this v3 is better than v2, because this is simpler than v2 so
> better for maintainance and this doesn't change pageblock isolation
> logic so it is much easier to backport.
> 
> This problems are found by testing my patchset [3]. There are some race
> conditions on pageblock isolation and these race cause incorrect
> freepage count.
> 
> Before describing bugs itself, I first explain definition of freepage.
> 
> 1. pages on buddy list are counted as freepage.
> 2. pages on isolate migratetype buddy list are *not* counted as freepage.
> 3. pages on cma buddy list are counted as CMA freepage, too.
> 
> Now, I describe problems and related patch.
> 
> Patch 1: There is race conditions on getting pageblock migratetype that
> it results in misplacement of freepages on buddy list, incorrect
> freepage count and un-availability of freepage.
> 
> Patch 2: Freepages on pcp list could have stale cached information to
> determine migratetype of buddy list to go. This causes misplacement
> of freepages on buddy list and incorrect freepage count.
> 
> Patch 4: Merging between freepages on different migratetype of
> pageblocks will cause freepages accouting problem. This patch fixes it.
> 
> Without patchset [3], above problem doesn't happens on my CMA allocation
> test, because CMA reserved pages aren't used at all. So there is no
> chance for above race.
> 
> With patchset [3], I did simple CMA allocation test and get below result.
> 
> - Virtual machine, 4 cpus, 1024 MB memory, 256 MB CMA reservation
> - run kernel build (make -j16) on background
> - 30 times CMA allocation(8MB * 30 = 240MB) attempts in 5 sec interval
> - Result: more than 5000 freepage count are missed
> 
> With patchset [3] and this patchset, I found that no freepage count are
> missed so that I conclude that problems are solved.
> 
> On my simple memory offlining test, these problems also occur on that
> environment.
> 
> This patchset is based on v3.18-rc1.
> Please see individual patches for more information.
> 
> Thanks.
> 
> [1]: https://lkml.org/lkml/2014/7/4/79
> [2]: lkml.org/lkml/2014/8/6/52
> [3]: Aggressively allocate the pages on cma reserved memory
>       https://lkml.org/lkml/2014/5/30/291
> 
> Joonsoo Kim (4):
>    mm/page_alloc: fix incorrect isolation behavior by rechecking
>      migratetype
>    mm/page_alloc: add freepage on isolate pageblock to correct buddy
>      list
>    mm/page_alloc: move migratetype recheck logic to __free_one_page()
>    mm/page_alloc: restrict max order of merging on isolated pageblock
> 
>   include/linux/mmzone.h         |    9 +++++++++
>   include/linux/page-isolation.h |    8 ++++++++
>   mm/page_alloc.c                |   29 ++++++++++++++++++++---------
>   mm/page_isolation.c            |    2 ++
>   4 files changed, 39 insertions(+), 9 deletions(-)
> 

Thanks a lot.
v4 looks more elegance than previous one.
I'm looking forward to applying of this and [3].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
