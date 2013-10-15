Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f79.google.com (mail-oa0-f79.google.com [209.85.219.79])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1286B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 12:19:06 -0400 (EDT)
Received: by mail-oa0-f79.google.com with SMTP id i3so20624oag.2
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 09:19:06 -0700 (PDT)
Date: Tue, 15 Oct 2013 13:41:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
Message-ID: <20131015174128.GH856@cmpxchg.org>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
 <20131011003930.GC4446@dastard>
 <20131014214250.GG856@cmpxchg.org>
 <20131015014123.GQ4446@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131015014123.GQ4446@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 15, 2013 at 12:41:23PM +1100, Dave Chinner wrote:
> On Mon, Oct 14, 2013 at 05:42:50PM -0400, Johannes Weiner wrote:
> > Hi Dave,
> > 
> > On Fri, Oct 11, 2013 at 11:39:30AM +1100, Dave Chinner wrote:
> > > On Thu, Oct 10, 2013 at 05:46:54PM -0400, Johannes Weiner wrote:
> > > > 	Costs
> > > > 
> > > > These patches increase struct inode by three words to manage shadow
> > > > entries in the page cache radix tree.
> > > 
> > > An additional 24 bytes on a 64 bit system. Filesystem developers
> > > will kill to save 4 bytes in the struct inode, so adding 24 bytes is
> > > a *major* concern.
> > > 
> > > > However, given that a typical
> > > > inode (like the ext4 inode) is already 1k in size, this is not much.
> > > > It's a 2% size increase for a reclaimable object. 
> > > 
> > > The struct ext4_inode is one of the larger inodes in the system at
> > > 960 bytes (same as the xfs_inode) - most of the filesystem inode
> > > structures are down around the 600-700 byte range.
> > > 
> > > Really, the struct inode is what you should be comparing the
> > > increase against (i.e. the VFS inode footprint), not the filesystem
> > > specific inode footprint. In that case, it's actually an increase of
> > > closer to a 4% increase in size because we are talking about a 560
> > > byte structure....
> > > 
> > > > fs_mark metadata
> > > > tests with millions of inodes did not show a measurable difference.
> > > > And as soon as there is any file data involved, the page cache pages
> > > > dominate the memory cost anyway.
> > > 
> > > We don't need to measure it at runtime to know the difference - a
> > > million inodes will consume an extra 24MB of RAM at minimum. If the
> > > size increase pushes the inode over a slab boundary, it might be
> > > significantly more than that...
> > > 
> > > The main cost here is a new list head for a new shrinker. There's
> > > interesting new inode lifecycle issues introduced by this shadow
> > > tree - adding serialisation in evict() because the VM can now modify
> > > to the address space without having a reference to the inode
> > > is kinda nasty.
> > 
> > This is unlikely to change, though.  Direct reclaim may hold all kinds
> > of fs locks so we can't reasonably do iput() from reclaim context.
> 
> Right, but you do exactly that from the new shrinker because it
> doesn't have protection against being called in GFP_NOFS
> contexts....

Oops, yes, that's a bug, but easy to fix.

> > We already serialize inode eviction and reclaim through the page lock
> > of cached pages.
> 
> Sure, we do that via truncate_inode_pages() but that is not playing
> games with the inode life cycle - we know the inode is already dead
> and all users of the pages are gone at the point we remove the pages
> from the page cache.
> 
> That's kind of my point: the VM already has an address space
> serialisation point in the evict() path via truncate_inode_pages() and
> so I don't see any reason for you needing to introduce a new one
> that disables/enables interrupts in the hot path regardless of
> whether the flag needs to be set or not. Why can't you put this in
> truncate_inode_pages() or some new wrapper and keep the
> synchronisation wholly within the VM subsystem like we do now?

Fair enough, that should be easily fixable as well.

> > > Also, I really don't like the idea of a new inode cache shrinker
> > > that is completely uncoordinated with the existing inode cache
> > > shrinkers. It uses a global lock and list and is not node aware so
> > > all it will do under many workloads is re-introduce a scalability
> > > choke point we just got rid of in 3.12.
> > 
> > Shadow entries are mostly self-regulating and, unlike the inode case,
> > the shrinker is not the primary means of resource control here.  I
> > don't think this has the same scalability requirements as inode
> > shrinking.
> 
> Anything that introduces a global lock that needs to be taken in the
> inode evict() path is a scalability limitation. I've been working to
> remove all global locks and lists from the evict() path precisely
> because they severely limit VFS scalability. Hence new code that
> that introduces a global lock and list into hot VFS paths is simply
> not acceptible any more.

Fair enough as well.  But do keep in mind that the lock and list is
only involved when the address space actually had pages evicted from
it in the past.  As you said, most inodes don't even have pages...

> > > I think that you could simply piggy-back on inode_lru_isolate() to
> > > remove shadow mappings in exactly the same manner it removes inode
> > > buffers and page cache pages on inodes that are about to be
> > > reclaimed.  Keeping the size of the inode cache down will have the
> > > side effect of keeping the shadow mappings under control, and so I
> > > don't see a need for a separate shrinker at all here.
> > 
> > Pinned inodes are not on the LRU, so you could send a machine OOM by
> > simply catting a single large (sparse) file to /dev/null.
> 
> Then you have a serious design flaw if you are relying on a shrinker
> to control memory consumed by page cache radix trees as a result of
> page cache reclaim inserting exceptional entries into the radix
> tree and then forgetting about them.

I'm not forgetting about them, I just track them very coarsely by
linking up address spaces and then lazily enforce their upper limit
when memory is tight by using the shrinker callback.  The assumption
was that actually scanning them is such a rare event that we trade the
rare computational costs for smaller memory consumption most of the
time.

