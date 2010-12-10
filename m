Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 537066B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 20:16:21 -0500 (EST)
Received: by iwn1 with SMTP id 1so4646400iwn.37
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 17:16:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291893500-12342-4-git-send-email-mel@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
	<1291893500-12342-4-git-send-email-mel@csn.ul.ie>
Date: Fri, 10 Dec 2010 10:16:19 +0900
Message-ID: <AANLkTi=2LYh04DMagfEQ6dtsfrzzLtopPG--BW+SGtpy@mail.gmail.com>
Subject: Re: [PATCH 3/6] mm: kswapd: Use the order that kswapd was reclaiming
 at for sleeping_prematurely()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 8:18 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> Before kswapd goes to sleep, it uses sleeping_prematurely() to check if
> there was a race pushing a zone below its watermark. If the race
> happened, it stays awake. However, balance_pgdat() can decide to reclaim
> at a lower order if it decides that high-order reclaim is not working as

Could you specify "order-0" explicitly instead of "a lower order"?
It makes more clear to me.

> expected. This information is not passed back to sleeping_prematurely().
> The impact is that kswapd remains awake reclaiming pages long after it
> should have gone to sleep. This patch passes the adjusted order to
> sleeping_prematurely and uses the same logic as balance_pgdat to decide
> if it's ok to go to sleep.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

A comment below.

> ---
> =A0mm/vmscan.c | =A0 14 ++++++++++----
> =A01 files changed, 10 insertions(+), 4 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b4472a1..52e229e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2132,7 +2132,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsign=
ed long balanced)
> =A0}
>
> =A0/* is kswapd sleeping prematurely? */
> -static int sleeping_prematurely(pg_data_t *pgdat, int order, long remain=
ing)
> +static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remai=
ning)
> =A0{
> =A0 =A0 =A0 =A0int i;
> =A0 =A0 =A0 =A0unsigned long balanced =3D 0;
> @@ -2142,7 +2142,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, i=
nt order, long remaining)
> =A0 =A0 =A0 =A0if (remaining)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
>
> - =A0 =A0 =A0 /* If after HZ/10, a zone is below the high mark, it's prem=
ature */
> + =A0 =A0 =A0 /* Check the watermark levels */
> =A0 =A0 =A0 =A0for (i =3D 0; i < pgdat->nr_zones; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone =3D pgdat->node_zones + =
i;
>
> @@ -2427,7 +2427,13 @@ out:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 return sc.nr_reclaimed;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Return the order we were reclaiming at so sleeping_pre=
maturely()
> + =A0 =A0 =A0 =A0* makes a decision on the order we were last reclaiming =
at. However,
> + =A0 =A0 =A0 =A0* if another caller entered the allocator slow path whil=
e kswapd
> + =A0 =A0 =A0 =A0* was awake, order will remain at the higher level
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 return order;
> =A0}

Please change return value description of balance_pgdat.
"Returns the number of pages which were actually freed"


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
