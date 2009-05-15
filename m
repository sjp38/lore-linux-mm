Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9B4F66B008C
	for <linux-mm@kvack.org>; Thu, 14 May 2009 21:28:24 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so827112ywm.26
        for <linux-mm@kvack.org>; Thu, 14 May 2009 18:28:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090514162201.GA2361@cmpxchg.org>
References: <20090514231555.f52c81eb.minchan.kim@gmail.com>
	 <2f11576a0905140727j5ba02b07t94826f57dd99839c@mail.gmail.com>
	 <44c63dc40905140739n271d3d2w2e0cc364c0012d71@mail.gmail.com>
	 <20090514162201.GA2361@cmpxchg.org>
Date: Fri, 15 May 2009 10:28:50 +0900
Message-ID: <28c262360905141828v6c9503e9q12cd0e6157a8b5e9@mail.gmail.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
	of no swap space V3
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <barrioskmc@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 15, 2009 at 1:22 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Thu, May 14, 2009 at 11:39:49PM +0900, Minchan Kim wrote:
>> On Thu, May 14, 2009 at 11:27 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> =C2=A0mm/vmscan.c | =C2=A0 =C2=A02 +-
>> >> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>> >>
>> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >> index 2f9d555..621708f 100644
>> >> --- a/mm/vmscan.c
>> >> +++ b/mm/vmscan.c
>> >> @@ -1577,7 +1577,7 @@ static void shrink_zone(int priority, struct zo=
ne *zone,
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Even if we did not try to evict anon pa=
ges at all, we want to
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * rebalance the anon lru active/inactive =
ratio.
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> >> - =C2=A0 =C2=A0 =C2=A0 if (inactive_anon_is_low(zone, sc))
>> >> + =C2=A0 =C2=A0 =C2=A0 if (inactive_anon_is_low(zone, sc) && nr_swap_=
pages > 0)
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_active_=
list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
>> >
>> >
>> > =C2=A0 =C2=A0 =C2=A0 if (nr_swap_pages > 0 && inactive_anon_is_low(zon=
e, sc))
>> >
>> > is better?
>> > compiler can't swap evaluate order around &&.
>>
>> If GCC optimizes away that branch with CONFIG_SWAP=3Dn as Rik mentioned,
>> we don't have a concern.
>
> It can only optimize it away when the condition is a compile time
> constant.
>
> But inactive_anon_is_low() contains atomic operations which the
> compiler is not allowed to drop and so the && semantics lead to
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_read() && 0
>
> emitting the read while still knowing the whole expression is 0 at
> compile-time, optimizing away only the branch itself but leaving the
> read in place!
>
> Compared to
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A00 && atomic_read()
>
> where the && short-circuitry leads to atomic_read() not being
> executed. =C2=A0And since the 0 is a compile time constant, no code has t=
o
> be emitted for the read.
>
> So KOSAKI-san's is right. =C2=A0Your version results in bigger object cod=
e.

You're right.  I realized it from you.
I will repost this.
Thanks for great review, Hannes :)

> =C2=A0 =C2=A0 =C2=A0 =C2=A0Hannes
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
