Date: Tue, 21 Mar 2000 17:48:56 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: Extensions to mincore
Message-ID: <20000321174856.B5455@pcep-jamie.cern.ch>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org> <20000321024731.C4271@pcep-jamie.cern.ch> <m1puso1ydn.fsf@flinx.hidden> <20000321113448.A6991@dukat.scot.redhat.com> <20000321161507.D5291@pcep-jamie.cern.ch> <20000321154117.A8113@dukat.scot.redhat.com> <20000321165532.A5461@pcep-jamie.cern.ch> <20000321160828.C8204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000321160828.C8204@redhat.com>; from Stephen C. Tweedie on Tue, Mar 21, 2000 at 04:08:28PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > Didn't you read a few paragraphs down, where I explain how to implement
> > this?  You've got struct page.  It is enough for private mappings, and
> > we don't need this feature for shared mappings.
> 
> Umm, yes, but just saying "we'll solve synchronisation problems by 
> stopping all the other threads" hardly seems like a "solution" to me:
> more of a workaround of the problem!  mprotect() does work correctly
> without stopping other threads.

It is a limitation on mincore (at present).

But I haven't though of a GC implementation that will work without
synchronising the threads anyway.  So the limitation may not be a
problem for GC, and only GC would use this feature.

That said, the synchronisation issue is really separate from the dirty
page issue.  They're orthogonal.  There's no reason why mincore should
not have an option to synchronise with other processors, in just the
same way that mprotect does.

User space SEGV processing is horrible, per-page mprotect()
write-enabling is slow and a resource hog, and the mprotect works on
vmas instead of pages unfortunately so you get zillions of vmas.
zillions of vmas isn't good.  Try cat /proc/self/maps when you have
25000 entries :-)

Oops, I also forgot to mention that each per-page mprotect to
write-enable the page on SEGV causes horrendous SMP behaviour too.

> > It would be enough the say "the mincore accessed/dirty bits are not
> > guaranteed to be accurate if pages are accessed by concurrent threads
> > during the mincore call".
> 
> Exactly why you need mprotect, which _does_ make the necessary 
> guarantees.

It does so with utterly sucking performance too.  And not because of the
synchronisation -- but because you need 2500 separate mprotect calls and
to handle 2500 SEGV signals to detect that 10MB of pages have been
dirtied between GC runs.

mincore() can gather that info in one relatively fast system call.

It does have synchronisation issues -- on _some_ architectures.  But
they can be either documented (where they may not be a problem for GC),
or explicit synchronisation can be added for architectures that need it.

> Oh, and suggesting that we can obtain the dirty bit by assuming all
> mappings are private doesn't work either.  Private mappings *need* a 
> per-pte (NOT per-page, but per-pte) dirty bit to distinguish between 
> pages shared with the underlying mapped object, and pages which have
> been modified by the local process.

For private mappings, any page pointing to the underlying mapped object
is by definition clean.  That's easy enough to check.

Any other page has either a struct page or a swap entry that's local to
its pte.  So the mincore-dirty flag can be stored in the struct page or
the swap entry.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
