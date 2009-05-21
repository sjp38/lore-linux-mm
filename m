Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 601B86B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 18:46:30 -0400 (EDT)
Date: Thu, 21 May 2009 23:47:55 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090521234755.31ab1c3a@lxorguk.ukuu.org.uk>
In-Reply-To: <20090521214638.GL10756@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
	<1242852158.6582.231.camel@laptop>
	<4A15A69F.3040604@redhat.com>
	<20090521202628.39625a5d@lxorguk.ukuu.org.uk>
	<20090521195603.GK10756@oblivion.subreption.com>
	<20090521214713.65adfd6e@lxorguk.ukuu.org.uk>
	<20090521214638.GL10756@oblivion.subreption.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

> Let me know if you are keen on this approach and I'll follow with an
> updated patch.

Seems a good way to proceed. I think at the point you've got the SLAB/VMA
flags you'll find you don't need anything else. The VMA flag is valuable
on its own for the more relaxed security case of just wanting to crypt a
bit of swap to be safe (or to dump some stuff to a separate secure swap)
without doing all swap.

> I wasn't talking about disk based attacks. I'm talking about a rogue
> module or just some information leak which let's an user peek at known

If you've got a rogue module you already lost, except that by marking
what is sensitive you made the bad guys job easier. Bit like the way
people visually overlay maps and overhead shots from multiple sources and
the 'scrubbed' secret locations stand out for you and are easier to find
than if they were left.

If you are looking for a credit card number in 6GB of RAM you at least
have a chaffing style defence right now.

> Security conscious users normally disable suspend or hibernation
> altogether. It's far more difficult to get it right than it seems. You
> will *always* need some static place to store your key. Apple's XNU

On the systems I've used and use that key (or its passphrase) resides in
the user. That has its own compromise problems (if I can borrow your
laptop I can trojan the key input) but it does stop basic steal and
decrypt attacks.

> I haven't identified a single place that stored potentially sensitive
> information which can be reasonably protected with a simple approach
> like this, that doesn't use kmalloc or the low level page allocator
> directly.

Obvious candidates would be AGPGart, DRI buffers, DMA lowmem buffering,
pad buffers - I dont think they clear all cases and in some cases
(notably DRI) there is data that is potentially "secret" stored in the
video RAM.

You can also extract bits of data post clear out of fascinating corners
like the debug interfaces to FIFOs on I/O controllers. There are also a
large category of buffers that don't get freed/reallocated notably ring
buffers for networking, and tty ring buffers which are mostly not freed
for the lifetime of the device (ie forever). Cleaning all RAM as an
option on S2D and shutdown would be the only real way you'd fix that.

> 	1. The kernel has interfaces which deal with likely sensitive
> 	information (from tty input drivers, to crypto api and network
> 	stack implementations).

However you can't tell what is sensitive, you must assume anything is.
Even a graphic pixmap might be sensitive or an executable's presence
might reveal things.
 
> 	2. Memory allocated by these interfaces will suffer of data
> 	remanence problems, even post-release. This will scatter such
> 	information and make coldboot/Iceman attacks possible to recover
> 	cryptographic secrets (ex. scanning for AES key expansion blocks
> 	is trivial, and this has been demonstrated for RSA as well, see
> 	the Princeton paper about it).

I would argue the logical follow-on from the fact you don't know what is
secure, combined with the basic security concept that you start from the
secure position and relax rights is that the only safe way to do this is
to have an option which turns on scrubbing on free for *all* objects.
Ditto clearing all memory on S2D.
 
> 	3. LIFO allocators make re-allocation leaks possible. If an
> 	interface allocates a buffer, stores data in it and releases it

No argument.

> I agree the ideal, best approach would be to sanitize all pages. If you
> are interested on a patch doing just that (as long as a Kconfig option
> enables it), I can provide you with a clean one. The original code in
> PaX did just that.

Runtime would be even better (and I think you can argue boot one way or
the other). That way distributions can ship the feature for people
who want it but without the performance hit.

> is, no execmem/execstack/execheap checks). We should really make .rodata
> read-only by default, and disallow mprotect to produce RWX mappings by
> default. Otherwise our NX is flawed. These are matters for another
> patch, and a different discussion too.

Thats what SELinux is for and with SELinux you can default that way and
relax (as you have to because there are lots of things that produce RWX
mappings).

A similar problem is the lack of kernel side true read-only, which is a
weakness in the hypervisors. Physical hardware can't do irrevocable read
only but it is perfectly doable for a guest under a hypervisor, and the
hypervisor kernel can often be configured to have vastly less external
exposure. (Rik that's a hint to remind the KVM people ;))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
