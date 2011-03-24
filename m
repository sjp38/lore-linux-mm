Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C84FE8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 01:35:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AF3963EE0C7
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:09 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F4F945DE61
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7446E45DE5C
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 605B4E08002
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FA541DB8047
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <AANLkTim1=Z5VhWJyn596cyez3hDe1BgDHvPvj6eoPp1j@mail.gmail.com>
References: <20110324111200.1AF4.A69D9226@jp.fujitsu.com> <AANLkTim1=Z5VhWJyn596cyez3hDe1BgDHvPvj6eoPp1j@mail.gmail.com>
Message-Id: <20110324143541.CC78.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 24 Mar 2011 14:35:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

Hi Minchan,

> Nick's original goal is to prevent OOM killing until all zone we're
> interested in are unreclaimable and whether zone is reclaimable or not
> depends on kswapd. And Nick's original solution is just peeking
> zone->all_unreclaimable but I made it dirty when we are considering
> kswapd freeze in hibernation. So I think we still need it to handle
> kswapd freeze problem and we should add original behavior we missed at
> that time like below.
>=20
> static bool zone_reclaimable(struct zone *zone)
> {
>         if (zone->all_unreclaimable)
>                 return false;
>=20
>         return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
> }
>=20
> If you remove the logic, the problem Nick addressed would be showed
> up, again. How about addressing the problem in your patch? If you
> remove the logic, __alloc_pages_direct_reclaim lose the chance calling
> dran_all_pages. Of course, it was a side effect but we should handle
> it.

Ok, you are successfull to persuade me. lost drain_all_pages() chance has
a risk.

> And my last concern is we are going on right way?


> I think fundamental cause of this problem is page_scanned and
> all_unreclaimable is race so isn't the approach fixing the race right
> way?

Hmm..
If we can avoid lock, we should. I think. that's performance reason.
therefore I'd like to cap the issue in do_try_to_free_pages(). it's
slow path.

Is the following patch acceptable to you? it is
 o rewrote the description
 o avoid mix to use zone->all_unreclaimable and zone->pages_scanned
 o avoid to reintroduce hibernation issue
 o don't touch fast path


> If it is hard or very costly, your and my approach will be fallback.

-----------------------------------------------------------------
=46rom f3d277057ad3a092aa1c94244f0ed0d3ebe5411c Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 14 May 2011 05:07:48 +0900
Subject: [PATCH] vmscan: all_unreclaimable() use zone->all_unreclaimable as=
 the name

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

Eventually, oom-killer never works on such systems. That said, we
can't use zone->pages_scanned for this purpose. This patch restore
all_unreclaimable() use zone->all_unreclaimable as old. and in addition,
to add oom_killer_disabled check to avoid reintroduce the issue of
commit d1908362.

Reported-by: Andrey Vagin <avagin@openvz.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 060e4c1..54ac548 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -41,6 +41,7 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#include <linux/oom.h>
=20
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1988,17 +1989,12 @@ static bool zone_reclaimable(struct zone *zone)
 	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
 }
=20
-/*
- * As hibernation is going on, kswapd is freezed so that it can't mark
- * the zone into all_unreclaimable. It can't handle OOM during hibernation.
- * So let's check zone's unreclaimable in direct reclaim as well as kswapd.
- */
+/* All zones in zonelist are unreclaimable? */
 static bool all_unreclaimable(struct zonelist *zonelist,
 		struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
-	bool all_unreclaimable =3D true;
=20
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 			gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -2006,13 +2002,11 @@ static bool all_unreclaimable(struct zonelist *zone=
list,
 			continue;
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
-		if (zone_reclaimable(zone)) {
-			all_unreclaimable =3D false;
-			break;
-		}
+		if (!zone->all_unreclaimable)
+			return false;
 	}
=20
-	return all_unreclaimable;
+	return true;
 }
=20
 /*
@@ -2108,6 +2102,14 @@ out:
 	if (sc->nr_reclaimed)
 		return sc->nr_reclaimed;
=20
+	/*
+	 * As hibernation is going on, kswapd is freezed so that it can't mark
+	 * the zone into all_unreclaimable. Thus bypassing all_unreclaimable
+	 * check.
+	 */
+	if (oom_killer_disabled)
+		return 0;
+
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
