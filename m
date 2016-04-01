Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3FD6B025E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 04:19:27 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id 191so11303965wmq.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 01:19:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r124si16384520wma.9.2016.04.01.01.19.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Apr 2016 01:19:26 -0700 (PDT)
Subject: Re: [PATCH v2 5/5] power: add zone range overlapping check
References: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459476406-28418-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FE2F11.2090406@suse.cz>
Date: Fri, 1 Apr 2016 10:19:29 +0200
MIME-Version: 1.0
In-Reply-To: <1459476406-28418-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 1.4.2016 4:06, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> There is a system that node's pfn are overlapped like as following.
> 
> -----pfn-------->
> N0 N1 N2 N0 N1 N2
> 
> Therefore, we need to care this overlapping when iterating pfn range.
> 
> mark_free_pages() iterates requested zone's pfn range and unset
> all range's bitmap first. And then it marks freepages in a zone
> to the bitmap. If there is an overlapping zone, above unset could
> clear previous marked bit and reference to this bitmap in the future
> will cause the problem. To prevent it, this patch adds a zone check
> in mark_free_pages().
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0cfee62..437a934 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2156,6 +2156,10 @@ void mark_free_pages(struct zone *zone)
>  	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
>  		if (pfn_valid(pfn)) {
>  			page = pfn_to_page(pfn);
> +
> +			if (page_zone(page) != zone)
> +				continue;
> +
>  			if (!swsusp_page_is_forbidden(page))
>  				swsusp_unset_page_free(page);
>  		}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
