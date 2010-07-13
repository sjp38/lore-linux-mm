Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1FC806B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 01:41:32 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D5fTIX008071
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Jul 2010 14:41:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B65445DE6E
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:41:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 51D9345DE60
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:41:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 35FCF1DB803E
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:41:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D36DF1DB803A
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:41:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of lru_pages,  not page order
In-Reply-To: <AANLkTinwZfaQiTJhP8RcGhlSS-ynEXtbpzorrIZrNyIH@mail.gmail.com>
References: <20100708163934.CD37.A69D9226@jp.fujitsu.com> <AANLkTinwZfaQiTJhP8RcGhlSS-ynEXtbpzorrIZrNyIH@mail.gmail.com>
Message-Id: <20100713144008.EA52.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 13 Jul 2010 14:41:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Thu, Jul 8, 2010 at 4:40 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Fix simple argument error. Usually 'order' is very small value than
> > lru_pages. then it can makes unnecessary icache dropping.
> >
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>=20
> With your test result, This patch makes sense to me.
> Please, include your test result in description.

How's this?

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46rom 19872d74875e2331cbe7eca46c8ef65f5f00d7c4 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 13 Jul 2010 13:39:11 +0900
Subject: [PATCH] vmscan: shrink_slab() require number of lru_pages, not pag=
e order

Now, shrink_slab() has following scanning equation.

                            lru_scanned        max_pass
  basic_scan_objects =3D 4 x -------------  x -----------------------------
                            lru_pages        shrinker->seeks (default:2)

  scan_objects =3D min(basic_scan_objects, max_pass * 2)

Then, If we pass very small value as lru_pages instead real number of
lru pages, shrink_slab() drop much objects rather than necessary. and
now, __zone_reclaim() pass 'order' as lru_pages by mistake. that makes
bad result.

Example, If we receive very low memory pressure (scan =3D 32, order =3D 0),
shrink_slab() via zone_reclaim() always drop _all_ icache/dcache
objects. (see above equation, very small lru_pages make very big
scan_objects result)

This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Christoph Lameter <cl@linux-foundation.org>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6ff51c0..1bf9f72 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2612,6 +2612,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gf=
p_mask, unsigned int order)
=20
 	nr_slab_pages0 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	if (nr_slab_pages0 > zone->min_slab_pages) {
+		unsigned long lru_pages =3D zone_reclaimable_pages(zone);
+
 		/*
 		 * shrink_slab() does not currently allow us to determine how
 		 * many pages were freed in this zone. So we take the current
@@ -2622,7 +2624,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gf=
p_mask, unsigned int order)
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
+		while (shrink_slab(sc.nr_scanned, gfp_mask, lru_pages) &&
 		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
 			nr_slab_pages0))
 			;
--=20
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
