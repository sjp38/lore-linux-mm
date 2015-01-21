Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2C74E6B006E
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 05:01:12 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so34728370wib.5
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 02:01:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id op9si38141208wjc.165.2015.01.21.02.01.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 02:01:10 -0800 (PST)
Message-ID: <54BF78E3.7030303@suse.cz>
Date: Wed, 21 Jan 2015 11:01:07 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: compaction: fix the page state calculation in too_many_isolated
References: <1421832864-30643-1-git-send-email-vinmenon@codeaurora.org>
In-Reply-To: <1421832864-30643-1-git-send-email-vinmenon@codeaurora.org>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, minchan@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com

On 01/21/2015 10:34 AM, Vinayak Menon wrote:
> Commit "3611badc1baa" (mm: vmscan: fix the page state calculation in

That appears to be a -next commit ID, which won't be the same in Linus' tree, so
it shouldn't be in commit message, AFAIK.

> too_many_isolated) fixed an issue where a number of tasks were
> blocked in reclaim path for seconds, because of vmstat_diff not being
> synced in time. A similar problem can happen in isolate_migratepages_block,
> similar calculation is performed. This patch fixes that.

I guess it's not possible to fix the stats instantly and once in the safe
versions, so that future readings will be correct without safe, right?
So until it gets fixed, each reading will have to be safe and thus expensive?

I think in case of async compaction, we could skip the safe stuff and just
terminate it - it's already done when too_many_isolated returns true, and
there's no congestion waiting in that case.

So you could extend the too_many_isolated() with "safe" parameter (as you did
for vmscan) and pass it "cc->mode != MIGRATE_ASYNC" value from
isolate_migrate_block().

> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> ---
>  mm/compaction.c | 32 +++++++++++++++++++++++++++-----
>  1 file changed, 27 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 546e571..2d9730d 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -537,21 +537,43 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
>  	mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
>  }
>  
> -/* Similar to reclaim, but different enough that they don't share logic */
> -static bool too_many_isolated(struct zone *zone)
> +static bool __too_many_isolated(struct zone *zone, int safe)
>  {
>  	unsigned long active, inactive, isolated;
>  
> -	inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
> +	if (safe) {
> +		inactive = zone_page_state_snapshot(zone, NR_INACTIVE_FILE) +
> +			zone_page_state_snapshot(zone, NR_INACTIVE_ANON);
> +		active = zone_page_state_snapshot(zone, NR_ACTIVE_FILE) +
> +			zone_page_state_snapshot(zone, NR_ACTIVE_ANON);
> +		isolated = zone_page_state_snapshot(zone, NR_ISOLATED_FILE) +
> +			zone_page_state_snapshot(zone, NR_ISOLATED_ANON);
> +	} else {
> +		inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
>  					zone_page_state(zone, NR_INACTIVE_ANON);

Nit: could you ident the line above (and the other 2 below) the same way as they
are in the if (safe) part?

Thanks!

> -	active = zone_page_state(zone, NR_ACTIVE_FILE) +
> +		active = zone_page_state(zone, NR_ACTIVE_FILE) +
>  					zone_page_state(zone, NR_ACTIVE_ANON);
> -	isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
> +		isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
>  					zone_page_state(zone, NR_ISOLATED_ANON);
> +	}
>  
>  	return isolated > (inactive + active) / 2;
>  }
>  
> +/* Similar to reclaim, but different enough that they don't share logic */
> +static bool too_many_isolated(struct zone *zone)
> +{
> +	/*
> +	 * __too_many_isolated(safe=0) is fast but inaccurate, because it
> +	 * doesn't account for the vm_stat_diff[] counters.  So if it looks
> +	 * like too_many_isolated() is about to return true, fall back to the
> +	 * slower, more accurate zone_page_state_snapshot().
> +	 */
> +	if (unlikely(__too_many_isolated(zone, 0)))
> +		return __too_many_isolated(zone, 1);
> +	return 0;
> +}
> +
>  /**
>   * isolate_migratepages_block() - isolate all migrate-able pages within
>   *				  a single pageblock
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
