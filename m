Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A1A196B01AC
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:52:35 -0400 (EDT)
Date: Fri, 2 Jul 2010 12:51:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
Message-Id: <20100702125155.69c02f85.akpm@linux-foundation.org>
In-Reply-To: <1277811288-5195-13-git-send-email-mel@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
	<1277811288-5195-13-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 2010 12:34:46 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> When memory is under enough pressure, a process may enter direct
> reclaim to free pages in the same manner kswapd does. If a dirty page is
> encountered during the scan, this page is written to backing storage using
> mapping->writepage. This can result in very deep call stacks, particularly
> if the target storage or filesystem are complex. It has already been observed
> on XFS that the stack overflows but the problem is not XFS-specific.
> 
> This patch prevents direct reclaim writing back pages by not setting
> may_writepage in scan_control. Instead, dirty pages are placed back on the
> LRU lists for either background writing by the BDI threads or kswapd. If
> in direct lumpy reclaim and dirty pages are encountered, the process will
> stall for the background flusher before trying to reclaim the pages again.
> 
> Memory control groups do not have a kswapd-like thread nor do pages get
> direct reclaimed from the page allocator. Instead, memory control group
> pages are reclaimed when the quota is being exceeded or the group is being
> shrunk. As it is not expected that the entry points into page reclaim are
> deep call chains memcg is still allowed to writeback dirty pages.

I already had "[PATCH 01/14] vmscan: Fix mapping use after free" and
I'll send that in for 2.6.35.

I grabbed [02/14] up to [11/14].  Including "[PATCH 06/14] vmscan: kill
prev_priority completely", grumpyouallsuck.

I wimped out at this, "Do not writeback pages in direct reclaim".  It
really is a profound change and needs a bit more thought, discussion
and if possible testing which is designed to explore possible pathologies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
