Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 352696B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 05:33:10 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x12so2088281wgg.1
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 02:33:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rz17si2057476wjb.88.2014.02.07.02.33.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 02:33:09 -0800 (PST)
Message-ID: <52F4B662.5070809@suse.cz>
Date: Fri, 07 Feb 2014 11:33:06 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm/compaction: clean-up code on success of ballon
 isolation
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com> <1391749726-28910-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391749726-28910-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/07/2014 06:08 AM, Joonsoo Kim wrote:
> It is just for clean-up to reduce code size and improve readability.
> There is no functional change.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 985b782..7a4e3b7 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -554,11 +554,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			if (unlikely(balloon_page_movable(page))) {
>  				if (locked && balloon_page_isolate(page)) {
>  					/* Successfully isolated */
> -					cc->finished_update_migrate = true;
> -					list_add(&page->lru, migratelist);
> -					cc->nr_migratepages++;
> -					nr_isolated++;
> -					goto check_compact_cluster;
> +					goto isolate_success;
>  				}
>  			}
>  			continue;
> @@ -610,13 +606,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  		VM_BUG_ON(PageTransCompound(page));
>  
>  		/* Successfully isolated */
> -		cc->finished_update_migrate = true;
>  		del_page_from_lru_list(page, lruvec, page_lru(page));
> +
> +isolate_success:
> +		cc->finished_update_migrate = true;
>  		list_add(&page->lru, migratelist);
>  		cc->nr_migratepages++;
>  		nr_isolated++;
>  
> -check_compact_cluster:
>  		/* Avoid isolating too much */
>  		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
>  			++low_pfn;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
