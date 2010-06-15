Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B367B6B023F
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 10:44:32 -0400 (EDT)
Date: Tue, 15 Jun 2010 10:43:42 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615144342.GA3339@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615142219.GE28052@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 04:22:19PM +0200, Andrea Arcangeli wrote:
> If we were forbidden to call ->writepage just because of stack
> overflow yes as I don't think it's big deal with memory compaction and
> I see this as a too limiting design to allow ->writepage only in
> kernel thread. ->writepage is also called by the pagecache layer,
> msync etc.. not just by kswapd.

Other callers of ->writepage are fine because they come from a
controlled environment with relatively little stack usage.  The problem
with direct reclaim is that we splice multiple stack hogs ontop of each
other.

Direct reclaim can come from any point that does memory allocations,
including those that absolutely have to because their stack "quota"
is almost used up.  Let's look at a worst case scenario:

We're in a deep stack codepath, say

 (1) core_sys_select, which has to kmalloc the array if it doesn't
     fit on the huge stack variable.  All fine by now, it stays in it's
     stack quota.
 (2) That code now calls into the slab allocator, which doesn't find free
     space in the large slab, and then calls into kmem_getpages, adding
     more stack usage.
 (3) That calls into alloc_pages_exact_node which adds stack usage of
     the page allocator.
 (4) no free pages in the zone anymore, and direct reclaim is invoked,
     adding the stack usage of the reclaim code, which currently is
     quite heavy.
 (5) direct reclaim calls into foofs ->writepage.  foofs_writepage
     notices the page is delayed allocated and needs to conver it.
     It now has to start a transaction, then call the extent management
     code to convert the extent, which calls into the space managment
     code, which calls into the buffercache for the metadata buffers,
     which needs to submit a bio to read/write the metadata.
 (6) The metadata buffer goes through submit_bio and the block layer
     code.  Because we're doing a synchronous writeout it gets directly
     dispatched to the block layer.
 (7) for extra fun add a few remapping layers for raid or similar to
     add to the stack usage.
 (8) The lowlevel block driver is iscsi or something similar, so after
     going through the scsi layer adding more stack it now goes through
     the networking layer with tcp and ipv4 (if you're unlucky ipv6)
     code
 (9) we finally end up in the lowlevel networking driver (except that we
     would have long overflown the stack)

And for extrea fun:

(10) Just when we're way down that stack an IRQ comes in on the CPU that
     we're executing on.  Because we don't enable irqstacks for the only
     sensible stack configuration (yeah, still bitter about the patch
     for that getting ignored) it goes on the same stack above.


And note that the above does not only happen with ext4/btrfs/xfs that
have delayed allocations.  With every other filesystem it can also
happen, just a lot less likely - when writing to a file through shared
mmaps we still have to call the allocator from ->writepage in
ext2/ext3/reiserfs/etc.

And seriously, if the VM isn't stopped from calling ->writepage from
reclaim context we FS people will simply ignore any ->writepage from
reclaim context.  Been there, done that and never again.

Just wondering, what filesystems do your hugepage testing systems use?
If it's any of the ext4/btrfs/xfs above you're already seeing the
filesystem refuse ->writepage from both kswapd and direct reclaim,
so Mel's series will allow us to reclaim pages from more contexts
than before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
