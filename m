Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EA8BD6B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 02:33:58 -0400 (EDT)
Received: by iwn2 with SMTP id 2so6462798iwn.14
        for <linux-mm@kvack.org>; Mon, 12 Jul 2010 23:33:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100712101237.EA0E.A69D9226@jp.fujitsu.com>
References: <20100709195625.FA28.A69D9226@jp.fujitsu.com>
	<AANLkTilA2rzWVVLqDQjhivHmnt0ZfaQBGEDh2TU6OfcJ@mail.gmail.com>
	<20100712101237.EA0E.A69D9226@jp.fujitsu.com>
Date: Tue, 13 Jul 2010 15:33:57 +0900
Message-ID: <AANLkTil3zWyAh-gZHJXAiAfvy524ukf9P7l9JBLSOPs5@mail.gmail.com>
Subject: Re: [PATCH] vmscan: stop meaningless loop iteration when no
	reclaimable slab
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 1:48 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>>
>> old shrink_slab
>>
>> shrinker->nr +=3D delta; /* Add delta to previous shrinker's remained co=
unt */
>> total_scan =3D shrinker->nr;
>>
>> while(total_scan >=3D SHRINK_BATCH) {
>> =A0 =A0 =A0 nr_before =3D shrink(xxx);
>> =A0 =A0 =A0 total_scan =3D- this_scan;
>> }
>>
>> shrinker->nr +=3D total_scan;
>>
>> The total_scan can always be the number < SHRINK_BATCH.
>> So, when next shrinker calcuates loop count, the number can affect.
>
> Correct.
>
>
>>
>> new shrink_slab
>>
>> shrinker->nr +=3D delta; /* nr is always zero by your patch */
>
> no.
> my patch don't change delta calculation at all.
>
>
>> total_scan =3D shrinker->nr;
>>
>> while(total_scan >=3D SHRINK_BATCH) {
>> =A0 =A0 =A0 nr_before =3D shrink(xxx);
>> =A0 =A0 =A0 if (nr_before =3D=3D 0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scan =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 }
>> }
>>
>> shrinker->nr +=3D 0;
>>
>> But after your patch, total_scan is always zero. It never affect
>> next shrinker's loop count.
>
> No. after my patch this loop has two exiting way
> =A01) total_scan are less than SHRINK_BATCH.
> =A0 =A0 =A0-> no behavior change. =A0we still pass shrinker->nr +=3D tota=
l_scan code.
> =A02) (*shrinker->shrink)(0, gfp_mask) return 0
> =A0 =A0 =A0don't increase shrinker->nr. =A0because two reason,
> =A0 =A0 =A0a) if total_scan are 10000, =A0we shouldn't carry over such bi=
g number.
> =A0 =A0 =A0b) now, we have zero slab objects, then we have been freed for=
m the guilty of keeping
> =A0 =A0 =A0 =A0 =A0balance page and slab reclaim. shrinker->nr +=3D 0; ha=
ve zero side effect.

Totally, I agree with you.
Thanks for good explanation, Kosaki.

Reviewed-by: Minchan kim <minchan.kim@gmail.com>


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
