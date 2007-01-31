Date: Wed, 31 Jan 2007 16:31:31 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: mremap correct rmap accounting
In-Reply-To: <45C0A0B0.4030100@de.ibm.com>
Message-ID: <Pine.LNX.4.64.0701311600300.28314@blonde.wat.veritas.com>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
 <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org>
 <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701291219040.3611@woody.linux-foundation.org>
 <Pine.LNX.4.64.0701292029390.20859@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701292107510.26482@blonde.wat.veritas.com> <45BF68A4.5070002@de.ibm.com>
 <Pine.LNX.4.64.0701302157250.22828@blonde.wat.veritas.com> <45C0A0B0.4030100@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <carsteno@de.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jan 2007, Carsten Otte wrote:
> Nasty. I got your point now, but as far as I can see we're still in-spec:
> 
> MAP_PRIVATE
> Create a private copy-on-write mapping.  Stores to the region do not
> affect the original file.  It is unspecified whether changes made to
> the file after the mmap call are visible in the mapped region.

I agree that last sentence _appears_ to give you a let out.  I believe
its intention is to address the case where one page has been faulted
in and written to by the app, the next page is unfaulted then modified
by some other means and then faulted into the app for the first time:
that page will contain the mods made to the underlying object, even
though they were made after the private copy of the previous page was
taken (which copy should never show later mods to the underlying object).
Whereas if the mapping were mmap'ed with MAP_LOCKED (or mlocked), all
pages would be faulted in immediately, and subsequent mods to the
underlying object never seen at all.

Whatever the wording, I don't know of any application which is happy
for the modifications it makes to a MAP_PRIVATE mapping to disappear
without warning - except when it actually asks for that behaviour by
calling madvise(start, len, MADV_DONTNEED).

> 
> A fix could be to use my own empty page instead of the ZERO_PAGE for xip.

Exactly, that's what I was meaning.  Just take care to do enough
but not too much locking when allocating that page: for example
	if (!our_zero_page) {
		allocate a zeroed page;
		spin_lock;
		if (!our_zero_page)
			our_zero_page = page just allocated;
		else
			free page just allocted;
		spin_unlock;
	}

> At least we have different behavior with/without xip here, therefore I
> agree that this requires fixing.

Yes, if your testing shows that it really does behave as I suspect.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
