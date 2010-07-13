Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4666F6B02A5
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 05:32:27 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D9WNx3014434
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Jul 2010 18:32:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BD4F45DE4F
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 18:32:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E543F45DE4C
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 18:32:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CB6D81DB8014
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 18:32:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 724951DB8012
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 18:32:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 1/2] vmscan: don't subtraction of unsined
In-Reply-To: <20100709152851.330bf2b2.akpm@linux-foundation.org>
References: <20100709090956.CD51.A69D9226@jp.fujitsu.com> <20100709152851.330bf2b2.akpm@linux-foundation.org>
Message-Id: <20100713182918.EA67.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 13 Jul 2010 18:32:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Fri,  9 Jul 2010 10:16:33 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>=20
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2588,7 +2588,7 @@ static int __zone_reclaim(struct zone *zone, gfp_=
t gfp_mask, unsigned int order)
> >  		.swappiness =3D vm_swappiness,
> >  		.order =3D order,
> >  	};
> > -	unsigned long slab_reclaimable;
> > +	unsigned long nr_slab_pages0, nr_slab_pages1;
> > =20
> >  	disable_swap_token();
> >  	cond_resched();
> > @@ -2615,8 +2615,8 @@ static int __zone_reclaim(struct zone *zone, gfp_=
t gfp_mask, unsigned int order)
> >  		} while (priority >=3D 0 && sc.nr_reclaimed < nr_pages);
> >  	}
> > =20
> > -	slab_reclaimable =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> > -	if (slab_reclaimable > zone->min_slab_pages) {
> > +	nr_slab_pages0 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> > +	if (nr_slab_pages0 > zone->min_slab_pages) {
> >  		/*
> >  		 * shrink_slab() does not currently allow us to determine how
> >  		 * many pages were freed in this zone.
>=20
> Well no, but it could do so, with some minor changes to struct
> reclaim_state and its handling.  Put a zone* and a counter in
> reclaim_state, handle them in sl?b.c.
>=20
> > So we take the current
> > @@ -2628,16 +2628,17 @@ static int __zone_reclaim(struct zone *zone, gf=
p_t gfp_mask, unsigned int order)
> >  		 * take a long time.
> >  		 */
> >  		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
> > -			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
> > -				slab_reclaimable - nr_pages)
> > +		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
> > +				nr_slab_pages0))
> >  			;
> > =20
> >  		/*
> >  		 * Update nr_reclaimed by the number of slab pages we
> >  		 * reclaimed from this zone.
> >  		 */
> > -		sc.nr_reclaimed +=3D slab_reclaimable -
> > -			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> > +		nr_slab_pages1 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> > +		if (nr_slab_pages1 < nr_slab_pages0)
> > +			sc.nr_reclaimed +=3D nr_slab_pages0 - nr_slab_pages1;
>=20
> My, that's horrible.  The whole expression says "this number is
> basically a pile of random junk.  Let's add it in anyway".
>=20
>=20
> >  	}
> > =20
> >  	p->reclaim_state =3D NULL;


How's this?

Christoph, Can we hear your opinion about to add new branch in slab-free pa=
th?
I think this is ok, because reclaim makes a lot of cache miss then branch
mistaken is relatively minor penalty. thought?



=46rom 9f7d7a9bd836b7373ade3056e6a3d2a3d82ac7ce Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 13 Jul 2010 14:43:21 +0900
Subject: [PATCH] vmscan: count reclaimed slab pages properly

Andrew Morton pointed out __zone_reclaim() shouldn't compare old and new
zone_page_state(NR_SLAB_RECLAIMABLE) result. Instead, it have to account
number of free slab pages by to enhance reclaim_state.

This patch does it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/swap.h |    3 ++-
 mm/slab.c            |    4 +++-
 mm/slob.c            |    4 +++-
 mm/slub.c            |    7 +++++--
 mm/vmscan.c          |   44 ++++++++++++++++----------------------------
 5 files changed, 29 insertions(+), 33 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ff4acea..b8d3f33 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -107,7 +107,8 @@ typedef struct {
  * memory reclaim
  */
 struct reclaim_state {
-	unsigned long reclaimed_slab;
+	unsigned long	reclaimed_slab;
+	struct zone	*zone;
 };
=20
 #ifdef __KERNEL__
diff --git a/mm/slab.c b/mm/slab.c
index 4e9c46f..aac9306 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1741,7 +1741,9 @@ static void kmem_freepages(struct kmem_cache *cachep,=
 void *addr)
 		page++;
 	}
 	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab +=3D nr_freed;
