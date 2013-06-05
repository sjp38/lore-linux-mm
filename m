Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 5C4296B0032
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 16:04:29 -0400 (EDT)
Message-ID: <51AF99C5.9010508@redhat.com>
Date: Wed, 05 Jun 2013 16:04:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] mm: compaction: reset before initializing the scan
 cursors
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1370445037-24144-5-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On 06/05/2013 11:10 AM, Andrea Arcangeli wrote:
> Otherwise the first iteration of compaction after restarting it, will
> only do a partial scan.

Changelog could be a little more verbose :)

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

>   mm/compaction.c | 19 +++++++++++--------
>   1 file changed, 11 insertions(+), 8 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 525baaa..afaf692 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -934,6 +934,17 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   	}
>
>   	/*
> +	 * Clear pageblock skip if there were failures recently and
> +	 * compaction is about to be retried after being
> +	 * deferred. kswapd does not do this reset and it will wait
> +	 * direct compaction to do so either when the cursor meets
> +	 * after one compaction pass is complete or if compaction is
> +	 * restarted after being deferred for a while.
> +	 */
> +	if ((compaction_restarting(zone, cc->order)) && !current_is_kswapd())
> +		__reset_isolation_suitable(zone);
> +
> +	/*
>   	 * Setup to move all movable pages to the end of the zone. Used cached
>   	 * information on where the scanners should start but check that it
>   	 * is initialised by ensuring the values are within zone boundaries.
> @@ -949,14 +960,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   		zone->compact_cached_migrate_pfn = cc->migrate_pfn;
>   	}
>
> -	/*
> -	 * Clear pageblock skip if there were failures recently and compaction
> -	 * is about to be retried after being deferred. kswapd does not do
> -	 * this reset as it'll reset the cached information when going to sleep.
> -	 */
> -	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
> -		__reset_isolation_suitable(zone);
> -
>   	migrate_prep_local();
>
>   	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
