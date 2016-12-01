Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73F99280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 09:27:31 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o2so32083406wje.5
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 06:27:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si863553wmf.122.2016.12.01.06.27.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 06:27:30 -0800 (PST)
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v4
References: <20161201002440.5231-1-mgorman@techsingularity.net>
 <8c666476-f8b6-d468-6050-56e3b5ff84cd@suse.cz>
 <20161201142429.w6lazfn4g6ndpezl@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <08b15992-a94e-1dc1-533c-16cdff7a2e8c@suse.cz>
Date: Thu, 1 Dec 2016 15:27:28 +0100
MIME-Version: 1.0
In-Reply-To: <20161201142429.w6lazfn4g6ndpezl@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On 12/01/2016 03:24 PM, Mel Gorman wrote:
> On Thu, Dec 01, 2016 at 02:41:29PM +0100, Vlastimil Babka wrote:
>> On 12/01/2016 01:24 AM, Mel Gorman wrote:
>>
>> ...
>>
>>
>> Hmm I think that if this hits, we don't decrease count/increase nr_freed and
>> pcp->count will become wrong.
>
> Ok, I think you're right but I also think it's relatively trivial to fix
> with
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 94808f565f74..8777aefc1b8e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1134,13 +1134,13 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			if (unlikely(isolated_pageblocks))
>  				mt = get_pageblock_migratetype(page);
>
> +			nr_freed += (1 << order);
> +			count -= (1 << order);
>  			if (bulkfree_pcp_prepare(page))
>  				continue;
>
>  			__free_one_page(page, page_to_pfn(page), zone, order, mt);
>  			trace_mm_page_pcpu_drain(page, order, mt);
> -			nr_freed += (1 << order);
> -			count -= (1 << order);
>  		} while (count > 0 && --batch_free && !list_empty(list));
>  	}
>  	spin_unlock(&zone->lock);
>
>> And if we are unlucky/doing full drain, all
>> lists will get empty, but as count stays e.g. 1, we loop forever on the
>> outer while()?
>>
>
> Potentially yes. Granted the system is already in a bad state as pages
> are being freed in a bad or unknown state but we haven't halted the
> system for that in the past.
>
>> BTW, I think there's a similar problem (but not introduced by this patch) in
>> rmqueue_bulk() and its
>>
>>     if (unlikely(check_pcp_refill(page)))
>>             continue;
>>
>
> Potentially yes. It's outside the scope of this patch but it needs
> fixing.
>
> If you agree with the above fix, I'll roll it into a v5 and append
> another patch for this issue.

Yeah, looks fine. Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
