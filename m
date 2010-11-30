Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1BC916B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 19:25:29 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU0PPdY019416
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Nov 2010 09:25:25 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E3C1445DE4D
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:25:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE68F45DE6F
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:25:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 718501DB803A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:25:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 29C95EF8002
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:25:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <alpine.DEB.2.00.1011260943220.12265@router.home>
References: <20101125101803.F450.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011260943220.12265@router.home>
Message-Id: <20101130092534.82D5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 30 Nov 2010 09:25:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Simon Kirby <sim@hostway.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 25 Nov 2010, KOSAKI Motohiro wrote:
> > Please try SLAB instead SLUB (it can be switched by kernel build option=
).
> > SLUB try to use high order allocation implicitly.
>=20
> SLAB uses orders 0-1. Order is fixed per slab cache and determined based
> on object size at slab creation.
>=20
> SLUB uses orders 0-3. Falls back to smallest order if alloc order cannot
> be met by the page allocator.
>=20
> One can reduce SLUB to SLAB orders by specifying the following kernel
> commandline parameter:
>=20
> slub_max_order=3D1

This?


=46rom 3edd305fc58ac89364806cd60140793d37422acc Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 24 Dec 2010 18:04:10 +0900
Subject: [PATCH] slub: reduce slub_max_order by default

slab is already using order-1.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/slub.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8c66aef..babf359 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1964,7 +1964,8 @@ static struct page *get_object_page(const void *x)
  * take the list_lock.
  */
 static int slub_min_order;
-static int slub_max_order =3D PAGE_ALLOC_COSTLY_ORDER;
+/* order-1 is maximum size which we can assume to exist always. */
+static int slub_max_order =3D 1;
 static int slub_min_objects;
=20
 /*
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
