Date: Tue, 30 Jan 2007 22:04:57 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: mremap correct rmap accounting
In-Reply-To: <45BF68A4.5070002@de.ibm.com>
Message-ID: <Pine.LNX.4.64.0701302157250.22828@blonde.wat.veritas.com>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
 <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org>
 <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701291219040.3611@woody.linux-foundation.org>
 <Pine.LNX.4.64.0701292029390.20859@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701292107510.26482@blonde.wat.veritas.com> <45BF68A4.5070002@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <carsteno@de.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jan 2007, Carsten Otte wrote:
> Hugh Dickins wrote:
> > Could make it loop over them all, but a quicker patch would be as
> > below.  I've no idea if the intersection of filemap_xip users and
> > MIPS users is the empty set or more interesting.  But I'd prefer
> > you don't just slam in the patch, better have an opinion from
> > Carsten and/or Nick first.
> Took me some time to catch up on this thread, sorry for that.

No problem.  And sorry for being so slow to reply to you,
there seems to have been an assault on my home connectivity.

I think it's now clear that XIP won't be impacted at all by my
ZERO_PAGE(0) change, and that's the patch Linus should put in
for 2.6.20 (given how much he disliked Nick's patch to maintain
the different zeropage counts across mremap move).  Ah, good,
that's now gone into his tree since last I looked.

> Yea, I think xip can be implemented correctly that it works on
> mips when we loop over all zero pages on unmap. Let me try to
> come up with a patch for that.

Sorry, no, I didn't mean for you to try that, and there appears
to be no need for it at all, for the foreseeable future anyway:
please don't waste your time on that.

But there is a change which I now think you do need to make,
for 2.6.21 - let it not distract attention from the pagecount
correctness issue we've been discussing so far.  Something I
should have noticed when I first looked at your clever use of
the ZERO_PAGE, but have only noticed now.  Doesn't it clash
with the clever use of the ZERO_PAGE when reading /dev/zero
(see read_zero_pagealigned in drivers/char/mem.c)?

Consider two PROT_READ|PROT_WRITE,MAP_PRIVATE mappings of a
four-page hole in a XIP file.  One of them just readfaults the
four pages in (and is given ZERO_PAGE for each), the other has
four pages read from /dev/zero into it (which also maps the
ZERO_PAGE into its four ptes).

Then imagine that non-zero data is written to the first page of
that hole, by a write syscall, or through a PROT_WRITE,MAP_SHARED
mapping.  __xip_unmap will replace the first ZERO_PAGE in each of
the MAP_PRIVATE mappings by the new non-zero data page.  Which is
correct for the first mapping which just did readfaults, but wrong
for the second mapping which has overwritten by reading /dev/zero
- those pages ought to remain zeroed, never seeing the later data.

I've never much liked the read_zero_pagealigned cleverness, seems
"too clever by half" as we say, and this overlooked clash shows why.
But I'm also scared to remove any long-established optimization(?),
for fear of impacting some unknown workload.

So, if you're to retain your share-one-page-for-holes cleverness,
I think you need to switch over to allocating a page of your own
for it, instead of using the ZERO_PAGE.

Or have I got it wrong?  A simple test should show.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
