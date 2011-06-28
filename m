Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B4A849000BD
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:49:46 -0400 (EDT)
Date: Tue, 28 Jun 2011 14:49:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] mm: vmscan: Correct check for kswapd sleeping in
 sleeping_prematurely
Message-Id: <20110628144900.b33412c6.akpm@linux-foundation.org>
In-Reply-To: <1308926697-22475-2-git-send-email-mgorman@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
	<1308926697-22475-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: =?ISO-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, 24 Jun 2011 15:44:54 +0100
Mel Gorman <mgorman@suse.de> wrote:

> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.
>=20
> A problem occurs if the highest zone is small.  balance_pgdat()
> only considers unreclaimable zones when priority is DEF_PRIORITY
> but sleeping_prematurely considers all zones. It's possible for this
> sequence to occur
>=20
>   1. kswapd wakes up and enters balance_pgdat()
>   2. At DEF_PRIORITY, marks highest zone unreclaimable
>   3. At DEF_PRIORITY-1, ignores highest zone setting end_zone
>   4. At DEF_PRIORITY-1, calls shrink_slab freeing memory from
>         highest zone, clearing all_unreclaimable. Highest zone
>         is still unbalanced
>   5. kswapd returns and calls sleeping_prematurely
>   6. sleeping_prematurely looks at *all* zones, not just the ones
>      being considered by balance_pgdat. The highest small zone
>      has all_unreclaimable cleared but but the zone is not
>      balanced. all_zones_ok is false so kswapd stays awake
>=20
> This patch corrects the behaviour of sleeping_prematurely to check
> the zones balance_pgdat() checked.

But kswapd is making progress: it's reclaiming slab.  Eventually that
won't work any more and all_unreclaimable will not be cleared and the
condition will fix itself up?



btw,

	if (!sleeping_prematurely(...))
		sleep();

hurts my brain.  My brain would prefer

	if (kswapd_should_sleep(...))
		sleep();

no?

> Reported-and-tested-by: P=E1draig Brady <P@draigBrady.com>

But what were the before-and-after observations?  I don't understand
how this can cause a permanent cpuchew by kswapd.

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2323,7 +2323,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, =
int order, long remaining,
>  		return true;
> =20
>  	/* Check the watermark levels */
> -	for (i =3D 0; i < pgdat->nr_zones; i++) {
> +	for (i =3D 0; i <=3D classzone_idx; i++) {
>  		struct zone *zone =3D pgdat->node_zones + i;
> =20
>  		if (!populated_zone(zone))

The patch looks sensible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
