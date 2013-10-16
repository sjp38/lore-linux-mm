Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id A503B6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 22:26:37 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so138618pbc.37
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 19:26:37 -0700 (PDT)
Date: Wed, 16 Oct 2013 13:26:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
Message-ID: <20131016022606.GD4446@dastard>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
 <20131011003930.GC4446@dastard>
 <20131014214250.GG856@cmpxchg.org>
 <20131015014123.GQ4446@dastard>
 <20131015174128.GH856@cmpxchg.org>
 <20131015234147.GA4446@dastard>
 <525DF466.6030308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <525DF466.6030308@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 15, 2013 at 10:05:26PM -0400, Rik van Riel wrote:
> On 10/15/2013 07:41 PM, Dave Chinner wrote:
> > On Tue, Oct 15, 2013 at 01:41:28PM -0400, Johannes Weiner wrote:
> 
> >> I'm not forgetting about them, I just track them very coarsely by
> >> linking up address spaces and then lazily enforce their upper limit
> >> when memory is tight by using the shrinker callback.  The assumption
> >> was that actually scanning them is such a rare event that we trade the
> >> rare computational costs for smaller memory consumption most of the
> >> time.
> > 
> > Sure, I understand the tradeoff that you made. But there's nothing
> > worse than a system that slows down unpredictably because of some
> > magic threshold in some subsystem has been crossed and
> > computationally expensive operations kick in.
> 
> The shadow shrinker should remove the radix nodes with
> the oldest shadow entries first, so true LRU should actually
> work for the radix tree nodes.
> 
> Actually, since we only care about the age of the youngest
> shadow entry in each radix tree node, FIFO will be the same
> as LRU for that list.
> 
> That means the shrinker can always just take the radix tree
> nodes off the end.

Right, but it can't necessarily free the node as it may still have
pointers to pages in it. In that case, it would have to simply
rotate the page to the end of the LRU again.

Unless, of course, we kept track of the number of exceptional
entries in a node and didn't add it to the reclaim list until there
were no non-expceptional entries in the node....

> >> But it
> >> looks like tracking radix tree nodes with a list and backpointers to
> >> the mapping object for the lock etc. will be a major pain in the ass.
> > 
> > Perhaps so - it may not work out when we get down to the fine
> > details...
> 
> I suspect that a combination of lifetime rules (inode cannot
> disappear until all the radix tree nodes) and using RCU free
> for the radix tree nodes, and the inodes might do the trick.
> 
> That would mean that, while holding the rcu read lock, the
> back pointer from a radix tree node to the inode will always
> point to valid memory.

Yes, that is what I was thinking...

> That allows the shrinker to lock the inode, and verify that
> the inode is still valid, before it attempts to rcu free the
> radix tree node with shadow entries.

Lock the mapping, not the inode. The radix tree is protected by the
mapping_lock, not an inode lock. i.e. I'd hope that this can all b
contained within the struct address_space and not require any
knowledge of inodes or inode lifecycles at all.

> It also means that locking only needs to be in the inode,
> and on the LRU list for shadow radix tree nodes.
> 
> Does that sound sane?
> 
> Am I overlooking something?

It's pretty much along the same lines of what I was thinking, but
lets see what Johannes thinks.

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
