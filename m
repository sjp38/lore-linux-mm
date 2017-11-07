Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F11A36B02CA
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 08:33:52 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l23so16823465pgc.10
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 05:33:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n4sor419216plp.29.2017.11.07.05.33.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 05:33:51 -0800 (PST)
Date: Wed, 8 Nov 2017 00:33:32 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <20171108002448.6799462e@roar.ozlabs.ibm.com>
In-Reply-To: <20171107122825.posamr2dmzlzvs2p@node.shutemov.name>
References: <20171105231850.5e313e46@roar.ozlabs.ibm.com>
	<871slcszfl.fsf@linux.vnet.ibm.com>
	<20171106174707.19f6c495@roar.ozlabs.ibm.com>
	<24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com>
	<20171106192524.12ea3187@roar.ozlabs.ibm.com>
	<d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
	<546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
	<20171107160705.059e0c2b@roar.ozlabs.ibm.com>
	<20171107111543.ep57evfxxbwwlhdh@node.shutemov.name>
	<20171107222228.0c8a50ff@roar.ozlabs.ibm.com>
	<20171107122825.posamr2dmzlzvs2p@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Florian Weimer <fweimer@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 7 Nov 2017 15:28:25 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Tue, Nov 07, 2017 at 10:56:36PM +1100, Nicholas Piggin wrote:
> > > No, it won't. You will hit stack first.  
> > 
> > I guess so. Florian's bug didn't crash there for some reason, okay
> > but I suppose my point about brk is not exactly where the standard
> > heap is, but the pattern of allocations. An allocator that uses
> > mmap for managing its address space might do the same thing, e.g.,
> > incrementally expand existing mmaps as necessary.  
> 
> With MAP_FIXED? I don't think so.

brk() based allocator effectively usees MAP_FIXED. If you know where
your addresses are, using MAP_FIXED can be used.

But okay let's ignore MAP_FIXED as a corner case. Then what happens
with !MAP_FIXED when an allocation ends exactly at 128TB and then next
one begins at 128TB? Won't that expand the address space? Should we
ignore that corner case too?

> 
> > > > Second, the kernel can never completely solve the problem this way.
> > > > How do we know a malloc library will not ask for > 128TB addresses
> > > > and pass them to an unknowing application?    
> > > 
> > > The idea is that an application can provide hint (mallopt() ?) to malloc
> > > implementation that it's ready to full address space. In this case, malloc
> > > can use mmap((void *) -1,...) for its allocations and get full address
> > > space this way.  
> > 
> > Point is, there's nothing stopping an allocator library or runtime
> > from asking for mmap anywhere and returning it to userspace.  
> 
> Right. Nobody would stop it from doing stupid things. There are many
> things that a library may do that application would not be happy about.

Indeed.

> 
> > Do > 128TB pointers matter so much that we should add this heuristic
> > to prevent breakage, but little enough that we can accept some rare
> > cases getting through? Genuine question.  
> 
> At the end of the day what matters is if heuristic helps prevent breakage
> of existing userspace and doesn't stay in the way of legitimate use of
> full address space.
> 
> So far, it looks okay to me.

Well that wasn't really the point of my question. Yes of course that
is important. But the question is how are these heuristics chosen and
evaluated? Why is this a good change to make?

We've decided there is some benefit from preventing 128TB pointers, but
also not enough that we have to completely prevent them accidentally
being returned. Yet it's important enough to make mmap behaviour diverge
in about 5 ways around 128TB depending on what combination of address
and length and MAP_FIXED you specify, and introducing this new way to
use the interface to get an expanded address space?

And we're doing this because we don't want to add a prctl or personality
or whatever for SAP HANA, because it was decided that would be too complex?

> 
> > > The idea was we shouldn't allow to slip above 47-bits by accidentally.
> > > 
> > > Correctly functioning program would never request addr+len above 47-bit
> > > with MAP_FIXED, unless it's ready to handle such addresses. Otherwise the
> > > request would simply fail on machine that doesn't support large VA.
> > > 
> > > In contrast, addr+len above 47-bit without MAP_FIXED will not fail on
> > > machine that doesn't support large VA, kernel will find another place
> > > under 47-bit. And I can imagine a reasonable application that does
> > > something like this.
> > > 
> > > So we cannot rely that application is ready to handle large
> > > addresses if we see addr+len without MAP_FIXED.  
> > 
> > By the same logic, a request for addr > 128TB without MAP_FIXED will
> > not fail, therefore we can't rely on that either.
> > 
> > Or an app that links to a library that attempts MAP_FIXED allocation
> > of addr + len above 128TB might use high bits of pointer returned by
> > that library because those are never satisfied today and the library
> > would fall back.  
> 
> If you want to point that it's ABI break, yes it is.
> 
> But we allow ABI break as long as nobody notices. I think it's reasonable
> to expect that nobody relies on such corner cases.

I accept the point, but I do worry mmap syscall is very fundamental,
and that it is used in a lot of ways that are difficult to foresee,
so there's a lot of room for unintended consequences. Plus the state
of the code (that's not to pick on x86, powerpc is worse) is worrying.

> 
> If we would find any piece of software affect by the change we would need
> to reconsider.
> 

Problem is that if there was an issue caused by this, it's unlikely
to be found until a long time later. By that time, hopefully there
aren't too many other apps that are now rely on the behaviour if it
has to be changed.

I just don't see why that's a risk worth taking at all. I can't see how
the cost benefit is there. I have to confess I could have been more
involved in discussion, but is any other interface honestly too complex
to add?

If it is decided to keep these kind of heuristics, can we get just a
small but reasonably precise description of each change to the
interface and ways for using the new functionality, such that would be
suitable for the man page? I couldn't fix powerpc because nothing
matches and even Aneesh and you differ on some details (MAP_FIXED
behaviour).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
