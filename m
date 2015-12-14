Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id EC6636B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 05:07:15 -0500 (EST)
Received: by wmpp66 with SMTP id p66so53516334wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 02:07:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n127si3045082wma.8.2015.12.14.02.07.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Dec 2015 02:07:05 -0800 (PST)
Subject: Re: [PATCH 1/2] mm/compaction: fix invalid free_pfn and
 compact_cached_free_pfn
References: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <566E94C6.5080000@suse.cz>
Date: Mon, 14 Dec 2015 11:07:02 +0100
MIME-Version: 1.0
In-Reply-To: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/14/2015 06:02 AM, Joonsoo Kim wrote:
> free_pfn and compact_cached_free_pfn are the pointer that remember
> restart position of freepage scanner. When they are reset or invalid,
> we set them to zone_end_pfn because freepage scanner works in reverse
> direction. But, because zone range is defined as [zone_start_pfn,
> zone_end_pfn), zone_end_pfn is invalid to access. Therefore, we should
> not store it to free_pfn and compact_cached_free_pfn. Instead, we need
> to store zone_end_pfn - 1 to them. There is one more thing we should
> consider. Freepage scanner scan reversely by pageblock unit. If free_pfn
> and compact_cached_free_pfn are set to middle of pageblock, it regards
> that sitiation as that it already scans front part of pageblock so we
> lose opportunity to scan there. To fix-up, this patch do round_down()
> to guarantee that reset position will be pageblock aligned.
>
> Note that thanks to the current pageblock_pfn_to_page() implementation,
> actual access to zone_end_pfn doesn't happen until now. But, following
> patch will change pageblock_pfn_to_page() so this patch is needed
> from now on.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Note that until now in compaction we've used basically an open-coded 
round_down(), and ALIGN() for rounding up. You introduce a first use of 
round_down(), and it would be nice to standardize on round_down() and 
round_up() everywhere. I think it's more obvious than open-coding and 
ALIGN() (which doesn't tell the reader if it's aligning up or down). 
Hopefully they really do the same thing and there are no caveats...

> ---
>   mm/compaction.c | 9 +++++----
>   1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 585de54..56fa321 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -200,7 +200,8 @@ static void reset_cached_positions(struct zone *zone)
>   {
>   	zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
>   	zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
> -	zone->compact_cached_free_pfn = zone_end_pfn(zone);
> +	zone->compact_cached_free_pfn =
> +			round_down(zone_end_pfn(zone) - 1, pageblock_nr_pages);
>   }
>
>   /*
> @@ -1371,11 +1372,11 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   	 */
>   	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
>   	cc->free_pfn = zone->compact_cached_free_pfn;
> -	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
> -		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
> +	if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
> +		cc->free_pfn = round_down(end_pfn - 1, pageblock_nr_pages);
>   		zone->compact_cached_free_pfn = cc->free_pfn;
>   	}
> -	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn > end_pfn) {
> +	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
>   		cc->migrate_pfn = start_pfn;
>   		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
>   		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
