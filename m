Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5A66B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 23:21:10 -0500 (EST)
Received: by qyk10 with SMTP id 10so6941121qyk.14
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 20:21:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291172911.12777.58.camel@sli10-conroe>
References: <1291172911.12777.58.camel@sli10-conroe>
Date: Wed, 1 Dec 2010 13:21:07 +0900
Message-ID: <AANLkTi=whw86_7T0tVi5S8xmwS+Z3PDE_AbXEJSQFqR4@mail.gmail.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 1, 2010 at 12:08 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> T0: Task1 wakeup_kswapd(order=3D3)
> T1: kswapd enters balance_pgdat
> T2: Task2 wakeup_kswapd(order=3D2), because pages reclaimed by kswapd are=
 used
> quickly
> T3: kswapd exits balance_pgdat. kswapd will do check. Now new order=3D2,
> pgdat->kswapd_max_order will become 0, but order=3D3, if sleeping_prematu=
rely,
> then order will become pgdat->kswapd_max_order(0), while at this time the
> order should 2
> This isn't a big deal, but we do have a small window the order is wrong.
>
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmai.com>

But you need the description more easily.

I try it.

T0 : Task 1 wakes up kswapd with order-3
T1 : So, kswapd starts to reclaim pages using balance_pgdat
T2:  Task 2 wakes up kswapd with order-2 because pages reclaimed by T1
are consumed quickly.
T3: kswapd exits balance_pgdat and will recheck remained work
T4-1 : In beginning of kswapd's loop, pgdat->kswapd_max_order will be
reset with zero.
T4-2: If previous balance_pgdat can't meet requirement of order-3 free
pages by high watermark, it can start reclaiming again.
T4-3 :Unfortunately, balance_pgdat's argument _order_ is
pgdat->kswapd_max_order which was zero.  It should have been 2.

Regardless of my suggestion, I will add my Reviewed-by.

>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d31d7ce..15cd0d2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2450,7 +2450,7 @@ static int kswapd(void *p)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgdat->kswapd_max=
_order;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D max_t(unsigned lo=
ng, new_order, pgdat->kswapd_max_order);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0finish_wait(&pgdat->kswapd_wait, &wait);
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
