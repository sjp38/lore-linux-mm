Date: Tue, 26 Jun 2007 13:14:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC] fsblock
Message-ID: <20070626111414.GA9352@wotan.suse.de>
References: <20070624014528.GA17609@wotan.suse.de> <20070626030640.GM989688@sgi.com> <46808E1F.1000509@yahoo.com.au> <20070626092309.GF31489@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070626092309.GF31489@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 26, 2007 at 07:23:09PM +1000, David Chinner wrote:
> On Tue, Jun 26, 2007 at 01:55:11PM +1000, Nick Piggin wrote:
> > >
> > >Realistically, this is not about "filesystem blocks", this is
> > >about file offset to disk blocks. i.e. it's a mapping.
> > 
> > Yeah, fsblock ~= the layer between the fs and the block layers.
> 
> Sure, but it's not a "filesystem block" which is what you are
> calling it. IMO, it's overloading a well known term with something
> different, and that's just confusing.

Well it is the metadata used to manage the filesystem block for the
given bit of pagecache (even if the block is not actually allocated
or even a hole, it is deemed to be so by the filesystem).

> Can we call it a block mapping layer or something like that?
> e.g. struct blkmap?

I'm not fixed on fsblock, but blkmap doesn't grab me either. It
is a map from the pagecache to the block layer, but blkmap sounds
like it is a map from the block to somewhere.

fsblkmap ;)

 
> > >> Probably better would be to
> > >> move towards offset,length rather than page based fs APIs where 
> > >> everything
> > >> can be batched up nicely and this sort of non-trivial locking can be more
> > >> optimal.
> > >
> > >If we are going to turn over the API completely like this, can
> > >we seriously look at moving to this sort of interface at the same
> > >time?
> > 
> > Yeah we can move to anything. But note that fsblock is perfectly
> > happy with <= PAGE_CACHE_SIZE blocks today, and isn't _terrible_
> > at >.
> 
> Extent based block mapping is entirely independent of block size.
> Please don't confuse the two....

I'm not, but it seemed like you were confused that fsblock is tied
to changing the aops APIs. It is not, but they can be changed to
give improvements in a good number of areas (*including* better
large block support).


> > >With special "disk blocks" for indicating delayed allocation
> > >blocks (-1) and unwritten extents (-2). Worst case we end up
> > >with is an iomap per filesystem block.
> > 
> > I was thinking about doing an extent based scheme, but it has
> > some issues as well. Block based is light weight and simple, it
> > aligns nicely with the pagecache structures.
> 
> Yes. Block based is simple, but has flexibility and scalability
> problems.  e.g the number of fsblocks that are required to map large
> files.  It's not uncommon for use to have millions of bufferheads
> lying around after writing a single large file that only has a
> handful of extents. That's 5-6 orders of magnitude difference there
> in memory usage and as memory and disk sizes get larger, this will
> become more of a problem....

I guess fsblock is 3 times smaller and you would probably have 16
times fewer of them for such a filesystem (given a 4K page size)
still leaves a few orders of magnitude ;)

However, fsblock has this nice feature where it can drop the blocks
when the last reference goes away, so you really only have fsblocks
around for dirty or currently-being-read blocks...

But you give me a good idea: I'll gear the filesystem-side APIs to
be more extent based as well (eg. fsblock's get_block equivalent).
That way it should be much easier to change over to such extents in
future or even have an extent based representation sitting in front
of the fsblock one and acting as a high density cache in your above
situation.


> > >If we allow iomaps to be split and combined along with range
> > >locking, we can parallelise read and write access to each
> > >file on an iomap basis, etc. There's plenty of goodness that
> > >comes from indexing by range....
> > 
> > Some operations AFAIKS will always need to be per-page (eg. in
> > the core VM it wants to lock a single page to fault it in, or
> > wait for a single page to writeout etc). So I didn't see a huge
> > gain in a one-lock-per-extent type arrangement.
> 
> For VM operations, no, but they would continue to be locked on a
> per-page basis. However, we can do filesystem block operations
> without needing to hold page locks. e.g. space reservation and
> allocation......

You could do that without holding the page locks as well AFAIKS.
Actually again it might be a bit troublesome with the current
aops APIs, but I don't think fsblock stands in your way there
either.
 
> > If you're worried about parallelisability, then I don't see what
> > iomaps give you that buffer heads or fsblocks do not? In fact
> > they would be worse because there are fewer of them? :)
> 
> No, that's wrong. I'm not talking about VM parallelisation,
> I want to be able to support multiple writers to a single file.
> i.e. removing the i_mutex restriction on writes. To do that
> you've got to have a range locking scheme integrated into
> the block map for the file so that concurrent lookups and
> allocations don't trip over each other.
 
> iomaps can double as range locks simply because iomaps are
> expressions of ranges within the file.  Seeing as you can only
> access a given range exclusively to modify it, inserting an empty
> mapping into the tree as a range lock gives an effective method of
> allowing safe parallel reads, writes and allocation into the file.
> 
> The fsblocks and the vm page cache interface cannot be used to
> facilitate this because a radix tree is the wrong type of tree to
> store this information in. A sparse, range based tree (e.g. btree)
> is the right way to do this and it matches very well with
> a range based API.
> 
> None of what I'm talking about requires any changes to the existing
> page cache or VM address space. I'm proposing that we should be
> treat the block mapping as an address space in it's own right. i.e.
> perhaps the struct page should not have block mapping objects
> attached to it at all.
> 
> By separating out the block mapping from the page cache, we make the
> page cache completely independent of filesystem block size, and it
> can just operate wholly on pages. We can implement a generic extent
> mapping tree instead of every filesystem having to (re)implement
> their own. And if the filesystem does it's job of preventing
> fragmentation, the amount of memory consumed by the tree will
> be orders of magnitude lower than any fsblock based indexing.

The independent mapping tree is something I have been thinking
about, but you still need to tie the page to the block at some
point and you need to track IO details and such.

The problem with implementing it in generic code is that it
will add another layer of locking and data structure that may
be better done in the filesystem. (because you _do_ already
need to do all the per-page stuff as well). This was my thing
about overengineering: fsblock is supposed to be just a very
light layer.


> I also like what this implies for keeping track of sub-block dirty
> ranges. i.e. no need for RMW cycles for if we are doing sector sized
> and aligned I/O - we can keep track of sub-block dirty state in the
> block mapping tree easily *and* we know exactly what sector on disk
> it maps to. That means we don't care about filesystem block size
> as it no longer has any influence on RMW boundaries.
> 
> None of this is possible with fsblocks, so I really think that
> fsblocks are not the step forward we need. They are just bufferheads
> under another name and hence have all the same restrictions that
> bufferheads imply. We should be looking to eliminate bufferheads
> entirely rather than perpetuating them as fsblocks.....

I don't know why you think none of that is possible with fsblocks.
You could easily keep an in-memory btree or similar as the 
authoritative block management structure and feed the fsblock
layer from that.

There is nothing about fsblock that is tied to i_mutex, and all
it's locking basically comes for free on top of the page based
locking that's already required in the VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
