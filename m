Date: Thu, 13 Mar 2008 12:07:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: grow_dev_page's __GFP_MOVABLE
Message-ID: <20080313120755.GC12351@csn.ul.ie>
References: <Pine.LNX.4.64.0803112116380.18085@blonde.site> <20080312140831.GD6072@csn.ul.ie> <Pine.LNX.4.64.0803121740170.32508@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803121740170.32508@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (12/03/08 18:11), Hugh Dickins didst pronounce:
> On Wed, 12 Mar 2008, Mel Gorman wrote:
> > On (11/03/08 21:33), Hugh Dickins didst pronounce:
> > > 
> > > I'm (slightly) worried by your __GFP_MOVABLE in grow_dev_page:
> > > is it valid, given that we come here for filesystem metadata pages
> > > - don't we? 
> > 
> > This is a tricky one and the second time it's come up. The pages allocated
> > here end up on the page cache and had a similar life-cycle to other LRU-pages
> > in the majority of cases when I checked at the time. The allocations are
> > labeled MOVABLE, but in this case they can be cleaned and moved to disk
> > rather than movable by page migration.  Strictly, one would argue that
> > they could be marked RECLAIMABLE but it increases the number of pageblocks
> > used by RECLAIMABLE allocations quite considerably and they have a very
> > different lifecycle which in itself is bad (spreads difficult to reclaim
> > allocations wider than necessary).
> 
> I was finding this ever so hard to understand, but now think I was blocked
> by the misapprehension that a filesystem would hold all the metadata pages
> associated with an inode in core while that file was open.  That might be
> true of some primitive filesystems, but could hardly be true of a grownup
> filesystem. 

That is my current understanding.

> Though even so, I'd expect different kinds of metadata pages
> to have significantly different lifecycles, and quite dependent on the
> filesystem in question e.g. superblock pages are held in core? inodes?
> 

This is probably true. To be right, every caller that enters this path should
be updated separetly.

> But you found that the majority are not, their counts merely raised while
> being accessed by the filesystem, so made the decision to treat them all
> as MOVABLE because most can be reclaimed from the pagecache in the same
> way as pagecache pages, which needs significantly less effort than
> RECLAIMing from slab. 

Yes, this is correct. For some filesystems, the pages with buffers can
also be migrated (ext2, ext3, ext4, gfs2, ntfs, ocfs2, xfs) but it's not
universal.

> Too bad about the obstacle to defragmentation
> that the held ones would pose. 

Yeah and I suspect if this is going to hit as a bug report, it will be
related to memory hot-remove. At some point, I'll may have to bite
the bullet and set this place to GFP_NOFS, distinguish between the
different types of caller.

> Okay (if I'm getting it right): you
> have to choose one way or the other, you've chosen this way, fine.
> And my argument by analogy with __GFP_HIGHMEM was just bogus.
> 
> (I guess this is why you added GFP_HIGHUSER_PAGECACHE etc., which to
> my mind just obfuscate things further, and intend a patch to remove.)
> 

Ironically, that was originally introduced to make things easier to
read. 

> Though, what prevents them from being genuinely MOVABLE while they're
> not transiently in use by the filesystem? 

Some of them are. The address_space will have a migratepage() helper if
they are really movable.

>And why does block_dev.c
> set mapping gfp_mask to GFP_USER instead of (not yet defined)
> GFP_USER_MOVABLE (ah, GFP_USER_PAGECACHE is defined, but unused)? 
> 

When I last checked, the blockdev address_space did not implement migratepage()
so pages allocated on its behalf were not movable. I cannot recall if
they ended up on the LRU where they could be reclaimed as normal or not.

> > Similarly, leaving them GFP_NOFS would
> > scatter allocations like page table pages wider than expected.
> 
> Yes, I accept we should do better than GFP_NOFS there: but I'm
> now not seeing why it isn't just &~__GFP_FS, with block_dev.c
> supplying the MOVABLE.
> 

I don't have a quick answer. I've added to the to-do list to revisit
this and see can it be done better.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
