Date: Wed, 11 Oct 2000 23:42:04 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] atomic pte updates for x86 smp
In-Reply-To: <Pine.LNX.3.96.1001011232450.23223A-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.10010112318110.2852-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: tytso@mit.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.elte.hu>
List-ID: <linux-mm.kvack.org>


On Thu, 12 Oct 2000, Benjamin C.R. LaHaise wrote:
> 
> Note the fragment above those portions of the patch where the
> pte_xchg_clear is done on the page table: this results in a page fault
> for any other cpu that looks at the pte while it is unavailable.

Ok, I see..

Hmm.. That's a singularly ugly interface, though - it all looks very
x86-specific. Things like "pte_xchg_clear()" look just a bit too obviously
like the name only makes sense due to the x86 implementation. So I'd like
to change the naming to be more about the design and less about the
implementation..

(It also doesn't make sense to me that you call the "clear the write bit"
thing "atomic_pte_wrprotect()", but you call the "clear the dirty bit"
"pte_test_and_clear_dirty()" - why not the same naming scheme for the two 
things?). 

I also have this suspicion that if this was done right, we should be able
to clean up the 64-bit atomic stuff for the x86 PAE case - which does a
cmpxchg8b right now on PAE entries exactly because of atomicity reasons.

With your patch as it stands now, we'd end up basically always doing two
of them.

And looking at the patch I get this nagging feeling that if this was
really done right, we could get rid of that PAE special case for
set_pte(), because the issue with atomic updates on PAE really boils down
to pretty much the same thing as the issue of one atomic bit.

(Instead of doing an atomic 64-bit memory write, we would be doing the
atomic "pte_xchg_clear()" followed by two _non_atomic 32-bit writes where
the second write would set the present bit. Although maybe the erratum
about the PAE pgd entry not honoring the P bit correctly makes this be
unworkable).

Ingo? I'd really like you to take a long look at this patch for sanity,
especially wrt PAE.

After this patch, are there any cases where we do a "set_pte()" where the
PTE wasn't clear before? That might be a good sanity-test to add, just to
make sure. And I'd really like to speed up the PAE set_pte() - as far as I
can tell both set_pte and set_pmd really should be safe without the atomic
64-bit crap with your changes.

Why do I care?

Basically, I'd be a lot happier about this patch if it also solves another
problem - if the "lost dirty bits" patch automagically also solves the
"64-bit atomic PTE" issue for the PAE case, then I will just feel a lot
happier about the fact that the solution is not just a specific hack for
handling "dirty", but a real change that makes conceptual sense for two
unrelated problems.

Because this, as always, is my final test for a "GoodDesign(tm)" patch: if
it solves just one problem it's a bug-fix, but if it solves two problems
it is the "RightThing(tm)" to do. And bug-fixes are a dime a dozen. Good
design is something to be admired.

What do you say, Ben? Do you think your approach really would solve the
PAE atomicity issue too, or am I just expecting too much?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
