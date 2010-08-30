Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4A62A6B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 02:16:37 -0400 (EDT)
Received: by iwn33 with SMTP id 33so6473619iwn.14
        for <linux-mm@kvack.org>; Sun, 29 Aug 2010 23:16:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinqm0o=AfmgFy+SpZ1mrdekRnjeXvs_7=OcLii8@mail.gmail.com>
References: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com>
	<AANLkTinCKJw2oaNgAvfm0RawbW4zuJMtMb2pUROeY2ij@mail.gmail.com>
	<4C7ABD14.9050207@redhat.com>
	<AANLkTimjVHp1=Fc35xLnyPb2aa+ew7w1P9DC_0GfhZgY@mail.gmail.com>
	<AANLkTi==mQh31PzuNa1efH2WM1s-VPKyZX0f5iwb54PD@mail.gmail.com>
	<AANLkTinqm0o=AfmgFy+SpZ1mrdekRnjeXvs_7=OcLii8@mail.gmail.com>
Date: Mon, 30 Aug 2010 15:16:35 +0900
Message-ID: <AANLkTikbs9sUVLhE4sWWVw8uEqY=v6SCdJ_6FLhXY6HW@mail.gmail.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 30, 2010 at 2:40 PM, Ying Han <yinghan@google.com> wrote:
> On Sun, Aug 29, 2010 at 5:18 PM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
>> Hi Ying,
>>
>> On Mon, Aug 30, 2010 at 6:23 AM, Ying Han <yinghan@google.com> wrote:
>>> On Sun, Aug 29, 2010 at 1:03 PM, Rik van Riel <riel@redhat.com> wrote:
>>>> On 08/29/2010 01:45 PM, Ying Han wrote:
>>>>
>>>>> There are few other places in vmscan where we check nr_swap_pages and
>>>>> inactive_anon_is_low. Are we planning to change them to use
>>>>> total_swap_pages
>>>>> to be consistent ?
>>>>
>>>> If that makes sense, maybe the check can just be moved into
>>>> inactive_anon_is_low itself?
>>>
>>> That was the initial patch posted, instead we changed to use
>>> total_swap_pages instead. How this patch looks:
>>>
>>> @@ -1605,6 +1605,9 @@ static int inactive_anon_is_low(struct zone
>>> *zone, struct scan_control *sc)
>>> =A0{
>>> =A0 =A0 =A0 =A0int low;
>>>
>>> + =A0 =A0 =A0 if (total_swap_pages <=3D 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>> +
>>> =A0 =A0 =A0 =A0if (scanning_global_lru(sc))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0low =3D inactive_anon_is_low_global(zone=
);
>>> =A0 =A0 =A0 =A0else
>>> @@ -1856,7 +1859,7 @@ static void shrink_zone(int priority, struct zone=
 *zone,
>>> =A0 =A0 =A0 =A0 * Even if we did not try to evict anon pages at all, we=
 want to
>>> =A0 =A0 =A0 =A0 * rebalance the anon lru active/inactive ratio.
>>> =A0 =A0 =A0 =A0 */
>>> - =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
>>> + =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_active_list(SWAP_CLUSTER_MAX, zon=
e, sc, priority, 0);
>>>
>>> =A0 =A0 =A0 =A0throttle_vm_writeout(sc->gfp_mask);
>>>
>>> --Ying
>>>
>>>>
>>
>> I did it intentionally since inactive_anon_is_low have been used both
>> direct reclaim and background path. In this point, your patch could
>> make side effect in swap enabled system when swap is full.
>>
>> I think we need aging in only background if system is swap full.
>> That's because if the swap space is full, we don't reclaim anon pages
>> in direct reclaim path with (nr_swap_pages < 0) =A0and even have been
>> not rebalance it until now.
>> I think direct reclaim path is important about latency as well as
>> reclaim's effectiveness.
>> So if you don't mind, I hope direct reclaim patch would be left just as =
it is.
>
> Minchan, I would prefer to make kswapd as well as direct reclaim to be
> consistent if possible.
> They both try to reclaim pages when system is under memory pressure,
> and also do not make
> much sense to look at anon lru if no swap space available. Either
> because of no swapon or run
> out of swap space.

In out of swap space, The few swap space would become more precious.
So I think we still need background aging to protect hot page swap out.
But I admit it's hard to measure it so I can't insist on.
But I wanted to maintain it as it is to avoid _unexpected_ side effect.

And your patch can't compile out inactive_anon_is_low call in non swap
configurable system. It makes unnecessary call. So I want to use
nr_swap_pages && inactive_anon_is_low.

For it, I sended following patch at last version

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1b145e6..0b8a3ce 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1747,7 +1747,7 @@ static void shrink_zone(int priority, struct zone *zo=
ne,
         * Even if we did not try to evict anon pages at all, we want to
         * rebalance the anon lru active/inactive ratio.
         */
-       if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
+       if (nr_swap_pges > 0 && inactive_anon_is_low(zone, sc))
                shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0)=
;

        throttle_vm_writeout(sc->gfp_mask);

But Andrew merged middle version.
I will send this patch again.

Thanks.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
