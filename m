Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DDE476B004D
	for <linux-mm@kvack.org>; Fri, 22 May 2009 07:23:08 -0400 (EDT)
Date: Fri, 22 May 2009 04:22:36 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090522112236.GA13971@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <1242852158.6582.231.camel@laptop> <4A15A69F.3040604@redhat.com> <20090521202628.39625a5d@lxorguk.ukuu.org.uk> <20090521195603.GK10756@oblivion.subreption.com> <20090521214713.65adfd6e@lxorguk.ukuu.org.uk> <20090521214638.GL10756@oblivion.subreption.com> <20090521234755.31ab1c3a@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090521234755.31ab1c3a@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On 23:47 Thu 21 May     , Alan Cox wrote:
> Seems a good way to proceed. I think at the point you've got the SLAB/VMA
> flags you'll find you don't need anything else. The VMA flag is valuable
> on its own for the more relaxed security case of just wanting to crypt a
> bit of swap to be safe (or to dump some stuff to a separate secure swap)
> without doing all swap.
> 
> If you've got a rogue module you already lost, except that by marking
> what is sensitive you made the bad guys job easier.

Definitely, but there's no need for this at all. If you want to target
certain sensitive data, just grep the variable names in the
world-readable System.map of your distribution of choice.

> Obvious candidates would be AGPGart, DRI buffers, DMA lowmem buffering,
> pad buffers - I dont think they clear all cases and in some cases
> (notably DRI) there is data that is potentially "secret" stored in the
> video RAM.

Overkill. Again, you really don't need to scan memory for anything. Much
less video memory. If you already have CAP_SYS_RAWIO, you have more
reliable and easier techniques to intercept information.

> You can also extract bits of data post clear out of fascinating corners
> like the debug interfaces to FIFOs on I/O controllers. There are also a
> large category of buffers that don't get freed/reallocated notably ring
> buffers for networking, and tty ring buffers which are mostly not freed
> for the lifetime of the device (ie forever). Cleaning all RAM as an
> option on S2D and shutdown would be the only real way you'd fix that.

One of the patches takes care of tty buffer management to adopt the new
flag. The only real way to solve the lengthy list of security risks
coming along suspend-to-disk approaches is to simply disable
suspend-to-disk altogether.
 
> However you can't tell what is sensitive, you must assume anything is.
> Even a graphic pixmap might be sensitive or an executable's presence
> might reveal things.

So far we can start off by assuming the cryptoapi kmallocated buffers
are sensitive, especially those containing context information. The tty
buffer management ones too. And so are the AF_KEY ones. Etc.

Step by step, we'll get to full system memory labeling when there's an
actual hardware enforcement platform that allows us to implement this in
a manner which actually works, and isn't subject to being subverted as is
any other current security mechanism present in the Linux or other OS
kernels.

> I would argue the logical follow-on from the fact you don't know what is
> secure, combined with the basic security concept that you start from the
> secure position and relax rights is that the only safe way to do this is
> to have an option which turns on scrubbing on free for *all* objects.
> Ditto clearing all memory on S2D.

We're still talking about preventing kernel memory leaks right now, but
mostly everyone around assumed userland is being discussed. That will
come later, though.

> Runtime would be even better (and I think you can argue boot one way or
> the other). That way distributions can ship the feature for people
> who want it but without the performance hit.

Alright, if you want that (no config option, but boot cmdline option), I
can follow up with a tested patch today. If timing constraints allow it,
I might be able to provide the updated patchset for SLAB/vma flags too.

I'll follow-up to this thread with those.

> Thats what SELinux is for and with SELinux you can default that way and
> relax (as you have to because there are lots of things that produce RWX
> mappings).

I would have preferred to have a binary marking as well, but let's keep
this discussion for a future thread. You can fire me a private email as
well, or start a new thread.

> A similar problem is the lack of kernel side true read-only, which is a
> weakness in the hypervisors. Physical hardware can't do irrevocable read
> only but it is perfectly doable for a guest under a hypervisor, and the
> hypervisor kernel can often be configured to have vastly less external
> exposure. (Rik that's a hint to remind the KVM people ;))

PaX has KERNEXEC with its own methods to allow enforcement of read-only
and executable kernel pages, to a certain a degree. Perhaps a look at
its implementation could provide some ideas on these grounds.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
