Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5586B0005
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:41:39 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id 9so146181989iom.1
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 18:41:39 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id sb8si21312258igb.97.2016.02.14.18.41.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 14 Feb 2016 18:41:38 -0800 (PST)
Date: Mon, 15 Feb 2016 11:42:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
Message-ID: <20160215024220.GA30918@js1304-P5Q-DELUXE>
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
 <20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
 <CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
 <56C0550F.8020402@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56C0550F.8020402@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>

On Sun, Feb 14, 2016 at 06:21:03PM +0800, zhong jiang wrote:
> On 2016/2/6 0:11, Joonsoo Kim wrote:
> > 2016-02-05 9:49 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
> >> On Thu,  4 Feb 2016 15:19:35 +0900 Joonsoo Kim <js1304@gmail.com> wrote:
> >>
> >>> There is a performance drop report due to hugepage allocation and in there
> >>> half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
> >>> In that workload, compaction is triggered to make hugepage but most of
> >>> pageblocks are un-available for compaction due to pageblock type and
> >>> skip bit so compaction usually fails. Most costly operations in this case
> >>> is to find valid pageblock while scanning whole zone range. To check
> >>> if pageblock is valid to compact, valid pfn within pageblock is required
> >>> and we can obtain it by calling pageblock_pfn_to_page(). This function
> >>> checks whether pageblock is in a single zone and return valid pfn
> >>> if possible. Problem is that we need to check it every time before
> >>> scanning pageblock even if we re-visit it and this turns out to
> >>> be very expensive in this workload.
> >>>
> >>> Although we have no way to skip this pageblock check in the system
> >>> where hole exists at arbitrary position, we can use cached value for
> >>> zone continuity and just do pfn_to_page() in the system where hole doesn't
> >>> exist. This optimization considerably speeds up in above workload.
> >>>
> >>> Before vs After
> >>> Max: 1096 MB/s vs 1325 MB/s
> >>> Min: 635 MB/s 1015 MB/s
> >>> Avg: 899 MB/s 1194 MB/s
> >>>
> >>> Avg is improved by roughly 30% [2].
> >>>
> >>> [1]: http://www.spinics.net/lists/linux-mm/msg97378.html
> >>> [2]: https://lkml.org/lkml/2015/12/9/23
> >>>
> >>> ...
> >>>
> >>> --- a/include/linux/memory_hotplug.h
> >>> +++ b/include/linux/memory_hotplug.h
> >>> @@ -196,6 +196,9 @@ void put_online_mems(void);
> >>>  void mem_hotplug_begin(void);
> >>>  void mem_hotplug_done(void);
> >>>
> >>> +extern void set_zone_contiguous(struct zone *zone);
> >>> +extern void clear_zone_contiguous(struct zone *zone);
> >>> +
> >>>  #else /* ! CONFIG_MEMORY_HOTPLUG */
> >>>  /*
> >>>   * Stub functions for when hotplug is off
> >>
> >> Was it really intended that these declarations only exist if
> >> CONFIG_MEMORY_HOTPLUG?  Seems unrelated.
> > 
> > These are called for caching memory layout whether it is contiguous
> > or not. So, they are always called in memory initialization. Then,
> > hotplug could change memory layout so they should be called
> > there, too. So, they are defined in page_alloc.c and exported only
> > if CONFIG_MEMORY_HOTPLUG.
> > 
> >> The i386 allnocofnig build fails in preditable ways so I fixed that up
> >> as below, but it seems wrong.
> > 
> > Yeah, it seems wrong to me. :)
> > Here goes fix.
> > 
> > ----------->8------------
> >>From ed6add18bc361e00a7ac6746de6eeb62109e6416 Mon Sep 17 00:00:00 2001
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Date: Thu, 10 Dec 2015 17:03:54 +0900
> > Subject: [PATCH] mm/compaction: speed up pageblock_pfn_to_page() when zone is
> >  contiguous
> > 
> > There is a performance drop report due to hugepage allocation and in there
> > half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
> > In that workload, compaction is triggered to make hugepage but most of
> > pageblocks are un-available for compaction due to pageblock type and
> > skip bit so compaction usually fails. Most costly operations in this case
> > is to find valid pageblock while scanning whole zone range. To check
> > if pageblock is valid to compact, valid pfn within pageblock is required
> > and we can obtain it by calling pageblock_pfn_to_page(). This function
> > checks whether pageblock is in a single zone and return valid pfn
> > if possible. Problem is that we need to check it every time before
> > scanning pageblock even if we re-visit it and this turns out to
> > be very expensive in this workload.
> > 
> > Although we have no way to skip this pageblock check in the system
> > where hole exists at arbitrary position, we can use cached value for
> > zone continuity and just do pfn_to_page() in the system where hole doesn't
> > exist. This optimization considerably speeds up in above workload.
> > 
> > Before vs After
> > Max: 1096 MB/s vs 1325 MB/s
> > Min: 635 MB/s 1015 MB/s
> > Avg: 899 MB/s 1194 MB/s
> > 
> > Avg is improved by roughly 30% [2].
> > 
> > [1]: http://www.spinics.net/lists/linux-mm/msg97378.html
> > [2]: https://lkml.org/lkml/2015/12/9/23
> > 
> > v3
> > o remove pfn_valid_within() check for all pages in the pageblock
> > because pageblock_pfn_to_page() is only called with pageblock aligned pfn.
> 
> I have a question about the zone continuity. because hole exists at
> arbitrary position in a page block. Therefore, only pageblock_pf_to_page()
> is insufficiency, whether pageblock aligned pfn or not , the pfn_valid_within()
> is necessary.
> 
> eh: 120M-122M is a range of page block, but the 120.5M-121.5M is holes, only by
> pageblock_pfn_to_page() to conclude in the result is inaccurate

contiguous may be misleading word. It doesn't represent there are no
hole. It only represents that all pageblocks within zone span belong to
corresponding zone and validity of all pageblock aligned pfn is
checked. So, if it is set, we can safely call pfn_to_page() for pageblock
aligned pfn in that zone without checking pfn_valid().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
