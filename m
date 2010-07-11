Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3B9E46B024D
	for <linux-mm@kvack.org>; Sun, 11 Jul 2010 18:28:12 -0400 (EDT)
Received: by iwn2 with SMTP id 2so4730496iwn.14
        for <linux-mm@kvack.org>; Sun, 11 Jul 2010 15:28:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100709195625.FA28.A69D9226@jp.fujitsu.com>
References: <20100709191308.FA25.A69D9226@jp.fujitsu.com>
	<AANLkTins0OMGnj3JmUjIctO0dSnXPsQV1AUsbMEVt2D1@mail.gmail.com>
	<20100709195625.FA28.A69D9226@jp.fujitsu.com>
Date: Mon, 12 Jul 2010 07:28:09 +0900
Message-ID: <AANLkTilA2rzWVVLqDQjhivHmnt0ZfaQBGEDh2TU6OfcJ@mail.gmail.com>
Subject: Re: [PATCH] vmscan: stop meaningless loop iteration when no
	reclaimable slab
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 9, 2010 at 8:04 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Fri, Jul 9, 2010 at 7:13 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > If number of reclaimable slabs are zero, shrink_icache_memory() and
>> > shrink_dcache_memory() return 0. but strangely shrink_slab() ignore
>> > it and continue meaningless loop iteration.
>> >
>> > This patch fixes it.
>> >
>> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > ---
>> > =A0mm/vmscan.c | =A0 =A05 +++++
>> > =A01 files changed, 5 insertions(+), 0 deletions(-)
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 0f9f624..8f61adb 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -243,6 +243,11 @@ unsigned long shrink_slab(unsigned long scanned, =
gfp_t gfp_mask,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int nr_before;
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_before =3D (*shrinke=
r->shrink)(0, gfp_mask);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* no slab objects, no m=
ore reclaim. */
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_before =3D=3D 0) =
{
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_sc=
an =3D 0;
>>
>> Why do you reset totoal_scan to 0?
>
> If shab objects are zero, we don't need more reclaim.
>
>> I don't know exact meaning of shrinker->nr.
>
> similar meaning of reclaim_stat->nr_saved_scan.
> If total_scan can't divide SHRINK_BATCH(128), saving remainder and using =
at next shrink_slab().
>
>> AFAIU, it can affect next shrinker's total_scan.
>> Isn't it harmful?
>
> No. =A0This loop is
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scan =3D shrinker->nr; =A0 =A0 =A0 =
=A0 =A0 =A0 =A0/* Reset and init total_scan */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrinker->nr =3D 0;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (total_scan >=3D SHRINK_BATCH) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_before =3D (*shrinker->=
shrink)(0, gfp_mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* no slab objects, no mor=
e reclaim. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nr_before =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scan=
 =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_ret =3D (*shrinker-=
>shrink)(this_scan, gfp_mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (shrink_ret =3D=3D -1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (shrink_ret < nr_before=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret +=3D n=
r_before - shrink_ret;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scan -=3D this_scan;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrinker->nr +=3D total_scan; =A0 =A0 =A0 =
=A0 =A0 =A0 /* save remainder #of-scan */
>
>
I can't understand your point.


old shrink_slab

shrinker->nr +=3D delta; /* Add delta to previous shrinker's remained count=
 */
total_scan =3D shrinker->nr;

while(total_scan >=3D SHRINK_BATCH) {
	nr_before =3D shrink(xxx);
	total_scan =3D- this_scan;
}

shrinker->nr +=3D total_scan;

The total_scan can always be the number < SHRINK_BATCH.
So, when next shrinker calcuates loop count, the number can affect.

new shrink_slab

shrinker->nr +=3D delta; /* nr is always zero by your patch */
total_scan =3D shrinker->nr;

while(total_scan >=3D SHRINK_BATCH) {
	nr_before =3D shrink(xxx);
	if (nr_before =3D=3D 0) {
		total_scan =3D 0;
		break;
	}
}

shrinker->nr +=3D 0;

But after your patch, total_scan is always zero. It never affect
next shrinker's loop count.

Am I missing something?
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
