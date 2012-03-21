Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 3DF8C6B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 07:45:49 -0400 (EDT)
Date: Wed, 21 Mar 2012 11:45:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: forbid lumpy-reclaim in shrink_active_list()
Message-ID: <20120321114543.GD16573@suse.de>
References: <20120319091821.17716.54031.stgit@zurg>
 <4F676FA4.50905@redhat.com>
 <4F6773CC.2010705@openvz.org>
 <4F6774E8.2050202@redhat.com>
 <alpine.LSU.2.00.1203191239570.3498@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1203191239570.3498@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Mar 19, 2012 at 01:05:55PM -0700, Hugh Dickins wrote:
> On Mon, 19 Mar 2012, Rik van Riel wrote:
> > On 03/19/2012 01:58 PM, Konstantin Khlebnikov wrote:
> > > Rik van Riel wrote:
> > > > On 03/19/2012 05:18 AM, Konstantin Khlebnikov wrote:
> > > > > This patch reset reclaim mode in shrink_active_list() to
> > > > > RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC.
> > > > > (sync/async sign is used only in shrink_page_list and does not affect
> > > > > shrink_active_list)
> > > > > 
> > > > > Currenly shrink_active_list() sometimes works in lumpy-reclaim mode,
> > > > > if RECLAIM_MODE_LUMPYRECLAIM left over from earlier
> > > > > shrink_inactive_list().
> > > > > Meanwhile, in age_active_anon() sc->reclaim_mode is totally zero.
> > > > > So, current behavior is too complex and confusing, all this looks
> > > > > like bug.
> > > > > 
> > > > > In general, shrink_active_list() populate inactive list for next
> > > > > shrink_inactive_list().
> > > > > Lumpy shring_inactive_list() isolate pages around choosen one from
> > > > > both active and
> > > > > inactive lists. So, there no reasons for lumpy-isolation in
> > > > > shrink_active_list()
> > > > > 
> > > > > Proposed-by: Hugh Dickins<hughd@google.com>
> > > > > Link: https://lkml.org/lkml/2012/3/15/583
> > > > > Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > > > 
> > > > Confirmed, this is already done by commit
> > > > 26f5f2f1aea7687565f55c20d69f0f91aa644fb8 in the
> > > > linux-next tree.
> > > > 
> > > 
> > > No, your patch fix this problem only if CONFIG_COMPACTION=y
> > 
> > True.
> > 
> > It was done that way, because Mel explained to me that deactivating
> > a whole chunk of active pages at once is a desired feature that makes
> > it more likely that a whole contiguous chunk of pages will eventually
> > reach the end of the inactive list.
> 
> I'm rather sceptical about this: is there a test which demonstrates
> a useful effect of that kind?
> 

Testing was done on this over a number of releases around the time that
lumpy reclaim was merged. It made a measurable difference both to allocation
success rates and latency. It is not something I have tested recently
because the focus has been on compaction but it acted as expected once upon
a time. This is why I asked Rik not to change the behaviour in his
patch. My preference would be that lumpy reclaim be removed in the next
cycle and it was on my TODO list to write the patch around 3.4-rc1 after
the merge window closed.

> Lumpy movement from active won't help a lumpy allocation this time,
> because lumpy reclaim from inactive doesn't care which lru the
> surrounding pages come from anyway - and I argue that lumpy movement
> from active actually reduces the number of choices which lumpy
> reclaim will have, if they do near the bottom of inactive together.
> 

The behaviour at the time was that lumpy reclaim would move a number of
hugepage-aligned regions including pages from the active list.  Lumpy reclaim
would reclaim some these but as order-0 reclaim aged the other regions,
it also tended to free pages in contiguous ranges.  In the event there
was a burst of lumpy reclaim requests, the latency of the allocation was
lower on average with this decision. This was disruptive of course but
at the time this only happened if the hugepage pool was being resized or
a large application was starting up using dynamic hugepage pool resizing
so the disruption was relatively short lived.

> So if lumpy movement from active (miscategorizing physically adjacent
> pages as inactive too) is actually useful (the miscategorization turning
> out to have been a good bet, since they're not activated again before
> they reach the bottom of the inactive), and a nice buddyable group of
> pages is later reclaimed from the inactive list because of it (without
> any need for lumpy reclaim that time), then wouldn't we want to be
> doing it more?
> 

Possibly but there is little point in working on making lumpy reclaim
more efficient right now.

> It should not be done only when inactive_is_low coincides with reclaim
> for a high-order allocation: we would want to note that there's a load
> which is making high-order requests, and do lumpy movement from active
> whenever replenishing inactive while such a load is in force.
> 
> If it does more good than harm; but I'm sceptical about that.
> 

My preference at this point is not to merge this patch and instead remove
lumpy reclaim in one go during the next cycle. If a user is really depending
on it, it would then be slightly easier to revert. The only potential user
I can think of is NOMMU but even then I'm skeptical they care.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
