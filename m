Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 531C46B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 17:46:37 -0400 (EDT)
Date: Thu, 21 May 2009 14:46:38 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090521214638.GL10756@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <1242852158.6582.231.camel@laptop> <4A15A69F.3040604@redhat.com> <20090521202628.39625a5d@lxorguk.ukuu.org.uk> <20090521195603.GK10756@oblivion.subreption.com> <20090521214713.65adfd6e@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090521214713.65adfd6e@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On 21:47 Thu 21 May     , Alan Cox wrote:
> In the kernel no and page flags are very precious, very few and if we run
> out will cost us a vast amount of extra kernel memory. If page flags were
> free the question would be trivial - but they are not. Thus it is worth
> asking whether its actually harder to remember to zap the buffer or set
> and clear the flag correctly.
> 
> There is no kernel paging (except virtualised but that is an entire other
> can of worms we shouldn't open), you can handle reallocation concerns
> without page flags by using a SLAB type for 'secure' allocations which
> clears the entry on free.
> 
> You don't need a page flag, just a per vma flag and something akin to
> madvise() to set the flag on the VMA (and/or split the VMA for partial
> maps as we do for anything else). VMA flags are cheap.

The patch already implements a SLAB_CONFIDENTIAL flag now (I finished
renaming the flags) for this purpose. This is my proposal and summary of
the changes I'll do to the patch, based off your feedback:

	1. A page flag seems to be frowned upon by you. I can understand
	this and agree that we must keep in mind that these come in
	scarce quantities. A page flag is the only way to allow the low
	level page allocator to mark pages that contain sensitive
	information (so we support this through normal gfp flags in
	get_free)pages and so forth).

	2. We can independently make SLAB/SLUB aware of a CONFIDENTIAL
	flag that:

		a) Sanitizes objects at kfree() time when they've been
		allocated with the gfp flag or they belong to a cache
		marked with the SLAB_CONFIDENTIAL flag.

		b) Does not require changes to the low level page
		allocator.

		c) Still can prevent leaks in re-allocation scenarios
		and other cases.

	3. We can implement a vma flag for this purpose and should be no
	issue to you or other maintainers.

I'll split the SLAB/SLUB changes, which add support for the flag and the
gfp counterpart, and then have a separate one which adds the page flag.
Please read my comments on the latter at the end of this email. We can
ditch the page flag patch if we finally reject that approach and stick
to the other one. I'm fine with that.

Let me know if you are keen on this approach and I'll follow with an
updated patch.

> If you are paging them to a crypted filestore they should be safe on
> disk. What is your problem with that ? If your suspend image is
> compromised it doesn't really matter if you wiped the data as what you
> resume may then wait for the new keys and compromise those. In fact
> having a page flag makes it easier for the attack code to know what to
> capture and send to the bad guys...

I wasn't talking about disk based attacks. I'm talking about a rogue
module or just some information leak which let's an user peek at known
addresses. For instance, some operating systems implement disk
encryption with IVs and keys stored as global variables. Microsoft's
BitLocker operates that way internally if they haven't changed it. Apple
does the same for swap encryption, etc.

> I was assuming you'd wipe such data from memory on a suspend to disk.
> However on a suspend to disk its basically as cheap to wipe all of memory
> and safer than wiping random bits and praying you know what the compiler
> did and you know what some other bit of library did.

Security conscious users normally disable suspend or hibernation
altogether. It's far more difficult to get it right than it seems. You
will *always* need some static place to store your key. Apple's XNU
kernel stores the key in the image header for instance. I bet other
systems do the same.

> Indeed - but a technically sound solution that doesn't waste a page flag
> is still important. It's btw not as simple as a page flag anyway - the
> kernel stores some stuff in places that do not have page flags, it also
> has kmaps and other things that will give you suprises.

I haven't identified a single place that stored potentially sensitive
information which can be reasonably protected with a simple approach
like this, that doesn't use kmalloc or the low level page allocator
directly.

I bet there are some, but there are plenty of other, more obvious, ones
which need our attention.

> Perhaps you should post your threat model to go with the patches. At the
> moment your model doesn't seem to make sense.

The threat model is simple:

	1. The kernel has interfaces which deal with likely sensitive
	information (from tty input drivers, to crypto api and network
	stack implementations).

	2. Memory allocated by these interfaces will suffer of data
	remanence problems, even post-release. This will scatter such
	information and make coldboot/Iceman attacks possible to recover
	cryptographic secrets (ex. scanning for AES key expansion blocks
	is trivial, and this has been demonstrated for RSA as well, see
	the Princeton paper about it).

	3. LIFO allocators make re-allocation leaks possible. If an
	interface allocates a buffer, stores data in it and releases it
	without clearing, a successive allocation somewhere else can
	return this same object and let the caller access the original
	contents out of the context they were meant to. If a network
	stack implementation allocates a 64 byte buffer after some
	cryptoapi ctx initialization code got another 64 byte buffer and
	released it, you've got a problem there. If an attacker couples
	an uninitialized variable usage bug with this situation, you've
	got a possibly exploitable problem there. Worst of all, is that
	he might not need such a bug for abusing it ;)

Let me know if you need any further clarifications, please.

> Surely we can attack the problem far more directly for all but S2R by
> 
> - choosing to use encrypted swap and encrypted S2D images (already
>   possible)
> - wiping the in memory image on S2D if the user chooses (which would be
>   smart)
> 
> That has the advantage that nobody has to label pages sensitive - which
> is flawed anyway, we want to label pages "non-sensitive" in the ideal
> world so we default secure.

I agree the ideal, best approach would be to sanitize all pages. If you
are interested on a patch doing just that (as long as a Kconfig option
enables it), I can provide you with a clean one. The original code in
PaX did just that.

BTW, this can be extrapolated to .rodata and DEBUG_RODATA, as well as
the lack of mprotect restrictions for hosts with SELinux disabled (that
is, no execmem/execstack/execheap checks). We should really make .rodata
read-only by default, and disallow mprotect to produce RWX mappings by
default. Otherwise our NX is flawed. These are matters for another
patch, and a different discussion too.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
