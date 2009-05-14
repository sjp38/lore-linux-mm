Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 80CBD6B01B0
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:57:41 -0400 (EDT)
Message-ID: <4A0C1571.2020106@redhat.com>
Date: Thu, 14 May 2009 08:58:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
 of no swap space V2
References: <20090514201150.8536f86e.minchan.kim@barrios-desktop>
In-Reply-To: <20090514201150.8536f86e.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:

> Now shrink_active_list is called several places.
> But if we don't have a swap space, we can't reclaim anon pages.

If swap space has run out, get_scan_ratio() will return
0 for the anon scan ratio, meaning we do not scan the
anon lists.

> So, we don't need deactivating anon pages in anon lru list.

If we are close to running out of swap space, with
swapins freeing up swap space on a regular basis,
I believe we do want to do aging on the active
pages, just so we can pick a decent page to swap
out next time swap space becomes available.

> +static int can_reclaim_anon(struct zone *zone, struct scan_control *sc)
> +{
> +	return (inactive_anon_is_low(zone, sc) && nr_swap_pages <= 0);
> +}
> +

This function name is misleading, because when we do have
swap space available but inactive_anon_is_low is false,
we still want to reclaim inactive anon pages!

What problem did you encounter that you think this patch
solves?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
