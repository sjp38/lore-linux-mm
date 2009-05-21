Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C7A296B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:45:43 -0400 (EDT)
Date: Thu, 21 May 2009 21:47:13 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090521214713.65adfd6e@lxorguk.ukuu.org.uk>
In-Reply-To: <20090521195603.GK10756@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
	<1242852158.6582.231.camel@laptop>
	<4A15A69F.3040604@redhat.com>
	<20090521202628.39625a5d@lxorguk.ukuu.org.uk>
	<20090521195603.GK10756@oblivion.subreption.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

> > You do at buffer free time.
> 
> Alan, I think you will agree with me that forcing people to know what
> they have to do exactly with their buffers when they will contain
> confidential/sensitive data is suboptimal. Like it's been said before,

In the kernel no and page flags are very precious, very few and if we run
out will cost us a vast amount of extra kernel memory. If page flags were
free the question would be trivial - but they are not. Thus it is worth
asking whether its actually harder to remember to zap the buffer or set
and clear the flag correctly.

> the clearing isn't the only issue here. We have pagination to disk,
> re-allocation leaks, etc.

There is no kernel paging (except virtualised but that is an entire other
can of worms we shouldn't open), you can handle reallocation concerns
without page flags by using a SLAB type for 'secure' allocations which
clears the entry on free.

> > Still doesn't need a page flag - that is a vma flag which is far cheaper.
> > Also means you can get rid of the stupid mlock() misuse by things like
> > GPG to work around OS weaknesses by crypting the page if it hits
> > disk/swap/whatever.
> 
> Do you suggest a vma flag should be created for this as well?

You don't need a page flag, just a per vma flag and something akin to
madvise() to set the flag on the VMA (and/or split the VMA for partial
maps as we do for anything else). VMA flags are cheap.

> The point is that the keys or sensitive marked pages should never, ever
> be swapped to disk, by any means. Right now the patch only affects
> kernel code, the task related flag and functionality patches haven't been
> submitted yet.

If you are paging them to a crypted filestore they should be safe on
disk. What is your problem with that ? If your suspend image is
compromised it doesn't really matter if you wiped the data as what you
resume may then wait for the new keys and compromise those. In fact
having a page flag makes it easier for the attack code to know what to
capture and send to the bad guys...

> Regarding retrieving the encryption keys, IVs, and so forth, why bother
> reading the data remaining on disk? You can just retrieve them off
> memory (ex. via rogue driver or some re-allocation bug scenario,
> information leak or similar issue) and that's it.

I was assuming you'd wipe such data from memory on a suspend to disk.
However on a suspend to disk its basically as cheap to wipe all of memory
and safer than wiping random bits and praying you know what the compiler
did and you know what some other bit of library did.

> After all, that was the beauty of Linux since the start. We don't need
> to follow a political or corporate agenda in these regards. Right?

Indeed - but a technically sound solution that doesn't waste a page flag
is still important. It's btw not as simple as a page flag anyway - the
kernel stores some stuff in places that do not have page flags, it also
has kmaps and other things that will give you suprises.

Perhaps you should post your threat model to go with the patches. At the
moment your model doesn't seem to make sense.

Surely we can attack the problem far more directly for all but S2R by

- choosing to use encrypted swap and encrypted S2D images (already
  possible)
- wiping the in memory image on S2D if the user chooses (which would be
  smart)

That has the advantage that nobody has to label pages sensitive - which
is flawed anyway, we want to label pages "non-sensitive" in the ideal
world so we default secure.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
