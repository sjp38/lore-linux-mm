Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id AAD576B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 03:25:19 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so20096362wib.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 00:25:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x15si3516526wia.58.2015.07.31.00.25.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 00:25:17 -0700 (PDT)
Subject: Re: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-10-git-send-email-mgorman@suse.com>
 <20150731055407.GA15912@js1304-P5Q-DELUXE>
 <20150731071113.GA5840@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55BB22D9.5040200@suse.cz>
Date: Fri, 31 Jul 2015 09:25:13 +0200
MIME-Version: 1.0
In-Reply-To: <20150731071113.GA5840@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/31/2015 09:11 AM, Mel Gorman wrote:
> On Fri, Jul 31, 2015 at 02:54:07PM +0900, Joonsoo Kim wrote:
>> Hello, Mel.
>>
>> On Mon, Jul 20, 2015 at 09:00:18AM +0100, Mel Gorman wrote:
>>> From: Mel Gorman <mgorman@suse.de>
>>>
>>> High-order watermark checking exists for two reasons --  kswapd high-order
>>> awareness and protection for high-order atomic requests. Historically we
>>> depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order free
>>> pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
>>> that reserves pageblocks for high-order atomic allocations. This is expected
>>> to be more reliable than MIGRATE_RESERVE was.
>>
>> I have some concerns on this patch.
>>
>> 1) This patch breaks intention of __GFP_WAIT.
>> __GFP_WAIT is used when we want to succeed allocation even if we need
>> to do some reclaim/compaction work. That implies importance of
>> allocation success. But, reserved pageblock for MIGRATE_HIGHATOMIC makes
>> atomic allocation (~__GFP_WAIT) more successful than allocation with
>> __GFP_WAIT in many situation. It breaks basic assumption of gfp flags
>> and doesn't make any sense.
>>
>
> Currently allocation requests that do not specify __GFP_WAIT get the
> ALLOC_HARDER flag which allows them to dip further into watermark reserves.
> It already is the case that there are corner cases where a high atomic
> allocation can succeed when a non-atomic allocation would reclaim.

I think (and said so before elsewhere) is that the problem is that we 
don't currently distinguish allocations that can't wait (=are really 
atomic and have no order-0 fallback) and allocations that just don't 
want to wait (=they have fallbacks). The second ones should obviously 
not access the current ALLOC_HARDER watermark-based reserves nor the 
proposed highatomic reserves.

Well we do look at __GFP_NO_KSWAPD flag to treat allocation as 
non-atomic, so that covers THP allocations and two drivers. But the 
recent networking commit fb05e7a89f50 didn't add the flag and nor does 
Joonsoo's slub patch use it. Either we should rename the flag and employ 
it where appropriate, or agree that access to reserves is orthogonal 
concern to waking up kswapd, and distinguish non-atomic non-__GFP_WAIT 
allocations differently.

>>> A MIGRATE_HIGHORDER pageblock is created when an allocation request steals
>>> a pageblock but limits the total number to 10% of the zone.
>>
>> When steals happens, pageblock already can be fragmented and we can't
>> fully utilize this pageblock without allowing order-0 allocation. This
>> is very waste.
>>
>
> If the pageblock was stolen, it implies there was at least 1 usable page
> of the correct order. As the pageblock is then reserved, any pages that
> free in that block stay free for use by high-order atomic allocations.
> Else, the number of pageblocks will increase again until the 10% limit
> is hit.

It's however true that many of the "any pages free in that block" may be 
order-0, so they both won't be useful to high-order atomic allocations, 
and won't be available to other allocations, so they might remain unused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
