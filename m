Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 672C16B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 17:24:40 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o7TLOa62013348
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 14:24:36 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by wpaz21.hot.corp.google.com with ESMTP id o7TLOYhs014219
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 14:24:35 -0700
Received: by qwk3 with SMTP id 3so5387120qwk.35
        for <linux-mm@kvack.org>; Sun, 29 Aug 2010 14:24:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C7ABD14.9050207@redhat.com>
References: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com>
	<AANLkTinCKJw2oaNgAvfm0RawbW4zuJMtMb2pUROeY2ij@mail.gmail.com>
	<4C7ABD14.9050207@redhat.com>
Date: Sun, 29 Aug 2010 14:23:31 -0700
Message-ID: <AANLkTimjVHp1=Fc35xLnyPb2aa+ew7w1P9DC_0GfhZgY@mail.gmail.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 29, 2010 at 1:03 PM, Rik van Riel <riel@redhat.com> wrote:
> On 08/29/2010 01:45 PM, Ying Han wrote:
>
>> There are few other places in vmscan where we check nr_swap_pages and
>> inactive_anon_is_low. Are we planning to change them to use
>> total_swap_pages
>> to be consistent ?
>
> If that makes sense, maybe the check can just be moved into
> inactive_anon_is_low itself?

That was the initial patch posted, instead we changed to use
total_swap_pages instead. How this patch looks:

@@ -1605,6 +1605,9 @@ static int inactive_anon_is_low(struct zone
*zone, struct scan_control *sc)
 {
        int low;

+       if (total_swap_pages <= 0)
+               return 0;
+
        if (scanning_global_lru(sc))
                low = inactive_anon_is_low_global(zone);
        else
@@ -1856,7 +1859,7 @@ static void shrink_zone(int priority, struct zone *zone,
         * Even if we did not try to evict anon pages at all, we want to
         * rebalance the anon lru active/inactive ratio.
         */
-       if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
+       if (inactive_anon_is_low(zone, sc))
                shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);

        throttle_vm_writeout(sc->gfp_mask);

--Ying

>
> --
> All rights reversed
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
