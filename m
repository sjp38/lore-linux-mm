Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 9DDAF6B0070
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 19:38:11 -0400 (EDT)
Received: by yhr47 with SMTP id 47so3907589yhr.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:38:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=qn_f5Vm4S=X99siuQzAJcHe8vSLJzU48GXTZXLZgGuWQ@mail.gmail.com>
References: <1335214564-17619-1-git-send-email-yinghan@google.com> <CAHGf_=qn_f5Vm4S=X99siuQzAJcHe8vSLJzU48GXTZXLZgGuWQ@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 11 Jun 2012 19:37:49 -0400
Message-ID: <CAHGf_=pY41-BMph5qCZ1ZwQy+Or1xi90FARZk9X8=kvKNr-DVA@mail.gmail.com>
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@gmail.com>

Sigh, fix Nick's e-mail address.


<full quote intentionally>

> On Mon, Apr 23, 2012 at 4:56 PM, Ying Han <yinghan@google.com> wrote:
>> This is not a patch targeted to be merged at all, but trying to understa=
nd
>> a logic in global direct reclaim.
>>
>> There is a logic in global direct reclaim where reclaim fails on priorit=
y 0
>> and zone->all_unreclaimable is not set, it will cause the direct to star=
t over
>> from DEF_PRIORITY. In some extreme cases, we've seen the system hang whi=
ch is
>> very likely caused by direct reclaim enters infinite loop.
>>
>> There have been serious patches trying to fix similar issue and the late=
st
>> patch has good summary of all the efforts:
>>
>> commit 929bea7c714220fc76ce3f75bef9056477c28e74
>> Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Date: =A0 Thu Apr 14 15:22:12 2011 -0700
>>
>> =A0 =A0vmscan: all_unreclaimable() use zone->all_unreclaimable as a name
>>
>> Kosaki explained the problem triggered by async zone->all_unreclaimable =
and
>> zone->pages_scanned where the later one was being checked by direct recl=
aim.
>> However, after the patch, the problem remains where the setting of
>> zone->all_unreclaimable is asynchronous with zone is actually reclaimabl=
e or not.
>>
>> The zone->all_unreclaimable flag is set by kswapd by checking zone->page=
s_scanned in
>> zone_reclaimable(). Is that possible to have zone->all_unreclaimable =3D=
=3D false while
>> the zone is actually unreclaimable?
>
> I'm backed very old threads. :-(
> I could reproduce this issue by using memory hotplug. Can anyone
> review following patch?
>
>
> From 767b9ff5b53a34cb95e59a7c230aef3fda07be49 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Mon, 11 Jun 2012 18:48:03 -0400
> Subject: [PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
>
> Currently, do_try_to_free_pages() can enter livelock. Because of,
> now vmscan has two conflicted policies.
>
> 1) kswapd sleep when it couldn't reclaim any page even though
> =A0 reach priority 0. This is because to avoid kswapd() infinite
> =A0 loop. That said, kswapd assume direct reclaim makes enough
> =A0 free pages either regular page reclaim or oom-killer.
> =A0 This logic makes kswapd -> direct-reclaim dependency.
> 2) direct reclaim continue to reclaim without oom-killer until
> =A0 kswapd turn on zone->all_unreclaimble. This is because
> =A0 to avoid too early oom-kill.
> =A0 This logic makes direct-reclaim -> kswapd dependency.
>
> In worst case, direct-reclaim may continue to page reclaim forever
> when kswapd is slept and any other thread don't wakeup kswapd.
>
> We can't turn on zone->all_unreclaimable because this is racy.
> direct reclaim path don't take any lock. Thus this patch removes
> zone->all_unreclaimable field completely and recalculates every
> time.
>
> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
> directly and kswapd continue to use zone->all_unreclaimable. Because,
> it is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
> zone->all_unreclaimable as a name) describes the detail.
>
> Reported-by: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Reported-by: Ying Han <yinghan@google.com>
> Cc: Nick Piggin <npiggin@gmail.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =A0include/linux/mm_inline.h | =A0 19 +++++++++++++++++
> =A0include/linux/mmzone.h =A0 =A0| =A0 =A02 +-
> =A0include/linux/vmstat.h =A0 =A0| =A0 =A01 -
> =A0mm/page-writeback.c =A0 =A0 =A0 | =A0 =A02 +
> =A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 | =A0 =A05 +--
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 48 ++++++++++++---------=
-----------------------
> =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A07 files changed, 39 insertions(+), 41 deletions(-)
>
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index 1397ccf..04f32e1 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -2,6 +2,7 @@
> =A0#define LINUX_MM_INLINE_H
>
> =A0#include <linux/huge_mm.h>
> +#include <linux/swap.h>
>
> =A0/**
> =A0* page_is_file_cache - should the page be on a file LRU or anon LRU?
> @@ -99,4 +100,22 @@ static __always_inline enum lru_list
> page_lru(struct page *page)
> =A0 =A0 =A0 =A0return lru;
> =A0}
>
> +static inline unsigned long zone_reclaimable_pages(struct zone *zone)
> +{
> + =A0 =A0 =A0 int nr;
> +
> + =A0 =A0 =A0 nr =3D zone_page_state(zone, NR_ACTIVE_FILE) +
> + =A0 =A0 =A0 =A0 =A0 =A0zone_page_state(zone, NR_INACTIVE_FILE);
> +
> + =A0 =A0 =A0 if (nr_swap_pages > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D zone_page_state(zone, NR_ACTIVE_ANO=
N) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_page_state(zone, NR_INACTI=
VE_ANON);
> +
> + =A0 =A0 =A0 return nr;
> +}
> +
> +static inline bool zone_reclaimable(struct zone *zone)
> +{
> + =A0 =A0 =A0 return zone->pages_scanned < zone_reclaimable_pages(zone) *=
 6;
> +}
> =A0#endif
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2427706..9d2a720 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -368,7 +368,7 @@ struct zone {
> =A0 =A0 =A0 =A0 * free areas of different sizes
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lock;
> - =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 all_unreclaimab=
le; /* All pages pinned */
> +
> =A0#ifdef CONFIG_MEMORY_HOTPLUG
> =A0 =A0 =A0 =A0/* see spanned/present_pages for more description */
> =A0 =A0 =A0 =A0seqlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 span_seqlock;
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 65efb92..9607256 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -140,7 +140,6 @@ static inline unsigned long
> zone_page_state_snapshot(struct zone *zone,
> =A0}
>
> =A0extern unsigned long global_reclaimable_pages(void);
> -extern unsigned long zone_reclaimable_pages(struct zone *zone);
>
> =A0#ifdef CONFIG_NUMA
> =A0/*
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 93d8d2f..d2d957f 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -34,6 +34,8 @@
> =A0#include <linux/syscalls.h>
> =A0#include <linux/buffer_head.h> /* __set_page_dirty_buffers */
> =A0#include <linux/pagevec.h>
> +#include <linux/mm_inline.h>
> +
> =A0#include <trace/events/writeback.h>
>
> =A0/*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4403009..5716b00 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -59,6 +59,7 @@
> =A0#include <linux/prefetch.h>
> =A0#include <linux/migrate.h>
> =A0#include <linux/page-debug-flags.h>
> +#include <linux/mm_inline.h>
>
> =A0#include <asm/tlbflush.h>
> =A0#include <asm/div64.h>
> @@ -638,7 +639,6 @@ static void free_pcppages_bulk(struct zone *zone, int=
 count,
> =A0 =A0 =A0 =A0int to_free =3D count;
>
> =A0 =A0 =A0 =A0spin_lock(&zone->lock);
> - =A0 =A0 =A0 zone->all_unreclaimable =3D 0;
> =A0 =A0 =A0 =A0zone->pages_scanned =3D 0;
>
> =A0 =A0 =A0 =A0while (to_free) {
> @@ -680,7 +680,6 @@ static void free_one_page(struct zone *zone,
> struct page *page, int order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int migrat=
etype)
> =A0{
> =A0 =A0 =A0 =A0spin_lock(&zone->lock);
> - =A0 =A0 =A0 zone->all_unreclaimable =3D 0;
> =A0 =A0 =A0 =A0zone->pages_scanned =3D 0;
>
> =A0 =A0 =A0 =A0__free_one_page(page, zone, order, migratetype);
> @@ -2870,7 +2869,7 @@ void show_free_areas(unsigned int filter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0K(zone_page_state(zone, NR=
_BOUNCE)),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0K(zone_page_state(zone, NR=
_WRITEBACK_TEMP)),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->pages_scanned,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (zone->all_unreclaimable ? =
"yes" : "no")
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(zone_reclaimable(zone) ? "y=
es" : "no")
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk("lowmem_reserve[]:");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i =3D 0; i < MAX_NR_ZONES; i++)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eeb3bc9..033671c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1592,7 +1592,7 @@ static void get_scan_count(struct lruvec
> *lruvec, struct scan_control *sc,
> =A0 =A0 =A0 =A0 * latencies, so it's better to scan a minimum amount ther=
e as
> =A0 =A0 =A0 =A0 * well.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (current_is_kswapd() && zone->all_unreclaimable)
> + =A0 =A0 =A0 if (current_is_kswapd() && !zone_reclaimable(zone))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0force_scan =3D true;
> =A0 =A0 =A0 =A0if (!global_reclaim(sc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0force_scan =3D true;
> @@ -1936,8 +1936,8 @@ static bool shrink_zones(struct zonelist
> *zonelist, struct scan_control *sc)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (global_reclaim(sc)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!cpuset_zone_allowed_h=
ardwall(zone, GFP_KERNEL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone->all_unreclaimable=
 &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 sc->priority !=3D DEF_PRIORITY)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_reclaimable(zone)=
 &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->priority !=3D D=
EF_PRIORITY)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue; =
=A0 =A0 =A0 /* Let kswapd poll it */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (COMPACTION_BUILD) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -1975,11 +1975,6 @@ static bool shrink_zones(struct zonelist
> *zonelist, struct scan_control *sc)
> =A0 =A0 =A0 =A0return aborted_reclaim;
> =A0}
>
> -static bool zone_reclaimable(struct zone *zone)
> -{
> - =A0 =A0 =A0 return zone->pages_scanned < zone_reclaimable_pages(zone) *=
 6;
> -}
> -
> =A0/* All zones in zonelist are unreclaimable? */
> =A0static bool all_unreclaimable(struct zonelist *zonelist,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct scan_control *sc)
> @@ -1993,7 +1988,7 @@ static bool all_unreclaimable(struct zonelist *zone=
list,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!cpuset_zone_allowed_hardwall(zone, GF=
P_KERNEL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone->all_unreclaimable)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone_reclaimable(zone))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
> =A0 =A0 =A0 =A0}
>
> @@ -2299,7 +2294,7 @@ static bool sleeping_prematurely(pg_data_t
> *pgdat, int order, long remaining,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * they must be considered balanced here a=
s well if kswapd
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * is to sleep
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone->all_unreclaimable) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone_reclaimable(zone)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0balanced +=3D zone->presen=
t_pages;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -2393,8 +2388,7 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!populated_zone(zone))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone->all_unreclaimable=
 &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.priority !=3D DE=
