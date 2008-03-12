Date: Wed, 12 Mar 2008 18:11:19 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: grow_dev_page's __GFP_MOVABLE
In-Reply-To: <20080312140831.GD6072@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0803121740170.32508@blonde.site>
References: <Pine.LNX.4.64.0803112116380.18085@blonde.site>
 <20080312140831.GD6072@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Mar 2008, Mel Gorman wrote:
> On (11/03/08 21:33), Hugh Dickins didst pronounce:
> > 
> > I'm (slightly) worried by your __GFP_MOVABLE in grow_dev_page:
> > is it valid, given that we come here for filesystem metadata pages
> > - don't we? 
> 
> This is a tricky one and the second time it's come up. The pages allocated
> here end up on the page cache and had a similar life-cycle to other LRU-pages
> in the majority of cases when I checked at the time. The allocations are
> labeled MOVABLE, but in this case they can be cleaned and moved to disk
> rather than movable by page migration.  Strictly, one would argue that
> they could be marked RECLAIMABLE but it increases the number of pageblocks
> used by RECLAIMABLE allocations quite considerably and they have a very
> different lifecycle which in itself is bad (spreads difficult to reclaim
> allocations wider than necessary).

I was finding this ever so hard to understand, but now think I was blocked
by the misapprehension that a filesystem would hold all the metadata pages
associated with an inode in core while that file was open.  That might be
true of some primitive filesystems, but could hardly be true of a grownup
filesystem.  Though even so, I'd expect different kinds of metadata pages
to have significantly different lifecycles, and quite dependent on the
filesystem in question e.g. superblock pages are held in core? inodes?

But you found that the majority are not, their counts merely raised while
being accessed by the filesystem, so made the decision to treat them all
as MOVABLE because most can be reclaimed from the pagecache in the same
way as pagecache pages, which needs significantly less effort than
RECLAIMing from slab.  Too bad about the obstacle to defragmentation
that the held ones would pose.  Okay (if I'm getting it right): you
have to choose one way or the other, you've chosen this way, fine.
And my argument by analogy with __GFP_HIGHMEM was just bogus.

(I guess this is why you added GFP_HIGHUSER_PAGECACHE etc., which to
my mind just obfuscate things further, and intend a patch to remove.)

Though, what prevents them from being genuinely MOVABLE while they're
not transiently in use by the filesystem?  And why does block_dev.c
set mapping gfp_mask to GFP_USER instead of (not yet defined)
GFP_USER_MOVABLE (ah, GFP_USER_PAGECACHE is defined, but unused)? 

> Similarly, leaving them GFP_NOFS would
> scatter allocations like page table pages wider than expected.

Yes, I accept we should do better than GFP_NOFS there: but I'm
now not seeing why it isn't just &~__GFP_FS, with block_dev.c
supplying the MOVABLE.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
