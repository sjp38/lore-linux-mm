Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AF2D56B007D
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 00:10:40 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C5AbTv012486
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Jan 2010 14:10:38 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9278645DE4F
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 14:10:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C92445DE4E
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 14:10:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5252F1DB803C
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 14:10:37 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 070E71DB803A
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 14:10:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for memory free
In-Reply-To: <20100112133223.005b81ed.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100112042116.GA26035@localhost> <20100112133223.005b81ed.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20100112140923.B3A4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 12 Jan 2010 14:10:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 12 Jan 2010 12:21:16 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > BTW,
> > > Hmm. It's not atomic as Kame pointed out.
> > >=20
> > > Now, zone->flags have several bit.
> > >  * ZONE_ALL_UNRECLAIMALBE
> > >  * ZONE_RECLAIM_LOCKED
> > >  * ZONE_OOM_LOCKED.
> > >=20
> > > I think this flags are likely to race when the memory pressure is hig=
h.
> > > If we don't prevent race, concurrent reclaim and killing could be hap=
pened.
> > > So I think reset zone->flags outside of zone->lock would make our eff=
orts which
> > > prevent current reclaim and killing invalidate.
> >=20
> > zone_set_flag()/zone_clear_flag() calls set_bit()/clear_bit() which is
> > atomic. Do you mean more high level exclusion?
> >=20
> Ah, sorry, I missed that.
> In my memory, this wasn't atomic ;) ...maybe recent change.
>=20
> I don't want to see atomic_ops here...So, how about making this back to b=
e
> zone->all_unreclaimable word ?
>=20
> Clearing this is not necessary to be atomic because this is cleard at eve=
ry
> page freeing.

I agree. How about this?



=46rom 751f197ad256c7245151681d7aece591b1dab343 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 12 Jan 2010 13:53:47 +0900
Subject: [PATCH] mm: Restore zone->all_unreclaimable to independence word

commit e815af95 (change all_unreclaimable zone member to flags) chage
all_unreclaimable member to bit flag. but It have undesireble side
effect.
free_one_page() is one of most hot path in linux kernel and increasing
atomic ops in it can reduce kernel performance a bit.

Thus, this patch revert such commit partially. at least
all_unreclaimable shouldn't share memory word with other zone flags.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mmzone.h |    7 +------
 mm/page_alloc.c        |    6 +++---
 mm/vmscan.c            |   20 ++++++++------------
 mm/vmstat.c            |    2 +-
 4 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 30fe668..4f0c6f1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -341,6 +341,7 @@ struct zone {
=20
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
+	int                     all_unreclaimable; /* All pages pinned */
=20
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
@@ -425,7 +426,6 @@ struct zone {
 } ____cacheline_internodealigned_in_smp;
=20
 typedef enum {
-	ZONE_ALL_UNRECLAIMABLE,		/* all pages pinned */
 	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
 } zone_flags_t;
@@ -445,11 +445,6 @@ static inline void zone_clear_flag(struct zone *zone, =
zone_flags_t flag)
 	clear_bit(flag, &zone->flags);
 }
=20
-static inline int zone_is_all_unreclaimable(const struct zone *zone)
-{
-	return test_bit(ZONE_ALL_UNRECLAIMABLE, &zone->flags);
-}
-
 static inline int zone_is_reclaim_locked(const struct zone *zone)
 {
 	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e9f5cc..19a5b0e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -530,7 +530,7 @@ static void free_pcppages_bulk(struct zone *zone, int c=
ount,
 	int batch_free =3D 0;
=20
 	spin_lock(&zone->lock);
-	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
+	zone->all_unreclaimable =3D 0;
 	zone->pages_scanned =3D 0;
=20
 	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
@@ -567,7 +567,7 @@ static void free_one_page(struct zone *zone, struct pag=
e *page, int order,
 				int migratetype)
 {
 	spin_lock(&zone->lock);
-	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
+	zone->all_unreclaimable =3D 0;
 	zone->pages_scanned =3D 0;
=20
 	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
@@ -2270,7 +2270,7 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			zone->pages_scanned,
-			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
+			(zone->all_unreclaimable ? "yes" : "no")
 			);
 		printk("lowmem_reserve[]:");
 		for (i =3D 0; i < MAX_NR_ZONES; i++)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 885207a..8057d36 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1694,8 +1694,7 @@ static void shrink_zones(int priority, struct zonelis=
t *zonelist,
 				continue;
 			note_zone_scanning_priority(zone, priority);
=20
-			if (zone_is_all_unreclaimable(zone) &&
-						priority !=3D DEF_PRIORITY)
+			if (zone->all_unreclaimable && priority !=3D DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
 			sc->all_unreclaimable =3D 0;
 		} else {
@@ -2009,8 +2008,7 @@ loop_again:
 			if (!populated_zone(zone))
 				continue;
=20
-			if (zone_is_all_unreclaimable(zone) &&
-			    priority !=3D DEF_PRIORITY)
+			if (zone->all_unreclaimable && priority !=3D DEF_PRIORITY)
 				continue;
=20
 			/*
@@ -2053,8 +2051,7 @@ loop_again:
 			if (!populated_zone(zone))
 				continue;
=20
-			if (zone_is_all_unreclaimable(zone) &&
-					priority !=3D DEF_PRIORITY)
+			if (zone->all_unreclaimable && priority !=3D DEF_PRIORITY)
 				continue;
=20
 			if (!zone_watermark_ok(zone, order,
@@ -2084,12 +2081,11 @@ loop_again:
 						lru_pages);
 			sc.nr_reclaimed +=3D reclaim_state->reclaimed_slab;
 			total_scanned +=3D sc.nr_scanned;
-			if (zone_is_all_unreclaimable(zone))
+			if (zone->all_unreclaimable)
 				continue;
-			if (nr_slab =3D=3D 0 && zone->pages_scanned >=3D
-					(zone_reclaimable_pages(zone) * 6))
-					zone_set_flag(zone,
-						      ZONE_ALL_UNRECLAIMABLE);
+			if (nr_slab =3D=3D 0 &&
+			    zone->pages_scanned >=3D (zone_reclaimable_pages(zone) * 6))
+				zone->all_unreclaimable =3D 1;
 			/*
 			 * If we've done a decent amount of scanning and
 			 * the reclaim ratio is low, start doing writepage
@@ -2612,7 +2608,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, u=
nsigned int order)
 	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <=3D zone->min_slab_pages)
 		return ZONE_RECLAIM_FULL;
=20
-	if (zone_is_all_unreclaimable(zone))
+	if (zone->all_unreclaimable)
 		return ZONE_RECLAIM_FULL;
=20
 	/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6051fba..8175c64 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -761,7 +761,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_=
data_t *pgdat,
 		   "\n  prev_priority:     %i"
 		   "\n  start_pfn:         %lu"
 		   "\n  inactive_ratio:    %u",
-			   zone_is_all_unreclaimable(zone),
+		   zone->all_unreclaimable,
 		   zone->prev_priority,
 		   zone->zone_start_pfn,
 		   zone->inactive_ratio);
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
