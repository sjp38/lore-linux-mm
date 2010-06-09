Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F2E6C6B01BA
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 05:52:23 -0400 (EDT)
Date: Wed, 9 Jun 2010 10:52:00 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
	and use a_ops->writepages() where possible
Message-ID: <20100609095200.GA5650@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100609115211.435a45f7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100609115211.435a45f7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 09, 2010 at 11:52:11AM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue,  8 Jun 2010 10:02:19 +0100
> > <SNIP>
> > 
> > Patch 5 writes out contiguous ranges of pages where possible using
> > a_ops->writepages. When writing a range, the inode is pinned and the page
> > lock released before submitting to writepages(). This potentially generates
> > a better IO pattern and it should avoid a lock inversion problem within the
> > filesystem that wants the same page lock held by the VM. The downside with
> > writing ranges is that the VM may not be generating more IO than necessary.
> > 
> > Patch 6 prevents direct reclaim writing out pages at all and instead dirty
> > pages are put back on the LRU. For lumpy reclaim, the caller will briefly
> > wait on dirty pages to be written out before trying to reclaim the dirty
> > pages a second time.
> > 
> > The last patch increases the responsibility of kswapd somewhat because
> > it's now cleaning pages on behalf of direct reclaimers but kswapd seemed
> > a better fit than background flushers to clean pages as it knows where the
> > pages needing cleaning are. As it's async IO, it should not cause kswapd to
> > stall (at least until the queue is congested) but the order that pages are
> > reclaimed on the LRU is altered. Dirty pages that would have been reclaimed
> > by direct reclaimers are getting another lap on the LRU. The dirty pages
> > could have been put on a dedicated list but this increased counter overhead
> > and the number of lists and it is unclear if it is necessary.
> > 
> > <SNIP>
> 
> My concern is how memcg should work. IOW, what changes will be necessary for
> memcg to work with the new vmscan logic as no-direct-writeback.
> 

At worst, memcg waits on background flushers to clean their pages but
obviously this could lead to stalls in containers if it happened to be full
of dirty pages.

Do you have test scenarios already setup for functional and performance
regression testing of containers? If so, can you run tests with this series
and see what sort of impact you find? I haven't done performance testing
with containers to date so I don't know what the expected values are.

> Maybe an ideal solution will be
>  - support buffered I/O tracking in I/O cgroup.
>  - flusher threads should work with I/O cgroup.
>  - memcg itself should support dirty ratio. and add a trigger to kick flusher
>    threads for dirty pages in a memcg.
> But I know it's a long way.
> 

I'm not very familiar with memcg I'm afraid or its requirements so I am
having trouble guessing which of these would behave the best. You could take
a gamble on having memcg doing writeback in direct reclaim but you may run
into the same problem of overflowing stacks.

I'm not sure how a flusher thread would work just within a cgroup. It
would have to do a lot of searching to find the pages it needs
considering that it's looking at inodes rather than pages.

One possibility I guess would be to create a flusher-like thread if a direct
reclaimer finds that the dirty pages in the container are above the dirty
ratio. It would scan and clean all dirty pages in the container LRU on behalf
of dirty reclaimers.

Another possibility would be to have kswapd work in containers.
Specifically, if wakeup_kswapd() is called with a cgroup that it's added
to a list. kswapd gives priority to global reclaim but would
occasionally check if there is a container that needs kswapd on a
pending list and if so, work within the container. Is there a good
reason why kswapd does not work within container groups?

Finally, you could just allow reclaim within a memcg do writeback. Right
now, the check is based on current_is_kswapd() but I could create a helper
function that also checked for sc->mem_cgroup. Direct reclaim from the
page allocator never appears to work within a container group (which
raises questions in itself such as why a process in a container would
reclaim pages outside the container?) so it would remain safe.

> How the new logic works with memcg ? Because memcg doesn't trigger kswapd,
> memcg has to wait for a flusher thread make pages clean ?

Right now, memcg has to wait for a flusher thread to make pages clean.

> Or memcg should have kswapd-for-memcg ?
> 
> Is it okay to call writeback directly when !scanning_global_lru() ?
> memcg's reclaim routine is only called from specific positions, so, I guess
> no stack problem.

It's a judgement call from you really. I see that direct reclaimers do
not set mem_cgroup so it's down to - are you reasonably sure that all
the paths that reclaim based on a container are not deep? I looked
around for a while and the bulk appeared to be in the fault path so I
would guess "yes" but as I'm not familiar with the memcg implementation
I'll have missed a lot.

> But we just have I/O pattern problem.

True.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
