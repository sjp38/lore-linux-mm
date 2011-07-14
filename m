Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 41F566B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 00:46:53 -0400 (EDT)
Date: Thu, 14 Jul 2011 00:46:43 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/5] mm: vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-ID: <20110714044643.GA3203@infradead.org>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-2-git-send-email-mgorman@suse.de>
 <20110714103801.83e10fdb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110714103801.83e10fdb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 14, 2011 at 10:38:01AM +0900, KAMEZAWA Hiroyuki wrote:
> > +			/*
> > +			 * Only kswapd can writeback filesystem pages to
> > +			 * avoid risk of stack overflow
> > +			 */
> > +			if (page_is_file_cache(page) && !current_is_kswapd()) {
> > +				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
> > +				goto keep_locked;
> > +			}
> > +
> 
> 
> This will cause tons of memcg OOM kill because we have no help of kswapd (now).

XFS and btrfs already disable writeback from memcg context, as does ext4
for the typical non-overwrite workloads, and none has fallen apart.

In fact there's no way we can enable them as the memcg calling contexts
tend to have massive stack usage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