F_PRIORITY)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_reclaimable(zone)=
 && sc.priority !=3D DEF_PRIORITY)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -2443,14 +2437,13 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i =3D 0; i <=3D end_zone; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone =3D pgda=
t->node_zones + i;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nr_slab, testorder;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int testorder;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long balance_gap;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!populated_zone(zone))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone->all_unreclaimable=
 &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.priority !=3D DE=
F_PRIORITY)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_reclaimable(zone)=
 && sc.priority !=3D DEF_PRIORITY)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.nr_scanned =3D 0;
> @@ -2497,12 +2490,11 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zon=
e(zone, &sc);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reclaim_st=
ate->reclaimed_slab =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_slab =3D=
 shrink_slab(&shrink, sc.nr_scanned, lru_pages);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_slab=
(&shrink, sc.nr_scanned, lru_pages);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.nr_recl=
aimed +=3D reclaim_state->reclaimed_slab;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scan=
ned +=3D sc.nr_scanned;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_slab=
 =3D=3D 0 && !zone_reclaimable(zone))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 zone->all_unreclaimable =3D 1;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -2514,7 +2506,7 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scanned > sc=
.nr_reclaimed + sc.nr_reclaimed / 2)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.may_wri=
tepage =3D 1;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone->all_unreclaimable=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_reclaimable(zone)=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (end_zo=
ne && end_zone =3D=3D i)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0end_zone--;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> @@ -2616,7 +2608,7 @@ out:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!populated_zone(zone))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone->all_unreclaimable=
 &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_reclaimable(zone)=
 &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.priority !=3D D=