> To work around this, you keep a global count of exceptional entries
> and a global list of inodes with such exceptional radix tree
> entries. The count doesn't really tell you how much memory is used
> by the radix trees - the same count can mean an order of
> magnitude difference in actual memory consumption (one shadow entry
> per radix tree node vs 64) so it's not a very good measure to base
> memory reclaim behaviour on but it is an inferred (rather than
> actual) object count.

Capping shadow entries instead of memory consumption was intentional.
They should be trimmed based on whether old shadow entries are still
meaningful and have an effect if refaulted, not based on memory
pressure.  These entries have an influence on future memory pressure
so we shouldn't kick them out based on how tight resources are but
based on whether there are too many expired entries.

Previous implementations of non-resident history from Peter & Rik
maintained a big system-wide hash table with a constant cost instead
of using radix tree memory like this.  My idea was that this is cache
friendlier and memory consumption should be lower in most cases and
the shrinker is only there to cap the extreme / malicious cases.

> You walk the inode list by a shrinker and scan radix trees for
> shadow entries that can be removed. It's expensive to scan radix
> trees, especially for inodes with large amounts of cached data, so
> this could do a lot of work to find very little in way of entries to
> free.
> 
> The shrinker doesn't rotate inodes on the list, so it will always
> scan the same inodes on the list in the same order and so if memory
> reclaim removes a few pages from an inode with a large amount of
> cached pages between each shrinker call, then those radix trees will
> be repeatedly scanned in it's entirety on each call to the shrinker.
>
> Also, the shrinker only decrements nr_to_scan when it finds an entry
> to reclaim. nr_to_scan is the number of objects to scan for reclaim,
> not the number of objects to reclaim. hence the shrinker will be
> doing a lot of scanning if there's inodes at the head of the list
> with large radix trees....

I realize all of this.  The scanner is absolutely expensive, I just
didn't care because it's not supposed to run in the first place but
rather act like an emergency brake.

Again, the shrinker isn't even called until shadow entries are in
excess, regardless of how bad memory pressure is.  On the other hand,
the fact that this code is unneeded most of the time makes the struct
inode size increase even worse.

Don't get me wrong, I am very much for improving this, but I think
it's important that we agree on how performance critical that whole
thing is.

> Do I need to go on pointing out how unscalable this approach is?

No, I think I got your point ;-)

> > Buffers and page cache are kept in check by page reclaim, the inode
> > shrinker only drops cache as part of inode lifetime management.  Just
> > like with buffers and page cache, there is no relationship between the
> > amount of memory occupied and the number of inodes; or between the
> > node of said memory and the node that holds the inode object.
> 
> Yes, but buffers and page cache pages are kept in check directly the
> VM, not another shrinker. That's the big difference here - you're
> introducing something that is the equivalent of pages or buffers
> (i.e. allocated and controlled by the VM) and then saying that it
> can't be controlled by the VM and we need to link inodes together so
> a shrinker can do a new type of per-inode scan to find the VM
> controlled objects.
>
> Besides, doesn't the fact that you're requiring VFS cache lifecycle
> awareness in the core VM functionality ring alarm bells about
> layering violations in your head? They are loud enough to hurt my
> head...

Page reclaim is one big-ass layering violation.  The whole source of
this is that we work on objects tied to inode lifetime without keeping
a reference to the inode.  The VM already assumes that the inode will
stay alive as long as it holds a locked, untruncated page.  As I said,
I don't think I added a new class of cross-subsystem synchronization.

> > The
> > inode shrinker does not really seem appropriate for managing excessive
> > shadow entry memory.
> 
> It may not be - it was simply a suggestion on how we might be able
> get rid of the nasty shrinker code in your patchset....
> 
> > > And removing the special shrinker will bring the struct inode size
> > > increase back to only 8 bytes, and I think we can live with that
> > > increase given the workload improvements that the rest of the
> > > functionality brings.
> > 
> > That would be very desirable indeed.
> > 
> > What we would really want is a means of per-zone tracking of
> > radix_tree_nodes occupied by shadow entries but I can't see a way to
> > do this without blowing up the radix tree structure at a much bigger
> > cost than an extra list_head in struct address_space.
> 
> Putting a list_head in the radix tree node is likely to have a lower
> cost than putting one in every inode. Most cached inodes don't have
> any page cache associated with them. Indeed, my workstation right
> now shows:
> 
> $ sudo grep "radix\|xfs_inode" /proc/slabinfo 
> xfs_inode         277773 278432   1024    4    1 : tunables   54   27    8 : slabdata  69608  69608      0
> radix_tree_node    74137  74956    560    7    1 : tunables   54   27    8 : slabdata  10708  10708      0

Is that a slab configuration?  On my slub config, this actually shows
568 even though the structure definition really adds up to 560 bytes.

> 4x as many inodes as there are radix tree nodes in memory(*).
> That's with 55% of memory being used by the page cache. So it's
> pretty clear that tracking radix tree nodes directly might well be
> lower cost than tracking address spaces and/or inodes....
> 
> (*) Note that the inode size is 1024 bytes in the config I'm using, so
> increasing it is going to push it to only 3 inodes per page rather
> than 4, so that extra 16 listhead means a 25% increase in memory
> consumption for the inode cache, not 2%. The radix tree node can be
> increased by 24 bytes and still fit 7 per page and so not actually
> increase memory consumption at all....

Yes, I really don't like the extra inode cost and the computational
overhead in corner cases.

What I do like is that the shadow entries are in-line and not in an
auxiliary array and that memory consumption of shadow entries is
mostly low, so I'm not eager to change the data structure.  But it
looks like tracking radix tree nodes with a list and backpointers to
the mapping object for the lock etc. will be a major pain in the ass.

I'll see what I can come up with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
