Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 14AC86B01AF
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:34:35 -0400 (EDT)
Received: by gxk20 with SMTP id 20so2382344gxk.14
        for <linux-mm@kvack.org>; Thu, 14 May 2009 05:35:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090514210839.9B90.A69D9226@jp.fujitsu.com>
References: <20090514204033.9B87.A69D9226@jp.fujitsu.com>
	 <28c262360905140505h2db7ac3bp5ca10fcf2b4301bb@mail.gmail.com>
	 <20090514210839.9B90.A69D9226@jp.fujitsu.com>
Date: Thu, 14 May 2009 21:35:07 +0900
Message-ID: <28c262360905140535w4bfdbbccp55f395daa18fbf0e@mail.gmail.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
	of no swap space V2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 9:11 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Thu, May 14, 2009 at 8:44 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> >
>> >> > Changelog since V2
>> >> > ?o Add new function - can_reclaim_anon : it tests anon_list can be =
reclaim
>> >> >
>> >> > Changelog since V1
>> >> > ?o Use nr_swap_pages <=3D 0 in shrink_active_list to prevent scanni=
ng ?of active anon list.
>> >> >
>> >> > Now shrink_active_list is called several places.
>> >> > But if we don't have a swap space, we can't reclaim anon pages.
>> >> > So, we don't need deactivating anon pages in anon lru list.
>> >> >
>> >> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> >> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> >> > Cc: Johannes Weiner <hannes@cmpxchg.org>
>> >> > Cc: Rik van Riel <riel@redhat.com>
>> >>
>> >> looks good to me. thanks :)
>> >
>> > Grr, my fault.
>> >
>> >
>> >
>> >> ?static unsigned long shrink_list(enum lru_list lru, unsigned long nr=
_to_scan,
>> >> ? ? ? struct zone *zone, struct scan_control *sc, int priority)
>> >> ?{
>> >> @@ -1399,7 +1412,7 @@ static unsigned long shrink_list(enum lru_list =
lru, unsigned long nr_to_scan,
>> >> ? ? ? ? ? ? ? return 0;
>> >> ? ? ? }
>> >>
>> >> - ? ? if (lru =3D=3D LRU_ACTIVE_ANON && inactive_anon_is_low(zone, sc=
)) {
>> >> + ? ? if (lru =3D=3D LRU_ACTIVE_ANON && can_reclaim_anon(zone, sc)) {
>> >> ? ? ? ? ? ? ? shrink_active_list(nr_to_scan, zone, sc, priority, file=
);
>> >> ? ? ? ? ? ? ? return 0;
>> >
>> > you shouldn't do that. if nr_swap_pages=3D=3D0, get_scan_ratio return =
anon=3D0%.
>> > then, this branch is unnecessary.
>> >
>>
>> But, I think at last it can be happen following as.
>>
>> 1515 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Even if we did not try to evict anon =
pages at all, we want to
>> 1516 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * rebalance the anon lru active/inactiv=
e ratio.
>> 1517 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> 1518 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (inactive_anon_is_low(zone, sc))
>> 1519 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_activ=
e_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
>
> I pointed to shrink_list(), but you replayed shrink_zone().
> I only talked about shrink_list().
>

In shrink_zone, we call get_scan_ratio. it prevent scanning anon list.
but, in shrink_all_zones can't prevent it.

Also,  I think shrink_list is not hot patch.
So check of one condition adding is trivial

If I don't understand your point, please explain detaily


--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
