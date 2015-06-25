Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 24A496B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 05:08:35 -0400 (EDT)
Received: by wguu7 with SMTP id u7so56721500wgu.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 02:08:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8si51616473wjw.93.2015.06.25.02.08.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 02:08:33 -0700 (PDT)
Message-ID: <558BC50E.3030000@suse.cz>
Date: Thu, 25 Jun 2015 11:08:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 03/10] mm/compaction: always update cached pfn
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com> <1435193121-25880-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

I can has commit log? :)

On 06/25/2015 02:45 AM, Joonsoo Kim wrote:
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/compaction.c | 11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9c5d43c..2d8e211 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -510,6 +510,10 @@ isolate_fail:
>   	if (locked)
>   		spin_unlock_irqrestore(&cc->zone->lock, flags);
>
> +	if (blockpfn == end_pfn &&
> +		blockpfn > cc->zone->compact_cached_free_pfn)
> +		cc->zone->compact_cached_free_pfn = blockpfn;
> +
>   	update_pageblock_skip(cc, valid_page, total_isolated,
>   			*start_pfn, end_pfn, blockpfn, false);
>
> @@ -811,6 +815,13 @@ isolate_success:
>   	if (locked)
>   		spin_unlock_irqrestore(&zone->lru_lock, flags);
>
> +	if (low_pfn == end_pfn && cc->mode != MIGRATE_ASYNC) {
> +		int sync = cc->mode != MIGRATE_ASYNC;
> +
> +		if (low_pfn > zone->compact_cached_migrate_pfn[sync])
> +			zone->compact_cached_migrate_pfn[sync] = low_pfn;
> +	}
> +
>   	update_pageblock_skip(cc, valid_page, nr_isolated,
>   			start_pfn, end_pfn, low_pfn, true);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
