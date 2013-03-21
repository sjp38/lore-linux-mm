Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 33DC86B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 11:48:12 -0400 (EDT)
Date: Thu, 21 Mar 2013 16:48:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 05/10] mm: vmscan: Do not allow kswapd to scan at maximum
 priority
Message-ID: <20130321154810.GR6094@dhcp22.suse.cz>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363525456-10448-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Sun 17-03-13 13:04:11, Mel Gorman wrote:
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

OK, it should work. raise_priority should prevent from pointless
lowerinng the priority and if there is really nothing to reclaim then
relying on the direct reclaim is probably a better idea.

> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7513bd1..af3bb6f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2891,7 +2891,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  		 */
>  		if (raise_priority || !this_reclaimed)
>  			sc.priority--;
> -	} while (sc.priority >= 0 &&
> +	} while (sc.priority >= 1 &&
>  		 !pgdat_balanced(pgdat, order, *classzone_idx));
>  
>  out:
> -- 
> 1.8.1.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
