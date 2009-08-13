Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D9F5C6B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 11:13:17 -0400 (EDT)
Date: Thu, 13 Aug 2009 08:13:12 -0700
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Discard support (was Re: [PATCH] swap: send callback when swap
	slot is freed)
Message-ID: <20090813151312.GA13559@linux.intel.com>
References: <200908122007.43522.ngupta@vflare.org> <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 12, 2009 at 11:48:27PM +0100, Hugh Dickins wrote:
> But fundamentally, though I can see how this cutdown communication
> path is useful to compcache, I'd much rather deal with it by the more
> general discard route if we can.  (I'm one of those still puzzled by
> the way swap is mixed up with block device in compcache: probably
> because I never found time to pay attention when you explained.)
> 
> You're right to question the utility of the current swap discard
> placement.  That code is almost a year old, written from a position
> of great ignorance, yet only now do we appear to be on the threshold
> of having an SSD which really supports TRIM (ah, the Linux ATA TRIM
> support seems to have gone missing now, but perhaps it's been
> waiting for a reality to check against too - Willy?).

I am indeed waiting for hardware with TRIM support to appear on my
desk before resubmitting the TRIM code.  It'd also be nice to be able to
get some performance numbers.

> I won't be surprised if we find that we need to move swap discard
> support much closer to swap_free (though I know from trying before
> that it's much messier there): in which case, even if we decided to
> keep your hotline to compcache (to avoid allocating bios etc.), it
> would be better placed alongside.

It turns out there are a lot of tradeoffs involved with discard, and
they're different between TRIM and UNMAP.

Let's start with UNMAP.  This SCSI command is used by giant arrays.
They want to do Thin Provisioning, so allocate physical storage to virtual
LUNs on demand, and want to deallocate it when they get an UNMAP command.
They allocate storage in large chunks (hundreds of kilobytes at a time).
They only care about discards that enable them to free an entire chunk.
The vast majority of users *do not care* about these arrays, because
they don't have one, and will never be able to afford one.  We should
ignore the desires of these vendors when designing our software.

Solid State Drives are introducing an ATA command called TRIM.  SSDs
generally have an intenal mapping layer, and due to their low, low seek
penalty, will happily remap blocks anywhere on the flash.  They want
to know when a block isn't in use any more, so they don't have to copy
it around when they want to erase the chunk of storage that it's on.
The unfortunate thing about the TRIM command is that it's not NCQ, so
all NCQ commands have to finish, then we can send the TRIM command and
wait for it to finish, then we can send NCQ commands again.

So TRIM isn't free, and there's a better way for the drive to find
out that the contents of a block no longer matter -- write some new
data to it.  So if we just swapped a page in, and we're going to swap
something else back out again soon, just write it to the same location
instead of to a fresh location.  You've saved a command, and you've
saved the drive some work, plus you've allowed other users to continue
accessing the drive in the meantime.

I am planning a complete overhaul of the discard work.  Users can send
down discard requests as frequently as they like.  The block layer will
cache them, and invalidate them if writes come through.  Periodically,
the block layer will send down a TRIM or an UNMAP (depending on the
underlying device) and get rid of the blocks that have remained unwanted
in the interim.

Thoughts on that are welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
