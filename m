Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D59326B01B8
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:18:49 -0400 (EDT)
Message-ID: <4A0C1A41.7040202@redhat.com>
Date: Thu, 14 May 2009 09:18:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
 	of no swap space V2
References: <20090514201150.8536f86e.minchan.kim@barrios-desktop>	 <4A0C1571.2020106@redhat.com> <28c262360905140609y580b6835m759dee08f08a26ab@mail.gmail.com>
In-Reply-To: <28c262360905140609y580b6835m759dee08f08a26ab@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> HI, Rik
> 
> Thanks for careful review. :)
> 
> On Thu, May 14, 2009 at 9:58 PM, Rik van Riel <riel@redhat.com> wrote:
>> Minchan Kim wrote:
>>
>>> Now shrink_active_list is called several places.
>>> But if we don't have a swap space, we can't reclaim anon pages.
>> If swap space has run out, get_scan_ratio() will return
>> 0 for the anon scan ratio, meaning we do not scan the
>> anon lists.
> 
> I think get_scan_ration can't prevent scanning of anon pages in no
> swap system(like embedded system).
> That's because in shrink_zone, you add following as
> 
>         /*
>          * Even if we did not try to evict anon pages at all, we want to
>          * rebalance the anon lru active/inactive ratio.
>          */
>         if (inactive_anon_is_low(zone, sc))
>                 shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);

That's a fair point.

How about we change this to:

	if (inactive_anon_is_low(zone, sc) && nr_swap_pages >= 0)

That way GCC will statically optimize away this branch on
systems with CONFIG_SWAP=n.

Does that look reasonable?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
