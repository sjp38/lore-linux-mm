Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4226B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 05:11:14 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D31B23EE0B6
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:11:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B84FA45DE61
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:11:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E0B045DE7A
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:11:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 919741DB803E
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:11:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AB661DB802C
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:11:09 +0900 (JST)
Date: Thu, 11 Aug 2011 18:03:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] mm: vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-Id: <20110811180348.e59c6cbe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1312973240-32576-2-git-send-email-mgorman@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
	<1312973240-32576-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, 10 Aug 2011 11:47:14 +0100
Mel Gorman <mgorman@suse.de> wrote:

> From: Mel Gorman <mel@csn.ul.ie>
> 
> When kswapd is failing to keep zones above the min watermark, a process
> will enter direct reclaim in the same manner kswapd does. If a dirty
> page is encountered during the scan, this page is written to backing
> storage using mapping->writepage.
> 
> This causes two problems. First, it can result in very deep call
> stacks, particularly if the target storage or filesystem are complex.
> Some filesystems ignore write requests from direct reclaim as a result.
> The second is that a single-page flush is inefficient in terms of IO.
> While there is an expectation that the elevator will merge requests,
> this does not always happen. Quoting Christoph Hellwig;
> 
> 	The elevator has a relatively small window it can operate on,
> 	and can never fix up a bad large scale writeback pattern.
> 
> This patch prevents direct reclaim writing back filesystem pages by
> checking if current is kswapd. Anonymous pages are still written to
> swap as there is not the equivalent of a flusher thread for anonymous
> pages. If the dirty pages cannot be written back, they are placed
> back on the LRU lists. There is now a direct dependency on dirty page
> balancing to prevent too many pages in the system being dirtied which
> would prevent reclaim making forward progress.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
