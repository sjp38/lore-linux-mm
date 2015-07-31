Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C80766B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 03:19:11 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so47040541wib.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 00:19:11 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id cg18si6375905wjb.154.2015.07.31.00.19.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 00:19:10 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 688EB98C4D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:19:09 +0000 (UTC)
Date: Fri, 31 Jul 2015 08:19:07 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150731071907.GB5840@techsingularity.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-11-git-send-email-mgorman@suse.com>
 <20150731060838.GB15912@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150731060838.GB15912@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 31, 2015 at 03:08:38PM +0900, Joonsoo Kim wrote:
> On Mon, Jul 20, 2015 at 09:00:19AM +0100, Mel Gorman wrote:
> > From: Mel Gorman <mgorman@suse.de>
> > 
> > The primary purpose of watermarks is to ensure that reclaim can always
> > make forward progress in PF_MEMALLOC context (kswapd and direct reclaim).
> > These assume that order-0 allocations are all that is necessary for
> > forward progress.
> > 
> > High-order watermarks serve a different purpose. Kswapd had no high-order
> > awareness before they were introduced (https://lkml.org/lkml/2004/9/5/9).
> > This was particularly important when there were high-order atomic requests.
> > The watermarks both gave kswapd awareness and made a reserve for those
> > atomic requests.
> > 
> > There are two important side-effects of this. The most important is that
> > a non-atomic high-order request can fail even though free pages are available
> > and the order-0 watermarks are ok. The second is that high-order watermark
> > checks are expensive as the free list counts up to the requested order must
> > be examined.
> > 
> > With the introduction of MIGRATE_HIGHATOMIC it is no longer necessary to
> > have high-order watermarks. Kswapd and compaction still need high-order
> > awareness which is handled by checking that at least one suitable high-order
> > page is free.
> 
> I totally agree removing watermark checking for order from
> PAGE_ALLOC_COSTLY_ORDER to MAX_ORDER. It doesn't make sense to
> maintain such high-order freepage that MM don't guarantee allocation
> success. For example, in my system, when there is 1 order-9 freepage,
> allocation request for order-9 fails because watermark check requires
> at least 2 order-9 freepages in order to succeed order-9 allocation.
> 
> But, I think watermark checking with order up to PAGE_ALLOC_COSTLY_ORDER is
> different. If we maintain just 1 high-order freepages, successive
> high-order allocation request that should be success always fall into
> allocation slow-path and go into the direct reclaim/compaction. It enlarges
> many workload's latency. We should prepare at least some number of freepage
> to handle successive high-order allocation request gracefully.
> 
> So, how about following?
> 
> 1) kswapd checks watermark as is up to PAGE_ALLOC_COSTLY_ORDER. It
> guarantees kswapd prepares some number of high-order freepages so
> successive high-order allocation request will be handlded gracefully.
> 2) In case of !kswapd, just check whether appropriate freepage is
> in buddy or not.
> 

If !atomic allocations use the high-order reserves then they'll fragment
similarly to how they get fragmented today. It defeats the purpose of
the reserve. I noted in the leader that embedded platforms may choose to
carry an out-of-ftree patch that makes the reserves a kernel reserve for
high-order pages but that I didn't think it was a good idea for mainline.

Your suggestion implies we have two watermark checks. The fast path
which obeys watermarks in the traditional way. kswapd would use the same
watermark check. The slow path would use the watermark check in this
path. It is quite complex when historically it was expected that a
!atomic high-order allocation request may take a long time. Furthermore,
it's the case that kswapd gives up high-order reclaim requests very
quickly because there were cases where a high-order request would cause
kswapd to continually reclaim when the system was fragmented. I fear
that your suggestion would partially reintroduce the problem in the name
of trying to decrease the latency of a !atomic high-order allocation
request that is expected to be expensive sometimes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
