Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A39618D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 20:54:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2B7903EE0C2
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:54:00 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EE97645DE97
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:53:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3C0E45DE92
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:53:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BE7FEE18007
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:53:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E2721DB803E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:53:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V2 1/2] change the shrink_slab by passing shrink_control
In-Reply-To: <20110426094356.F341.A69D9226@jp.fujitsu.com>
References: <1303752134-4856-2-git-send-email-yinghan@google.com> <20110426094356.F341.A69D9226@jp.fujitsu.com>
Message-Id: <20110426095524.F348.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 26 Apr 2011 09:53:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> > This patch consolidates existing parameters to shrink_slab() to
> > a new shrink_control struct. This is needed later to pass the same
> > struct to shrinkers.
> >=20
> > changelog v2..v1:
> > 1. define a new struct shrink_control and only pass some values down
> > to the shrinker instead of the scan_control.
> >=20
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  fs/drop_caches.c   |    6 +++++-
> >  include/linux/mm.h |   13 +++++++++++--
> >  mm/vmscan.c        |   30 ++++++++++++++++++++++--------
> >  3 files changed, 38 insertions(+), 11 deletions(-)
>=20
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Sigh. No. This patch seems premature.


> This patch consolidates existing parameters to shrink_slab() to
> a new shrink_control struct. This is needed later to pass the same
> struct to shrinkers.
>=20
> changelog v2..v1:
> 1. define a new struct shrink_control and only pass some values down
> to the shrinker instead of the scan_control.
>=20
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  fs/drop_caches.c   |    6 +++++-
>  include/linux/mm.h |   13 +++++++++++--
>  mm/vmscan.c        |   30 ++++++++++++++++++++++--------
>  3 files changed, 38 insertions(+), 11 deletions(-)
>=20
> diff --git a/fs/drop_caches.c b/fs/drop_caches.c
> index 816f88e..c671290 100644
> --- a/fs/drop_caches.c
> +++ b/fs/drop_caches.c
> @@ -36,9 +36,13 @@ static void drop_pagecache_sb(struct super_block *sb, =
void *unused)
>  static void drop_slab(void)
>  {
>  	int nr_objects;
> +	struct shrink_control shrink =3D {
> +		.gfp_mask =3D GFP_KERNEL,
> +		.nr_scanned =3D 1000,
> +	};
> =20
>  	do {
> -		nr_objects =3D shrink_slab(1000, GFP_KERNEL, 1000);
> +		nr_objects =3D shrink_slab(&shrink, 1000);
>  	} while (nr_objects > 10);
>  }
> =20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0716517..7a2f657 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1131,6 +1131,15 @@ static inline void sync_mm_rss(struct task_struct =
*task, struct mm_struct *mm)
>  #endif
> =20
>  /*
> + * This struct is used to pass information from page reclaim to the shri=
nkers.
> + * We consolidate the values for easier extention later.
> + */
> +struct shrink_control {
> +	unsigned long nr_scanned;

nr_to_scan is better. sc.nr_scanned mean how much _finished_ scan pages.
eg.
	scan_control {
	(snip)
	        /* Number of pages freed so far during a call to shrink_zones() */
	        unsigned long nr_reclaimed;

	        /* How many pages shrink_list() should reclaim */
	        unsigned long nr_to_reclaim;



> +	gfp_t gfp_mask;
> +};
> +
> +/*
>   * A callback you can register to apply pressure to ageable caches.
>   *
>   * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
> @@ -1601,8 +1610,8 @@ int in_gate_area_no_task(unsigned long addr);
> =20
>  int drop_caches_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
> -unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> -			unsigned long lru_pages);
> +unsigned long shrink_slab(struct shrink_control *shrink,
> +				unsigned long lru_pages);
> =20
>  #ifndef CONFIG_MMU
>  #define randomize_va_space 0
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 060e4c1..40edf73 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -220,11 +220,13 @@ EXPORT_SYMBOL(unregister_shrinker);
>   *
>   * Returns the number of slab objects which we shrunk.
>   */
> -unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> -			unsigned long lru_pages)
> +unsigned long shrink_slab(struct shrink_control *shrink,
> +			  unsigned long lru_pages)
>  {
>  	struct shrinker *shrinker;
>  	unsigned long ret =3D 0;
> +	unsigned long scanned =3D shrink->nr_scanned;
> +	gfp_t gfp_mask =3D shrink->gfp_mask;
> =20
>  	if (scanned =3D=3D 0)
>  		scanned =3D SWAP_CLUSTER_MAX;
> @@ -2032,7 +2034,8 @@ static bool all_unreclaimable(struct zonelist *zone=
list,
>   * 		else, the number of pages reclaimed
>   */
>  static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> -					struct scan_control *sc)
> +					struct scan_control *sc,
> +					struct shrink_control *shrink)
>  {

Worthless argument addition. gfpmask can be getting from scan_control and
=2Enr_scanned is calculated in this function.



>  	int priority;
>  	unsigned long total_scanned =3D 0;
> @@ -2066,7 +2069,8 @@ static unsigned long do_try_to_free_pages(struct zo=
nelist *zonelist,
>  				lru_pages +=3D zone_reclaimable_pages(zone);
>  			}
> =20
> -			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
> +			shrink->nr_scanned =3D sc->nr_scanned;
> +			shrink_slab(shrink, lru_pages);
>  			if (reclaim_state) {
>  				sc->nr_reclaimed +=3D reclaim_state->reclaimed_slab;
>  				reclaim_state->reclaimed_slab =3D 0;
> @@ -2130,12 +2134,15 @@ unsigned long try_to_free_pages(struct zonelist *=
zonelist, int order,
>  		.mem_cgroup =3D NULL,
>  		.nodemask =3D nodemask,
>  	};
> +	struct shrink_control shrink =3D {
> +		.gfp_mask =3D sc.gfp_mask,
> +	};
> =20
>  	trace_mm_vmscan_direct_reclaim_begin(order,
>  				sc.may_writepage,
>  				gfp_mask);
> =20
> -	nr_reclaimed =3D do_try_to_free_pages(zonelist, &sc);
> +	nr_reclaimed =3D do_try_to_free_pages(zonelist, &sc, &shrink);
> =20
>  	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
> =20
> @@ -2333,6 +2340,9 @@ static unsigned long balance_pgdat(pg_data_t *pgdat=
, int order,
>  		.order =3D order,
>  		.mem_cgroup =3D NULL,
>  	};
> +	struct shrink_control shrink =3D {
> +		.gfp_mask =3D sc.gfp_mask,
> +	};
>  loop_again:
>  	total_scanned =3D 0;
>  	sc.nr_reclaimed =3D 0;
> @@ -2432,8 +2442,8 @@ loop_again:
>  					end_zone, 0))
>  				shrink_zone(priority, zone, &sc);
>  			reclaim_state->reclaimed_slab =3D 0;
> -			nr_slab =3D shrink_slab(sc.nr_scanned, GFP_KERNEL,
> -						lru_pages);
> +			shrink.nr_scanned =3D sc.nr_scanned;
> +			nr_slab =3D shrink_slab(&shrink, lru_pages);
>  			sc.nr_reclaimed +=3D reclaim_state->reclaimed_slab;
>  			total_scanned +=3D sc.nr_scanned;
> =20
> @@ -2969,6 +2979,9 @@ static int __zone_reclaim(struct zone *zone, gfp_t =
gfp_mask, unsigned int order)
>  		.swappiness =3D vm_swappiness,
>  		.order =3D order,
>  	};
> +	struct shrink_control shrink =3D {
> +		.gfp_mask =3D sc.gfp_mask,
> +	};
>  	unsigned long nr_slab_pages0, nr_slab_pages1;
> =20
>  	cond_resched();
> @@ -2995,6 +3008,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t =
gfp_mask, unsigned int order)
>  	}
> =20
>  	nr_slab_pages0 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> +	shrink.nr_scanned =3D sc.nr_scanned;
>  	if (nr_slab_pages0 > zone->min_slab_pages) {

strange. this assignment should be move into this if brace.


>  		/*
>  		 * shrink_slab() does not currently allow us to determine how
> @@ -3010,7 +3024,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t =
gfp_mask, unsigned int order)
>  			unsigned long lru_pages =3D zone_reclaimable_pages(zone);
> =20
>  			/* No reclaimable slab or very low memory pressure */
> -			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages))
> +			if (!shrink_slab(&shrink, lru_pages))
>  				break;
> =20
>  			/* Freed enough memory */
> --=20
> 1.7.3.1
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.=
ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
