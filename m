Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DA20A6B016E
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:48:51 -0400 (EDT)
Date: Mon, 13 Sep 2010 21:48:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/10] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100913134845.GB12355@localhost>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
 <1283770053-18833-11-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1283770053-18833-11-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> +	/*
> +	 * If reclaim is encountering dirty pages, it may be because
> +	 * dirty pages are reaching the end of the LRU even though the
> +	 * dirty_ratio may be satisified. In this case, wake flusher
> +	 * threads to pro-actively clean up to a maximum of
> +	 * 4 * SWAP_CLUSTER_MAX amount of data (usually 1/2MB) unless
> +	 * !may_writepage indicates that this is a direct reclaimer in
> +	 * laptop mode avoiding disk spin-ups
> +	 */
> +	if (file && nr_dirty_seen && sc->may_writepage)
> +		wakeup_flusher_threads(nr_writeback_pages(nr_dirty));

wakeup_flusher_threads() works, but seems not the pertinent one.

- locally, it needs some luck to clean the pages that direct reclaim is waiting on
- globally, it cleans up some dirty pages, however some heavy dirtier
  may quickly create new ones..

So how about taking the approaches in these patches?

- "[PATCH 4/4] vmscan: transfer async file writeback to the flusher"
- "[PATCH 15/17] mm: lower soft dirty limits on memory pressure"

In particular the first patch should work very nicely with memcg, as
all pages of an inode typically belong to the same memcg. So doing
write-around helps clean lots of dirty pages in the target LRU list in
one shot.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
