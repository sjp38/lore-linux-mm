Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ACCD06B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 11:29:07 -0400 (EDT)
Date: Mon, 16 Aug 2010 17:26:48 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm: page allocator: Update free page counters after pages are placed on the free list
Message-ID: <20100816152648.GA15103@cmpxchg.org>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1281951733-29466-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 16, 2010 at 10:42:11AM +0100, Mel Gorman wrote:
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
