Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7836B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 08:41:27 -0400 (EDT)
Date: Tue, 14 Sep 2010 14:40:33 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/4] writeback: quit background/periodic work when
 other works are enqueued
Message-ID: <20100914124033.GA4874@quack.suse.cz>
References: <20100913123110.372291929@intel.com>
 <20100913130149.994322762@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Content-Disposition: inline
In-Reply-To: <20100913130149.994322762@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

  Hi,

On Mon 13-09-10 20:31:12, Wu Fengguang wrote:
>  From: Jan Kara <jack@suse.cz>
> 
> Background writeback and kupdate-style writeback are easily livelockable
> (from a definition of their target). This is inconvenient because it can
> make sync(1) stall forever waiting on its queued work to be finished.
> Fix the problem by interrupting background and kupdate writeback if there
> is some other work to do. We can return to them after completing all the
> queued work.
  I actually have a slightly updated version with a better changelog:

Background writeback are easily livelockable (from a definition of their
target). This is inconvenient because it can make sync(1) stall forever waiting
on its queued work to be finished. Generally, when a flusher thread has
some work queued, someone submitted the work to achieve a goal more specific
than what background writeback does. So it makes sense to give it a priority
over a generic page cleaning.

Thus we interrupt background writeback if there is some other work to do. We
return to the background writeback after completing all the queued work.

  Could you please update it? Thanks.
								Honza

PS: I've also attached the full patch if that's more convenient for you.

> Signed-off-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> --- linux-next.orig/fs/fs-writeback.c	2010-09-13 13:58:47.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2010-09-13 14:03:54.000000000 +0800
> @@ -643,6 +643,14 @@ static long wb_writeback(struct bdi_writ
>  			break;
>  
>  		/*
> +		 * Background writeout and kupdate-style writeback are
> +		 * easily livelockable. Stop them if there is other work
> +		 * to do so that e.g. sync can proceed.
> +		 */
> +		if ((work->for_background || work->for_kupdate) &&
> +		    !list_empty(&wb->bdi->work_list))
> +			break;
> +		/*
>  		 * For background writeout, stop when we are below the
>  		 * background dirty threshold
>  		 */
> 
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--dDRMvlgZJXvWKvBx
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0002-mm-Stop-background-writeback-if-there-is-other-work-.patch"


--dDRMvlgZJXvWKvBx--
