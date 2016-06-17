Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB756B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:55:14 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id c1so20503987lbw.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:55:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si6026778wml.43.2016.06.17.03.55.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 03:55:13 -0700 (PDT)
Subject: Re: [PATCH 22/27] mm: Convert zone_reclaim to node_reclaim
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-23-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <75031785-fd9b-8ed2-54ae-c12874d3df5f@suse.cz>
Date: Fri, 17 Jun 2016 12:55:11 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-23-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> As reclaim is now per-node based, convert zone_reclaim to be node_reclaim.
> It is possible that a node will be reclaimed multiple times if it has
> multiple zones but this is unavoidable without caching all nodes traversed
> so far.  The documentation and interface to userspace is the same from
> a configuration perspective and will will be similar in behaviour unless
> the node-local allocation requests were also limited to lower zones.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

[...]

> @@ -682,6 +674,14 @@ typedef struct pglist_data {
>  	 */
>  	unsigned long		totalreserve_pages;
>
> +#ifdef CONFIG_NUMA
> +	/*
> +	 * zone reclaim becomes active if more unmapped pages exist.

            node reclaim

> +	 */
> +	unsigned long		min_unmapped_pages;
> +	unsigned long		min_slab_pages;
> +#endif /* CONFIG_NUMA */
> +
>  	/* Write-intensive fields used from the page allocator */
>  	ZONE_PADDING(_pad1_)
>  	spinlock_t		lru_lock;

[...]

> @@ -3580,7 +3580,7 @@ static inline unsigned long node_unmapped_file_pages(struct pglist_data *pgdat)
>  }
>
>  /* Work out how many page cache pages we can reclaim in this reclaim_mode */
> -static unsigned long zone_pagecache_reclaimable(struct zone *zone)
> +static unsigned long zone_pagecache_reclaimable(struct pglist_data *pgdat)

Rename to node_pagecache_reclaimable?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
