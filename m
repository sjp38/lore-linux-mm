Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D40A38D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 14:03:46 -0500 (EST)
Date: Mon, 15 Nov 2010 14:03:35 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Oops while rebalancing, now unmountable.
Message-ID: <20101115190335.GA11374@infradead.org>
References: <1289236257.3611.3.camel@mars>
 <1289310046-sup-839@think>
 <1289326892.4231.2.camel@mars>
 <1289764507.4303.9.camel@mars>
 <20101114204206.GV6809@random.random>
 <20101114220018.GA4512@infradead.org>
 <20101114221222.GX6809@random.random>
 <20101115182314.GA2493@infradead.org>
 <1289845457-sup-9432@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289845457-sup-9432@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Shane Shrybman <shrybman@teksavvy.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 01:46:02PM -0500, Chris Mason wrote:
> For the metadata blocks, btrfs gets into a problematic lock inversion
> where it needs to record that a block has been written so that it will
> be properly recowed when someone tries to change it again.
> 
> Basically the rule for btree_writepage:
> 
> 1) lock the extent buffer (different from the page)
> 2) mark the metadata block as written
> 3) lock the page
> 4) call writepage
> 
> Btrfs does this correctly everywhere it uses writepage, and everyone
> else either uses writepages or is PF_MEMALLOC, except for the page
> migration code, which just jumps to step 4.
>
> So, my current fix adds a migrate page hook and adds a warning into the
> code to make sure we protest loudly when the block isn't marked as
> written.  Since this shakedown worked well, I'm changing the warning to
> a BUG().
> 

This sounds to me like you shouldn't bother to use ->writepage
for the case that adheres to your locking protocol, but just call into
extent_write_full_page directly.  ->writepage is supposed to directly
callable from the VM, and not require filesystems specific calling
conventions.  Just calling extent_write_full_page directly and
making btree_writepage do the PF_MEMALLOC unconditionally should
also fix the page migration corruption.  And at the same time
making btree_writepage future proof.

Btw, magic like the one there currently does need at least a long
describing comment.

> The check for kupdate in btree_writepages is different.  Once we write
> something, we have to do a good amount of work in order to modify it
> again.  The btrfs log commits make sure that we write metadata from time
> to time, so we don't really need help from the flusher threads unless.
>
> We also don't want to waste time writing metadata from
> balance_dirty_pages.  It'll just make more allocations later as we
> wander around and recow things, and it is much more likely to be seeky
> than the file IO.  So we setup a threshold where we don't bother doing
> metadata IO unless there is a good amount pending.
> 
> I'm fine with removing the metadata writepage entirely, it didn't use to
> have this many rules and it seems like a better idea to have it not
> there at all.

for_kupdate only covers a tiny subset of the flusher threads, as it's
only set for the older_than_this still writeback.  It doesn't cover
regular percentage background reclaim not other asynchronous activity
from the flusher threads, like wakeup_flusher_threads or the laptop-mode
I/O completion.

At the very least it should check for_kupdate || for_background to cover
all background writeback, which is what the few other uses of
for_kupdate already do, but I suspect you simply want to not mark
the btree inode as hashed in the inode hash and skip background
writeback completely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
