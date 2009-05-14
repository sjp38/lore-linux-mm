Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5EC506B004D
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:08:56 -0400 (EDT)
Received: by gxk20 with SMTP id 20so2413141gxk.14
        for <linux-mm@kvack.org>; Thu, 14 May 2009 06:09:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A0C1571.2020106@redhat.com>
References: <20090514201150.8536f86e.minchan.kim@barrios-desktop>
	 <4A0C1571.2020106@redhat.com>
Date: Thu, 14 May 2009 22:09:03 +0900
Message-ID: <28c262360905140609y580b6835m759dee08f08a26ab@mail.gmail.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
	of no swap space V2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

HI, Rik

Thanks for careful review. :)

On Thu, May 14, 2009 at 9:58 PM, Rik van Riel <riel@redhat.com> wrote:
> Minchan Kim wrote:
>
>> Now shrink_active_list is called several places.
>> But if we don't have a swap space, we can't reclaim anon pages.
>
> If swap space has run out, get_scan_ratio() will return
> 0 for the anon scan ratio, meaning we do not scan the
> anon lists.

I think get_scan_ration can't prevent scanning of anon pages in no
swap system(like embedded system).
That's because in shrink_zone, you add following as

        /*
         * Even if we did not try to evict anon pages at all, we want to
         * rebalance the anon lru active/inactive ratio.
         */
        if (inactive_anon_is_low(zone, sc))
                shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0)=
;

>> So, we don't need deactivating anon pages in anon lru list.
>
> If we are close to running out of swap space, with
> swapins freeing up swap space on a regular basis,
> I believe we do want to do aging on the active
> pages, just so we can pick a decent page to swap
> out next time swap space becomes available.

I agree your opinion.

>> +static int can_reclaim_anon(struct zone *zone, struct scan_control *sc)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 return (inactive_anon_is_low(zone, sc) && nr_swap=
_pages <=3D 0);
>> +}
>> +
>
> This function name is misleading, because when we do have
> swap space available but inactive_anon_is_low is false,
> we still want to reclaim inactive anon pages!

Indeed. I will rename it.

> What problem did you encounter that you think this patch
> solves?

I thought In embedded system most products don't have swap space.
In such environment, We don't need anon lru list.
I think even scanning of anon list is much bad


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
