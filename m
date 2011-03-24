Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E84FD8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 01:53:23 -0400 (EDT)
Received: by iyf13 with SMTP id 13so12856187iyf.14
        for <linux-mm@kvack.org>; Wed, 23 Mar 2011 22:53:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324143541.CC78.A69D9226@jp.fujitsu.com>
References: <20110324111200.1AF4.A69D9226@jp.fujitsu.com>
	<AANLkTim1=Z5VhWJyn596cyez3hDe1BgDHvPvj6eoPp1j@mail.gmail.com>
	<20110324143541.CC78.A69D9226@jp.fujitsu.com>
Date: Thu, 24 Mar 2011 14:53:18 +0900
Message-ID: <AANLkTik0AUXX2O9-=7dpF2-_CovqXtqenieZA9HRanEc@mail.gmail.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct
 reclaim path completely
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

Hi Kosaki,

On Thu, Mar 24, 2011 at 2:35 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi Minchan,
>
>> Nick's original goal is to prevent OOM killing until all zone we're
>> interested in are unreclaimable and whether zone is reclaimable or not
>> depends on kswapd. And Nick's original solution is just peeking
>> zone->all_unreclaimable but I made it dirty when we are considering
>> kswapd freeze in hibernation. So I think we still need it to handle
>> kswapd freeze problem and we should add original behavior we missed at
>> that time like below.
>>
>> static bool zone_reclaimable(struct zone *zone)
>> {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (zone->all_unreclaimable)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 return zone->pages_scanned < zone_reclaimabl=
e_pages(zone) * 6;
>> }
>>
>> If you remove the logic, the problem Nick addressed would be showed
>> up, again. How about addressing the problem in your patch? If you
>> remove the logic, __alloc_pages_direct_reclaim lose the chance calling
>> dran_all_pages. Of course, it was a side effect but we should handle
>> it.
>
> Ok, you are successfull to persuade me. lost drain_all_pages() chance has
> a risk.
>
>> And my last concern is we are going on right way?
>
>
>> I think fundamental cause of this problem is page_scanned and
>> all_unreclaimable is race so isn't the approach fixing the race right
>> way?
>
> Hmm..
> If we can avoid lock, we should. I think. that's performance reason.
> therefore I'd like to cap the issue in do_try_to_free_pages(). it's
> slow path.
>
> Is the following patch acceptable to you? it is
> =C2=A0o rewrote the description
> =C2=A0o avoid mix to use zone->all_unreclaimable and zone->pages_scanned
> =C2=A0o avoid to reintroduce hibernation issue
> =C2=A0o don't touch fast path
>
>
>> If it is hard or very costly, your and my approach will be fallback.
>
> -----------------------------------------------------------------
> From f3d277057ad3a092aa1c94244f0ed0d3ebe5411c Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Sat, 14 May 2011 05:07:48 +0900
> Subject: [PATCH] vmscan: all_unreclaimable() use zone->all_unreclaimable =
as the name
>
> all_unreclaimable check in direct reclaim has been introduced at 2.6.19
> by following commit.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A02006 Sep 25; commit 408d8544; oom: use unrecla=
imable info
>
> And it went through strange history. firstly, following commit broke
> the logic unintentionally.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A02008 Apr 29; commit a41f24ea; page allocator: =
smarter retry of
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0costly-order all=
ocations
>
> Two years later, I've found obvious meaningless code fragment and
> restored original intention by following commit.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A02010 Jun 04; commit bb21c7ce; vmscan: fix do_t=
ry_to_free_pages()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return value whe=
n priority=3D=3D0
>
> But, the logic didn't works when 32bit highmem system goes hibernation
> and Minchan slightly changed the algorithm and fixed it .
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A02010 Sep 22: commit d1908362: vmscan: check al=
l_unreclaimable
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0in direct reclai=
m path
>
> But, recently, Andrey Vagin found the new corner case. Look,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0..
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 all_unreclaimable;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0..
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages_scanned;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0..
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> zone->all_unreclaimable and zone->pages_scanned are neigher atomic
> variables nor protected by lock. Therefore zones can become a state
> of zone->page_scanned=3D0 and zone->all_unreclaimable=3D1. In this case,
> current all_unreclaimable() return false even though
> zone->all_unreclaimabe=3D1.
>
> Is this ignorable minor issue? No. Unfortunatelly, x86 has very
> small dma zone and it become zone->all_unreclamble=3D1 easily. and
> if it become all_unreclaimable=3D1, it never restore all_unreclaimable=3D=
0.
> Why? if all_unreclaimable=3D1, vmscan only try DEF_PRIORITY reclaim and
> a-few-lru-pages>>DEF_PRIORITY always makes 0. that mean no page scan
> at all!
>
> Eventually, oom-killer never works on such systems. That said, we
> can't use zone->pages_scanned for this purpose. This patch restore
> all_unreclaimable() use zone->all_unreclaimable as old. and in addition,
> to add oom_killer_disabled check to avoid reintroduce the issue of
> commit d1908362.
>
> Reported-by: Andrey Vagin <avagin@openvz.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 24 +++++++++++++-----------
> =C2=A01 files changed, 13 insertions(+), 11 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 060e4c1..54ac548 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -41,6 +41,7 @@
> =C2=A0#include <linux/memcontrol.h>
> =C2=A0#include <linux/delayacct.h>
> =C2=A0#include <linux/sysctl.h>
> +#include <linux/oom.h>
>
> =C2=A0#include <asm/tlbflush.h>
> =C2=A0#include <asm/div64.h>
> @@ -1988,17 +1989,12 @@ static bool zone_reclaimable(struct zone *zone)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return zone->pages_scanned < zone_reclaimable_=
pages(zone) * 6;
> =C2=A0}
>
> -/*
> - * As hibernation is going on, kswapd is freezed so that it can't mark
> - * the zone into all_unreclaimable. It can't handle OOM during hibernati=
on.
> - * So let's check zone's unreclaimable in direct reclaim as well as kswa=
pd.
> - */
> +/* All zones in zonelist are unreclaimable? */
> =C2=A0static bool all_unreclaimable(struct zonelist *zonelist,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct scan_contro=
l *sc)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zoneref *z;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone;
> - =C2=A0 =C2=A0 =C2=A0 bool all_unreclaimable =3D true;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_zone_zonelist_nodemask(zone, z, zonel=
ist,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0gfp_zone(sc->gfp_mask), sc->nodemask) {
> @@ -2006,13 +2002,11 @@ static bool all_unreclaimable(struct zonelist *zo=
nelist,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cpuset_zone_a=
llowed_hardwall(zone, GFP_KERNEL))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (zone_reclaimable(z=
one)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 all_unreclaimable =3D false;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!zone->all_unrecla=
imable)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return false;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 return all_unreclaimable;
> + =C2=A0 =C2=A0 =C2=A0 return true;
> =C2=A0}
>
> =C2=A0/*
> @@ -2108,6 +2102,14 @@ out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sc->nr_reclaimed)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return sc->nr_recl=
aimed;
>
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* As hibernation is going on, kswapd is free=
zed so that it can't mark
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* the zone into all_unreclaimable. Thus bypa=
ssing all_unreclaimable
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* check.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (oom_killer_disabled)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* top priority shrink_zones still had more to=
 do? don't OOM, then */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (scanning_global_lru(sc) && !all_unreclaima=
ble(zonelist, sc))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> --
> 1.6.5.2
>
Thanks for your effort, Kosaki.
But I still doubt this patch is good.

This patch makes early oom killing in hibernation as it skip
all_unreclaimable check.
Normally,  hibernation needs many memory so page_reclaim pressure
would be big in small memory system. So I don't like early give up.

Do you think my patch has a problem? Personally, I think it's very
simple and clear. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
