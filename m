Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 87A396B0087
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 18:35:20 -0500 (EST)
Received: by iwn33 with SMTP id 33so2404725iwn.14
        for <linux-mm@kvack.org>; Sun, 05 Dec 2010 15:35:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291376734-30202-2-git-send-email-mel@csn.ul.ie>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie>
	<1291376734-30202-2-git-send-email-mel@csn.ul.ie>
Date: Mon, 6 Dec 2010 08:35:18 +0900
Message-ID: <AANLkTi=ZXBXS2m0WCTNWT1t6EFi=Vji5t-yQG=fTJQgs@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm: kswapd: Stop high-order balancing when any
 suitable zone is balanced
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Fri, Dec 3, 2010 at 8:45 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> When the allocator enters its slow path, kswapd is woken up to balance th=
e
> node. It continues working until all zones within the node are balanced. =
For
> order-0 allocations, this makes perfect sense but for higher orders it ca=
n
> have unintended side-effects. If the zone sizes are imbalanced, kswapd ma=
y
> reclaim heavily within a smaller zone discarding an excessive number of
> pages. The user-visible behaviour is that kswapd is awake and reclaiming
> even though plenty of pages are free from a suitable zone.
>
> This patch alters the "balance" logic for high-order reclaim allowing ksw=
apd
> to stop if any suitable zone becomes balanced to reduce the number of pag=
es
> it reclaims from other zones. kswapd still tries to ensure that order-0
> watermarks for all zones are met before sleeping.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

<snip>

> - =A0 =A0 =A0 if (!all_zones_ok) {
> + =A0 =A0 =A0 if (!(all_zones_ok || (order && any_zone_ok))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cond_resched();
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0try_to_freeze();
> @@ -2361,6 +2366,31 @@ out:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto loop_again;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If kswapd was reclaiming at a higher order, it has the=
 option of
> + =A0 =A0 =A0 =A0* sleeping without all zones being balanced. Before it d=
oes, it must
> + =A0 =A0 =A0 =A0* ensure that the watermarks for order-0 on *all* zones =
are met and
> + =A0 =A0 =A0 =A0* that the congestion flags are cleared
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (order) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i <=3D end_zone; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat=
->node_zones + i;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone->all_unreclaimable=
 && priority !=3D DEF_PRIORITY)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_clear_flag(zone, ZONE_=
CONGESTED);

Why clear ZONE_CONGESTED?
If you have a cause, please, write down the comment.

<snip>

First impression on this patch is that it changes scanning behavior as
well as reclaiming on high order reclaim.
I can't say old behavior is right but we can't say this behavior is
right, too although this patch solves the problem. At least, we might
need some data that shows this patch doesn't have a regression. It's
not easy but I believe you can do very well as like having done until
now. I didn't see whole series so I might miss something.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
