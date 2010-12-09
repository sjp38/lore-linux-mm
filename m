Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3807E6B0089
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 13:51:47 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id oB9IphvP029060
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 10:51:43 -0800
Received: from qwe5 (qwe5.prod.google.com [10.241.194.5])
	by hpaq1.eem.corp.google.com with ESMTP id oB9InYkS015292
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 10:51:42 -0800
Received: by qwe5 with SMTP id 5so2937739qwe.12
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 10:51:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
Date: Thu, 9 Dec 2010 10:51:40 -0800
Message-ID: <AANLkTikOgkGBn9AbEDAM4KegsnwuXqF2jg7icu0yc8Kh@mail.gmail.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 8, 2010 at 7:16 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Kswapd tries to rebalance zones persistently until their high
> watermarks are restored.
>
> If the amount of unreclaimable pages in a zone makes this impossible
> for reclaim, though, kswapd will end up in a busy loop without a
> chance of reaching its goal.
>
> This behaviour was observed on a virtual machine with a tiny
> Normal-zone that filled up with unreclaimable slab objects.
>
> This patch makes kswapd skip rebalancing on such 'hopeless' zones and
> leaves them to direct reclaim.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0include/linux/mmzone.h | =A0 =A02 ++
> =A0mm/page_alloc.c =A0 =A0 =A0 =A0| =A0 =A04 ++--
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 36 ++++++++++++++++++++++++++=
++--------
> =A03 files changed, 32 insertions(+), 10 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 4890662..0cc1d63 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -655,6 +655,8 @@ typedef struct pglist_data {
> =A0extern struct mutex zonelists_mutex;
> =A0void build_all_zonelists(void *data);
> =A0void wakeup_kswapd(struct zone *zone, int order);
> +bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int classzone_idx, int a=
lloc_flags, long free_pages);
> =A0bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int classzone_idx, int alloc_flags);
> =A0bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long m=
ark,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1845a97..c7d2b28 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1458,8 +1458,8 @@ static inline int should_fail_alloc_page(gfp_t gfp_=
mask, unsigned int order)
> =A0* Return true if free pages are above 'mark'. This takes into account =
the order
> =A0* of the allocation.
> =A0*/
> -static bool __zone_watermark_ok(struct zone *z, int order, unsigned long=
 mark,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int classzone_idx, int alloc_fl=
ags, long free_pages)
> +bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int classzone_idx, int a=
lloc_flags, long free_pages)
> =A0{
> =A0 =A0 =A0 =A0/* free_pages my go negative - that's OK */
> =A0 =A0 =A0 =A0long min =3D mark;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 42a4859..5623f36 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2191,6 +2191,25 @@ unsigned long try_to_free_mem_cgroup_pages(struct =
mem_cgroup *mem_cont,
> =A0}
> =A0#endif
>
> +static bool zone_needs_scan(struct zone *zone, int order,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long goal,=
 int classzone_idx)
> +{
> + =A0 =A0 =A0 unsigned long free, prospect;
> +
> + =A0 =A0 =A0 free =3D zone_page_state(zone, NR_FREE_PAGES);
> + =A0 =A0 =A0 if (zone->percpu_drift_mark && free < zone->percpu_drift_ma=
rk)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free =3D zone_page_state_snapshot(zone, NR_=
FREE_PAGES);
> +
> + =A0 =A0 =A0 if (__zone_watermark_ok(zone, order, goal, classzone_idx, 0=
, free))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Ensure that the watermark is at all restorable through
> + =A0 =A0 =A0 =A0* reclaim. =A0Otherwise, leave the zone to direct reclai=
m.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 prospect =3D free + zone_reclaimable_pages(zone);
> + =A0 =A0 =A0 return prospect >=3D goal;
> +}
> +
> =A0/* is kswapd sleeping prematurely? */
> =A0static int sleeping_prematurely(pg_data_t *pgdat, int order, long rema=
ining)
> =A0{
> @@ -2210,8 +2229,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, i=
nt order, long remaining)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (zone->all_unreclaimable)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_watermark_ok_safe(zone, order, hi=
gh_wmark_pages(zone),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, 0))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone_needs_scan(zone, order, high_wmark=
_pages(zone), 0))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0}
>
> @@ -2282,6 +2300,7 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i =3D pgdat->nr_zones - 1; i >=3D 0; =
i--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone =3D pgda=
t->node_zones + i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long goal;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!populated_zone(zone))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> @@ -2297,8 +2316,8 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_act=
ive_list(SWAP_CLUSTER_MAX, zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&sc, priority, 0);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_watermark_ok_safe=
(zone, order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 high_wmark_pages(zone), 0, 0)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal =3D high_wmark_pages(z=
one);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone_needs_scan(zone, o=
rder, goal, 0)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0end_zone =
=3D i;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -2323,6 +2342,7 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i =3D 0; i <=3D end_zone; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone =3D pgda=
t->node_zones + i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long goal;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int nr_slab;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!populated_zone(zone))
> @@ -2339,12 +2359,13 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_limit_recl=
aim(zone, order, sc.gfp_mask);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal =3D high_wmark_pages(z=
one);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We put equal pressure o=
n every zone, unless one
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * zone has way too many p=
ages free already.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!zone_watermark_ok_saf=
e(zone, order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 8*high_wmark_pages(zone), end_zone, 0))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8 * goal, end_zone, 0))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zon=
e(priority, zone, &sc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reclaim_state->reclaimed_s=
lab =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_slab =3D shrink_slab(sc=
.nr_scanned, GFP_KERNEL,
> @@ -2373,8 +2394,7 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compact_zo=
ne_order(zone, sc.order, sc.gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0false);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_watermark_ok_safe=
(zone, order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 high_wmark_pages(zone), end_zone, 0)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone_needs_scan(zone, o=
rder, goal, end_zone)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0all_zones_=
ok =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We are =
still under min water mark. =A0This
> @@ -2587,7 +2607,7 @@ void wakeup_kswapd(struct zone *zone, int order)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat->kswapd_max_order =3D order;
> =A0 =A0 =A0 =A0if (!waitqueue_active(&pgdat->kswapd_wait))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> - =A0 =A0 =A0 if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zon=
e), 0, 0))
> + =A0 =A0 =A0 if (!zone_needs_scan(zone, order, low_wmark_pages(zone), 0)=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zon=
e), order);


So we look at zone_reclaimable_pages() only to determine proceed
reclaiming or not. What if I have tons of unused dentry and inode
caches and we are skipping the shrinker here?

--Ying


> 1.7.3.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
