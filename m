Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AF1EC6B02A3
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 21:40:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6G1dxSx028305
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Jul 2010 10:39:59 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BA1D327839
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 10:39:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FFD345DD6C
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 10:39:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E65191DB803C
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 10:39:58 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9873C1DB804A
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 10:39:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of lru_pages,  not page order
In-Reply-To: <20100715121551.bd5ccc61.akpm@linux-foundation.org>
References: <20100713144008.EA52.A69D9226@jp.fujitsu.com> <20100715121551.bd5ccc61.akpm@linux-foundation.org>
Message-Id: <20100716090302.7351.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 16 Jul 2010 10:39:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> >  	nr_slab_pages0 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> >  	if (nr_slab_pages0 > zone->min_slab_pages) {
> > +		unsigned long lru_pages =3D zone_reclaimable_pages(zone);
> > +
> >  		/*
> >  		 * shrink_slab() does not currently allow us to determine how
> >  		 * many pages were freed in this zone. So we take the current
> > @@ -2622,7 +2624,7 @@ static int __zone_reclaim(struct zone *zone, gfp_=
t gfp_mask, unsigned int order)
> >  		 * Note that shrink_slab will free memory on all zones and may
> >  		 * take a long time.
> >  		 */
> > -		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
> > +		while (shrink_slab(sc.nr_scanned, gfp_mask, lru_pages) &&
> >  		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
> >  			nr_slab_pages0))
> >  			;
>=20
> Wouldn't it be better to recalculate zone_reclaimable_pages() each time
> around the loop?  For example, shrink_icache_memory()->prune_icache()
> will remove pagecache from an inode if it hits the tail of the list.=20
> This can change the number of reclaimable pages by squigabytes, but
> this code thinks nothing changed?

Ah, I missed this. incrementa patch is here.

thank you!



=46rom 8f7c70cfb4a25f8292a59564db6c3ff425a69b53 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 16 Jul 2010 08:40:01 +0900
Subject: [PATCH] vmscan: recalculate lru_pages on each shrink_slab()

Andrew Morton pointed out shrink_slab() may change number of reclaimable
pages (e.g. shrink_icache_memory()->prune_icache() will remove unmapped
pagecache).

So, we need to recalculate lru_pages on each shrink_slab() calling.
This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1bf9f72..1da9b14 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2612,8 +2612,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gf=
p_mask, unsigned int order)
=20
 	nr_slab_pages0 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	if (nr_slab_pages0 > zone->min_slab_pages) {
-		unsigned long lru_pages =3D zone_reclaimable_pages(zone);
-
 		/*
 		 * shrink_slab() does not currently allow us to determine how
 		 * many pages were freed in this zone. So we take the current
@@ -2624,10 +2622,18 @@ static int __zone_reclaim(struct zone *zone, gfp_t =
gfp_mask, unsigned int order)
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, lru_pages) &&
-		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
-			nr_slab_pages0))
-			;
+		for (;;) {
+			unsigned long lru_pages =3D zone_reclaimable_pages(zone);
+
+			/* No reclaimable slab or very low memroy pressure */
+			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages))
+				break;
+
+			/* Freed enouch memory */
+			nr_slab_pages1 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+			if (nr_slab_pages1 + nr_pages <=3D nr_slab_pages0)
+				break;
+		}
=20
 		/*
 		 * Update nr_reclaimed by the number of slab pages we
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
