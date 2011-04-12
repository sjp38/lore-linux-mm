Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E5C118D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 20:59:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8F5753EE0B5
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:59:55 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6740145DE4D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:59:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FA2545DE50
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:59:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 427A7E78003
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:59:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 048C81DB803E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:59:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <20110411141950.46d3d6da.akpm@linux-foundation.org>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com> <20110411141950.46d3d6da.akpm@linux-foundation.org>
Message-Id: <20110412095958.43F0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 12 Apr 2011 09:59:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> On Mon, 11 Apr 2011 17:19:31 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>=20
> > Recently, Robert Mueller reported zone_reclaim_mode doesn't work
>=20
> It's time for some nagging. =20
>=20
> I'm trying to work out what the user-visible effect of this problem
> was, but it isn't described in the changelog and there is no link to
> any report and not even a Reported-by: or a Cc: and a search for Robert
> in linux-mm and linux-kernel turned up blank.

Here.
	http://lkml.org/lkml/2010/9/12/236


>=20
> > properly on his new NUMA server (Dual Xeon E5520 + Intel S5520UR MB).
> > He is using Cyrus IMAPd and it's built on a very traditional
> > single-process model.
> >=20
> >   * a master process which reads config files and manages the other
> >     process
> >   * multiple imapd processes, one per connection
> >   * multiple pop3d processes, one per connection
> >   * multiple lmtpd processes, one per connection
> >   * periodical "cleanup" processes.
> >=20
> > Then, there are thousands of independent processes. The problem is,
> > recent Intel motherboard turn on zone_reclaim_mode by default and
> > traditional prefork model software don't work fine on it.
> > Unfortunatelly, Such model is still typical one even though 21th
> > century. We can't ignore them.
> >=20
> > This patch raise zone_reclaim_mode threshold to 30. 30 don't have
> > specific meaning. but 20 mean one-hop QPI/Hypertransport and such
> > relatively cheap 2-4 socket machine are often used for tradiotional
> > server as above. The intention is, their machine don't use
> > zone_reclaim_mode.
> >=20
> > Note: ia64 and Power have arch specific RECLAIM_DISTANCE definition.
> > then this patch doesn't change such high-end NUMA machine behavior.
> >=20
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Acked-by: Christoph Lameter <cl@linux.com>
> > Acked-by: David Rientjes <rientjes@google.com>
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/topology.h |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/include/linux/topology.h b/include/linux/topology.h
> > index b91a40e..fc839bf 100644
> > --- a/include/linux/topology.h
> > +++ b/include/linux/topology.h
> > @@ -60,7 +60,7 @@ int arch_update_cpu_topology(void);
> >   * (in whatever arch specific measurement units returned by node_dista=
nce())
> >   * then switch on zone reclaim on boot.
> >   */
> > -#define RECLAIM_DISTANCE 20
> > +#define RECLAIM_DISTANCE 30
>=20
> Any time we tweak a magic number to improve one platform, we risk
> causing deterioration on another.  Do we know that this risk is low
> with this patch?

In last thread, Robert Mueller who bug reporter explained he is only using
mere commodity whitebox hardware and very common workload.
Therefore, we agreed benefit is bigger than negative. IOW, mere whitebox
are used lots than special purpose one.



> Also, what are we doing setting
>=20
> 	zone_relaim_mode =3D 1;
>=20
> when we have nice enumerated constants for this?  It should be
>=20
> 	zone_relaim_mode =3D RECLAIM_ZONE;
>=20
> or, pedantically but clearer:
>=20
> 	zone_relaim_mode =3D RECLAIM_ZONE & !RECLAIM_WRITE & !RECLAIM_SWAP;

Indeed.



=46rom 0298eb3256bd17eb88584a90917be749bd8d2c98 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 12 Apr 2011 09:40:38 +0900
Subject: [PATCH 2/2] mm: Don't use hardcoded constant for zone_reclaim_mode

Initially, zone_reclaim_mode was introduced by commit 9eeff2395e3
(Zone reclaim: Reclaim logic). At that time, it was 0/1 boolean
variable.

Next, commit 1b2ffb7896 (Zone reclaim: Allow modification of zone reclaim
behavior) changed it to bitmask. But, page_alloc.c still use it as
boolean. It is slightly harder to read.

Let's convert it.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/swap.h |    5 +++++
 mm/page_alloc.c      |    2 +-
 mm/vmscan.c          |    5 -----
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 384eb5f..078ba25 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -266,6 +266,11 @@ extern int remove_mapping(struct address_space *mappin=
g, struct page *page);
 extern long vm_total_pages;
=20
 #ifdef CONFIG_NUMA
+#define RECLAIM_OFF 0
+#define RECLAIM_ZONE (1<<0)	/* Run shrink_inactive_list on the zone */
+#define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
+#define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
+
 extern int zone_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
 extern int sysctl_min_slab_ratio;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e400779..be8607e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2982,7 +2982,7 @@ static void build_zonelists(pg_data_t *pgdat)
 		 * to reclaim pages in a zone before going off node.
 		 */
 		if (distance > RECLAIM_DISTANCE)
-			zone_reclaim_mode =3D 1;
+			zone_reclaim_mode =3D RECLAIM_ZONE;
=20
 		/*
 		 * We don't want to pressure a particular node.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0c5a3d6..019e00c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2893,11 +2893,6 @@ module_init(kswapd_init)
  */
 int zone_reclaim_mode __read_mostly;
=20
-#define RECLAIM_OFF 0
-#define RECLAIM_ZONE (1<<0)	/* Run shrink_inactive_list on the zone */
-#define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
-#define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
-
 /*
  * Priority for ZONE_RECLAIM. This determines the fraction of pages
  * of a node considered for each zone_reclaim. 4 scans 1/16th of
--=20
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
