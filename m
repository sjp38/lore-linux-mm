Subject: Re: Extensions to mincore
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org> <20000321024731.C4271@pcep-jamie.cern.ch> <m1puso1ydn.fsf@flinx.hidden> <20000321113448.A6991@dukat.scot.redhat.com> <20000321161507.D5291@pcep-jamie.cern.ch> <20000321154117.A8113@dukat.scot.redhat.com> <20000321165532.A5461@pcep-jamie.cern.ch> <20000321160828.C8204@redhat.com> <20000321174856.B5455@pcep-jamie.cern.ch>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 22 Mar 2000 01:36:02 -0600
In-Reply-To: Jamie Lokier's message of "Tue, 21 Mar 2000 17:48:56 +0100"
Message-ID: <m14s9z1mot.fsf@flinx.hidden>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jamie Lokier <jamie.lokier@cern.ch> writes:

> Stephen C. Tweedie wrote:
> > > Didn't you read a few paragraphs down, where I explain how to implement
> > > this?  You've got struct page.  It is enough for private mappings, and
> > > we don't need this feature for shared mappings.
> > 
> > Umm, yes, but just saying "we'll solve synchronisation problems by 
> > stopping all the other threads" hardly seems like a "solution" to me:
> > more of a workaround of the problem!  mprotect() does work correctly
> > without stopping other threads.
> 
> It is a limitation on mincore (at present).
> 
> But I haven't though of a GC implementation that will work without
> synchronising the threads anyway.  So the limitation may not be a
> problem for GC, and only GC would use this feature.

Nope.  In dosemu we do the mprotect style of munging with mappings
as well.  This allows us to detect which parts of a virtual frame
buffer have been changed pretty cheaply.  I think it is actually
implemented with mmap & munamp though.  Same story....

Doing mprotect tricks in a GC algorithm is actually a pretty
stupid way to go.  Upon occasion it might be the only solution
where you can't get in and modify the code the GC algorithm
is cooperating with.  But it still won't work great.

And only the slower GC algorithms, that need backwards compatiblity
with languages like C.

Anyway as you have mentioned to make this work you have to add
additional state from what is already kept, and it isn't
clear exactly what would make efficient use of this state.

I won't argue that in the long run this a bad idea.  But in
the short run of the upcomming 2.4.  I see no clear win.

For a GC that works with a SMP threaded heap you should never 
need to do that crap anyway.  You have the cost of the write lock
per object or group of objects anyway.  And it shouldn't be hard
to instrument the lock aquiring paths to mark the object dirty as
well.

> User space SEGV processing is horrible, per-page mprotect()
> write-enabling is slow and a resource hog, and the mprotect works on
> vmas instead of pages unfortunately so you get zillions of vmas.
> zillions of vmas isn't good.  Try cat /proc/self/maps when you have
> 25000 entries :-)

That's atleast 97 meg of RAM being managed, and given that
we combing adjacent vmas with the same permissions probably a lot 
more.  While not unthinkable I suspect that is a pretty unlikely case.

> Oops, I also forgot to mention that each per-page mprotect to
> write-enable the page on SEGV causes horrendous SMP behaviour too.


> > > It would be enough the say "the mincore accessed/dirty bits are not
> > > guaranteed to be accurate if pages are accessed by concurrent threads
> > > during the mincore call".
> > 
> > Exactly why you need mprotect, which _does_ make the necessary 
> > guarantees.
> 
> It does so with utterly sucking performance too.  And not because of the
> synchronisation -- but because you need 2500 separate mprotect calls and
> to handle 2500 SEGV signals to detect that 10MB of pages have been
> dirtied between GC runs.
> 
> mincore() can gather that info in one relatively fast system call.

mincore has to use exactly the same implementation except it
might be able to get lucky, and not need to juggle vmas.

In which case it probably makes more sense to figure out how
to store the page writeable flag in the page table of a swapped
out page so mprotect does not need to break vmas....

All GC's that use mprotect & co will have sucky performance period.
They are definentily compromise solutions.

> It does have synchronisation issues -- on _some_ architectures.  But
> they can be either documented (where they may not be a problem for GC),
> or explicit synchronisation can be added for architectures that need it.
> 
> > Oh, and suggesting that we can obtain the dirty bit by assuming all
> > mappings are private doesn't work either.  Private mappings *need* a 
> > per-pte (NOT per-page, but per-pte) dirty bit to distinguish between 
> > pages shared with the underlying mapped object, and pages which have
> > been modified by the local process.
> 
> For private mappings, any page pointing to the underlying mapped object
> is by definition clean.  That's easy enough to check.
> 
> Any other page has either a struct page or a swap entry that's local to
> its pte.  So the mincore-dirty flag can be stored in the struct page or
> the swap entry.

Again if you must please look at optimising mprotect.  If we can find
3 bits in a pte of a swapped out page we don't need to split the
vma's.   Nor do we need to change existing applications.

Plus the shared case is handled as well.  At the cost of a slightly
higher miss penalty for a page.  That sound like a much more
reasonable thing to do then what you are proposing now.

Please feel free to tell me I'm an idiot but I think I just stumbled
upon a pretty decent idea.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
