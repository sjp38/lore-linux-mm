Date: Tue, 10 Jul 2001 17:42:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [wip-PATCH] Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.33.0107100146100.5611-100000@toomuch.toronto.redhat.com>
Message-ID: <Pine.LNX.4.21.0107101650280.15992-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2001, Ben LaHaise wrote:
> On Mon, 9 Jul 2001, Hugh Dickins wrote:
> 
> > I doubt loop unrolling will make much difference.  Mark Hemment tells me
> > that lmbench makes very widely spaced accesses in its mmap() tests, so is
> > liable to show up the latency from the larger reads.
> 
> Err, the difference is that unrolling those loops should allow them to run
> with decreased latency as the current code will suffer from a number of
> mispredictions.

Yes, but I wouldn't expect that to be significant compared with
e.g. the avoidance of repeated faults by prefilling ptes.

(I think the latency you're talking about is in CPU execution,
whereas the latency I was talking about was in I/O?  Which are
many magnitudes different?  Am I misunderstanding you completely?)

If the prefilling of ptes turns out to be a significant win, then it can
be implemented very simply in do_no_page(), independent of more complex
patches for PAGE_CACHE_SIZE or PAGE_SIZE enlargement.  Our patches give
it a better chance of succeeding first time around, that's all.

> > (In looking at your do_no_page() code briefly then, I notice addr_min
> > and addr_max are first set up with page-table-limits, then immediately
> > overwritten with vma-limits - I think you meant to take max and min.)
> 
> Not quite -- I just forgot to remove the first two as they're not needed
> since everything operates on powers of two.

Right.  Took me awhile to understand your code there, different mindset.
Your folio of ptes is aligned in address space, does not have to worry
about page table changeover, may involve more than one page group.  My
folio of ptes is aligned in file offset, has to worry about page table
changeover, only involves one large page.  Your approach much simpler
than mine; mine finds more ptes to fill in first time around,
no difference once the cache is primed.

> > I'm interested you're having trouble with the anonymous->swap pages,
> > they're one of the reasons I went the large PAGE_SIZE instead of the
> > large PAGE_CACHE_SIZE route.  I think there's a lot in my mm/memory.c
> > mods which you could apply in yours, so even anonymous pages could use
> > PAGE_CACHE_SIZE pages efficiently.
> 
> I'm not having trouble with it, I'm just uninterested in implementing it
> since it has no effect on the performance measurements.  Namely, if there
> is no change in performance, then there is little reason to waste time on
> fixing swapping.

Fair enough.

> > I agree that our approaches are complementary, with a large overlap.
> > Shall we aim towards one patch combining configurable PAGE_CACHE_SIZE
> > and configurable PAGE_SIZE?  and later discard one or the other if
> > it proves redundant.
> 
> Sure.  It doesn't look like much work to add in large page support, so let
> me know one way or the other.

Umm, well, my patch is 350KB touching 160 files.  A lot of that trivial,
a fair amount tangential.  You might take a fresh look at it and find a
lot could be thrown out or simplified.  But don't let me hold you up:
you're steaming ahead, and your patch is much the smaller, I think it's
up to me to merge your work into mine once I've rebased and made it
available to you.

Back to work...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
