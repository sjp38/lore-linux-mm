Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6959C6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 11:38:12 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id b14so141053535wmb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:38:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m64si5236391wma.122.2016.01.22.08.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 08:38:11 -0800 (PST)
Date: Fri, 22 Jan 2016 11:38:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
Message-ID: <20160122163801.GA16668@cmpxchg.org>
References: <87k2n2usyf.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k2n2usyf.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Peter Zijlstra <peterz@infradead.org>

Hi,

On Fri, Jan 22, 2016 at 10:11:12AM +0530, Aneesh Kumar K.V wrote:
> * CMA allocator issues:
>   (1) order zero allocation failures:
>       We are observing order zero non-movable allocation failures in kernel
> with CMA configured. We don't start a reclaim because our free memory check
> does not consider free_cma. Hence the reclaim code assume we have enough free
> pages. Joonsoo Kim tried to fix this with his ZOME_CMA patches. I would
> like to discuss the challenges in getting this merged upstream.
> https://lkml.org/lkml/2015/2/12/95 (ZONE_CMA)

The exclusion of cma pages from the watermark checks means that
reclaim is happening too early, not too late, which leaves memory
underutilized. That's what ZONE_CMA set out to fix.

But unmovable allocations can still fail when the only free memory is
inside CMA regions. I don't see how ZONE_CMA would fix that.

CC Joonsoo

But as Jan said, we discussed ZONE_CMA before, so it's not clear
whether rehashing it without new data points would be too useful.

> Others needed for the discussion:
> Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
>   (2) CMA allocation failures due to pinned pages in the region:
>       We allow only movable allocation from the CMA region to enable us
> to migrate those pages later when we get a CMA allocation request. But
> if we pin those movable pages, we will fail the migration which can result
> in CMA allocation failure. One such report can be found here.
> http://article.gmane.org/gmane.linux.kernel.mm/136738
> 
> Peter Zijlstra's VM_PINNED patch series should help in fixing the issue. I would
> like to discuss what needs to be done to get this patch series merged upstream
> https://lkml.org/lkml/2014/5/26/345 (VM_PINNED)
> 
> Others needed for the discussion:
> Peter Zijlstra <peterz@infradead.org>

There was no consensus whether this specific implementation would work
well for all sources of pinning. Giving this some time in the MM track
could be useful.

CC Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
