Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B5416B01F0
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 22:21:16 -0400 (EDT)
Received: by vws16 with SMTP id 16so4780859vws.14
        for <linux-mm@kvack.org>; Mon, 16 Aug 2010 19:21:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1281951733-29466-2-git-send-email-mel@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
	<1281951733-29466-2-git-send-email-mel@csn.ul.ie>
Date: Tue, 17 Aug 2010 11:21:15 +0900
Message-ID: <AANLkTi=wtAAaW4HoU7Oee=gNuM_t1hvf9sAK7RGRJ1AQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: page allocator: Update free page counters after
 pages are placed on the free list
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Mel.

On Mon, Aug 16, 2010 at 6:42 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> When allocating a page, the system uses NR_FREE_PAGES counters to determine
> if watermarks would remain intact after the allocation was made. This
> check is made without interrupts disabled or the zone lock held and so is
> race-prone by nature. Unfortunately, when pages are being freed in batch,
> the counters are updated before the pages are added on the list. During this
> window, the counters are misleading as the pages do not exist yet. When
> under significant pressure on systems with large numbers of CPUs, it's
> possible for processes to make progress even though they should have been
> stalled. This is particularly problematic if a number of the processes are
> using GFP_ATOMIC as the min watermark can be accidentally breached and in
> extreme cases, the system can livelock.
>
> This patch updates the counters after the pages have been added to the
> list. This makes the allocator more cautious with respect to preserving
> the watermarks and mitigates livelock possibilities.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Page free path looks good by your patch.

Now allocation path decrease NR_FREE_PAGES _after_ it remove pages from buddy.
It can make that actually we don't have enough pages in buddy but
pretend to have enough pages.
It could make same situation with free path which is your concern.
So I think it can confuse watermark check in extreme case.

So don't we need to consider _allocation_ path with conservative?


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
