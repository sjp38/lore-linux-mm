Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id D42376B0075
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 18:00:15 -0400 (EDT)
Date: Tue, 19 Jun 2012 15:00:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] memcg: prevent from OOM with too many dirty pages
Message-Id: <20120619150014.1ebc108c.akpm@linux-foundation.org>
In-Reply-To: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Tue, 19 Jun 2012 16:50:04 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> Current implementation of dirty pages throttling is not memcg aware which makes
> it easy to have LRUs full of dirty pages which might lead to memcg OOM if the
> hard limit is small and so the lists are scanned faster than pages written
> back.

This is a bit hard to parse.  I changed it to

: The current implementation of dirty pages throttling is not memcg aware
: which makes it easy to have memcg LRUs full of dirty pages.  Without
: throttling, these LRUs can be scanned faster than the rate of writeback,
: leading to memcg OOM conditions when the hard limit is small.

does that still say what you meant to say?

> The solution is far from being ideal - long term solution is memcg aware
> dirty throttling - but it is meant to be a band aid until we have a real
> fix.

Fair enough I guess.  The fix is small and simple and if it makes the
kernel better, why not?

Would like to see a few more acks though.  Why hasn't everyone been
hitting this?

> We are seeing this happening during nightly backups which are placed into
> containers to prevent from eviction of the real working set.

Well that's a trick which we want to work well.  It's a killer
featurelet for people who wonder what all this memcg crap is for ;)

> The change affects only memcg reclaim and only when we encounter PageReclaim
> pages which is a signal that the reclaim doesn't catch up on with the writers
> so somebody should be throttled. This could be potentially unfair because it
> could be somebody else from the group who gets throttled on behalf of the
> writer but as writers need to allocate as well and they allocate in higher rate
> the probability that only innocent processes would be penalized is not that
> high.

OK.

> ...
>
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

A couple of things here.

With my gcc and CONFIG_CGROUP_MEM_RES_CTLR=n (for gawd's sake can we
please rename this to CONFIG_MEMCG?), this:

--- a/mm/vmscan.c~memcg-prevent-from-oom-with-too-many-dirty-pages-fix
+++ a/mm/vmscan.c
@@ -726,8 +726,8 @@ static unsigned long shrink_page_list(st
 			 * writeback from reclaim and there is nothing else to
 			 * reclaim.
 			 */
-			if (PageReclaim(page)
-					&& may_enter_fs && !global_reclaim(sc))
+			if (!global_reclaim(sc) && PageReclaim(page) &&
+					may_enter_fs)
 				wait_on_page_writeback(page);
 			else {
 				nr_writeback++;


reduces vmscan.o's .text by 48 bytes(!).  Because the compiler can
avoid generating any code for PageReclaim() and perhaps the
may_enter_fs test.  Because global_reclaim() evaluates to constant
true.  Do you think that's an improvement?

Also, why do we test may_enter_fs here?  I should have been able to
work out your reasoning from either code comments or changelogging but
I cannot (bad).  I don't *think* there's a deadlock issue here?  If the
page is now under writeback, that writeback *will* complete?

Finally, I wonder if there should be some timeout of that wait.  I
don't know why, but I wouldn't be surprised if we hit some glitch which
causes us to add one!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
