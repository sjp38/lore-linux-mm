Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AE1416B02A3
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 21:44:29 -0400 (EDT)
Received: by iwn2 with SMTP id 2so1897259iwn.14
        for <linux-mm@kvack.org>; Thu, 15 Jul 2010 18:44:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100716090302.7351.A69D9226@jp.fujitsu.com>
References: <20100713144008.EA52.A69D9226@jp.fujitsu.com>
	<20100715121551.bd5ccc61.akpm@linux-foundation.org>
	<20100716090302.7351.A69D9226@jp.fujitsu.com>
Date: Fri, 16 Jul 2010 10:44:24 +0900
Message-ID: <AANLkTikwsuuZHJxK0+1mdJVLZ7vw3r4oZBQrzuowLQXE@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of lru_pages,
	not page order
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 16, 2010 at 10:39 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > =A0 =A0 nr_slab_pages0 =3D zone_page_state(zone, NR_SLAB_RECLAIMABLE);
>> > =A0 =A0 if (nr_slab_pages0 > zone->min_slab_pages) {
>> > + =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages =3D zone_reclaimable_pag=
es(zone);
>> > +
>> > =A0 =A0 =A0 =A0 =A0 =A0 /*
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0* shrink_slab() does not currently allow us=
 to determine how
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0* many pages were freed in this zone. So we=
 take the current
>> > @@ -2622,7 +2624,7 @@ static int __zone_reclaim(struct zone *zone, gfp=
_t gfp_mask, unsigned int order)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0* Note that shrink_slab will free memory on=
 all zones and may
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0* take a long time.
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > - =A0 =A0 =A0 =A0 =A0 while (shrink_slab(sc.nr_scanned, gfp_mask, orde=
r) &&
>> > + =A0 =A0 =A0 =A0 =A0 while (shrink_slab(sc.nr_scanned, gfp_mask, lru_=
pages) &&
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(zone_page_state(zone, NR_SLAB_=
RECLAIMABLE) + nr_pages >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_slab_pages0))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ;
>>
>> Wouldn't it be better to recalculate zone_reclaimable_pages() each time
>> around the loop? =A0For example, shrink_icache_memory()->prune_icache()
>> will remove pagecache from an inode if it hits the tail of the list.
>> This can change the number of reclaimable pages by squigabytes, but
>> this code thinks nothing changed?
>
> Ah, I missed this. incrementa patch is here.
>
> thank you!
>
>
>
> From 8f7c70cfb4a25f8292a59564db6c3ff425a69b53 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Fri, 16 Jul 2010 08:40:01 +0900
> Subject: [PATCH] vmscan: recalculate lru_pages on each shrink_slab()
>
> Andrew Morton pointed out shrink_slab() may change number of reclaimable
> pages (e.g. shrink_icache_memory()->prune_icache() will remove unmapped
> pagecache).
>
> So, we need to recalculate lru_pages on each shrink_slab() calling.
> This patch fixes it.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

It does make sense.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
