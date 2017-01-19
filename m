Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBF3A6B0290
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 05:47:17 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id yr2so7596616wjc.4
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 02:47:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c48si3920211wra.290.2017.01.19.02.47.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 02:47:16 -0800 (PST)
Subject: Re: [RFC PATCH 1/5] mm/vmstat: retrieve suitable free pageblock
 information just once
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1484291673-2239-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <123434e3-1d63-6ba7-1bdb-7bb66b4619a6@suse.cz>
Date: Thu, 19 Jan 2017 11:47:09 +0100
MIME-Version: 1.0
In-Reply-To: <1484291673-2239-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/13/2017 08:14 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> It's inefficient to retrieve buddy information for fragmentation index
> calculation on every order. By using some stack memory, we could retrieve
> it once and reuse it to compute all the required values. MAX_ORDER is
> usually small enough so there is no big risk about stack overflow.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Sounds useful regardless of the rest of the series.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

A nit below.

> ---
>  mm/vmstat.c | 25 ++++++++++++-------------
>  1 file changed, 12 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7c28df3..e1ca5eb 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -821,7 +821,7 @@ unsigned long node_page_state(struct pglist_data *pgdat,
>  struct contig_page_info {
>  	unsigned long free_pages;
>  	unsigned long free_blocks_total;
> -	unsigned long free_blocks_suitable;
> +	unsigned long free_blocks_order[MAX_ORDER];

No need to rename _suitable to _order IMHO. The meaning is still the
same, it's just an array now. For me a name "free_blocks_order" would
suggest it's just simple zone->free_area[order].nr_free.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
