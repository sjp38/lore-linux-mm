Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 317FB6B005A
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 22:43:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9R2h0bt014478
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 27 Oct 2009 11:43:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BF4145DE60
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:43:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5960945DE4D
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:43:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4096B1DB803A
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:43:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E2BC21DB8037
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:42:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] vmscan: Force kswapd to take notice faster when high-order watermarks are being hit
In-Reply-To: <1256221356-26049-4-git-send-email-mel@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-4-git-send-email-mel@csn.ul.ie>
Message-Id: <20091026232924.2F75.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 27 Oct 2009 11:42:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> When a high-order allocation fails, kswapd is kicked so that it reclaims
> at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
> allocations. Something has changed in recent kernels that affect the timi=
ng
> where high-order GFP_ATOMIC allocations are now failing with more frequen=
cy,
> particularly under pressure. This patch forces kswapd to notice sooner th=
at
> high-order allocations are occuring.
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
>=20
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 64e4388..cd68109 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2016,6 +2016,15 @@ loop_again:
>  					priority !=3D DEF_PRIORITY)
>  				continue;
> =20
> +			/*
> +			 * Exit quickly to restart if it has been indicated
> +			 * that higher orders are required
> +			 */
> +			if (pgdat->kswapd_max_order > order) {
> +				all_zones_ok =3D 1;
> +				goto out;
> +			}
> +
>  			if (!zone_watermark_ok(zone, order,
>  					high_wmark_pages(zone), end_zone, 0))
>  				all_zones_ok =3D 0;

this is simplest patch and seems reasonable.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro>


btw, now balance_pgdat() have too complex flow. at least Vincent was
confused it.
Then, I think kswap_max_order handling should move into balance_pgdat()
at later release.
the following patch addressed my proposed concept.



=46rom 2c5be772f6db25a5ef82975960d0b5788736ec2b Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 26 Oct 2009 23:25:29 +0900
Subject: [PATCH] kswapd_max_order handling move into balance_pgdat()

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   45 +++++++++++++++++++++------------------------
 1 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 64e4388..49001d3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1915,7 +1915,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem=
_cgroup *mem_cont,
  * interoperates with the page allocator fallback scheme to ensure that ag=
ing
  * of pages is balanced across the zones.
  */
-static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
+static unsigned long balance_pgdat(pg_data_t *pgdat)
 {
 	int all_zones_ok;
 	int priority;
@@ -1928,7 +1928,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, =
int order)
 		.may_swap =3D 1,
 		.swap_cluster_max =3D SWAP_CLUSTER_MAX,
 		.swappiness =3D vm_swappiness,
-		.order =3D order,
+		.order =3D 0,
 		.mem_cgroup =3D NULL,
 		.isolate_pages =3D isolate_pages_global,
 	};
@@ -1938,6 +1938,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, =
int order)
 	 * free_pages =3D=3D high_wmark_pages(zone).
 	 */
 	int temp_priority[MAX_NR_ZONES];
+	int order =3D 0;
+	int new_order;
=20
 loop_again:
 	total_scanned =3D 0;
@@ -1945,6 +1947,11 @@ loop_again:
 	sc.may_writepage =3D !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
=20
+	new_order =3D pgdat->kswapd_max_order;
+	pgdat->kswapd_max_order =3D 0;
+	if (order < new_order)
+		order =3D sc.order =3D new_order;
+
 	for (i =3D 0; i < pgdat->nr_zones; i++)
 		temp_priority[i] =3D DEF_PRIORITY;
=20
@@ -2087,11 +2094,17 @@ out:
=20
 		zone->prev_priority =3D temp_priority[i];
 	}
-	if (!all_zones_ok) {
-		cond_resched();
=20
-		try_to_freeze();
+	cond_resched();
+	try_to_freeze();
=20
+	/*
+	 * restart if someone wants a larger 'order' allocation
+	 */
+	if (order < pgdat->kswapd_max_order)
+		goto loop_again;
+
+	if (!all_zones_ok) {
 		/*
 		 * Fragmentation may mean that the system cannot be
 		 * rebalanced for high-order allocations in all zones.
@@ -2130,7 +2143,6 @@ out:
  */
 static int kswapd(void *p)
 {
-	unsigned long order;
 	pg_data_t *pgdat =3D (pg_data_t*)p;
 	struct task_struct *tsk =3D current;
 	DEFINE_WAIT(wait);
@@ -2160,32 +2172,17 @@ static int kswapd(void *p)
 	tsk->flags |=3D PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 	set_freezable();
=20
-	order =3D 0;
 	for ( ; ; ) {
-		unsigned long new_order;
-
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
-		new_order =3D pgdat->kswapd_max_order;
-		pgdat->kswapd_max_order =3D 0;
-		if (order < new_order) {
-			/*
-			 * Don't sleep if someone wants a larger 'order'
-			 * allocation
-			 */
-			order =3D new_order;
-		} else {
-			if (!freezing(current))
-				schedule();
-
-			order =3D pgdat->kswapd_max_order;
-		}
+		if (!freezing(current))
+			schedule();
 		finish_wait(&pgdat->kswapd_wait, &wait);
=20
 		if (!try_to_freeze()) {
 			/* We can speed up thawing tasks if we don't call
 			 * balance_pgdat after returning from the refrigerator
 			 */
-			balance_pgdat(pgdat, order);
+			balance_pgdat(pgdat);
 		}
 	}
 	return 0;
--=20
1.6.2.5






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
