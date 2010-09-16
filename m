Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2FD6B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 04:23:29 -0400 (EDT)
Date: Thu, 16 Sep 2010 09:23:12 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 7/8] writeback: Do not sleep on the congestion queue if
	there are no congested BDIs
Message-ID: <20100916082312.GA15709@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie> <1284553671-31574-8-git-send-email-mel@csn.ul.ie> <20100916075949.GA16115@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100916075949.GA16115@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 04:59:49PM +0900, Minchan Kim wrote:
> On Wed, Sep 15, 2010 at 01:27:50PM +0100, Mel Gorman wrote:
> > If congestion_wait() is called with no BDI congested, the caller will sleep
> > for the full timeout and this may be an unnecessary sleep. This patch adds
> > a wait_iff_congested() that checks congestion and only sleeps if a BDI is
> > congested else, it calls cond_resched() to ensure the caller is not hogging
> > the CPU longer than its quota but otherwise will not sleep.
> > 
> > This is aimed at reducing some of the major desktop stalls reported during
> > IO. For example, while kswapd is operating, it calls congestion_wait()
> > but it could just have been reclaiming clean page cache pages with no
> > congestion. Without this patch, it would sleep for a full timeout but after
> > this patch, it'll just call schedule() if it has been on the CPU too long.
> > Similar logic applies to direct reclaimers that are not making enough
> > progress.
> 
> I confused due to kswapd you mentioned.
> This patch affects only direct reclaim.
> Please, complete the description. 
> 

My bad, when the description was first written, both were affected and I
neglected to correct the description. I'm still debating with myself as
to whether the kswapd congestion_wait() should be wait_iff_congested()
or not.

Thanks

> "This patch affects direct reclaimer to reduce stall"
> Otherwise, looks good to me. 
> 
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> -- 
> Kind regards,
> Minchan Kim
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
