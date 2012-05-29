Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 663EF6B005C
	for <linux-mm@kvack.org>; Mon, 28 May 2012 23:10:04 -0400 (EDT)
Date: Tue, 29 May 2012 11:08:57 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120529030857.GA7762@localhost>
References: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

Hi Michal,

On Mon, May 28, 2012 at 05:38:55PM +0200, Michal Hocko wrote:
> Current implementation of dirty pages throttling is not memcg aware which makes
> it easy to have LRUs full of dirty pages which might lead to memcg OOM if the
> hard limit is small and so the lists are scanned faster than pages written
> back.
> 
> This patch fixes the problem by throttling the allocating process (possibly
> a writer) during the hard limit reclaim by waiting on PageReclaim pages.
> We are waiting only for PageReclaim pages because those are the pages
> that made one full round over LRU and that means that the writeback is much
> slower than scanning.
> The solution is far from being ideal - long term solution is memcg aware
> dirty throttling - but it is meant to be a band aid until we have a real
> fix.

IMHO it's still an important "band aid" -- perhaps worthwhile for
sending to Greg's stable trees. Because it fixes a really important
use case: it enables the users to put backups into a small memcg.

The users visible changes are:

        the backup program get OOM killed
=>
        it runs now, although being a bit slow and bumpy


Talking about the more comprehensive fix, I'm sorry for delaying this
patch for several months:

        [PATCH 6/9] vmscan: dirty reclaim throttling
        http://thread.gmane.org/gmane.linux.kernel.mm/74582

Now that Jan's iput() avoidance patchset has just been merged by
Linus, I'll rebase the patchset on top of his great work.

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c978ce4..7cccd81 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -720,9 +720,20 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
>  
>  		if (PageWriteback(page)) {
> -			nr_writeback++;
> -			unlock_page(page);
> -			goto keep;
> +			/*
> +			 * memcg doesn't have any dirty pages throttling so we
> +			 * could easily OOM just because too many pages are in
> +			 * writeback from reclaim and there is nothing else to
> +			 * reclaim.
> +			 */
> +			if (PageReclaim(page)
> +					&& may_enter_fs && !global_reclaim(sc))
> +				wait_on_page_writeback(page);
> +			else {
> +				nr_writeback++;
> +				unlock_page(page);
> +				goto keep;
> +			}
>  		}
>  
>  		references = page_check_references(page, sc);

Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>

This is all good for memcg. I'd suggest sending it to 3.5 and 3.4.x as well.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
