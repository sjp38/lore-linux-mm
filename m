Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 52A4E6B0078
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 05:59:12 -0400 (EDT)
Date: Wed, 20 Jun 2012 11:59:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120620095908.GB5541@tiehlicka.suse.cz>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
 <20120619150014.1ebc108c.akpm@linux-foundation.org>
 <20120620092011.GB4011@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120620092011.GB4011@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Wed 20-06-12 10:20:11, Mel Gorman wrote:
> On Tue, Jun 19, 2012 at 03:00:14PM -0700, Andrew Morton wrote:
> > On Tue, 19 Jun 2012 16:50:04 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > Current implementation of dirty pages throttling is not memcg aware which makes
> > > it easy to have LRUs full of dirty pages which might lead to memcg OOM if the
> > > hard limit is small and so the lists are scanned faster than pages written
> > > back.
> > 
> > This is a bit hard to parse.  I changed it to
> > 
> > : The current implementation of dirty pages throttling is not memcg aware
> > : which makes it easy to have memcg LRUs full of dirty pages.  Without
> > : throttling, these LRUs can be scanned faster than the rate of writeback,
> > : leading to memcg OOM conditions when the hard limit is small.
> > 
> > does that still say what you meant to say?
> > 
> > > The solution is far from being ideal - long term solution is memcg aware
> > > dirty throttling - but it is meant to be a band aid until we have a real
> > > fix.
> > 
> > Fair enough I guess.  The fix is small and simple and if it makes the
> > kernel better, why not?
> > 
> > Would like to see a few more acks though.  Why hasn't everyone been
> > hitting this?
> > 
> 
> I had been quiet because Acks from people in the same company tend to not
> carry much weight.
> 
> I think this patch is appropriate. It is not necessarily the *best*
> and potentially there is a better solution out there which is why I think
> people have been reluctent to ack it. However, some of the better solutions
> also had corner cases where they could simply break again or require a lot
> of new infrastructure such as dirty-limit tracking within memcgs that we
> are just not ready for.  This patch may not be subtle but it fixes a very
> annoying issue that currently makes memcg dangerous to use for workloads
> that dirty a lot of their memory. When the all singing all dancing fix
> exists then it can be reverted if necessary but from me;
> 
> Reviewed-by: Mel Gorman <mgorman@suse.de>

Thanks, I will respin the patch and send v2.

[...]
> > Also, why do we test may_enter_fs here? 
> 
> I think this is partially my fault because it's based on a similar test
> lumpy reclaim used to do and I at least didn't reconsider it properly during
> review. Back then, there were two reasons for the may_enter_fs check. The
> first was to avoid processes like kjournald ever stalling on page writeback
> because it caused the system to "stutter". The more relevant reason was
> because callers that lacked may_enter_fs were also likely to fail lumpy
> reclaim if they could not write dirty pages and wait on them so it was
> better to give up or move to another block.
> 
> In the context of memcg reclaim there should be no concern about kernel
> threads getting stuck on writeback and it does not have the same problem
> as lumpy reclaim had with being unable to writeout pages. IMO, the check
> is safe to drop. Michal?

Yes, Is I wrote in other email. memcg reclaim is about LRU pages so the
may_enter_fs is not needed here.

> 
> > Finally, I wonder if there should be some timeout of that wait.  I
> > don't know why, but I wouldn't be surprised if we hit some glitch which
> > causes us to add one!
> > 
> 
> If we hit such a situation it means that flush is no longer working which
> is interesting in itself. I guess one possibility where it can occur is
> if we hit global dirty limits (or memcg dirty limits when they exist)
> and the page is backed by NFS that is disconnected. That would stall here
> potentially forever but it's already the case that a system that hits its
> dirty limits with a disconnected NFS is in trouble and a timeout here will
> not do much to help.

Agreed.

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
