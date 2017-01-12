Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5CA76B0289
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:44:25 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id l2so5475197wml.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:44:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si2146209wmd.63.2017.01.12.07.44.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 07:44:24 -0800 (PST)
Subject: Re: [PATCH 1/3] mm, page_alloc: Split buffered_rmqueue
References: <20170112104300.24345-1-mgorman@techsingularity.net>
 <20170112104300.24345-2-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <63cb1f14-ab02-31a2-f386-16c1b52f61fe@suse.cz>
Date: Thu, 12 Jan 2017 16:44:20 +0100
MIME-Version: 1.0
In-Reply-To: <20170112104300.24345-2-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 01/12/2017 11:42 AM, Mel Gorman wrote:
> buffered_rmqueue removes a page from a given zone and uses the per-cpu
> list for order-0. This is fine but a hypothetical caller that wanted
> multiple order-0 pages has to disable/reenable interrupts multiple
> times. This patch structures buffere_rmqueue such that it's relatively
> easy to build a bulk order-0 page allocator. There is no functional
> change.

Strictly speaking, this will now skip VM_BUG_ON_PAGE(bad_range(...)) for order-0 
allocations. Do we care?

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> ---
>  mm/page_alloc.c | 126 ++++++++++++++++++++++++++++++++++----------------------
>  1 file changed, 77 insertions(+), 49 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2c6d5f64feca..d8798583eaf8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2610,68 +2610,96 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
>  #endif
>  }
>
> +/* Remote page from the per-cpu list, caller must protect the list */

     ^ Remove

> +static struct page *__rmqueue_pcplist(struct zone *zone, unsigned int order,
> +			gfp_t gfp_flags, int migratetype, bool cold,

order and gfp_flags seem unused here

> +			struct per_cpu_pages *pcp, struct list_head *list)
> +{
> +	struct page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
