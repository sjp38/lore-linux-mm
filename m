Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E09CC6B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 22:19:52 -0400 (EDT)
Received: by iagv1 with SMTP id v1so3438717iag.14
        for <linux-mm@kvack.org>; Thu, 01 Sep 2011 19:19:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110831173031.GA21571@redhat.com>
References: <1321285043-3470-1-git-send-email-minchan.kim@gmail.com>
	<20110831173031.GA21571@redhat.com>
Date: Fri, 2 Sep 2011 11:19:49 +0900
Message-ID: <CAEwNFnDcNqLvo=oyXXkxgFxs8wNc+WTLwot0qeru1VfQKmUYDQ@mail.gmail.com>
Subject: Re: [PATCH] vmscan: Do reclaim stall in case of mlocked page.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, Sep 1, 2011 at 2:30 AM, Johannes Weiner <jweiner@redhat.com> wrote:
> On Tue, Nov 15, 2011 at 12:37:23AM +0900, Minchan Kim wrote:
>> [1] made avoid unnecessary reclaim stall when second shrink_page_list(ie=
, synchronous
>> shrink_page_list) try to reclaim page_list which has not-dirty pages.
>> But it seems rather awkawrd on unevictable page.
>> The unevictable page in shrink_page_list would be moved into unevictable=
 lru from page_list.
>> So it would be not on page_list when shrink_page_list returns.
>> Nevertheless it skips reclaim stall.
>>
>> This patch fixes it so that it can do reclaim stall in case of mixing ml=
ocked pages
>> and writeback pages on page_list.
>>
>> [1] 7d3579e,vmscan: narrow the scenarios in whcih lumpy reclaim uses syn=
chrounous reclaim
>
> Lumpy isolates physically contiguous in the hope to free a bunch of
> pages that can be merged to a bigger page. =C2=A0If an unevictable page i=
s
> encountered, the chance of that is gone. =C2=A0Why invest the allocation
> latency when we know it won't pay off anymore?
>

Good point!

Except some cases, when we require higher orer page, we used zone
defensive algorithm by zone_watermark_ok. So the number of fewer
higher order pages would be factor of failure of allocation. If it was
problem, we could rescue the situation by only reclaim part of the
block in the hope to free fewer higher order pages.

I thought the lumpy was designed to consider the case.(I might be wrong).
Why I thought is that when we isolate the pages for lumpy and found
the page isn't able to isolate, we don't rollback the isolated pages
in the lumpy phsyical block. It's very pointless to get a higher order
pages.

If we consider that, we have to fix other reset_reclaim_mode cases as
well as mlocked pages.
Or
fix isolataion logic for the lumpy? (When we find the page isn't able
to isolate, rollback the pages in the lumpy block to the LRU)
Or
Nothing and wait to remove lumpy completely.

What do you think about it?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
