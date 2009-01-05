Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD576B00C4
	for <linux-mm@kvack.org>; Sun,  4 Jan 2009 23:14:44 -0500 (EST)
Date: Mon, 5 Jan 2009 05:14:40 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
Message-ID: <20090105041440.GB367@wotan.suse.de>
References: <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com> <1228138641.14439.18.camel@penberg-laptop> <4933EE8A.2010007@gmail.com> <20081201161404.GE10790@wotan.suse.de> <4934149A.4020604@gmail.com> <20081201172044.GB14074@infradead.org> <alpine.LFD.2.00.0812011241080.3197@localhost.localdomain> <20081201181047.GK10790@wotan.suse.de> <alpine.LFD.2.00.0812311649230.3854@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0812311649230.3854@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Len Brown <lenb@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Alexey Starikovskiy <aystarik@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 31, 2008 at 05:04:22PM -0500, Len Brown wrote:
> On Mon, 1 Dec 2008, Nick Piggin wrote:
> 
> > If there is good reason to keep them around, I'm fine with that.
> > I think Pekka's suggestion of not doing unions but have better
> > typing in the code and then allocate the smaller types from
> > kmalloc sounds like a good idea.
> 
> Yes, I'll take that up with Bob when he comes back from break.
> Maybe the ACPICA code can be improved here.
> 
> > If the individual kmem caches are here to stay, then the
> > kmem_cache_shrink call should go away. Either way we can delete
> > some code from slab.
> 
> I think they are here to stay.  We are running
> an interpreter in kernel-space with arbitrary input,
> so I think the ability to easily isolate run-time memory leaks
> on a non-debug system is important.

I don't really see the connection. Or why being an interpreter is so
special. Filesystems, network stack, etc run in kernel with arbitrary
input. If kmem caches are part of a security strategy, then it's
broken... You'd surely have to detect bad input before the interpreter
turns it into a memory leak (or recover afterward, in which case it
isn't a leak).


> You may hardly ever see the interpreter run on systems
> with few run-time ACPI features, but it runs quite routinely
> on many systems.
> 
> That said, we have not discovered a memory leak
> in a very long time...
> 
> 
> BTW.
> I question that SLUB combining caches is a good idea.
> It seems to fly in the face of how zone allocators
> avoid fragmentation -- assuming that "like size"
> equates to "like use".
> 
> But more important to me is that it reduces visibility.

Yeah, that's another issue.


> > The OS agnostic code that implements its own allocator is kind
> > of a hack -- I don't understand why you would turn on allocator
> > debugging and then circumvent it because you find it too slow.
> > But I will never maintain that so if it is compiled out for
> > Linux, then OK.
> 
> The ACPI interpreter also builds into a user-space simulator
> and a debugger.  It is extremely valuable for us to be able
> to run the same code in the kernel and also in a user-space
> test environment.  So there are a number of features in
> the interpreter that we shut off when we build into the
> Linux kernel.  Sometimes shutting them off is elegant,
> sometime it is clumzy.
> 
> "Slabs can take a non-trivial amount of memory.
>  On bigger machines it can be many megabytes."
> 
> I don't think this thread addressed this concern.
> Is it something we should follow-up on?

There are some fundamental issues like per-cpu/node queues and
external fragmentation in slab pages that means a kmem_cache is
never going to be free (unless it is combined with another one,
but at that point you lose this tracking info anyway). SLAB has
bigger problems with data structures growing N^2 with the size
of the machine, but it is still the best choice in some situations.

Rather than rely on an arbitrary implementation of slab allocator
and tracking details, I would like to see your wrapper layer used
to collect exactly the details that are required for your acpi
work. You would then have all this available whether you ran in
userspace or on other OSes. Then investigate whether there would be
any performance or memory consumption regression introduced if you
move to kmalloc.

It's not a huge issue I guess, although if you split up object
types finely, you don't want to end up with a huge number of
kmem caches that are not frequently used. Splitting up objects that
way, together with tracking infrastructure, should result in even
better visibility than you have today too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
