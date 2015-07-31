Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 47C2A6B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:03:45 -0400 (EDT)
Received: by iodd187 with SMTP id d187so75611672iod.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 23:03:45 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id a13si7873775pdj.106.2015.07.30.23.03.43
        for <linux-mm@kvack.org>;
        Thu, 30 Jul 2015 23:03:44 -0700 (PDT)
Date: Fri, 31 Jul 2015 15:08:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150731060838.GB15912@js1304-P5Q-DELUXE>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-11-git-send-email-mgorman@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437379219-9160-11-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Mon, Jul 20, 2015 at 09:00:19AM +0100, Mel Gorman wrote:
> From: Mel Gorman <mgorman@suse.de>
> 
> The primary purpose of watermarks is to ensure that reclaim can always
> make forward progress in PF_MEMALLOC context (kswapd and direct reclaim).
> These assume that order-0 allocations are all that is necessary for
> forward progress.
> 
> High-order watermarks serve a different purpose. Kswapd had no high-order
> awareness before they were introduced (https://lkml.org/lkml/2004/9/5/9).
> This was particularly important when there were high-order atomic requests.
> The watermarks both gave kswapd awareness and made a reserve for those
> atomic requests.
> 
> There are two important side-effects of this. The most important is that
> a non-atomic high-order request can fail even though free pages are available
> and the order-0 watermarks are ok. The second is that high-order watermark
> checks are expensive as the free list counts up to the requested order must
> be examined.
> 
> With the introduction of MIGRATE_HIGHATOMIC it is no longer necessary to
> have high-order watermarks. Kswapd and compaction still need high-order
> awareness which is handled by checking that at least one suitable high-order
> page is free.

I totally agree removing watermark checking for order from
PAGE_ALLOC_COSTLY_ORDER to MAX_ORDER. It doesn't make sense to
maintain such high-order freepage that MM don't guarantee allocation
success. For example, in my system, when there is 1 order-9 freepage,
allocation request for order-9 fails because watermark check requires
at least 2 order-9 freepages in order to succeed order-9 allocation.

But, I think watermark checking with order up to PAGE_ALLOC_COSTLY_ORDER is
different. If we maintain just 1 high-order freepages, successive
high-order allocation request that should be success always fall into
allocation slow-path and go into the direct reclaim/compaction. It enlarges
many workload's latency. We should prepare at least some number of freepage
to handle successive high-order allocation request gracefully.

So, how about following?

1) kswapd checks watermark as is up to PAGE_ALLOC_COSTLY_ORDER. It
guarantees kswapd prepares some number of high-order freepages so
successive high-order allocation request will be handlded gracefully.
2) In case of !kswapd, just check whether appropriate freepage is
in buddy or not.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
