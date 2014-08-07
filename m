Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E946B6B0035
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 20:50:36 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so4223845pdj.0
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 17:50:36 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id b4si1051115pdc.309.2014.08.06.17.50.34
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 17:50:35 -0700 (PDT)
Message-ID: <53E2CCFC.6090307@cn.fujitsu.com>
Date: Thu, 7 Aug 2014 08:49:00 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/8] fix freepage count problems in memory isolation
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Joonsoo,

The first 3 patches in this patchset are in a bit of mess.

On 08/06/2014 03:18 PM, Joonsoo Kim wrote:
> Hello,
> 
> This patchset aims at fixing problems during memory isolation found by
> testing my patchset [1].
> 
> These are really subtle problems so I can be wrong. If you find what I am
> missing, please let me know.
> 
> Before describing bugs itself, I first explain definition of freepage.
> 
> 1. pages on buddy list are counted as freepage.
> 2. pages on isolate migratetype buddy list are *not* counted as freepage.
> 3. pages on cma buddy list are counted as CMA freepage, too.
> 4. pages for guard are *not* counted as freepage.
> 
> Now, I describe problems and related patch.
> 
> Patch 1: If guard page are cleared and merged into isolate buddy list,
> we should not add freepage count.
> 
> Patch 4: There is race conditions that results in misplacement of free
> pages on buddy list. Then, it results in incorrect freepage count and
> un-availability of freepage.
> 
> Patch 5: To count freepage correctly, we should prevent freepage from
> being added to buddy list in some period of isolation. Without it, we
> cannot be sure if the freepage is counted or not and miscount number
> of freepage.
> 
> Patch 7: In spite of above fixes, there is one more condition for
> incorrect freepage count. pageblock isolation could be done in pageblock
> unit  so we can't prevent freepage from merging with page on next
> pageblock. To fix it, start_isolate_page_range() and
> undo_isolate_page_range() is modified to process whole range at one go.
> With this change, if input parameter of start_isolate_page_range() and
> undo_isolate_page_range() is properly aligned, there is no condition for
> incorrect merging.
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
> This patchset is based on linux-next-20140728.
> Please see individual patches for more information.
> 
> Thanks.
> 
> [1]: Aggressively allocate the pages on cma reserved memory
>      https://lkml.org/lkml/2014/5/30/291
> 
> Joonsoo Kim (8):
>   mm/page_alloc: correct to clear guard attribute in DEBUG_PAGEALLOC
>   mm/isolation: remove unstable check for isolated page
>   mm/page_alloc: fix pcp high, batch management
>   mm/isolation: close the two race problems related to pageblock
>     isolation
>   mm/isolation: change pageblock isolation logic to fix freepage
>     counting bugs
>   mm/isolation: factor out pre/post logic on
>     set/unset_migratetype_isolate()
>   mm/isolation: fix freepage counting bug on
>     start/undo_isolat_page_range()
>   mm/isolation: remove useless race handling related to pageblock
>     isolation
> 
>  include/linux/page-isolation.h |    2 +
>  mm/internal.h                  |    5 +
>  mm/page_alloc.c                |  223 +++++++++++++++++-------------
>  mm/page_isolation.c            |  292 +++++++++++++++++++++++++++++++---------
>  4 files changed, 368 insertions(+), 154 deletions(-)
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
