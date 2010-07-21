Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 616E76B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 09:34:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6LDY2Qv024215
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 21 Jul 2010 22:34:02 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1646545DE6C
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BD37A45DE78
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D145FE18005
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:33:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3439E18006
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:33:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/7] memcg: nid and zid can be calculated from zone
In-Reply-To: <20100716105648.GG13117@csn.ul.ie>
References: <20100716191418.7372.A69D9226@jp.fujitsu.com> <20100716105648.GG13117@csn.ul.ie>
Message-Id: <20100721223349.870D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 21 Jul 2010 22:33:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

> > +static inline int zone_nid(struct zone *zone)
> > +{
> > +	return zone->zone_pgdat->node_id;
> > +}
> > +
>=20
> hmm, adding a helper and not converting the existing users of
> zone->zone_pgdat may be a little confusing particularly as both types of
> usage would exist in the same file e.g. in mem_cgroup_zone_nr_pages.

I see. here is incrementa patch.

Thanks

=46rom 62cf765251af257c98fc92a58215d101d200e7ef Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 20 Jul 2010 11:30:14 +0900
Subject: [PATCH] memcg: convert to zone_nid() from bare zone->zone_pgdat->n=
ode_id

Now, we have zone_nid(). this patch convert all existing users of
zone->zone_pgdat.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/memcontrol.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 82e191f..3d5b645 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -951,7 +951,7 @@ unsigned long mem_cgroup_zone_nr_pages(struct mem_cgrou=
p *memcg,
 				       struct zone *zone,
 				       enum lru_list lru)
 {
-	int nid =3D zone->zone_pgdat->node_id;
+	int nid =3D zone_nid(zone);
 	int zid =3D zone_idx(zone);
 	struct mem_cgroup_per_zone *mz =3D mem_cgroup_zoneinfo(memcg, nid, zid);
=20
@@ -961,7 +961,7 @@ unsigned long mem_cgroup_zone_nr_pages(struct mem_cgrou=
p *memcg,
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *m=
emcg,
 						      struct zone *zone)
 {
-	int nid =3D zone->zone_pgdat->node_id;
+	int nid =3D zone_nid(zone);
 	int zid =3D zone_idx(zone);
 	struct mem_cgroup_per_zone *mz =3D mem_cgroup_zoneinfo(memcg, nid, zid);
=20
@@ -1006,7 +1006,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long =
nr_to_scan,
 	LIST_HEAD(pc_list);
 	struct list_head *src;
 	struct page_cgroup *pc, *tmp;
-	int nid =3D z->zone_pgdat->node_id;
+	int nid =3D zone_nid(z);
 	int zid =3D zone_idx(z);
 	struct mem_cgroup_per_zone *mz;
 	int lru =3D LRU_FILE * file + active;
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
