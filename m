Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 1BF2E6B0081
	for <linux-mm@kvack.org>; Tue,  1 May 2012 11:38:36 -0400 (EDT)
Date: Tue, 1 May 2012 17:38:25 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 5/5] mm: refault distance-based file cache sizing
Message-ID: <20120501153825.GA4837@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
 <1335861713-4573-6-git-send-email-hannes@cmpxchg.org>
 <20120501141330.GA2207@barrios>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120501141330.GA2207@barrios>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, May 01, 2012 at 11:13:30PM +0900, Minchan Kim wrote:
> Hi Hannes,
> 
> On Tue, May 01, 2012 at 10:41:53AM +0200, Johannes Weiner wrote:
> > To protect frequently used page cache (workingset) from bursts of less
> > frequently used or one-shot cache, page cache pages are managed on two
> > linked lists.  The inactive list is where all cache starts out on
> > fault and ends on reclaim.  Pages that get accessed another time while
> > on the inactive list get promoted to the active list to protect them
> > from reclaim.
> > 
> > Right now we have two main problems.
> > 
> > One stems from numa allocation decisions and how the page allocator
> > and kswapd interact.  The both of them can enter into a perfect loop
> > where kswapd reclaims from the preferred zone of a task, allowing the
> > task to continuously allocate from that zone.  Or, the node distance
> > can lead to the allocator to do direct zone reclaim to stay in the
> > preferred zone.  This may be good for locality, but the task has only
> 
> Understood.
> 
> > the inactive space of that one zone to get its memory activated.
> > Forcing the allocator to spread out to lower zones in the right
> > situation makes the difference between continuous IO to serve the
> > workingset, or taking the numa cost but serving fully from memory.
> 
> It's hard to parse your word due to my dumb brain.
> Could you elaborate on it?
> It would be a good if you say with example.

Say your Normal zone is 4G (DMA32 also 4G) and you have 2G of active
file pages in Normal and DMA32 is full of other stuff.  Now you access
a new 6G file repeatedly.  First it allocates from Normal (preferred),
then tries DMA32 (full), wakes up kswapd and retries all zones.  If
kswapd then frees pages at roughly the same pace as the allocator
allocates from Normal, kswapd never goes to sleep and evicts pages
from the 6G file before they can get accessed a second time.  Even
though the 6G file could fit in memory (4G Normal + 4G DMA32), the
allocator only uses the 4G Normal zone.

Same applies if you have a load that would fit in the memory of two
nodes but the node distance leads the allocator to do zone_reclaim()
and forcing the pages to stay in one node, again preventing the load
from being fully cached in memory, which is much more expensive than
the foreign node cost.

> > up to half of memory, and don't recognize workingset changes that are
> > bigger than half of memory.
> 
> Workingset change?
> You mean if new workingset is bigger than half of memory and it's like
> stream before retouch, we could cache only part of working set because 
> head pages on working set would be discared by tail pages of working set
> in inactive list?

Spot-on.  I called that 'tail-chasing' in my notes :-) When you are in
a perpetual loop of evicting pages you will need in a couple hundred
page faults.  Those couple hundred page faults are the refault
distance and my code is able to detect these loops and increases the
space available to the inactive list to end them, if possible.

This is the whole principle of the series.

If such a loop is recognized in a single zone, the allocator goes for
lower zones to increase the inactive space.  If such a loop is
recognized over all allowed zones in the zonelist, the active lists
are shrunk to increase the inactive space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
