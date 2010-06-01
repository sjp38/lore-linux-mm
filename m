Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 13EB36B01B6
	for <linux-mm@kvack.org>; Mon, 31 May 2010 23:29:46 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o513ThrE030996
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 12:29:43 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B040545DE55
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 12:29:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 856D545DE61
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 12:29:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EA8F1DB8042
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 12:29:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DFCEC1DB8041
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 12:29:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan: Fix do_try_to_free_pages() return value when priority==0 reclaim failure
In-Reply-To: <xr93sk57yl9o.fsf@ninji.mtv.corp.google.com>
References: <20100430224316.056084208@cmpxchg.org> <xr93sk57yl9o.fsf@ninji.mtv.corp.google.com>
Message-Id: <20100601122140.2436.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue,  1 Jun 2010 12:29:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

CC to memcg folks.

> I agree with the direction of this patch, but I am seeing a hang when
> testing with mmotm-2010-05-21-16-05.  The following test hangs, unless I
> remove this patch from mmotm:
>   mount -t cgroup none /cgroups -o memory
>   mkdir /cgroups/cg1
>   echo $$ > /cgroups/cg1/tasks
>   dd bs=3D1024 count=3D1024 if=3D/dev/null of=3D/data/foo
>   echo $$ > /cgroups/tasks
>   echo 1 > /cgroups/cg1/memory.force_empty
>=20
> I think the hang is caused by the following portion of
> mem_cgroup_force_empty():
> 	while (nr_retries && mem->res.usage > 0) {
> 		int progress;
>=20
> 		if (signal_pending(current)) {
> 			ret =3D -EINTR;
> 			goto out;
> 		}
> 		progress =3D try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> 						false, get_swappiness(mem));
> 		if (!progress) {
> 			nr_retries--;
> 			/* maybe some writeback is necessary */
> 			congestion_wait(BLK_RW_ASYNC, HZ/10);
> 		}
>=20
> 	}
>=20
> With this patch applied, it is possible that when do_try_to_free_pages()
> calls shrink_zones() for priority 0 that shrink_zones() may return 1
> indicating progress, even though no pages may have been reclaimed.
> Because this is a cgroup operation, scanning_global_lru() is false and
> the following portion of do_try_to_free_pages() fails to set ret=3D0.
> > 	if (ret && scanning_global_lru(sc))
> >  		ret =3D sc->nr_reclaimed;
> This leaves ret=3D1 indicating that do_try_to_free_pages() reclaimed 1
> page even though it did not reclaim any pages.  Therefore
> mem_cgroup_force_empty() erroneously believes that
> try_to_free_mem_cgroup_pages() is making progress (one page at a time),
> so there is an endless loop.

Good catch!

Yeah, your analysis is fine. thank you for both your testing and
making analysis.

Unfortunatelly, this logic need more fix. because It have already been
corrupted by another regression. my point is, if priority=3D=3D0 reclaim=20
failure occur, "ret =3D sc->nr_reclaimed" makes no sense at all.

The fixing patch is here. What do you think?



=46rom 49a395b21fe1b2f864112e71d027ffcafbdc9fc0 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 1 Jun 2010 11:29:50 +0900
Subject: [PATCH] vmscan: Fix do_try_to_free_pages() return value when prior=
ity=3D=3D0 reclaim failure

Greg Thelen reported recent Johannes's stack diet patch makes kernel
hang. His test is following.

  mount -t cgroup none /cgroups -o memory
  mkdir /cgroups/cg1
  echo $$ > /cgroups/cg1/tasks
  dd bs=3D1024 count=3D1024 if=3D/dev/null of=3D/data/foo
  echo $$ > /cgroups/tasks
  echo 1 > /cgroups/cg1/memory.force_empty

Actually, This OOM hard to try logic have been corrupted
since following two years old patch.

	commit a41f24ea9fd6169b147c53c2392e2887cc1d9247
	Author: Nishanth Aravamudan <nacc@us.ibm.com>
	Date:   Tue Apr 29 00:58:25 2008 -0700

	    page allocator: smarter retry of costly-order allocations

Original intention was "return success if the system have shrinkable
zones though priority=3D=3D0 reclaim was failure". But the above patch
changed to "return nr_reclaimed if .....". Oh, That forgot nr_reclaimed
may be 0 if priority=3D=3D0 reclaim failure.

And Johannes's patch made more corrupt. Originally, priority=3D=3D0 recliam
failure on memcg return 0, but this patch changed to return 1. It
totally confused memcg.

This patch fixes it completely.

Reported-by: Greg Thelen <gthelen@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 915dceb..a204209 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1724,13 +1724,13 @@ static void shrink_zone(int priority, struct zone *=
zone,
  * If a zone is deemed to be full of pinned pages then just give it a ligh=
t
  * scan then give up on it.
  */
-static int shrink_zones(int priority, struct zonelist *zonelist,
+static bool shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	enum zone_type high_zoneidx =3D gfp_zone(sc->gfp_mask);
 	struct zoneref *z;
 	struct zone *zone;
-	int progress =3D 0;
+	bool all_unreclaimable =3D true;
=20
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
 					sc->nodemask) {
@@ -1757,9 +1757,9 @@ static int shrink_zones(int priority, struct zonelist=
 *zonelist,
 		}
=20
 		shrink_zone(priority, zone, sc);
-		progress =3D 1;
+		all_unreclaimable =3D false;
 	}
-	return progress;
+	return all_unreclaimable;
 }
=20
 /*
@@ -1782,7 +1782,7 @@ static unsigned long do_try_to_free_pages(struct zone=
list *zonelist,
 					struct scan_control *sc)
 {
 	int priority;
-	unsigned long ret =3D 0;
+	bool all_unreclaimable;=20
 	unsigned long total_scanned =3D 0;
 	struct reclaim_state *reclaim_state =3D current->reclaim_state;
 	unsigned long lru_pages =3D 0;
@@ -1813,7 +1813,7 @@ static unsigned long do_try_to_free_pages(struct zone=
list *zonelist,
 		sc->nr_scanned =3D 0;
 		if (!priority)
 			disable_swap_token();
-		ret =3D shrink_zones(priority, zonelist, sc);
+		all_unreclaimable =3D shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1826,10 +1826,8 @@ static unsigned long do_try_to_free_pages(struct zon=
elist *zonelist,
 			}
 		}
 		total_scanned +=3D sc->nr_scanned;
-		if (sc->nr_reclaimed >=3D sc->nr_to_reclaim) {
-			ret =3D sc->nr_reclaimed;
+		if (sc->nr_reclaimed >=3D sc->nr_to_reclaim)
 			goto out;
-		}
=20
 		/*
 		 * Try to write back as many pages as we just scanned.  This
@@ -1849,9 +1847,7 @@ static unsigned long do_try_to_free_pages(struct zone=
list *zonelist,
 		    priority < DEF_PRIORITY - 2)
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
-	/* top priority shrink_zones still had more to do? don't OOM, then */
-	if (ret && scanning_global_lru(sc))
-		ret =3D sc->nr_reclaimed;
+
 out:
 	/*
 	 * Now that we've scanned all the zones at this priority level, note
@@ -1877,7 +1873,14 @@ out:
 	delayacct_freepages_end();
 	put_mems_allowed();
=20
-	return ret;
+	if (sc->nr_reclaimed)
+		return sc->nr_reclaimed;
+
+	/* top priority shrink_zones still had more to do? don't OOM, then */
+	if (scanning_global_lru(sc) && !all_unreclaimable)
+		return 1;
+
+	return 0;
 }
=20
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
--=20
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
