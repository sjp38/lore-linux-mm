Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CF4478D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 22:11:54 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7340B3EE0C0
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:11:48 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5735245DE5E
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:11:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C8FB45DE57
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:11:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31628E08003
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:11:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE55FE18004
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:11:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <AANLkTi=w62=WR5WACJGk6JNhyCYpgNhFQK3CyQ5Ag-Yj@mail.gmail.com>
References: <20110323174545.1AE2.A69D9226@jp.fujitsu.com> <AANLkTi=w62=WR5WACJGk6JNhyCYpgNhFQK3CyQ5Ag-Yj@mail.gmail.com>
Message-Id: <20110324111200.1AF4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 24 Mar 2011 11:11:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

> On Wed, Mar 23, 2011 at 5:44 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> > Boo.
> >> > You seems forgot why you introduced current all_unreclaimable() func=
tion.
> >> > While hibernation, we can't trust all_unreclaimable.
> >>
> >> Hmm. AFAIR, the why we add all_unreclaimable is when the hibernation i=
s going on,
> >> kswapd is freezed so it can't mark the zone->all_unreclaimable.
> >> So I think hibernation can't be a problem.
> >> Am I miss something?
> >
> > Ahh, I missed. thans correct me. Okay, I recognized both mine and your =
works.
> > Can you please explain why do you like your one than mine?
>=20
> Just _simple_ :)
> I don't want to change many lines although we can do it simple and very c=
lear.
>
> >
> > btw, Your one is very similar andrey's initial patch. If your one is
> > better, I'd like to ack with andrey instead.
>=20
> When Andrey sent a patch, I though this as zone_reclaimable() is right
> place to check it than out of zone_reclaimable. Why I didn't ack is
> that Andrey can't explain root cause but you did so you persuade me.
>=20
> I don't mind if Andrey move the check in zone_reclaimable and resend
> or I resend with concrete description.
>=20
> Anyway, most important thing is good description to show the root cause.
> It is applied to your patch, too.
> You should have written down root cause in description.

honestly, I really dislike to use mixing zone->pages_scanned and=20
zone->all_unreclaimable. because I think it's no simple. I don't=20
think it's good taste nor easy to review. Even though you who VM=20
expert didn't understand this issue at once, it's smell of too=20
mess code.

therefore, I prefore to take either 1) just remove the function or
2) just only check zone->all_unreclaimable and oom_killer_disabled=20
instead zone->pages_scanned.

And, I agree I need to rewrite the description.=20
How's this?

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46rom 216bcf3fb0476b453080debf8999c74c635ed72f Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sun, 8 May 2011 17:39:44 +0900
Subject: [PATCH] vmscan: remove all_unreclaimable check from direct reclaim=
 path completely

all_unreclaimable check in direct reclaim has been introduced at 2.6.19
by following commit.

	2006 Sep 25; commit 408d8544; oom: use unreclaimable info

And it went through strange history. firstly, following commit broke
the logic unintentionally.

	2008 Apr 29; commit a41f24ea; page allocator: smarter retry of
				      costly-order allocations

Two years later, I've found obvious meaningless code fragment and
restored original intention by following commit.

	2010 Jun 04; commit bb21c7ce; vmscan: fix do_try_to_free_pages()
				      return value when priority=3D=3D0

But, the logic didn't works when 32bit highmem system goes hibernation
and Minchan slightly changed the algorithm and fixed it .

	2010 Sep 22: commit d1908362: vmscan: check all_unreclaimable
				      in direct reclaim path

But, recently, Andrey Vagin found the new corner case. Look,

	struct zone {
	  ..
	        int                     all_unreclaimable;
	  ..
	        unsigned long           pages_scanned;
	  ..
	}

zone->all_unreclaimable and zone->pages_scanned are neigher atomic
variables nor protected by lock. Therefore zones can become a state
of zone->page_scanned=3D0 and zone->all_unreclaimable=3D1. In this case,
current all_unreclaimable() return false even though
zone->all_unreclaimabe=3D1.

Is this ignorable minor issue? No. Unfortunatelly, x86 has very
small dma zone and it become zone->all_unreclamble=3D1 easily. and
if it become all_unreclaimable=3D1, it never restore all_unreclaimable=3D0.
Why? if all_unreclaimable=3D1, vmscan only try DEF_PRIORITY reclaim and
a-few-lru-pages>>DEF_PRIORITY always makes 0. that mean no page scan
at all!

Eventually, oom-killer never works on such systems.  Let's remove
this problematic logic completely.

Reported-by: Andrey Vagin <avagin@openvz.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   36 +-----------------------------------
 1 files changed, 1 insertions(+), 35 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 060e4c1..254aada 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1989,33 +1989,6 @@ static bool zone_reclaimable(struct zone *zone)
 }
=20
 /*
- * As hibernation is going on, kswapd is freezed so that it can't mark
- * the zone into all_unreclaimable. It can't handle OOM during hibernation.
- * So let's check zone's unreclaimable in direct reclaim as well as kswapd.
- */
-static bool all_unreclaimable(struct zonelist *zonelist,
-		struct scan_control *sc)
-{
-	struct zoneref *z;
-	struct zone *zone;
-	bool all_unreclaimable =3D true;
-
-	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-			gfp_zone(sc->gfp_mask), sc->nodemask) {
-		if (!populated_zone(zone))
-			continue;
-		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-			continue;
-		if (zone_reclaimable(zone)) {
-			all_unreclaimable =3D false;
-			break;
-		}
-	}
-
-	return all_unreclaimable;
-}
-
-/*
  * This is the main entry point to direct page reclaim.
  *
  * If a full scan of the inactive list fails to free enough memory then we
@@ -2105,14 +2078,7 @@ out:
 	delayacct_freepages_end();
 	put_mems_allowed();
=20
-	if (sc->nr_reclaimed)
-		return sc->nr_reclaimed;
-
-	/* top priority shrink_zones still had more to do? don't OOM, then */
-	if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
-		return 1;
-
-	return 0;
+	return sc->nr_reclaimed;
 }
=20
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
--=20
1.6.5.2





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
