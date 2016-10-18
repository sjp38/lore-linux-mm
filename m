Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4EF6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 03:43:05 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b75so5177647lfg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 00:43:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ul7si17557378wjc.40.2016.10.18.00.43.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 00:43:03 -0700 (PDT)
Subject: Re: [PATCH v6 3/6] mm/cma: populate ZONE_CMA
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <33f0a8f3-38d1-e527-f71f-839afe0b2ed9@suse.cz>
Date: Tue, 18 Oct 2016 09:42:57 +0200
MIME-Version: 1.0
In-Reply-To: <1476414196-3514-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 10/14/2016 05:03 AM, js1304@gmail.com wrote:
> @@ -145,6 +145,35 @@ static int __init cma_activate_area(struct cma *cma)
>  static int __init cma_init_reserved_areas(void)
>  {
>  	int i;
> +	struct zone *zone;
> +	pg_data_t *pgdat;
> +
> +	if (!cma_area_count)
> +		return 0;
> +
> +	for_each_online_pgdat(pgdat) {
> +		unsigned long start_pfn = UINT_MAX, end_pfn = 0;
> +
> +		for (i = 0; i < cma_area_count; i++) {
> +			if (pfn_to_nid(cma_areas[i].base_pfn) !=
> +				pgdat->node_id)
> +				continue;
> +
> +			start_pfn = min(start_pfn, cma_areas[i].base_pfn);
> +			end_pfn = max(end_pfn, cma_areas[i].base_pfn +
> +						cma_areas[i].count);
> +		}
> +
> +		if (!end_pfn)
> +			continue;
> +
> +		zone = &pgdat->node_zones[ZONE_CMA];
> +
> +		/* ZONE_CMA doesn't need to exceed CMA region */
> +		zone->zone_start_pfn = max(zone->zone_start_pfn, start_pfn);
> +		zone->spanned_pages = min(zone_end_pfn(zone), end_pfn) -
> +					zone->zone_start_pfn;

Hmm, do the max/min here work as intended? IIUC the initial 
zone_start_pfn is UINT_MAX and zone->spanned_pages is 1? So at least the 
max/min should be swapped?
Also the zone_end_pfn(zone) on the second line already sees the changes 
to zone->zone_start_pfn in the first line, so it's kind of a mess. You 
should probably cache zone_end_pfn() to a temporary variable before 
changing zone_start_pfn.

> +	}

I'm guessing the initial values come from this part in patch 2/6:

> @@ -5723,6 +5738,8 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
>                                                 unsigned long *zholes_size)
>  {
>         unsigned long realtotalpages = 0, totalpages = 0;
> +       unsigned long zone_cma_start_pfn = UINT_MAX;
> +       unsigned long zone_cma_end_pfn = 0;
>         enum zone_type i;
>
>         for (i = 0; i < MAX_NR_ZONES; i++) {
> @@ -5730,6 +5747,13 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
>                 unsigned long zone_start_pfn, zone_end_pfn;
>                 unsigned long size, real_size;
>
> +               if (is_zone_cma_idx(i)) {
> +                       zone->zone_start_pfn = zone_cma_start_pfn;
> +                       size = zone_cma_end_pfn - zone_cma_start_pfn;
> +                       real_size = 0;
> +                       goto init_zone;
> +               }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
