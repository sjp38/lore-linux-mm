Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 44EF76B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:48:36 -0400 (EDT)
Received: by wegp1 with SMTP id p1so32819011weg.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 06:48:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r8si29070211wjw.39.2015.03.18.06.48.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 06:48:34 -0700 (PDT)
Message-ID: <55098230.5080600@suse.cz>
Date: Wed, 18 Mar 2015 14:48:32 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: reset pages_scanned only when free pages are
 above high watermark
References: <20150311183023.4476.40069.stgit@buzz>
In-Reply-To: <20150311183023.4476.40069.stgit@buzz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org
Cc: Roman Gushchin <klamm@yandex-team.ru>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On 03/11/2015 07:30 PM, Konstantin Khlebnikov wrote:
> Technically, this counter works as OOM-countdown. Let's reset it only
> when zone is completely recovered and ready to handle any allocations.
> Otherwise system could never recover and stuck in livelock.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Hmm, could this help in cases like this one?
https://lkml.org/lkml/2015/1/23/688

> ---
>   mm/page_alloc.c |    6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ffd5ad2a6e10..ef7795c8c121 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -701,7 +701,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>
>   	spin_lock(&zone->lock);
>   	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
> -	if (nr_scanned)
> +	if (nr_scanned &&
> +	    zone_page_state(zone, NR_FREE_PAGES) > high_wmark_pages(zone))
>   		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
>
>   	while (to_free) {
> @@ -752,7 +753,8 @@ static void free_one_page(struct zone *zone,
>   	unsigned long nr_scanned;
>   	spin_lock(&zone->lock);
>   	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
> -	if (nr_scanned)
> +	if (nr_scanned &&
> +	    zone_page_state(zone, NR_FREE_PAGES) > high_wmark_pages(zone))
>   		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
>
>   	if (unlikely(has_isolate_pageblock(zone) ||
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
