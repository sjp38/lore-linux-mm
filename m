Date: Tue, 26 Jun 2007 19:23:09 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC] fsblock
Message-ID: <20070626092309.GF31489@sgi.com>
References: <20070624014528.GA17609@wotan.suse.de> <20070626030640.GM989688@sgi.com> <46808E1F.1000509@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46808E1F.1000509@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: David Chinner <dgc@sgi.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 26, 2007 at 01:55:11PM +1000, Nick Piggin wrote:
> David Chinner wrote:
> >On Sun, Jun 24, 2007 at 03:45:28AM +0200, Nick Piggin wrote:
> >>I'm announcing "fsblock" now because it is quite intrusive and so I'd
> >>like to get some thoughts about significantly changing this core part
> >>of the kernel.
> >
> >Can you rename it to something other than shorthand for
> >"filesystem block"? e.g. When you say:
> >
> >>- In line with the above item, filesystem block allocation is performed
> >
> >What are we actually talking aout here? filesystem block allocation
> >is something a filesystem does to allocate blocks on disk, not
> >allocate a mapping structure in memory.
> >
> >Realistically, this is not about "filesystem blocks", this is
> >about file offset to disk blocks. i.e. it's a mapping.
> 
> Yeah, fsblock ~= the layer between the fs and the block layers.

Sure, but it's not a "filesystem block" which is what you are
calling it. IMO, it's overloading a well known term with something
different, and that's just confusing.

Can we call it a block mapping layer or something like that?
e.g. struct blkmap?

> >> Probably better would be to
> >> move towards offset,length rather than page based fs APIs where 
> >> everything
> >> can be batched up nicely and this sort of non-trivial locking can be more
> >> optimal.
> >
> >If we are going to turn over the API completely like this, can
> >we seriously look at moving to this sort of interface at the same
> >time?
> 
> Yeah we can move to anything. But note that fsblock is perfectly
> happy with <= PAGE_CACHE_SIZE blocks today, and isn't _terrible_
> at >.

Extent based block mapping is entirely independent of block size.
Please don't confuse the two....

> >With a offset/len interface, we can start to track contiguous
> >ranges of blocks rather than persisting with a structure per
> >filesystem block. If you want to save memory, thet's where
> >we need to go.
> >
> >XFS uses "iomaps" for this purpose - it's basically:
> >
> >	- start offset into file
> >	- start block on disk
> >	- length of mapping
> >	- state 
> >
> >With special "disk blocks" for indicating delayed allocation
> >blocks (-1) and unwritten extents (-2). Worst case we end up
> >with is an iomap per filesystem block.
> 
> I was thinking about doing an extent based scheme, but it has
> some issues as well. Block based is light weight and simple, it
> aligns nicely with the pagecache structures.

Yes. Block based is simple, but has flexibility and scalability
problems.  e.g the number of fsblocks that are required to map large
files.  It's not uncommon for use to have millions of bufferheads
lying around after writing a single large file that only has a
handful of extents. That's 5-6 orders of magnitude difference there
in memory usage and as memory and disk sizes get larger, this will
become more of a problem....

> >If we allow iomaps to be split and combined along with range
> >locking, we can parallelise read and write access to each
> >file on an iomap basis, etc. There's plenty of goodness that
> >comes from indexing by range....
> 
> Some operations AFAIKS will always need to be per-page (eg. in
> the core VM it wants to lock a single page to fault it in, or
> wait for a single page to writeout etc). So I didn't see a huge
> gain in a one-lock-per-extent type arrangement.

For VM operations, no, but they would continue to be locked on a
per-page basis. However, we can do filesystem block operations
without needing to hold page locks. e.g. space reservation and
allocation......

> If you're worried about parallelisability, then I don't see what
> iomaps give you that buffer heads or fsblocks do not? In fact
> they would be worse because there are fewer of them? :)

No, that's wrong. I'm not talking about VM parallelisation,
I want to be able to support multiple writers to a single file.
i.e. removing the i_mutex restriction on writes. To do that
you've got to have a range locking scheme integrated into
the block map for the file so that concurrent lookups and
allocations don't trip over each other.

iomaps can double as range locks simply because iomaps are
expressions of ranges within the file.  Seeing as you can only
access a given range exclusively to modify it, inserting an empty
mapping into the tree as a range lock gives an effective method of
allowing safe parallel reads, writes and allocation into the file.

The fsblocks and the vm page cache interface cannot be used to
facilitate this because a radix tree is the wrong type of tree to
store this information in. A sparse, range based tree (e.g. btree)
is the right way to do this and it matches very well with
a range based API.

None of what I'm talking about requires any changes to the existing
page cache or VM address space. I'm proposing that we should be
treat the block mapping as an address space in it's own right. i.e.
perhaps the struct page should not have block mapping objects
attached to it at all.

By separating out the block mapping from the page cache, we make the
page cache completely independent of filesystem block size, and it
can just operate wholly on pages. We can implement a generic extent
mapping tree instead of every filesystem having to (re)implement
their own. And if the filesystem does it's job of preventing
fragmentation, the amount of memory consumed by the tree will
be orders of magnitude lower than any fsblock based indexing.

I also like what this implies for keeping track of sub-block dirty
ranges. i.e. no need for RMW cycles for if we are doing sector sized
and aligned I/O - we can keep track of sub-block dirty state in the
block mapping tree easily *and* we know exactly what sector on disk
it maps to. That means we don't care about filesystem block size
as it no longer has any influence on RMW boundaries.

None of this is possible with fsblocks, so I really think that
fsblocks are not the step forward we need. They are just bufferheads
under another name and hence have all the same restrictions that
bufferheads imply. We should be looking to eliminate bufferheads
entirely rather than perpetuating them as fsblocks.....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
