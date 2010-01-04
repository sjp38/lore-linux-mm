Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3F61B600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 00:52:41 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o045qbnQ014218
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 4 Jan 2010 14:52:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D5B045DE50
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 14:52:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FB6145DE4C
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 14:52:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C2801DB803F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 14:52:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F2E261DB8037
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 14:52:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] page allocator: fix update NR_FREE_PAGES only as necessary
In-Reply-To: <20100104122138.f54b7659.minchan.kim@barrios-desktop>
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com> <20100104122138.f54b7659.minchan.kim@barrios-desktop>
Message-Id: <20100104144332.96A2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Mon,  4 Jan 2010 14:52:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hi, Huang.=20
>=20
> On Mon,  4 Jan 2010 10:22:10 +0800
> Huang Shijie <shijie8@gmail.com> wrote:
>=20
> > When the `page' returned by __rmqueue() is NULL, the origin code
> > still adds -(1 << order) to zone's NR_FREE_PAGES item.
> >=20
> > The patch fixes it.
> >=20
> > Signed-off-by: Huang Shijie <shijie8@gmail.com>
> > ---
> >  mm/page_alloc.c |   10 +++++++---
> >  1 files changed, 7 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4e9f5cc..620921d 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1222,10 +1222,14 @@ again:
> >  		}
> >  		spin_lock_irqsave(&zone->lock, flags);
> >  		page =3D __rmqueue(zone, order, migratetype);
> > -		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
> > -		spin_unlock(&zone->lock);
> > -		if (!page)
> > +		if (likely(page)) {
> > +			__mod_zone_page_state(zone, NR_FREE_PAGES,
> > +						-(1 << order));
> > +			spin_unlock(&zone->lock);
> > +		} else {
> > +			spin_unlock(&zone->lock);
> >  			goto failed;
> > +		}
> >  	}
> > =20
> >  	__count_zone_vm_events(PGALLOC, zone, 1 << order);
>=20
> I think it's not desirable to add new branch in hot-path even though
> we could avoid that.=20
>=20
> How about this?
>=20
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4e4b5b3..87976ad 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1244,6 +1244,9 @@ again:
>         return page;
> =20
>  failed:
> +       spin_lock(&zone->lock);
> +       __mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> +       spin_unlock(&zone->lock);
>         local_irq_restore(flags);
>         put_cpu();
>         return NULL;

Why can't we write following? __mod_zone_page_state() only require irq
disabling, it doesn't need spin lock. I think.



=46rom 72011ff2b0bba6544ae35c6ee52715c8c824a34b Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 4 Jan 2010 14:38:20 +0900
Subject: [PATCH] page allocator: fix update NR_FREE_PAGES only as necessary

commit f2260e6b (page allocator: update NR_FREE_PAGES only as necessary)
made one minor regression.
if __rmqueue() was failed, NR_FREE_PAGES stat go wrong. this patch fixes
it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Huang Shijie <shijie8@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 11ae66e..ecf75a1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1227,10 +1227,10 @@ again:
 		}
 		spin_lock_irqsave(&zone->lock, flags);
 		page =3D __rmqueue(zone, order, migratetype);
-		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
 	}
=20
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
--=20
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
