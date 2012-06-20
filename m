Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 42DB06B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 04:28:00 -0400 (EDT)
Date: Wed, 20 Jun 2012 10:27:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120620082755.GA5541@tiehlicka.suse.cz>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
 <20120619150014.1ebc108c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120619150014.1ebc108c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Tue 19-06-12 15:00:14, Andrew Morton wrote:
> On Tue, 19 Jun 2012 16:50:04 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Current implementation of dirty pages throttling is not memcg aware which makes
> > it easy to have LRUs full of dirty pages which might lead to memcg OOM if the
> > hard limit is small and so the lists are scanned faster than pages written
> > back.
> 
> This is a bit hard to parse.  I changed it to
> 
> : The current implementation of dirty pages throttling is not memcg aware
> : which makes it easy to have memcg LRUs full of dirty pages.  Without
> : throttling, these LRUs can be scanned faster than the rate of writeback,
> : leading to memcg OOM conditions when the hard limit is small.
> 
> does that still say what you meant to say?

Yes, Thanks!

> > The solution is far from being ideal - long term solution is memcg aware
> > dirty throttling - but it is meant to be a band aid until we have a real
> > fix.
> 
> Fair enough I guess.  The fix is small and simple and if it makes the
> kernel better, why not?
> 
> Would like to see a few more acks though. 

> Why hasn't everyone been hitting this?

Because you need very small hard limit an heavy writers. We have seen
some complains in the past but our answer was "make the limit bigger".

[...]
> A couple of things here.
> 
> With my gcc and CONFIG_CGROUP_MEM_RES_CTLR=n (for gawd's sake can we
> please rename this to CONFIG_MEMCG?), this:
> 
> --- a/mm/vmscan.c~memcg-prevent-from-oom-with-too-many-dirty-pages-fix
> +++ a/mm/vmscan.c
> @@ -726,8 +726,8 @@ static unsigned long shrink_page_list(st
>  			 * writeback from reclaim and there is nothing else to
>  			 * reclaim.
>  			 */
> -			if (PageReclaim(page)
> -					&& may_enter_fs && !global_reclaim(sc))
> +			if (!global_reclaim(sc) && PageReclaim(page) &&
> +					may_enter_fs)
>  				wait_on_page_writeback(page);
>  			else {
>  				nr_writeback++;
> 
> 
> reduces vmscan.o's .text by 48 bytes(!).  Because the compiler can
> avoid generating any code for PageReclaim() and perhaps the
> may_enter_fs test.  Because global_reclaim() evaluates to constant
> true.  Do you think that's an improvement?

Yes you are right. We should optimize for the non-memcg case.

> Also, why do we test may_enter_fs here?  I should have been able to
> work out your reasoning from either code comments or changelogging but
> I cannot (bad).  I don't *think* there's a deadlock issue here?  If the
> page is now under writeback, that writeback *will* complete?

Good question.  To be honest I mimicked what sync. lumpy reclaim
did. You are right that we cannot deadlock here because writeback has
been already started.  But when I was digging back into history I found
this: https://lkml.org/lkml/2007/7/30/344

But now that I am thinking about it some more, memcg (hard limit) reclaim
is different and we shouldn't end up with !may_enter_fs allocation here
because all those allocations are for page cache or anon pages. 
So I guess we can drop the may_enter_fs part.
Thanks for pointing it out.

> Finally, I wonder if there should be some timeout of that wait.  I
> don't know why, but I wouldn't be surprised if we hit some glitch which
> causes us to add one!

As you said, the writeback will eventually complete so we will not wait
for ever. I have played with slow USB storages and saw only small
stalls which are much better than OOM.
Johannes was worried about stalls when we hit PageReclaim pages while
there are a lot of clean pages to reclaim when we would stall without
any good reason. This situation is rather hard to simulate even with
artificial loads so we concluded that this is a room for additional
improvements but this band aid is worth on its own.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
