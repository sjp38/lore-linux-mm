Date: Mon, 20 Mar 2000 14:09:26 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: MADV_SPACEAVAIL and MADV_FREE in pre2-3
In-Reply-To: <20000320135939.A3390@pcep-jamie.cern.ch>
Message-ID: <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

jamie-

i've moved this discussion to linux-mm where we were just discussing the
madvise() implementation.

On Mon, 20 Mar 2000, Jamie Lokier wrote:
> Chuck Lever wrote:
> > > Besides, MADV_FREE would be quite useful.  MADV_DONTNEED doesn't do the
> > > right thing for free(3) and similar things.

ok, i don't understand why you think this.  and besides, free(3) doesn't
shrink the heap currently, i believe.  this would work if free(3) used
sbrk() to shrink the heap in an intelligent fashion, freeing kernel VM
resources along the way.  if you want something to help free(3), i would
favor this design instead.

> No idea.  Didn't you see my message about the collected meanings of
> different MADV_ flags on different systems?

yes, i saw it, but perhaps didn't understand it completely.

> In particular, using the name MADV_DONTNEED is a really bad idea.  It
> means completely different things on different OSes.  For example your
> meaning of MADV_DONTNEED is different to BSD's: a program that assumes
> the BSD behaviour may well crash with your implementation and will
> almost certainly give invalid results if it doesn't crash.

i'm more concerned about portability from operating systems like Solaris,
because there are many more server applications there than on *BSD that
have been designed to use these interfaces.  i'm not saying the *BSD way
is wrong, but i think it would be a more useful compromise to make *BSD
functionality available via some other interface (like MADV_ZERO).

> [Aside: is there the possibility to have mincore return the "!accessed"
> and "!dirty" bits of each page, perhaps as bits 1 and 2 of the returned
> bytes?  I can imagine a bunch of garbage collection algorithms that
> could make good use of those bits.  Currently some GC systems mprotect()
> regions and unprotect them on SEGV -- simply reading the !dirty status
> would obviously be much simpler and faster.]

you could add that; the question is how to do it while not breaking
applications that do this:

if (!byte) {
   page not present
}

rather than checking the LSB specifically.  i think using "dirty" instead
of "!dirty" would help.  the "accessed" bit is only used by the
shrink_mmap logic to "time out" a page as memory gets short; i'm not sure
that's a semantic that is useful to a user-level garbarge collector?  and
it probably isn't very portable.

[ jamie's earlier summary included below for context, with commentary ]

> 1. A hint to the VM system: I've finished using this data.  If it's
>    modified, you can write it back right away.  If not, you can discard
>    it.  FreeBSD's MADV_DONTNEED does this, but DU's doesn't.
> 
> FreeBSD:
> >  MADV_DONTNEED    Allows the VM system to decrease the in-memory priority
> >                   of pages in the specified range.  Additionally future
> >                   references to this address range will incur a page
> >                   fault.
> 
>    To avoid ambiguity, perhaps we could call this one MADV_DONE?
> 
>    In BSD compatibility mode, Glibc would define MADV_DONTNEED to be
>    MADV_DONE.  In standard mode it would not define MADV_DONTNEED at all.

my preference is for the DU semantic of tossing dirty data instead of
flushing onto backing store, simply because that's what so many
applications expect DONTNEED to do.

as far as i can tell, linux's msync(MS_INVALIDATE) behaves like freeBSD's
MADV_DONTNEED.

> 2. Zeroing a range in a private map.  DU's MADV_DONTNEED does this --
>    that's my reading of the man page.
> 
> Digital Unix: (?yes)
> >   MADV_DONTNEED   Do not need these pages
> >                   The system will free any whole pages in the specified
> >                   region.  All modifications will be lost and any swapped
> >                   out pages will be discarded.  Subsequent access to the
> >                   region will result in a zero-fill-on-demand fault as
> >                   though it is being accessed for the first time.
> >                   Reserved swap space is not affected by this call.
> 
>    For Linux, simply read /dev/zero into the selected range.  The kernel
>    already optimises this case for anonymous mappings.
> 
>    If doing it in general turns out to be too hard to implement, I
>    propose MADV_ZERO should have this effect: exactly like reading
>    /dev/zero into the range, but always efficient.

linux's MADV_DONTNEED currently doesn't clear the MADV_DONTNEED area.  but
it would be easy to add, perhaps as a separate MADV_ZERO as you describe
below.

> 3. Zeroing a range in a shared map.
> 
>    I have no idea if DU's MADV_DONTNEED has this effect, or whether it
>    only has this effect on shared anonymous mappings.
> 
>    In any case, reading /dev/zero into the range will always have the
>    desired effect, and Stephen's work will eventually make this
>    efficient on Linux.
> 
>    Again, if the kiobuf work doesn't have the desired effect, I propose
>    MADV_ZERO should be exactly like reading /dev/zero into the range,
>    and efficiently if the underlying mapped object can do so
>    efficiently.

MADV_ZERO makes sense to me as an efficient way to zero a range of
addresses in a mapping.  but i think it's useful as a *separate* function,
not as combined with, say, MADV_DONTNEED.

> 4. Deferred freeing of pages.  FreeBSD's MADV_FREE does this, according
>    to the posted manual snippet.  I like this very much -- it is perfect
>    for a wide variety of memory allocators.
> 
> FreeBSD:
> >  MADV_FREE        Gives the VM system the freedom to free pages, and tells
> >                   the system that information in the specified page range
> >                   is no longer important.  This is an efficient way of al-
> >                   lowing malloc(3) to free pages anywhere in the address
> >                   space, while keeping the address space valid.  The next
> >                   time that the page is referenced, the page might be de-
> >                   mand zeroed, or might contain the data that was there
> >                   before the MADV_FREE call.  References made to that ad-
> >                   dress space range will not make the VM system page the
> >                   information back in from backing store until the page is
> >                   modified again.
> 
>    I like this so much I started coding it a long time ago, as an
>    mdiscard syscall.  But then I got onto something else.
> 
>    The principle here is very simple: MADV_FREE marks all the pages in
>    the region as "discardable", and clears the accessed and dirty bits
>    of those pages.
> 
>    Later when the kernel needs to free some memory, it is permitted to
>    free "discardable" pages immediately provided they are still not
>    accessed or dirty.  When vmscan is clearing the accessed and dirty
>    bits on pages, if they were set it must clear the " discardable" bit.
> 
>    This allows malloc() and other user space allocators to free pages
>    back to the system.  Unlike DU's MADV_DONTNEED, or mmapping
>    /dev/zero, if the system does not need the page there is no
>    inefficient zero-copy.  If there was, malloc() would be better off
>    not bothering to return the pages.

unless i've completely misunderstood what you are proposing, this is what
MADV_DONTNEED does today, except it doesn't schedule the "freed" pages for
disposal ahead of other pages in the system.  but that should be easy
enough to add once the semantics are nailed down and the bugs have been
eliminated.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
