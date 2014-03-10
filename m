Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6D06B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 11:29:13 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id u56so8798564wes.9
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 08:29:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pl10si2994932wic.8.2014.03.10.08.29.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 08:29:12 -0700 (PDT)
Message-ID: <531DDA46.5050803@suse.cz>
Date: Mon, 10 Mar 2014 16:29:10 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch] mm, compaction: determine isolation mode only once
References: <alpine.DEB.2.02.1403070358120.13046@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1403070358120.13046@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/07/2014 01:01 PM, David Rientjes wrote:
> The conditions that control the isolation mode in
> isolate_migratepages_range() do not change during the iteration, so
> extract them out and only define the value once.
>
> This actually does have an effect, gcc doesn't optimize it itself because
> of cc->sync.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/compaction.c | 9 ++-------
>   1 file changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -454,12 +454,13 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   	unsigned long last_pageblock_nr = 0, pageblock_nr;
>   	unsigned long nr_scanned = 0, nr_isolated = 0;
>   	struct list_head *migratelist = &cc->migratepages;
> -	isolate_mode_t mode = 0;
>   	struct lruvec *lruvec;
>   	unsigned long flags;
>   	bool locked = false;
>   	struct page *page = NULL, *valid_page = NULL;
>   	bool skipped_async_unsuitable = false;
> +	const isolate_mode_t mode = (!cc->sync ? ISOLATE_ASYNC_MIGRATE : 0) |
> +				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
>
>   	/*
>   	 * Ensure that there are not too many pages isolated from the LRU
> @@ -592,12 +593,6 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   			continue;
>   		}
>
> -		if (!cc->sync)
> -			mode |= ISOLATE_ASYNC_MIGRATE;
> -
> -		if (unevictable)
> -			mode |= ISOLATE_UNEVICTABLE;
> -
>   		lruvec = mem_cgroup_page_lruvec(page, zone);
>
>   		/* Try isolate the page */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
