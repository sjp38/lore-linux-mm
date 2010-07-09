Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 890216B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 21:16:37 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o691GYAM003373
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Jul 2010 10:16:35 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B9BF45DE57
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 10:16:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 62D0545DE51
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 10:16:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 447881DB803F
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 10:16:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E6FE11DB803C
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 10:16:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 1/2] vmscan: don't subtraction of unsined
In-Reply-To: <20100708130048.fccfcdad.akpm@linux-foundation.org>
References: <20100708163401.CD34.A69D9226@jp.fujitsu.com> <20100708130048.fccfcdad.akpm@linux-foundation.org>
Message-Id: <20100709090956.CD51.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  9 Jul 2010 10:16:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>


> > @@ -2628,16 +2628,16 @@ static int __zone_reclaim(struct zone *zone, gf=
p_t gfp_mask, unsigned int order)
> >  		 * take a long time.
> >  		 */
> >  		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
> > -			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
> > -				slab_reclaimable - nr_pages)
> > +		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages > n))
> >  			;
> > =20
> >  		/*
> >  		 * Update nr_reclaimed by the number of slab pages we
> >  		 * reclaimed from this zone.
> >  		 */
> > -		sc.nr_reclaimed +=3D slab_reclaimable -
> > -			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> > +		m =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> > +		if (m < n)
> > +			sc.nr_reclaimed +=3D n - m;
>=20
> And it's not a completly trivial objection.  Your patch made the above
> code snippet quite a lot harder to read (and hence harder to maintain).

Initially, I proposed following patch to Christoph. but he prefer n and m.
To be honest, I don't think this naming is big matter. so you prefer follow=
ing
I'll submit it.




=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46rom 397199d69860061eaa5e1aaadac45c46c76b0522 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 30 Jun 2010 13:35:16 +0900
Subject: [PATCH] vmscan: don't subtraction of unsined

'slab_reclaimable' and 'nr_pages' are unsigned. so, subtraction is
unsafe.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..79ff877 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2588,7 +2588,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gf=
p_mask, unsigned int order)
 		.swappiness =3D vm_swappiness,
 		.order =3D order,
 	};
-	unsigned long slab_reclaimable;
+	unsigned long nr_slab_pages0, nr_slab_pages1;
=20
 	disable_swap_token();
 	cond_resched();
@@ -2615,8 +2615,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gf=
p_mask, unsigned int order)
 		} while (priority >=3D 0 && sc.nr_reclaimed < nr_pages);
 	}
=20
-	slab_reclaimable =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-	if (slab_reclaimable > zone->min_slab_pages) {
+	nr_slab_pages0 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+	if (nr_slab_pages0 > zone->min_slab_pages) {
 		/*
 		 * shrink_slab() does not currently allow us to determine how
 		 * many pages were freed in this zone. So we take the current
@@ -2628,16 +2628,17 @@ static int __zone_reclaim(struct zone *zone, gfp_t =
gfp_mask, unsigned int order)
 		 * take a long time.
 		 */
 		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
-			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
-				slab_reclaimable - nr_pages)
+		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
+				nr_slab_pages0))
 			;
=20
 		/*
 		 * Update nr_reclaimed by the number of slab pages we
 		 * reclaimed from this zone.
 		 */
-		sc.nr_reclaimed +=3D slab_reclaimable -
-			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+		nr_slab_pages1 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+		if (nr_slab_pages1 < nr_slab_pages0)
+			sc.nr_reclaimed +=3D nr_slab_pages0 - nr_slab_pages1;
 	}
=20
 	p->reclaim_state =3D NULL;
--=20
1.6.5.2







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
