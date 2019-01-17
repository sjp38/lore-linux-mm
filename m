Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5AC68E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:01:21 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c34so3850987edb.8
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:01:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2-v6si3603583ejc.189.2019.01.17.09.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 09:01:20 -0800 (PST)
Subject: Re: [PATCH 16/25] mm, compaction: Check early for huge pages
 encountered by the migration scanner
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-17-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <724b7599-8300-15b5-2675-eecab2450f45@suse.cz>
Date: Thu, 17 Jan 2019 18:01:18 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-17-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:50 PM, Mel Gorman wrote:
> When scanning for sources or targets, PageCompound is checked for huge
> pages as they can be skipped quickly but it happens relatively late after
> a lot of setup and checking. This patch short-cuts the check to make it
> earlier. It might still change when the lock is acquired but this has
> less overhead overall. The free scanner advances but the migration scanner
> does not. Typically the free scanner encounters more movable blocks that
> change state over the lifetime of the system and also tends to scan more
> aggressively as it's actively filling its portion of the physical address
> space with data. This could change in the future but for the moment,
> this worked better in practice and incurred fewer scan restarts.
> 
> The impact on latency and allocation success rates is marginal but the
> free scan rates are reduced by 32% and system CPU usage is reduced by
> 2.6%. The 2-socket results are not materially different.

Hmm, interesting that adjusting migrate scanner affected free scanner. Oh well.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Nit below.

> ---
>  mm/compaction.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 608d274f9880..921720f7a416 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1071,6 +1071,9 @@ static bool suitable_migration_source(struct compact_control *cc,
>  {
>  	int block_mt;
>  
> +	if (pageblock_skip_persistent(page))
> +		return false;
> +
>  	if ((cc->mode != MIGRATE_ASYNC) || !cc->direct_compaction)
>  		return true;
>  
> @@ -1693,12 +1696,17 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  			continue;
>  
>  		/*
> -		 * For async compaction, also only scan in MOVABLE blocks.
> -		 * Async compaction is optimistic to see if the minimum amount
> -		 * of work satisfies the allocation.
> +		 * For async compaction, also only scan in MOVABLE blocks
> +		 * without huge pages. Async compaction is optimistic to see
> +		 * if the minimum amount of work satisfies the allocation.
> +		 * The cached PFN is updated as it's possible that all
> +		 * remaining blocks between source and target are suitable

								  ^ unsuitable?

> +		 * and the compaction scanners fail to meet.
>  		 */
> -		if (!suitable_migration_source(cc, page))
> +		if (!suitable_migration_source(cc, page)) {
> +			update_cached_migrate(cc, block_end_pfn);
>  			continue;
> +		}
>  
>  		/* Perform the isolation */
>  		low_pfn = isolate_migratepages_block(cc, low_pfn,
> 
