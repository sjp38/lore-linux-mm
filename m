Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 755F06B0318
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 08:10:30 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so6942097pbb.0
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 05:10:30 -0700 (PDT)
Received: from psmtp.com ([74.125.245.205])
        by mx.google.com with SMTP id v8si8475746pbi.167.2013.10.21.05.10.26
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 05:10:27 -0700 (PDT)
Date: Mon, 21 Oct 2013 23:10:16 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
Message-ID: <20131021121016.GB16161@dastard>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
 <20131011003930.GC4446@dastard>
 <20131014214250.GG856@cmpxchg.org>
 <20131015014123.GQ4446@dastard>
 <20131015174128.GH856@cmpxchg.org>
 <20131015234147.GA4446@dastard>
 <525DF466.6030308@redhat.com>
 <20131016022606.GD4446@dastard>
 <20131016223104.GA738@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131016223104.GA738@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 16, 2013 at 06:31:04PM -0400, Johannes Weiner wrote:
> On Wed, Oct 16, 2013 at 01:26:06PM +1100, Dave Chinner wrote:
> > On Tue, Oct 15, 2013 at 10:05:26PM -0400, Rik van Riel wrote:
> > > On 10/15/2013 07:41 PM, Dave Chinner wrote:
> > > > On Tue, Oct 15, 2013 at 01:41:28PM -0400, Johannes Weiner wrote:
> > > >> But it
> > > >> looks like tracking radix tree nodes with a list and backpointers to
> > > >> the mapping object for the lock etc. will be a major pain in the ass.
> > > > 
> > > > Perhaps so - it may not work out when we get down to the fine
> > > > details...
> > > 
> > > I suspect that a combination of lifetime rules (inode cannot
> > > disappear until all the radix tree nodes) and using RCU free
> > > for the radix tree nodes, and the inodes might do the trick.
> > > 
> > > That would mean that, while holding the rcu read lock, the
> > > back pointer from a radix tree node to the inode will always
> > > point to valid memory.
> > 
> > Yes, that is what I was thinking...
> > 
> > > That allows the shrinker to lock the inode, and verify that
> > > the inode is still valid, before it attempts to rcu free the
> > > radix tree node with shadow entries.
> > 
> > Lock the mapping, not the inode. The radix tree is protected by the
> > mapping_lock, not an inode lock. i.e. I'd hope that this can all b
> > contained within the struct address_space and not require any
> > knowledge of inodes or inode lifecycles at all.
> 
> Agreed, we can point to struct address_space and invalidate it by
> setting mapping->host to NULL or so during the RCU grace period.
> 
> Also, the parent pointer is in a union with the two-word rcu_head, so
> we get the address space backpointer for free.
> 
> The struct list_head for the FIFO, as you said, we can get for free as
> well (at least on slab).
> 
> The FIFO lists themselves can be trimmed by a shrinker, I think.  You
> were concerned about wind-up but if the nodes are not in excess and
> ->count just returns 0 until we are actually prepared to shrink
> objects, then there shouldn't be any windup, right?

It's not windup that will be the problem, it's the step change from
going from zero cache items to the global counter value when the
magic threshold is crossed. That will generate a massive delta, and
so generate a huge amount of work to be done from a single shrinker
call that will be executed on the next context that can run it.

i.e. the problem is that the cache size goes from 0 to something
huge in an instant, and will drop from something huge to zero just
as quickly. There is no way the shrinker can prevent overshoot and
oscillation around that magic threshold because the nature of the
step change overwhelms the damping algorithms in the shrinker used
to control the amount work being done and hence reach stability.

Normally, the shrinker sees the size of the cache change gradually,
and so the delta tends to be relatively small and so it does a
little bit of work every time it is called. This keeps the caches
balanced with all the other caches that are trimmed a little at a
time. IOWs, there is a natural damping algorithm built into the
shrinkers that biases them towards a stable, balanced condition,
even under changing workloads.

Windup occurs when that little bit of work keeps getting delayed and
aggregated (e.g. repeated GFP_NOFS reclaim context) which then gets
dumped on a single scan that can make progress (e.g. kswapd). So
windup is an iterative process that triggers "catchup work". The
macro level behaviour might end up looking the same, but they have
very different underlying algorithmic causes.

> I don't see a natural threshold for "excess" yet, though, because
> there is no relationship between where radix_tree_node is allocated
> and which zones the contained shadow entries point to, so it's hard to
> estimate how worthwile any given radix_tree_node is to a node.  Maybe
> tying it to an event might be better, like reclaim pressure, swapping
> etc.

The shrinker is provided a measure of reclaim pressure already,
which it uses to balance the cache sizes. The shadow entries are no
different from that perspective. You can't let them overrun the
system, but you want to keep a respectable number of them around to
keep (some metric of) performance within respectable bounds.  IOWs,
that's the same constraints as most other caches (e.g. inode and
dentry caches) with a shrinker shrinker and so I don't see any
reason why it needs some magic threshold to avoid being shrunk
proportionally like all other caches...

Indeed, as memory pressure gets higher, the value of keeping lots of
shadow entries around goes down because if there is lots of
refaulting occurring then the number of shadow entries will be
shrinking as a natural side effect of replacing shadow entries with
real pages.

If the memory pressure is not causing refaults to occur, then the
shadow entries are using memory that could otherwise be put to
better use, and so we should reclaim them in proportion to the
memory pressure.

If you use lazy lists, in the first case the scanner will expend
most of it work removing radix tree nodes from the list because they
have pages in them again, and so the shrinker does cleanup work
rather than reclaim work. If the second case occurs, then the
shrinker does reclaim work to free the radix tree nodes so the
memory can be put to better use. No magic thresholds are needed at
all...

> > > It also means that locking only needs to be in the inode,
> > > and on the LRU list for shadow radix tree nodes.
> > > 
> > > Does that sound sane?
> > > 
> > > Am I overlooking something?
> > 
> > It's pretty much along the same lines of what I was thinking, but
> > lets see what Johannes thinks.
> 
> That sounds great to me.  I just have looked at this code for so long
> that I'm getting blind towards it, so I really appreciate your input.

I think we all suffer from that problem from time to time :/

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
