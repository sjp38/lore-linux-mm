Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 10F326B0068
	for <linux-mm@kvack.org>; Tue, 29 May 2012 03:29:14 -0400 (EDT)
Date: Tue, 29 May 2012 09:28:53 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120529072853.GD1734@cmpxchg.org>
References: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
 <20120529030857.GA7762@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120529030857.GA7762@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Tue, May 29, 2012 at 11:08:57AM +0800, Fengguang Wu wrote:
> Hi Michal,
> 
> On Mon, May 28, 2012 at 05:38:55PM +0200, Michal Hocko wrote:
> > Current implementation of dirty pages throttling is not memcg aware which makes
> > it easy to have LRUs full of dirty pages which might lead to memcg OOM if the
> > hard limit is small and so the lists are scanned faster than pages written
> > back.
> > 
> > This patch fixes the problem by throttling the allocating process (possibly
> > a writer) during the hard limit reclaim by waiting on PageReclaim pages.
> > We are waiting only for PageReclaim pages because those are the pages
> > that made one full round over LRU and that means that the writeback is much
> > slower than scanning.
> > The solution is far from being ideal - long term solution is memcg aware
> > dirty throttling - but it is meant to be a band aid until we have a real
> > fix.
> 
> IMHO it's still an important "band aid" -- perhaps worthwhile for
> sending to Greg's stable trees. Because it fixes a really important
> use case: it enables the users to put backups into a small memcg.
> 
> The users visible changes are:
> 
>         the backup program get OOM killed
> =>
>         it runs now, although being a bit slow and bumpy

The problem is workloads that /don't/ have excessive dirty pages, but
instantiate clean page cache at a much faster rate than writeback can
clean the few dirties.  The dirty/writeback pages reach the end of the
lru several times while there are always easily reclaimable pages
around.

This was the rationale for introducing the backoff function that
considers the dirty page percentage of all pages looked at (bottom of
shrink_active_list) and removing all other sleeps that didn't look at
the bigger picture and made problems.  I'd hate for them to come back.

On the other hand, is there a chance to make this backoff function
work for memcgs?  Right now it only applies to the global case to not
mark a whole zone congested because of some dirty pages on a single
memcg LRU.  But maybe it can work by considering congestion on a
per-lruvec basis rather than per-zone?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
