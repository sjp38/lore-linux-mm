Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F17926B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 20:56:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7V0ufds022008
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 31 Aug 2010 09:56:41 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 04A2A45DE7B
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 09:56:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCBE045DE79
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 09:56:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE9A21DB8041
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 09:56:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 43B531DB803A
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 09:56:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
In-Reply-To: <AANLkTinqm0o=AfmgFy+SpZ1mrdekRnjeXvs_7=OcLii8@mail.gmail.com>
References: <AANLkTi==mQh31PzuNa1efH2WM1s-VPKyZX0f5iwb54PD@mail.gmail.com> <AANLkTinqm0o=AfmgFy+SpZ1mrdekRnjeXvs_7=OcLii8@mail.gmail.com>
Message-Id: <20100831095140.87C7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 31 Aug 2010 09:56:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Sun, Aug 29, 2010 at 5:18 PM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
> > Hi Ying,
> >
> > On Mon, Aug 30, 2010 at 6:23 AM, Ying Han <yinghan@google.com> wrote:
> >> On Sun, Aug 29, 2010 at 1:03 PM, Rik van Riel <riel@redhat.com> wrote:
> >>> On 08/29/2010 01:45 PM, Ying Han wrote:
> >>>
> >>>> There are few other places in vmscan where we check nr_swap_pages an=
d
> >>>> inactive_anon_is_low. Are we planning to change them to use
> >>>> total_swap_pages
> >>>> to be consistent ?
> >>>
> >>> If that makes sense, maybe the check can just be moved into
> >>> inactive_anon_is_low itself?
> >>
> >> That was the initial patch posted, instead we changed to use
> >> total_swap_pages instead. How this patch looks:
> >>
> >> @@ -1605,6 +1605,9 @@ static int inactive_anon_is_low(struct zone
> >> *zone, struct scan_control *sc)
> >> =A0{
> >> =A0 =A0 =A0 =A0int low;
> >>
> >> + =A0 =A0 =A0 if (total_swap_pages <=3D 0)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> >> +
> >> =A0 =A0 =A0 =A0if (scanning_global_lru(sc))
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0low =3D inactive_anon_is_low_global(zon=
e);
> >> =A0 =A0 =A0 =A0else
> >> @@ -1856,7 +1859,7 @@ static void shrink_zone(int priority, struct zon=
e *zone,
> >> =A0 =A0 =A0 =A0 * Even if we did not try to evict anon pages at all, w=
e want to
> >> =A0 =A0 =A0 =A0 * rebalance the anon lru active/inactive ratio.
> >> =A0 =A0 =A0 =A0 */
> >> - =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> >> + =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc))
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_active_list(SWAP_CLUSTER_MAX, zo=
ne, sc, priority, 0);
> >>
> >> =A0 =A0 =A0 =A0throttle_vm_writeout(sc->gfp_mask);
> >>
> >> --Ying
> >>
> >>>
> >
> > I did it intentionally since inactive_anon_is_low have been used both
> > direct reclaim and background path. In this point, your patch could
> > make side effect in swap enabled system when swap is full.
> >
> > I think we need aging in only background if system is swap full.
> > That's because if the swap space is full, we don't reclaim anon pages
> > in direct reclaim path with (nr_swap_pages < 0) =A0and even have been
> > not rebalance it until now.
> > I think direct reclaim path is important about latency as well as
> > reclaim's effectiveness.
> > So if you don't mind, I hope direct reclaim patch would be left just as=
 it is.
>=20
> Minchan, I would prefer to make kswapd as well as direct reclaim to be
> consistent if possible.
> They both try to reclaim pages when system is under memory pressure,
> and also do not make
> much sense to look at anon lru if no swap space available. Either
> because of no swapon or run
> out of swap space.
>=20
> I think letting kswapd to age anon lru without free swap space is not
> necessary neither. That leads
> to my initial patch:
>=20
> @@ -1605,6 +1605,9 @@ static int inactive_anon_is_low(struct zone
> *zone, struct scan_control *sc)
>  {
>        int low;
>=20
> +       if (nr_swap_pages <=3D 0)
> +               return 0;
> +
>        if (scanning_global_lru(sc))
>                low =3D inactive_anon_is_low_global(zone);
>        else
> @@ -1856,7 +1859,7 @@ static void shrink_zone(int priority, struct zone *=
zone,
>         * Even if we did not try to evict anon pages at all, we want to
>         * rebalance the anon lru active/inactive ratio.
>         */
> -       if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> +       if (inactive_anon_is_low(zone, sc))
>                shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0=
);
>=20
> What do you think ?

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


I think both Ying's and Minchan's opnion are right and makes sense.  howeve=
r I _personally_
like Ying version because 1) this version is simpler 2) swap full is very r=
arely event 3)
no swap mounting is very common on HPC. so this version could have a chance=
 to=20
improvement hpc workload too.

In the other word, both avoiding unnecessary TLB flush and keeping proper p=
age aging are
performance matter. so when we are talking performance, we always need to t=
hink frequency
of the event.

Anyway I'm very glad minchan who embedded developer pay attention server wo=
rkload
carefully. Very thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
