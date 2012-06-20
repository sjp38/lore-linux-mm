Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 63CFA6B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 05:20:17 -0400 (EDT)
Date: Wed, 20 Jun 2012 10:20:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120620092011.GB4011@suse.de>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
 <20120619150014.1ebc108c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120619150014.1ebc108c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Tue, Jun 19, 2012 at 03:00:14PM -0700, Andrew Morton wrote:
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
> 
> > The solution is far from being ideal - long term solution is memcg aware
> > dirty throttling - but it is meant to be a band aid until we have a real
> > fix.
> 
> Fair enough I guess.  The fix is small and simple and if it makes the
> kernel better, why not?
> 
> Would like to see a few more acks though.  Why hasn't everyone been
> hitting this?
> 

I had been quiet because Acks from people in the same company tend to not
carry much weight.

I think this patch is appropriate. It is not necessarily the *best*
and potentially there is a better solution out there which is why I think
people have been reluctent to ack it. However, some of the better solutions
also had corner cases where they could simply break again or require a lot
of new infrastructure such as dirty-limit tracking within memcgs that we
are just not ready for.  This patch may not be subtle but it fixes a very
annoying issue that currently makes memcg dangerous to use for workloads
that dirty a lot of their memory. When the all singing all dancing fix
exists then it can be reverted if necessary but from me;

Reviewed-by: Mel Gorman <mgorman@suse.de>

Some caveats with may_enter_fs below.

> > We are seeing this happening during nightly backups which are placed into
> > containers to prevent from eviction of the real working set.
> 
> Well that's a trick which we want to work well.  It's a killer
> featurelet for people who wonder what all this memcg crap is for ;)
> 

Turns out people get really pissed when their straight-forward workload
blows up.

> > +			/*
> > +			 * memcg doesn't have any dirty pages throttling so we
> > +			 * could easily OOM just because too many pages are in
> > +			 * writeback from reclaim and there is nothing else to
> > +			 * reclaim.
> > +			 */
> > +			if (PageReclaim(page)
> > +					&& may_enter_fs && !global_reclaim(sc))
> > +				wait_on_page_writeback(page);
> > +			else {
> > +				nr_writeback++;
> > +				unlock_page(page);
> > +				goto keep;
> > +			}
> 
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
> 

Looks functionally equivalent to me so why not get the 48 bytes!

> Also, why do we test may_enter_fs here? 

I think this is partially my fault because it's based on a similar test
lumpy reclaim used to do and I at least didn't reconsider it properly during
review. Back then, there were two reasons for the may_enter_fs check. The
first was to avoid processes like kjournald ever stalling on page writeback
because it caused the system to "stutter". The more relevant reason was
because callers that lacked may_enter_fs were also likely to fail lumpy
reclaim if they could not write dirty pages and wait on them so it was
better to give up or move to another block.

In the context of memcg reclaim there should be no concern about kernel
threads getting stuck on writeback and it does not have the same problem
as lumpy reclaim had with being unable to writeout pages. IMO, the check
is safe to drop. Michal?

> Finally, I wonder if there should be some timeout of that wait.  I
> don't know why, but I wouldn't be surprised if we hit some glitch which
> causes us to add one!
> 

If we hit such a situation it means that flush is no longer working which
is interesting in itself. I guess one possibility where it can occur is
if we hit global dirty limits (or memcg dirty limits when they exist)
and the page is backed by NFS that is disconnected. That would stall here
potentially forever but it's already the case that a system that hits its
dirty limits with a disconnected NFS is in trouble and a timeout here will
not do much to help.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
