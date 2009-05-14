Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 355E76B01A9
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:05:00 -0400 (EDT)
Received: by gxk20 with SMTP id 20so2358616gxk.14
        for <linux-mm@kvack.org>; Thu, 14 May 2009 05:05:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090514204033.9B87.A69D9226@jp.fujitsu.com>
References: <20090514201150.8536f86e.minchan.kim@barrios-desktop>
	 <20090514202538.9B81.A69D9226@jp.fujitsu.com>
	 <20090514204033.9B87.A69D9226@jp.fujitsu.com>
Date: Thu, 14 May 2009 21:05:03 +0900
Message-ID: <28c262360905140505h2db7ac3bp5ca10fcf2b4301bb@mail.gmail.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
	of no swap space V2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 8:44 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> >
>> > Changelog since V2
>> > =C2=A0o Add new function - can_reclaim_anon : it tests anon_list can b=
e reclaim
>> >
>> > Changelog since V1
>> > =C2=A0o Use nr_swap_pages <=3D 0 in shrink_active_list to prevent scan=
ning =C2=A0of active anon list.
>> >
>> > Now shrink_active_list is called several places.
>> > But if we don't have a swap space, we can't reclaim anon pages.
>> > So, we don't need deactivating anon pages in anon lru list.
>> >
>> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > Cc: Johannes Weiner <hannes@cmpxchg.org>
>> > Cc: Rik van Riel <riel@redhat.com>
>>
>> looks good to me. thanks :)
>
> Grr, my fault.
>
>
>
>> =C2=A0static unsigned long shrink_list(enum lru_list lru, unsigned long =
nr_to_scan,
>> =C2=A0 =C2=A0 =C2=A0 struct zone *zone, struct scan_control *sc, int pri=
ority)
>> =C2=A0{
>> @@ -1399,7 +1412,7 @@ static unsigned long shrink_list(enum lru_list lru=
, unsigned long nr_to_scan,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> - =C2=A0 =C2=A0 if (lru =3D=3D LRU_ACTIVE_ANON && inactive_anon_is_low(z=
one, sc)) {
>> + =C2=A0 =C2=A0 if (lru =3D=3D LRU_ACTIVE_ANON && can_reclaim_anon(zone,=
 sc)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrink_active_list(nr_t=
o_scan, zone, sc, priority, file);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>
> you shouldn't do that. if nr_swap_pages=3D=3D0, get_scan_ratio return ano=
n=3D0%.
> then, this branch is unnecessary.
>

But, I think at last it can be happen following as.

1515         * Even if we did not try to evict anon pages at all, we want t=
o
1516         * rebalance the anon lru active/inactive ratio.
1517         */
1518        if (inactive_anon_is_low(zone, sc))
1519                shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority=
, 0);


>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
