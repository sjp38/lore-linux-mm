Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 76ECF6B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 21:20:26 -0400 (EDT)
Message-ID: <514A604E.40303@redhat.com>
Date: Wed, 20 Mar 2013 21:20:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] mm: vmscan: Do not allow kswapd to scan at maximum
 priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1363525456-10448-6-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/17/2013 09:04 AM, Mel Gorman wrote:
> Page reclaim at priority 0 will scan the entire LRU as priority 0 is
> considered to be a near OOM condition. Kswapd can reach priority 0 quite
> easily if it is encountering a large number of pages it cannot reclaim
> such as pages under writeback. When this happens, kswapd reclaims very
> aggressively even though there may be no real risk of allocation failure
> or OOM.
>
> This patch prevents kswapd reaching priority 0 and trying to reclaim
> the world. Direct reclaimers will still reach priority 0 in the event
> of an OOM situation.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>   mm/vmscan.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7513bd1..af3bb6f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2891,7 +2891,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>   		 */
>   		if (raise_priority || !this_reclaimed)
>   			sc.priority--;
> -	} while (sc.priority >= 0 &&
> +	} while (sc.priority >= 1 &&
>   		 !pgdat_balanced(pgdat, order, *classzone_idx));
>
>   out:
>

If priority 0 is way way way way way too aggressive, what makes
priority 1 safe?

This makes me wonder, are the priorities useful at all to kswapd?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
