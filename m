Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 66BBC6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 05:25:30 -0400 (EDT)
Date: Thu, 11 Apr 2013 19:25:24 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Message-ID: <20130411092524.GK10481@dastard>
References: <51628877.5000701@parallels.com>
 <20130409005547.GC21654@lge.com>
 <20130409012931.GE17758@dastard>
 <20130409020505.GA4218@lge.com>
 <20130409123008.GM17758@dastard>
 <20130410025115.GA5872@lge.com>
 <20130410100752.GA10481@dastard>
 <CAAmzW4OMyZ=nVbHK_AiifPK5LVxvhOQUXmsD5NGfo33CBjf=eA@mail.gmail.com>
 <20130411004114.GC10481@dastard>
 <20130411072729.GA3605@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411072729.GA3605@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: JoonSoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Apr 11, 2013 at 03:27:30PM +0800, Wanpeng Li wrote:
> On Thu, Apr 11, 2013 at 10:41:14AM +1000, Dave Chinner wrote:
> >On Wed, Apr 10, 2013 at 11:03:39PM +0900, JoonSoo Kim wrote:
> >> Another one what I found is that they don't account "nr_reclaimed" precisely.
> >> There is no code which check whether "current->reclaim_state" exist or not,
> >> except prune_inode().
> >
> >That's because prune_inode() can free page cache pages when the
> >inode mapping is invalidated. Hence it accounts this in addition
> >to the slab objects being freed.
> >
> >IOWs, if you have a shrinker that frees pages from the page cache,
> >you need to do this. Last time I checked, only inode cache reclaim
> >caused extra page cache reclaim to occur, so most (all?) other
> >shrinkers do not need to do this.
> >
> 
> If we should account "nr_reclaimed" against huge zero page? There are 
> large number(512) of pages reclaimed which can throttle direct or 
> kswapd relcaim to avoid reclaim excess pages. I can do this work if 
> you think the idea is needed.

I'm not sure. the zero hugepage is allocated through:

	zero_page = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE,   
				HPAGE_PMD_ORDER);

which means the pages reclaimed by the shrinker aren't file/anon LRU
pages.  Hence I'm not sure what extra accounting might be useful
here, but accounting them as LRU pages being reclaimed seems wrong.

FWIW, the reclaim of a single global object by a shrinker is not
really a use case the shrinkers were designed for, so I suspect that
anything we try to do right now within the current framework will
just be a hack.

I suspect that what we need to do is add the current zone reclaim
priority to the shrinker control structure (like has been done with
the nodemask) so that objects like this can be considered for
removal at a specific reclaim priority level rather than trying to
use scan/count trickery to get where we want to be.

Perhaps we need a shrinker->shrink_priority method that is called just
once when the reclaim priority is high enough to trigger it. i.e.
all these "do something special when memory reclaim is struggling to
make progress" operations set the priority at which they get called
and every time shrink_slab() is then called with that priority (or
higher) the shrinker->shrink_priority method is called just once?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
