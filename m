Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f205.google.com (mail-ie0-f205.google.com [209.85.223.205])
	by kanga.kvack.org (Postfix) with ESMTP id C9B286B0035
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:02:22 -0400 (EDT)
Received: by mail-ie0-f205.google.com with SMTP id tp5so10265ieb.0
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:02:21 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:42:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
Message-ID: <20131014214250.GG856@cmpxchg.org>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
 <20131011003930.GC4446@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131011003930.GC4446@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Dave,

On Fri, Oct 11, 2013 at 11:39:30AM +1100, Dave Chinner wrote:
> On Thu, Oct 10, 2013 at 05:46:54PM -0400, Johannes Weiner wrote:
> > 	Costs
> > 
> > These patches increase struct inode by three words to manage shadow
> > entries in the page cache radix tree.
> 
> An additional 24 bytes on a 64 bit system. Filesystem developers
> will kill to save 4 bytes in the struct inode, so adding 24 bytes is
> a *major* concern.
> 
> > However, given that a typical
> > inode (like the ext4 inode) is already 1k in size, this is not much.
> > It's a 2% size increase for a reclaimable object. 
> 
> The struct ext4_inode is one of the larger inodes in the system at
> 960 bytes (same as the xfs_inode) - most of the filesystem inode
> structures are down around the 600-700 byte range.
> 
> Really, the struct inode is what you should be comparing the
> increase against (i.e. the VFS inode footprint), not the filesystem
> specific inode footprint. In that case, it's actually an increase of
> closer to a 4% increase in size because we are talking about a 560
> byte structure....
> 
> > fs_mark metadata
> > tests with millions of inodes did not show a measurable difference.
> > And as soon as there is any file data involved, the page cache pages
> > dominate the memory cost anyway.
> 
> We don't need to measure it at runtime to know the difference - a
> million inodes will consume an extra 24MB of RAM at minimum. If the
> size increase pushes the inode over a slab boundary, it might be
> significantly more than that...
> 
> The main cost here is a new list head for a new shrinker. There's
> interesting new inode lifecycle issues introduced by this shadow
> tree - adding serialisation in evict() because the VM can now modify
> to the address space without having a reference to the inode
> is kinda nasty.

This is unlikely to change, though.  Direct reclaim may hold all kinds
of fs locks so we can't reasonably do iput() from reclaim context.

We already serialize inode eviction and reclaim through the page lock
of cached pages.  I just added the equivalent for shadow entries,
which don't have their own per-item serialization.

> Also, I really don't like the idea of a new inode cache shrinker
> that is completely uncoordinated with the existing inode cache
> shrinkers. It uses a global lock and list and is not node aware so
> all it will do under many workloads is re-introduce a scalability
> choke point we just got rid of in 3.12.

Shadow entries are mostly self-regulating and, unlike the inode case,
the shrinker is not the primary means of resource control here.  I
don't think this has the same scalability requirements as inode
shrinking.

> I think that you could simply piggy-back on inode_lru_isolate() to
> remove shadow mappings in exactly the same manner it removes inode
> buffers and page cache pages on inodes that are about to be
> reclaimed.  Keeping the size of the inode cache down will have the
> side effect of keeping the shadow mappings under control, and so I
> don't see a need for a separate shrinker at all here.

Pinned inodes are not on the LRU, so you could send a machine OOM by
simply catting a single large (sparse) file to /dev/null.

Buffers and page cache are kept in check by page reclaim, the inode
shrinker only drops cache as part of inode lifetime management.  Just
like with buffers and page cache, there is no relationship between the
amount of memory occupied and the number of inodes; or between the
node of said memory and the node that holds the inode object.  The
inode shrinker does not really seem appropriate for managing excessive
shadow entry memory.

> And removing the special shrinker will bring the struct inode size
> increase back to only 8 bytes, and I think we can live with that
> increase given the workload improvements that the rest of the
> functionality brings.

That would be very desirable indeed.

What we would really want is a means of per-zone tracking of
radix_tree_nodes occupied by shadow entries but I can't see a way to
do this without blowing up the radix tree structure at a much bigger
cost than an extra list_head in struct address_space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
