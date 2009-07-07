Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D38EC6B004D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 19:35:04 -0400 (EDT)
Received: by yxe38 with SMTP id 38so3310399yxe.12
        for <linux-mm@kvack.org>; Tue, 07 Jul 2009 16:39:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090707184034.0C70.A69D9226@jp.fujitsu.com>
References: <20090707182947.0C6D.A69D9226@jp.fujitsu.com>
	 <20090707184034.0C70.A69D9226@jp.fujitsu.com>
Date: Wed, 8 Jul 2009 08:39:12 +0900
Message-ID: <28c262360907071639g4877b2c2w59a8eae8559557f7@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] vmscan don't isolate too many pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 7, 2009 at 6:47 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> Subject: [PATCH] vmscan don't isolate too many pages
>
> If the system have plenty threads or processes, concurrent reclaim can
> isolate very much pages.
>
> And if other processes isolate _all_ pages on lru, the reclaimer can't fi=
nd
> any reclaimable page and it makes accidental OOM.
>
> The solusion is, we should restrict maximum number of isolated pages.
> (this patch use inactive_page/2)
>
>
> FAQ
> -------
> Q: Why do you compared zone accumulate pages, not individual zone pages?
> A: If we check individual zone, #-of-reclaimer is restricted by smallest =
zone.
> =C2=A0 it mean decreasing the performance of the system having small dma =
zone.
>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =C2=A0mm/page_alloc.c | =C2=A0 27 +++++++++++++++++++++++++++
> =C2=A01 file changed, 27 insertions(+)
>
> Index: b/mm/page_alloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1721,6 +1721,28 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return alloc_flags;
> =C2=A0}
>
> +static bool too_many_isolated(struct zonelist *zonelist,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 enum zone_type high_zoneidx, nodemask_t *nodema=
sk)
> +{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long nr_inactive =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long nr_isolated =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 struct zoneref *z;
> + =C2=A0 =C2=A0 =C2=A0 struct zone *zone;
> +
> + =C2=A0 =C2=A0 =C2=A0 for_each_zone_zonelist_nodemask(zone, z, zonelist,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 high_zoneidx=
, nodemask) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!populated_zone(zo=
ne))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_inactive +=3D zone_=
page_state(zone, NR_INACTIVE_ANON);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_inactive +=3D zone_=
page_state(zone, NR_INACTIVE_FILE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_isolated +=3D zone_=
page_state(zone, NR_ISOLATED_ANON);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_isolated +=3D zone_=
page_state(zone, NR_ISOLATED_FILE);
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 return nr_isolated > nr_inactive;
> +}
> +
> =C2=A0static inline struct page *
> =C2=A0__alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zonelist *zonelist, enum zone_type high=
_zoneidx,
> @@ -1789,6 +1811,11 @@ rebalance:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (p->flags & PF_MEMALLOC)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto nopage;
>
> + =C2=A0 =C2=A0 =C2=A0 if (too_many_isolated(gfp_mask, zonelist, high_zon=
eidx, nodemask)) {

too_many_isolated(zonelist, high_zoneidx, nodemask)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
