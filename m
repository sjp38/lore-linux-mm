Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8E36B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 02:54:02 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id at7so12927723obd.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 23:54:02 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v187si1889026itb.22.2016.06.20.23.54.01
        for <linux-mm@kvack.org>;
        Mon, 20 Jun 2016 23:54:01 -0700 (PDT)
Date: Tue, 21 Jun 2016 15:56:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 0/6] Introduce ZONE_CMA
Message-ID: <20160621065630.GB20635@js1304-P5Q-DELUXE>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160526080454.GA11823@shbuild888>
 <20160527052820.GA13661@js1304-P5Q-DELUXE>
 <20160527062527.GA32297@shbuild888>
 <20160527064218.GA14858@js1304-P5Q-DELUXE>
 <20160527072702.GA7782@shbuild888>
 <5763A909.8080907@hisilicon.com>
 <20160620064816.GB13747@js1304-P5Q-DELUXE>
 <5768A198.7050607@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5768A198.7050607@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Feng Tang <feng.tang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yiping Xu <xuyiping@hisilicon.com>, "fujun (F)" <oliver.fu@hisilicon.com>, Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>, saberlily.xia@hisilicon.com

On Tue, Jun 21, 2016 at 10:08:24AM +0800, Chen Feng wrote:
> 
> 
> On 2016/6/20 14:48, Joonsoo Kim wrote:
> > On Fri, Jun 17, 2016 at 03:38:49PM +0800, Chen Feng wrote:
> >> Hi Kim & feng,
> >>
> >> Thanks for the share. In our platform also has the same use case.
> >>
> >> We only let the alloc with GFP_HIGHUSER_MOVABLE in memory.c to use cma memory.
> >>
> >> If we add zone_cma, It seems can resolve the cma migrate issue.
> >>
> >> But when free_hot_cold_page, we need let the cma page goto system directly not the pcp.
> >> It can be fail while cma_alloc and cma_release. If we alloc the whole cma pages which
> >> declared before.
> > 
> > Hmm...I'm not sure I understand your explanation. So, if I miss
> > something, please let me know. We calls drain_all_pages() when
> > isolating pageblock and alloc_contig_range() also has one
> > drain_all_pages() calls to drain pcp pages. And, after pageblock isolation,
> > freed pages belonging to MIGRATE_ISOLATE pageblock will go to the
> > buddy directly so there would be no problem you mentioned. Isn't it?
> > 
> Yes, you are right.
> 
> I mean if the we free cma page to pcp-list, it will goto the migrate_movable list.
> 
> Then the alloc with movable flag can use the cma memory from the list with buffered_rmqueue.
> 
> But that's not what we want. It will cause the migrate fail if all movable alloc can use cma memory.

Yes, if you modify current kernel code to allow cma pages only for
GFP_HIGHUSER_MOVABLE in memory.c, there are some corner cases and some of cma
pages would be allocated for !GFP_HIGHUSER_MOVABLE. One possible site is
pcp list as you mentioned and the other site is on compaction.

If we uses ZONE_CMA, there is no such problem, because freepages on
pcp list on ZONE_CMA are allocated only when GFP_HIGHUSER_MOVABLE requset
comes.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
