Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3F86B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 05:25:34 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 896743EE0B6
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:25:31 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 707FB45DF49
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:25:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5737E45DF4E
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:25:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D9BD1DB8045
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:25:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 660AB1DB8046
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:25:25 +0900 (JST)
Date: Thu, 11 Aug 2011 18:18:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/7] mm: vmscan: Throttle reclaim if encountering too
 many dirty pages under writeback
Message-Id: <20110811181804.44f2ee80.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1312973240-32576-7-git-send-email-mgorman@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
	<1312973240-32576-7-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, 10 Aug 2011 11:47:19 +0100
Mel Gorman <mgorman@suse.de> wrote:

> Workloads that are allocating frequently and writing files place a
> large number of dirty pages on the LRU. With use-once logic, it is
> possible for them to reach the end of the LRU quickly requiring the
> reclaimer to scan more to find clean pages. Ordinarily, processes that
> are dirtying memory will get throttled by dirty balancing but this
> is a global heuristic and does not take into account that LRUs are
> maintained on a per-zone basis. This can lead to a situation whereby
> reclaim is scanning heavily, skipping over a large number of pages
> under writeback and recycling them around the LRU consuming CPU.
> 
> This patch checks how many of the number of pages isolated from the
> LRU were dirty and under writeback. If a percentage of them under
> writeback, the process will be throttled if a backing device or the
> zone is congested. Note that this applies whether it is anonymous or
> file-backed pages that are under writeback meaning that swapping is
> potentially throttled. This is intentional due to the fact if the
> swap device is congested, scanning more pages and dispatching more
> IO is not going to help matters.
> 
> The percentage that must be in writeback depends on the priority. At
> default priority, all of them must be dirty. At DEF_PRIORITY-1, 50%
> of them must be, DEF_PRIORITY-2, 25% etc. i.e. as pressure increases
> the greater the likelihood the process will get throttled to allow
> the flusher threads to make some progress.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: Johannes Weiner <jweiner@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Maybe I need to add memcg_is_congested() ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
