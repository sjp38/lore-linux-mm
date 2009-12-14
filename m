Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 732916B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 07:31:41 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBECVcXq003597
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Dec 2009 21:31:38 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F1B5D45DE51
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:31:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C85D245DD75
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:31:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AD55D1DB803E
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:31:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EFB11DB8041
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:31:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 6/8] Stop reclaim quickly when the task reclaimed enough lots pages
In-Reply-To: <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
Message-Id: <20091214213103.BBC0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 14 Dec 2009 21:31:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>


=46rom latency view, There isn't any reason shrink_zones() continue to
reclaim another zone's page if the task reclaimed enough lots pages.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0880668..bf229d3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1654,7 +1654,7 @@ static void shrink_zone_end(struct zone *zone, struct=
 scan_control *sc)
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct re=
claim.
  */
-static void shrink_zone(int priority, struct zone *zone,
+static int shrink_zone(int priority, struct zone *zone,
 			struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
@@ -1669,7 +1669,7 @@ static void shrink_zone(int priority, struct zone *zo=
ne,
=20
 	ret =3D shrink_zone_begin(zone, sc);
 	if (ret)
-		return;
+		return ret;
=20
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <=3D 0)) {
@@ -1692,6 +1692,7 @@ static void shrink_zone(int priority, struct zone *zo=
ne,
 					  &reclaim_stat->nr_saved_scan[l]);
 	}
=20
+	ret =3D 0;
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {
@@ -1712,8 +1713,10 @@ static void shrink_zone(int priority, struct zone *z=
one,
 		 * with multiple processes reclaiming pages, the total
 		 * freeing target can get unreasonably large.
 		 */
-		if (nr_reclaimed >=3D nr_to_reclaim && priority < DEF_PRIORITY)
+		if (nr_reclaimed >=3D nr_to_reclaim && priority < DEF_PRIORITY) {
+			ret =3D -ERESTARTSYS;
 			break;
+		}
 	}
=20
 	sc->nr_reclaimed =3D nr_reclaimed;
@@ -1727,6 +1730,8 @@ static void shrink_zone(int priority, struct zone *zo=
ne,
=20
 	throttle_vm_writeout(sc->gfp_mask);
 	shrink_zone_end(zone, sc);
+
+	return ret;
 }
=20
 /*
@@ -1751,6 +1756,7 @@ static void shrink_zones(int priority, struct zonelis=
t *zonelist,
 	enum zone_type high_zoneidx =3D gfp_zone(sc->gfp_mask);
 	struct zoneref *z;
 	struct zone *zone;
+	int ret;
=20
 	sc->all_unreclaimable =3D 1;
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
@@ -1780,7 +1786,9 @@ static void shrink_zones(int priority, struct zonelis=
t *zonelist,
 							priority);
 		}
=20
-		shrink_zone(priority, zone, sc);
+		ret =3D shrink_zone(priority, zone, sc);
+		if (ret)
+			return;
 	}
 }
=20
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