EF_PRIORITY)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> @@ -2850,20 +2842,6 @@ unsigned long global_reclaimable_pages(void)
> =A0 =A0 =A0 =A0return nr;
> =A0}
>
> -unsigned long zone_reclaimable_pages(struct zone *zone)
> -{
> - =A0 =A0 =A0 int nr;
> -
> - =A0 =A0 =A0 nr =3D zone_page_state(zone, NR_ACTIVE_FILE) +
> - =A0 =A0 =A0 =A0 =A0 =A0zone_page_state(zone, NR_INACTIVE_FILE);
> -
> - =A0 =A0 =A0 if (nr_swap_pages > 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D zone_page_state(zone, NR_ACTIVE_ANO=
N) +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_page_state(zone, NR_INACTI=
VE_ANON);
> -
> - =A0 =A0 =A0 return nr;
> -}
> -
> =A0#ifdef CONFIG_HIBERNATION
> =A0/*
> =A0* Try to free `nr_to_reclaim' of memory, system-wide, and return the n=
umber of
> @@ -3158,7 +3136,7 @@ int zone_reclaim(struct zone *zone, gfp_t
> gfp_mask, unsigned int order)
> =A0 =A0 =A0 =A0 =A0 =A0zone_page_state(zone, NR_SLAB_RECLAIMABLE) <=3D zo=
ne->min_slab_pages)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ZONE_RECLAIM_FULL;
>
> - =A0 =A0 =A0 if (zone->all_unreclaimable)
> + =A0 =A0 =A0 if (!zone_reclaimable(zone))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ZONE_RECLAIM_FULL;
>
> =A0 =A0 =A0 =A0/*
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 1bbbbd9..94b9d4c 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -19,6 +19,7 @@
> =A0#include <linux/math64.h>
> =A0#include <linux/writeback.h>
> =A0#include <linux/compaction.h>
> +#include <linux/mm_inline.h>
>
> =A0#ifdef CONFIG_VM_EVENT_COUNTERS
> =A0DEFINE_PER_CPU(struct vm_event_state, vm_event_states) =3D {{0}};
> @@ -1022,7 +1023,7 @@ static void zoneinfo_show_print(struct seq_file
> *m, pg_data_t *pgdat,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "=A5n =A0all_unreclaimable: %u"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "=A5n =A0start_pfn: =A0 =A0 =A0 =A0 %=
lu"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "=A5n =A0inactive_ratio: =A0 =A0%u",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->all_unreclaimable,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!zone_reclaimable(zone),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->zone_start_pfn,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->inactive_ratio);
> =A0 =A0 =A0 =A0seq_putc(m, '=A5n');
> --
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
