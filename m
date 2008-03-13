Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2DF3Iom031145
	for <linux-mm@kvack.org>; Thu, 13 Mar 2008 11:03:18 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DF33xw162770
	for <linux-mm@kvack.org>; Thu, 13 Mar 2008 09:03:08 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DF32VX018828
	for <linux-mm@kvack.org>; Thu, 13 Mar 2008 09:03:03 -0600
Subject: Re: grow_dev_page's __GFP_MOVABLE
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20080313120755.GC12351@csn.ul.ie>
References: <Pine.LNX.4.64.0803112116380.18085@blonde.site>
	 <20080312140831.GD6072@csn.ul.ie>
	 <Pine.LNX.4.64.0803121740170.32508@blonde.site>
	 <20080313120755.GC12351@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 13 Mar 2008 07:05:58 -0800
Message-Id: <1205420758.19403.6.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-03-13 at 12:07 +0000, Mel Gorman wrote:
> On (12/03/08 18:11), Hugh Dickins didst pronounce:
> > On Wed, 12 Mar 2008, Mel Gorman wrote:
> > > On (11/03/08 21:33), Hugh Dickins didst pronounce:
> > > > 
> > > > I'm (slightly) worried by your __GFP_MOVABLE in grow_dev_page:
> > > > is it valid, given that we come here for filesystem metadata pages
> > > > - don't we? 
> > > 
> > > This is a tricky one and the second time it's come up. The pages allocated
> > > here end up on the page cache and had a similar life-cycle to other LRU-pages
> > > in the majority of cases when I checked at the time. The allocations are
> > > labeled MOVABLE, but in this case they can be cleaned and moved to disk
> > > rather than movable by page migration.  Strictly, one would argue that
> > > they could be marked RECLAIMABLE but it increases the number of pageblocks
> > > used by RECLAIMABLE allocations quite considerably and they have a very
> > > different lifecycle which in itself is bad (spreads difficult to reclaim
> > > allocations wider than necessary).
> > 
> > I was finding this ever so hard to understand, but now think I was blocked
> > by the misapprehension that a filesystem would hold all the metadata pages
> > associated with an inode in core while that file was open.  That might be
> > true of some primitive filesystems, but could hardly be true of a grownup
> > filesystem. 
> 
> That is my current understanding.
> 
> > Though even so, I'd expect different kinds of metadata pages
> > to have significantly different lifecycles, and quite dependent on the
> > filesystem in question e.g. superblock pages are held in core? inodes?
> > 
> 
> This is probably true. To be right, every caller that enters this path should
> be updated separetly.
> 
> > But you found that the majority are not, their counts merely raised while
> > being accessed by the filesystem, so made the decision to treat them all
> > as MOVABLE because most can be reclaimed from the pagecache in the same
> > way as pagecache pages, which needs significantly less effort than
> > RECLAIMing from slab. 
> 
> Yes, this is correct. For some filesystems, the pages with buffers can
> also be migrated (ext2, ext3, ext4, gfs2, ntfs, ocfs2, xfs) but it's not
> universal.
> 
> > Too bad about the obstacle to defragmentation
> > that the held ones would pose. 
> 
> Yeah and I suspect if this is going to hit as a bug report, it will be
> related to memory hot-remove. At some point, I'll may have to bite
> the bullet and set this place to GFP_NOFS, distinguish between the
> different types of caller.
> 
> > Okay (if I'm getting it right): you
> > have to choose one way or the other, you've chosen this way, fine.
> > And my argument by analogy with __GFP_HIGHMEM was just bogus.
> > 
> > (I guess this is why you added GFP_HIGHUSER_PAGECACHE etc., which to
> > my mind just obfuscate things further, and intend a patch to remove.)
> > 
> 
> Ironically, that was originally introduced to make things easier to
> read. 
> 
> > Though, what prevents them from being genuinely MOVABLE while they're
> > not transiently in use by the filesystem? 
> 
> Some of them are. The address_space will have a migratepage() helper if
> they are really movable.
> 
> >And why does block_dev.c
> > set mapping gfp_mask to GFP_USER instead of (not yet defined)
> > GFP_USER_MOVABLE (ah, GFP_USER_PAGECACHE is defined, but unused)? 
> > 
> 
> When I last checked, the blockdev address_space did not implement migratepage()
> so pages allocated on its behalf were not movable. I cannot recall if
> they ended up on the LRU where they could be reclaimed as normal or not.
> 
> > > Similarly, leaving them GFP_NOFS would
> > > scatter allocations like page table pages wider than expected.
> > 
> > Yes, I accept we should do better than GFP_NOFS there: but I'm
> > now not seeing why it isn't just &~__GFP_FS, with block_dev.c
> > supplying the MOVABLE.
> > 
> 
> I don't have a quick answer. I've added to the to-do list to revisit
> this and see can it be done better.

Mel,

All I can say is, marking grow_dev_page() __GFP_MOVABLE is causing
nothing but trouble in my hotplug memory remove testing :(

I constantly see that even though memblock is marked "removable", I
can't move the allocations. Most of the times these allocations came
from grow_dev_pages or its friends :(

Either these pages are not movable/migratable or code is not working
or filesystem/block device is holding them up :(


memory offlining 0x8000 to 0x9000 failed

page_owner shows:

Page allocated via order 0, mask 0x120050
PFN 30625 Block 7 type 2          Flags      L
[0xc0000000000c511c] .alloc_pages_current+208
[0xc0000000001049d8] .__find_get_block_slow+88
[0xc0000000004f0bbc] .__wait_on_bit+232
[0xc0000000000994ec] .__page_cache_alloc+24
[0xc000000000104fd8] .__find_get_block+272
[0xc00000000009a124] .find_or_create_page+76
[0xc0000000001063fc] .unlock_buffer+48
[0xc000000000105280] .__getblk+312


Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
