Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2D56B0062
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:39:55 -0500 (EST)
Date: Wed, 25 Nov 2009 21:35:09 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: do not evict inactive pages when skipping an active list scan
Message-ID: <20091125203509.GA18018@cmpxchg.org>
References: <20091125133752.2683c3e4@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091125133752.2683c3e4@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, kosaki.motohiro@fujitsu.co.jp, Tomasz Chmielewski <mangoo@wpkg.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hello all,

On Wed, Nov 25, 2009 at 01:37:52PM -0500, Rik van Riel wrote:
> In AIM7 runs, recent kernels start swapping out anonymous pages
> well before they should.  This is due to shrink_list falling
> through to shrink_inactive_list if !inactive_anon_is_low(zone, sc),
> when all we really wanted to do is pre-age some anonymous pages to
> give them extra time to be referenced while on the inactive list.

I do not quite understand what changed 'recently'.

That fall-through logic to keep eating inactives when the ratio is off
came in a year ago with the second-chance-for-anon-pages patch..?

> The obvious fix is to make sure that shrink_list does not fall
> through to scanning/reclaiming inactive pages when we called it
> to scan one of the active lists.
>
> This change should be safe because the loop in shrink_zone ensures
> that we will still shrink the anon and file inactive lists whenever
> we should.

It was not so obvious to me ;)

At first, I thought it would make sense to actively rebalance between
the lists if the inactive one grows too large (the fall-through case).

But shrink_zone() does not know about this and although we scan
inactive pages, we do not account for them and decrease the 'nr[lru]'
for active pages instead, effectively shifting the 'active todo' over
to the 'inactive todo'.  I can imagine this going wrong!

So I agree, we should use the inactive_*_is_low() predicate only
passively.
 
> Reported-by: Larry Woodman <lwoodman@redhat.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 777af57..ec4dfda 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1469,13 +1469,15 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  {
>  	int file = is_file_lru(lru);
>  
> -	if (lru == LRU_ACTIVE_FILE && inactive_file_is_low(zone, sc)) {
> -		shrink_active_list(nr_to_scan, zone, sc, priority, file);
> +	if (lru == LRU_ACTIVE_FILE) {
> +		if (inactive_file_is_low(zone, sc))
> +		      shrink_active_list(nr_to_scan, zone, sc, priority, file);
>  		return 0;
>  	}
>  
> -	if (lru == LRU_ACTIVE_ANON && inactive_anon_is_low(zone, sc)) {
> -		shrink_active_list(nr_to_scan, zone, sc, priority, file);
> +	if (lru == LRU_ACTIVE_ANON) {
> +		if (inactive_file_is_low(zone, sc))
> +		      shrink_active_list(nr_to_scan, zone, sc, priority, file);
>  		return 0;
>  	}
>  	return shrink_inactive_list(nr_to_scan, zone, sc, priority, file);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
