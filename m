Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D5A136B0253
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 04:19:18 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id 20so13017883wmh.1
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 01:19:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id br5si15625171wjb.69.2016.04.01.01.19.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Apr 2016 01:19:18 -0700 (PDT)
Subject: Re: [PATCH v2 4/5] mm/page_owner: add zone range overlapping check
References: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459476406-28418-5-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FE2F0A.3000803@suse.cz>
Date: Fri, 1 Apr 2016 10:19:22 +0200
MIME-Version: 1.0
In-Reply-To: <1459476406-28418-5-git-send-email-iamjoonsoo.kim@lge.com>
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
> There are one place in page_owner.c that iterates pfn range and
> it doesn't consider this overlapping. Add it.
> 
> Without this patch, above system could over count early allocated
> page number before page_owner is activated.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_owner.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index ac3d8d1..438768c 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -301,6 +301,9 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  
>  			page = pfn_to_page(pfn);
>  
> +			if (page_zone(page) != zone)
> +				continue;
> +
>  			/*
>  			 * We are safe to check buddy flag and order, because
>  			 * this is init stage and only single thread runs.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
