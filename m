Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id BC53E6B00FF
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:06:29 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1653315pbc.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 13:06:29 -0700 (PDT)
Date: Mon, 19 Mar 2012 13:05:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: forbid lumpy-reclaim in shrink_active_list()
In-Reply-To: <4F6774E8.2050202@redhat.com>
Message-ID: <alpine.LSU.2.00.1203191239570.3498@eggly.anvils>
References: <20120319091821.17716.54031.stgit@zurg> <4F676FA4.50905@redhat.com> <4F6773CC.2010705@openvz.org> <4F6774E8.2050202@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 19 Mar 2012, Rik van Riel wrote:
> On 03/19/2012 01:58 PM, Konstantin Khlebnikov wrote:
> > Rik van Riel wrote:
> > > On 03/19/2012 05:18 AM, Konstantin Khlebnikov wrote:
> > > > This patch reset reclaim mode in shrink_active_list() to
> > > > RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC.
> > > > (sync/async sign is used only in shrink_page_list and does not affect
> > > > shrink_active_list)
> > > > 
> > > > Currenly shrink_active_list() sometimes works in lumpy-reclaim mode,
> > > > if RECLAIM_MODE_LUMPYRECLAIM left over from earlier
> > > > shrink_inactive_list().
> > > > Meanwhile, in age_active_anon() sc->reclaim_mode is totally zero.
> > > > So, current behavior is too complex and confusing, all this looks
> > > > like bug.
> > > > 
> > > > In general, shrink_active_list() populate inactive list for next
> > > > shrink_inactive_list().
> > > > Lumpy shring_inactive_list() isolate pages around choosen one from
> > > > both active and
> > > > inactive lists. So, there no reasons for lumpy-isolation in
> > > > shrink_active_list()
> > > > 
> > > > Proposed-by: Hugh Dickins<hughd@google.com>
> > > > Link: https://lkml.org/lkml/2012/3/15/583
> > > > Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > > 
> > > Confirmed, this is already done by commit
> > > 26f5f2f1aea7687565f55c20d69f0f91aa644fb8 in the
> > > linux-next tree.
> > > 
> > 
> > No, your patch fix this problem only if CONFIG_COMPACTION=y
> 
> True.
> 
> It was done that way, because Mel explained to me that deactivating
> a whole chunk of active pages at once is a desired feature that makes
> it more likely that a whole contiguous chunk of pages will eventually
> reach the end of the inactive list.

I'm rather sceptical about this: is there a test which demonstrates
a useful effect of that kind?

Lumpy movement from active won't help a lumpy allocation this time,
because lumpy reclaim from inactive doesn't care which lru the
surrounding pages come from anyway - and I argue that lumpy movement
from active actually reduces the number of choices which lumpy
reclaim will have, if they do near the bottom of inactive together.

So if lumpy movement from active (miscategorizing physically adjacent
pages as inactive too) is actually useful (the miscategorization turning
out to have been a good bet, since they're not activated again before
they reach the bottom of the inactive), and a nice buddyable group of
pages is later reclaimed from the inactive list because of it (without
any need for lumpy reclaim that time), then wouldn't we want to be
doing it more?

It should not be done only when inactive_is_low coincides with reclaim
for a high-order allocation: we would want to note that there's a load
which is making high-order requests, and do lumpy movement from active
whenever replenishing inactive while such a load is in force.

If it does more good than harm; but I'm sceptical about that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
