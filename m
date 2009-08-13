Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 19E7D6B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 13:19:48 -0400 (EDT)
Date: Thu, 13 Aug 2009 18:19:32 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
In-Reply-To: <20090813151312.GA13559@linux.intel.com>
Message-ID: <Pine.LNX.4.64.0908131746350.8831@sister.anvils>
References: <200908122007.43522.ngupta@vflare.org>
 <Pine.LNX.4.64.0908122312380.25501@sister.anvils> <20090813151312.GA13559@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Aug 2009, Matthew Wilcox wrote:
> 
> So TRIM isn't free, and there's a better way for the drive to find
> out that the contents of a block no longer matter -- write some new
> data to it.  So if we just swapped a page in, and we're going to swap
> something else back out again soon, just write it to the same location
> instead of to a fresh location.  You've saved a command, and you've
> saved the drive some work, plus you've allowed other users to continue
> accessing the drive in the meantime.
> 
> I am planning a complete overhaul of the discard work.  Users can send
> down discard requests as frequently as they like.  The block layer will
> cache them, and invalidate them if writes come through.  Periodically,
> the block layer will send down a TRIM or an UNMAP (depending on the
> underlying device) and get rid of the blocks that have remained unwanted
> in the interim.

Very interesting report, thanks a lot for it.  Certainly your
good point about writes should dictate some change at the swap end.

I have assumed all along (even from just a block layer perspective)
that discard would entail more overhead than I really want, just to
say "forget about it": I never expected that discarding a page at a
time would be a sensible way to proceed.

So at present swap tends to be discarding a 1MB range at a time.
And even if we have to move the point of discard much closer to
freeing swap, it would still be trying for such amounts - when
a process is exiting, even given the accumulation you propose,
I would not want to be trying to allocate lots of bios to pass
the info down to you.

So it looks as if we'd be duplicating work.
And won't filesystems be discarding extents too?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
