Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD8276B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 23:10:08 -0500 (EST)
Received: by iwn40 with SMTP id 40so391238iwn.14
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 20:10:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1101181751420.25382@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
	<AANLkTin036LNAJ053ByMRmQUnsBpRcv1s5uX1j_2c_Ds@mail.gmail.com>
	<alpine.DEB.2.00.1101181751420.25382@chino.kir.corp.google.com>
Date: Wed, 19 Jan 2011 13:10:06 +0900
Message-ID: <AANLkTikhkiw0dx_5aj3habTbhofN_=Ptz7J0eDa49eN9@mail.gmail.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone is
 not allowed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 19, 2011 at 10:53 AM, David Rientjes <rientjes@google.com> wrot=
e:
> On Wed, 19 Jan 2011, Minchan Kim wrote:
>
>> >
>> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> > --- a/mm/page_alloc.c
>> > +++ b/mm/page_alloc.c
>> > @@ -2034,6 +2034,18 @@ restart:
>> > =A0 =A0 =A0 =A0 */
>> > =A0 =A0 =A0 =A0alloc_flags =3D gfp_to_alloc_flags(gfp_mask);
>> >
>> > + =A0 =A0 =A0 /*
>> > + =A0 =A0 =A0 =A0* If preferred_zone cannot be allocated from in this =
context, find the
>> > + =A0 =A0 =A0 =A0* first allowable zone instead.
>> > + =A0 =A0 =A0 =A0*/
>> > + =A0 =A0 =A0 if ((alloc_flags & ALLOC_CPUSET) &&
>> > + =A0 =A0 =A0 =A0 =A0 !cpuset_zone_allowed_softwall(preferred_zone, gf=
p_mask)) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 first_zones_zonelist(zonelist, high_zone=
idx,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &cpuset_=
current_mems_allowed, &preferred_zone);
>>
>> This patch is one we need. but I have a nitpick.
>> I am not familiar with CPUSET so I might be wrong.
>>
>> I think it could make side effect of statistics of ZVM on
>> buffered_rmqueue since you intercept and change preferred_zone.
>> It could make NUMA_HIT instead of NUMA_MISS.
>> Is it your intention?
>>
>
> It depends on the semantics of NUMA_MISS: if no local nodes are allowed b=
y
> current's cpuset (a pretty poor cpuset config :), then it seems logical
> that all allocations would be a miss.

It does make sense to me but I delegate the decision to Christoph who is au=
thor.
And please write down this behavior change into changelog. :)
Thanks David.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