+		if (!current->reclaim_state->zone ||
+		    current->reclaim_state->zone =3D=3D page_zone(page))
+			current->reclaim_state->reclaimed_slab +=3D nr_freed;
 	free_pages((unsigned long)addr, cachep->gfporder);
 }
=20
diff --git a/mm/slob.c b/mm/slob.c
index 3f19a34..192d05c 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -260,7 +260,9 @@ static void *slob_new_pages(gfp_t gfp, int order, int n=
ode)
 static void slob_free_pages(void *b, int order)
 {
 	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab +=3D 1 << order;
+		if (!current->reclaim_state->zone ||
+		    current->reclaim_state->zone =3D=3D page_zone(page))
+			current->reclaim_state->reclaimed_slab +=3D 1 << order;
 	free_pages((unsigned long)b, order);
 }
=20
diff --git a/mm/slub.c b/mm/slub.c
index 7bb7940..f510b14 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1204,8 +1204,11 @@ static void __free_slab(struct kmem_cache *s, struct=
 page *page)
=20
 	__ClearPageSlab(page);
 	reset_page_mapcount(page);
-	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab +=3D pages;
+	if (current->reclaim_state) {
+		if (!current->reclaim_state->zone ||
+		    current->reclaim_state->zone =3D=3D page_zone(page))
+			current->reclaim_state->reclaimed_slab +=3D pages;
+	}
 	__free_pages(page, order);
 }
=20
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1bf9f72..8faef0c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2571,7 +2571,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gf=
p_mask, unsigned int order)
 	/* Minimum pages needed in order to stay on node */
 	const unsigned long nr_pages =3D 1 << order;
 	struct task_struct *p =3D current;
-	struct reclaim_state reclaim_state;
 	int priority;
 	struct scan_control sc =3D {
 		.may_writepage =3D !!(zone_reclaim_mode & RECLAIM_WRITE),
@@ -2583,8 +2582,10 @@ static int __zone_reclaim(struct zone *zone, gfp_t g=
fp_mask, unsigned int order)
 		.swappiness =3D vm_swappiness,
 		.order =3D order,
 	};
-	unsigned long nr_slab_pages0, nr_slab_pages1;
-
+	struct reclaim_state reclaim_state =3D {
+		.reclaimed_slab =3D 0,
+		.zone		=3D zone,
+	};
=20
 	cond_resched();
 	/*
@@ -2594,7 +2595,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gf=
p_mask, unsigned int order)
 	 */
 	p->flags |=3D PF_MEMALLOC | PF_SWAPWRITE;
 	lockdep_set_current_reclaim_state(gfp_mask);
-	reclaim_state.reclaimed_slab =3D 0;
 	p->reclaim_state =3D &reclaim_state;
=20
 	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {
@@ -2610,34 +2610,22 @@ static int __zone_reclaim(struct zone *zone, gfp_t =
gfp_mask, unsigned int order)
 		} while (priority >=3D 0 && sc.nr_reclaimed < nr_pages);
 	}
=20
-	nr_slab_pages0 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-	if (nr_slab_pages0 > zone->min_slab_pages) {
+	if (zone_page_state(zone, NR_SLAB_RECLAIMABLE) > zone->min_slab_pages) {
 		unsigned long lru_pages =3D zone_reclaimable_pages(zone);
=20
-		/*
-		 * shrink_slab() does not currently allow us to determine how
-		 * many pages were freed in this zone. So we take the current
-		 * number of slab pages and shake the slab until it is reduced
-		 * by the same nr_pages that we used for reclaiming unmapped
-		 * pages.
-		 *
-		 * Note that shrink_slab will free memory on all zones and may
-		 * take a long time.
-		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, lru_pages) &&
-		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
-			nr_slab_pages0))
-			;
-
-		/*
-		 * Update nr_reclaimed by the number of slab pages we
-		 * reclaimed from this zone.
-		 */
-		nr_slab_pages1 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-		if (nr_slab_pages1 < nr_slab_pages0)
-			sc.nr_reclaimed +=3D nr_slab_pages0 - nr_slab_pages1;
+		for(;;) {
+			/*
+			 * Note that shrink_slab will free memory on all zones
+			 * and may take a long time.
+			 */
+			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages))
+				break;
+			if (reclaim_state.reclaimed_slab >=3D nr_pages)
+				break;
+		}
 	}
=20
+	sc.nr_reclaimed +=3D reclaim_state.reclaimed_slab;
 	p->reclaim_state =3D NULL;
 	current->flags &=3D ~(PF_MEMALLOC | PF_SWAPWRITE);
 	lockdep_clear_current_reclaim_state();
--=20
1.6.5.2






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
