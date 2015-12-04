Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 17AF86B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 11:52:24 -0500 (EST)
Received: by wmec201 with SMTP id c201so82872398wme.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 08:52:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wk7si19618030wjb.244.2015.12.04.08.52.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Dec 2015 08:52:22 -0800 (PST)
Subject: Re: [PATCH v3 4/7] mm/compaction: update defer counter when
 allocation is expected to succeed
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-5-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5661C4C5.2020901@suse.cz>
Date: Fri, 4 Dec 2015 17:52:21 +0100
MIME-Version: 1.0
In-Reply-To: <1449126681-19647-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> It's rather strange that compact_considered and compact_defer_shift aren't
> updated but compact_order_failed is updated when allocation is expected
> to succeed. Regardless actual allocation success, deferring for current
> order will be disabled so it doesn't result in much difference to
> compaction behaviour.

The difference is that if the defer reset was wrong, the next compaction 
attempt that fails would resume the deferred counters?

> Moreover, in the past, there is a gap between expectation for allocation
> succeess in compaction and actual success in page allocator. But, now,
> this gap would be diminished due to providing classzone_idx and alloc_flags
> to watermark check in compaction and changed watermark check criteria
> for high-order allocation. Therfore, it's not a big problem to update
> defer counter when allocation is expected to succeed. This change
> will help to simplify defer logic.

I guess that's true. But at least some experiment would be better.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   include/linux/compaction.h |  2 --
>   mm/compaction.c            | 27 ++++++++-------------------
>   mm/page_alloc.c            |  1 -
>   3 files changed, 8 insertions(+), 22 deletions(-)
>

...

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7002c66..f3605fd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2815,7 +2815,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>   		struct zone *zone = page_zone(page);
>
>   		zone->compact_blockskip_flush = false;

While we are here, I wonder if this is useful at all? 
compact_blockskip_flush is set true when scanners meet. That typically 
means the compaction wasn't successful. Rarely it can be, but I doubt 
this will make much difference, so we could remove this line as well.

> -		compaction_defer_reset(zone, order, true);
>   		count_vm_event(COMPACTSUCCESS);
>   		return page;
>   	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
