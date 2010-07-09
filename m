Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 245F96B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 07:04:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o69B4buU005410
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Jul 2010 20:04:37 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F24645DE50
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 20:04:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 58B3545DE4E
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 20:04:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 371491DB8016
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 20:04:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E07501DB8014
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 20:04:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: stop meaningless loop iteration when no  reclaimable slab
In-Reply-To: <AANLkTins0OMGnj3JmUjIctO0dSnXPsQV1AUsbMEVt2D1@mail.gmail.com>
References: <20100709191308.FA25.A69D9226@jp.fujitsu.com> <AANLkTins0OMGnj3JmUjIctO0dSnXPsQV1AUsbMEVt2D1@mail.gmail.com>
Message-Id: <20100709195625.FA28.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  9 Jul 2010 20:04:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Fri, Jul 9, 2010 at 7:13 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > If number of reclaimable slabs are zero, shrink_icache_memory() and
> > shrink_dcache_memory() return 0. but strangely shrink_slab() ignore
> > it and continue meaningless loop iteration.
> >
> > This patch fixes it.
> >
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> > =A0mm/vmscan.c | =A0 =A05 +++++
> > =A01 files changed, 5 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 0f9f624..8f61adb 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -243,6 +243,11 @@ unsigned long shrink_slab(unsigned long scanned, g=
fp_t gfp_mask,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int nr_before;
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_before =3D (*shrinker=
->shrink)(0, gfp_mask);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* no slab objects, no mo=
re reclaim. */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_before =3D=3D 0) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_sca=
n =3D 0;
>=20
> Why do you reset totoal_scan to 0?

If shab objects are zero, we don't need more reclaim.=20

> I don't know exact meaning of shrinker->nr.

similar meaning of reclaim_stat->nr_saved_scan.
If total_scan can't divide SHRINK_BATCH(128), saving remainder and using at=
 next shrink_slab().

> AFAIU, it can affect next shrinker's total_scan.
> Isn't it harmful?

No.  This loop is

                total_scan =3D shrinker->nr;		/* Reset and init total_scan =
*/
                shrinker->nr =3D 0;

                while (total_scan >=3D SHRINK_BATCH) {
                        nr_before =3D (*shrinker->shrink)(0, gfp_mask);
                        /* no slab objects, no more reclaim. */
                        if (nr_before =3D=3D 0) {
                                total_scan =3D 0;
                                break;
                        }
                        shrink_ret =3D (*shrinker->shrink)(this_scan, gfp_m=
ask);
                        if (shrink_ret =3D=3D -1)
                                break;
                        if (shrink_ret < nr_before)
                                ret +=3D nr_before - shrink_ret;
                        total_scan -=3D this_scan;
                }

                shrinker->nr +=3D total_scan;		/* save remainder #of-scan *=
/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
