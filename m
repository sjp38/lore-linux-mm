Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 528746B006A
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 23:08:51 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0848mNQ032313
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 8 Jan 2010 13:08:48 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1812D45DE50
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 13:08:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DDA3345DE4E
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 13:08:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C44461DB8041
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 13:08:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7429F1DB803F
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 13:08:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
In-Reply-To: <20100108115531.C132.A69D9226@jp.fujitsu.com>
References: <20100108105841.b9a030c4.minchan.kim@barrios-desktop> <20100108115531.C132.A69D9226@jp.fujitsu.com>
Message-Id: <20100108130742.C138.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  8 Jan 2010 13:08:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Will Newton <will.newton@gmail.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Hi, Mel=20
> >=20
> > On Thu, 7 Jan 2010 13:58:31 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> >=20
> > > vmscan: kswapd should notice that all zones are not ok if they are un=
reclaimble
> > >=20
> > > In the event all zones are unreclaimble, it is possible for kswapd to
> > > never go to sleep because "all zones are ok even though watermarks ar=
e
> > > not reached". It gets into a situation where cond_reched() is not
> > > called.
> > >=20
> > > This patch notes that if all zones are unreclaimable then the zones a=
re
> > > not ok and cond_resched() should be called.
> > >=20
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > ---=20
> > >  mm/vmscan.c |    4 +++-
> > >  1 file changed, 3 insertions(+), 1 deletion(-)
> > >=20
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 2ad8603..d3c0848 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2022,8 +2022,10 @@ loop_again:
> > >  				break;
> > >  			}
> > >  		}
> > > -		if (i < 0)
> > > +		if (i < 0) {
> > > +			all_zones_ok =3D 0;
> > >  			goto out;
> > > +		}
> > > =20
> > >  		for (i =3D 0; i <=3D end_zone; i++) {
> > >  			struct zone *zone =3D pgdat->node_zones + i;
> > >=20
> > > --
> >=20
> > Nice catch!
> > Don't we care following as although it is rare case?
> >=20
> > ---
> >                 for (i =3D 0; i <=3D end_zone; i++) {
> >                         struct zone *zone =3D pgdat->node_zones + i;=20
> >                         int nr_slab;
> >                         int nid, zid;=20
> >=20
> >                         if (!populated_zone(zone))
> >                                 continue;
> >=20
> >                         if (zone_is_all_unreclaimable(zone) &&
> >                                         priority !=3D DEF_PRIORITY)
> >                                 continue;  <=3D=3D=3D=3D here
> >=20
> > ---
> >=20
> > And while I review all_zones_ok'usage in balance_pgdat,=20
> > I feel it's not consistent and rather confused.=20
> > How about this?
>=20
> Can you please read my patch?

Grr. I'm sorry. such thread don't CCed LKML.
cut-n-past here.


----------------------------------------
Umm..
This code looks a bit risky. Please imazine asymmetric numa. If the system =
has
very small node, its nude have unreclaimable state at almost time.

Thus, if all zones in the node are unreclaimable, It should be slept. To re=
try balance_pgdat()
is meaningless. this is original intention, I think.

So why can't we write following?

=46rom c00d7bb29552d3aa4d934b5007f3d52ade5f2dfd Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 8 Jan 2010 08:36:05 +0900
Subject: [PATCH] vmscan: kswapd don't retry balance_pgdat() if all zones ar=
e unreclaimable

Commit f50de2d3 (vmscan: have kswapd sleep for a short interval and
double check it should be asleep) can cause kswapd to enter an infinite
loop if running on a single-CPU system. If all zones are unreclaimble,
sleeping_prematurely return 1 and kswapd will call balance_pgdat()
again. but it's totally meaningless, balance_pgdat() doesn't anything
against unreclaimable zone!

Cc: Mel Gorman <mel@csn.ul.ie>
Reported-by: Will Newton <will.newton@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2bbee91..56327d5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1922,6 +1922,9 @@ static int sleeping_prematurely(pg_data_t *pgdat, int=
 order, long remaining)
 		if (!populated_zone(zone))
 			continue;
=20
+		if (zone_is_all_unreclaimable(zone))
+			continue;
+
 		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
 								0, 0))
 			return 1;
--=20
1.6.5.2







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
