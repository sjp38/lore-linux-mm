Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7764B6B01B9
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:32:46 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so626310yxh.26
        for <linux-mm@kvack.org>; Thu, 14 May 2009 06:33:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A0C1A41.7040202@redhat.com>
References: <20090514201150.8536f86e.minchan.kim@barrios-desktop>
	 <4A0C1571.2020106@redhat.com>
	 <28c262360905140609y580b6835m759dee08f08a26ab@mail.gmail.com>
	 <4A0C1A41.7040202@redhat.com>
Date: Thu, 14 May 2009 22:33:16 +0900
Message-ID: <28c262360905140633q3a7ace7byec2f47b0f0d2e78d@mail.gmail.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
	of no swap space V2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 10:18 PM, Rik van Riel <riel@redhat.com> wrote:
> Minchan Kim wrote:
>>
>> HI, Rik
>>
>> Thanks for careful review. :)
>>
>> On Thu, May 14, 2009 at 9:58 PM, Rik van Riel <riel@redhat.com> wrote:
>>>
>>> Minchan Kim wrote:
>>>
>>>> Now shrink_active_list is called several places.
>>>> But if we don't have a swap space, we can't reclaim anon pages.
>>>
>>> If swap space has run out, get_scan_ratio() will return
>>> 0 for the anon scan ratio, meaning we do not scan the
>>> anon lists.
>>
>> I think get_scan_ration can't prevent scanning of anon pages in no
>> swap system(like embedded system).
>> That's because in shrink_zone, you add following as
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Even if we did not try to evict anon pages=
 at all, we want to
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * rebalance the anon lru active/inactive rat=
io.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (inactive_anon_is_low(zone, sc))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_active_lis=
t(SWAP_CLUSTER_MAX, zone, sc, priority,
>> 0);
>
> That's a fair point.
>
> How about we change this to:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (inactive_anon_is_low(zone, sc) && nr_swap_=
pages >=3D 0)
> That way GCC will statically optimize away this branch on
> systems with CONFIG_SWAP=3Dn.
>
> Does that look reasonable?

Now inactive_anon_is_low called following as.

1. shrink_zone =3D> Looks good since your idea.
2. balance_pgdat =3D> Looks good since aging.
3. shrink_list
shrink_list is called at two places.
1. shrink_zone =3D> It's OK since get_scan_ratio can't prevent it.
2. shrink_all_zones. =3D> It's OK since we can't suspend without swap space=
.

So, Okay I will do that in next version.
Thanks for good review. Rik :)
Could I add your ack in next version ?

> --
> All rights reversed.
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
