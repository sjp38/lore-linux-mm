Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4EB236B02A4
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 21:46:34 -0400 (EDT)
Received: by iwn2 with SMTP id 2so1853471iwn.14
        for <linux-mm@kvack.org>; Thu, 08 Jul 2010 18:46:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100709090956.CD51.A69D9226@jp.fujitsu.com>
References: <20100708163401.CD34.A69D9226@jp.fujitsu.com>
	<20100708130048.fccfcdad.akpm@linux-foundation.org>
	<20100709090956.CD51.A69D9226@jp.fujitsu.com>
Date: Fri, 9 Jul 2010 10:46:32 +0900
Message-ID: <AANLkTik_NdsbyY3BBxqERxTVIQjKMzXCi-mw7EaISo7R@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] vmscan: don't subtraction of unsined
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 9, 2010 at 10:16 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> > @@ -2628,16 +2628,16 @@ static int __zone_reclaim(struct zone *zone, g=
fp_t gfp_mask, unsigned int order)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* take a long time.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (shrink_slab(sc.nr_sca=
nned, gfp_mask, order) &&
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone_=
page_state(zone, NR_SLAB_RECLAIMABLE) >
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 slab_reclaimable - nr_pages)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(zone_=
page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages > n))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Update nr_reclaimed =
by the number of slab pages we
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* reclaimed from this =
zone.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc.nr_reclaimed +=3D slab_reclaim=
able -
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone_=
page_state(zone, NR_SLAB_RECLAIMABLE);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 m =3D zone_page_state(zone, NR_SL=
AB_RECLAIMABLE);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (m < n)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc.nr=
_reclaimed +=3D n - m;
>>
>> And it's not a completly trivial objection. =C2=A0Your patch made the ab=
ove
>> code snippet quite a lot harder to read (and hence harder to maintain).
>
> Initially, I proposed following patch to Christoph. but he prefer n and m=
.
> To be honest, I don't think this naming is big matter. so you prefer foll=
owing
> I'll submit it.
>
>
>
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> From 397199d69860061eaa5e1aaadac45c46c76b0522 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Wed, 30 Jun 2010 13:35:16 +0900
> Subject: [PATCH] vmscan: don't subtraction of unsined
>
> 'slab_reclaimable' and 'nr_pages' are unsigned. so, subtraction is
> unsafe.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I like this than n,m.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
