Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0920B6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 03:27:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l124so953224wml.4
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:27:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si1632001wmf.0.2016.10.26.00.27.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 00:27:40 -0700 (PDT)
Subject: Re: [PATCH v6 3/6] mm/cma: populate ZONE_CMA
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-4-git-send-email-iamjoonsoo.kim@lge.com>
 <33f0a8f3-38d1-e527-f71f-839afe0b2ed9@suse.cz>
 <20161018082730.GA20442@js1304-P5Q-DELUXE>
 <20161026043123.GA2901@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <49fde512-15dd-33dc-2120-a6ac1491a165@suse.cz>
Date: Wed, 26 Oct 2016 09:27:33 +0200
MIME-Version: 1.0
In-Reply-To: <20161026043123.GA2901@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/26/2016 06:31 AM, Joonsoo Kim wrote:
> Hello,
>
> Here comes fixed one.
>
> ----------->8------------
> From 93fb05a83d74f9e2c8caebc2fa6d1a8807c9ffb6 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Thu, 24 Mar 2016 22:29:10 +0900
> Subject: [PATCH] mm/cma: populate ZONE_CMA
>
> Until now, reserved pages for CMA are managed in the ordinary zones
> where page's pfn are belong to. This approach has numorous problems
> and fixing them isn't easy. (It is mentioned on previous patch.)
> To fix this situation, ZONE_CMA is introduced in previous patch, but,
> not yet populated. This patch implement population of ZONE_CMA
> by stealing reserved pages from the ordinary zones.
>
> Unlike previous implementation that kernel allocation request with
> __GFP_MOVABLE could be serviced from CMA region, allocation request only
> with GFP_HIGHUSER_MOVABLE can be serviced from CMA region in the new
> approach. This is an inevitable design decision to use the zone
> implementation because ZONE_CMA could contain highmem. Due to this
> decision, ZONE_CMA will work like as ZONE_HIGHMEM or ZONE_MOVABLE.
>
> I don't think it would be a problem because most of file cache pages
> and anonymous pages are requested with GFP_HIGHUSER_MOVABLE. It could
> be proved by the fact that there are many systems with ZONE_HIGHMEM and
> they work fine. Notable disadvantage is that we cannot use these pages
> for blockdev file cache page, because it usually has __GFP_MOVABLE but
> not __GFP_HIGHMEM and __GFP_USER. But, in this case, there is pros and
> cons. In my experience, blockdev file cache pages are one of the top
> reason that causes cma_alloc() to fail temporarily. So, we can get more
> guarantee of cma_alloc() success by discarding that case.
>
> Implementation itself is very easy to understand. Steal when cma area is
> initialized and recalculate various per zone stat/threshold.
>
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
