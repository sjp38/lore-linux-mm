Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 141E6620089
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 12:22:34 -0400 (EDT)
Date: Tue, 15 Jun 2010 12:22:13 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615162213.GA2470@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
 <20100615150850.GF28052@random.random>
 <20100615153838.GO26788@csn.ul.ie>
 <20100615161419.GH28052@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615161419.GH28052@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 06:14:19PM +0200, Andrea Arcangeli wrote:
> On Tue, Jun 15, 2010 at 04:38:38PM +0100, Mel Gorman wrote:
> > That is pretty much what Dave is claiming here at
> > http://lkml.org/lkml/2010/4/13/121 where if mempool_alloc_slab() needed
> 
> This stack trace shows writepage called by shrink_page_list... that
> contradict Christoph's claim that xfs already won't writepage if
> invoked by direct reclaim.

We only recently did that - before that we tried to get the VM fixed
multiple times but finally had to bite the bullet and follow ext4 and
btrfs in that regard.

> Again not what looks like from the stack trace. Also grepping for
> PF_MEMALLOC in fs/xfs shows nothing. In fact it's ext4_write_inode
> that skips the write if PF_MEMALLOC is set, not writepage apparently
> (only did a quick grep so I might be wrong). I suspect
> ext4_write_inode is the case I just mentioned about slab shrink, not
> ->writepage ;).

ext4 in fact does not check PF_MEMALLOC but simply refuses to write
out anything in ->writepage in most cases.  There is a corner case
when the page doesn't have any buffers attached where it wouldn't
have write out data, without actually calling the allocator.  I
suspect this code actually is a leftover as we don't normally strip
buffers from a page that had them before.

> inodes are small, it's no big deal to keep an inode pinned and not
> slab-reclaimable because dirty, while skipping real writepage in
> memory pressure could really open a regression in oom false positives!
> One pagecache much bigger than one inode and there can be plenty more
> dirty pagecache than inodes.

At least for XFS ->write_inode is really simple these days.  If it's
a synchronous writeout, which won't happen from these path it logs the
inode, which is far less harmless than the whole allocator code, and
for write = 0 it only adds it to the delayed write queue, which doesn't
call into the I/O stack at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
