Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f205.google.com (mail-gg0-f205.google.com [209.85.161.205])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5516B0174
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 13:27:59 -0400 (EDT)
Received: by mail-gg0-f205.google.com with SMTP id p1so37417ggn.8
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 10:27:58 -0700 (PDT)
Date: Wed, 16 Oct 2013 18:31:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
Message-ID: <20131016223104.GA738@cmpxchg.org>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
 <20131011003930.GC4446@dastard>
 <20131014214250.GG856@cmpxchg.org>
 <20131015014123.GQ4446@dastard>
 <20131015174128.GH856@cmpxchg.org>
 <20131015234147.GA4446@dastard>
 <525DF466.6030308@redhat.com>
 <20131016022606.GD4446@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131016022606.GD4446@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 16, 2013 at 01:26:06PM +1100, Dave Chinner wrote:
> On Tue, Oct 15, 2013 at 10:05:26PM -0400, Rik van Riel wrote:
> > On 10/15/2013 07:41 PM, Dave Chinner wrote:
> > > On Tue, Oct 15, 2013 at 01:41:28PM -0400, Johannes Weiner wrote:
> > 
> > >> I'm not forgetting about them, I just track them very coarsely by
> > >> linking up address spaces and then lazily enforce their upper limit
> > >> when memory is tight by using the shrinker callback.  The assumption
> > >> was that actually scanning them is such a rare event that we trade the
> > >> rare computational costs for smaller memory consumption most of the
> > >> time.
> > > 
> > > Sure, I understand the tradeoff that you made. But there's nothing
> > > worse than a system that slows down unpredictably because of some
> > > magic threshold in some subsystem has been crossed and
> > > computationally expensive operations kick in.
> > 
> > The shadow shrinker should remove the radix nodes with
> > the oldest shadow entries first, so true LRU should actually
> > work for the radix tree nodes.
> > 
> > Actually, since we only care about the age of the youngest
> > shadow entry in each radix tree node, FIFO will be the same
> > as LRU for that list.
> > 
> > That means the shrinker can always just take the radix tree
> > nodes off the end.
> 
> Right, but it can't necessarily free the node as it may still have
> pointers to pages in it. In that case, it would have to simply
> rotate the page to the end of the LRU again.
> 
> Unless, of course, we kept track of the number of exceptional
> entries in a node and didn't add it to the reclaim list until there
> were no non-expceptional entries in the node....

I think that's doable.  As long as there is an actual page in the
node, no memory is going to be freed anyway.  And we have a full int
per node with only 64 slots, we can easily split the counter.

> > >> But it
> > >> looks like tracking radix tree nodes with a list and backpointers to
> > >> the mapping object for the lock etc. will be a major pain in the ass.
> > > 
> > > Perhaps so - it may not work out when we get down to the fine
> > > details...
> > 
> > I suspect that a combination of lifetime rules (inode cannot
> > disappear until all the radix tree nodes) and using RCU free
> > for the radix tree nodes, and the inodes might do the trick.
> > 
> > That would mean that, while holding the rcu read lock, the
> > back pointer from a radix tree node to the inode will always
> > point to valid memory.
> 
> Yes, that is what I was thinking...
> 
> > That allows the shrinker to lock the inode, and verify that
> > the inode is still valid, before it attempts to rcu free the
> > radix tree node with shadow entries.
> 
> Lock the mapping, not the inode. The radix tree is protected by the
> mapping_lock, not an inode lock. i.e. I'd hope that this can all b
> contained within the struct address_space and not require any
> knowledge of inodes or inode lifecycles at all.

Agreed, we can point to struct address_space and invalidate it by
setting mapping->host to NULL or so during the RCU grace period.

Also, the parent pointer is in a union with the two-word rcu_head, so
we get the address space backpointer for free.

The struct list_head for the FIFO, as you said, we can get for free as
well (at least on slab).

The FIFO lists themselves can be trimmed by a shrinker, I think.  You
were concerned about wind-up but if the nodes are not in excess and
->count just returns 0 until we are actually prepared to shrink
objects, then there shouldn't be any windup, right?

I don't see a natural threshold for "excess" yet, though, because
there is no relationship between where radix_tree_node is allocated
and which zones the contained shadow entries point to, so it's hard to
estimate how worthwile any given radix_tree_node is to a node.  Maybe
tying it to an event might be better, like reclaim pressure, swapping
etc.

> > It also means that locking only needs to be in the inode,
> > and on the LRU list for shadow radix tree nodes.
> > 
> > Does that sound sane?
> > 
> > Am I overlooking something?
> 
> It's pretty much along the same lines of what I was thinking, but
> lets see what Johannes thinks.

That sounds great to me.  I just have looked at this code for so long
that I'm getting blind towards it, so I really appreciate your input.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
