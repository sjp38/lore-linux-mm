Date: Mon, 9 Jul 2001 18:21:40 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [wip-PATCH] Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.33.0107082224020.30164-100000@toomuch.toronto.redhat.com>
Message-ID: <Pine.LNX.4.21.0107091740360.1402-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jul 2001, Ben LaHaise wrote:
> 
> Well, here are a few lmbench runs with larger PAGE_CACHE_SIZES.  Except
> for 2.4.2-2, the kernels are all based on 2.4.6-pre8, with -b and -c being
> the 2 and 3 shift page cache kernels.  As expected, exec and sh latencies
> are reduced.  Mmap latency appears to be adversely affected in the 16KB
> page cache case while other latencies are reduced.  My best guess here is
> that either a change in layout is causing cache collisions, or the changes
> in do_no_page are having an adverse impact on page fault timing.  Ideally
> the loop would be unrolled, however...

I doubt loop unrolling will make much difference.  Mark Hemment tells me
that lmbench makes very widely spaced accesses in its mmap() tests, so is
liable to show up the latency from the larger reads.

> The way I changed do_no_page to speculatively pre-fill ptes is suboptimal:
> it still has to obtain a ref count for each pte that touches the page
> cache page.  One idea here is to treat ptes within a given page cache page
> as sharing a single reference count, but this may have no impact on
> performance and simply add to code complexity and as such probably isn't
> worth the added hassle.

I'm sure not worth the added hassle - it means that all the unmappers
have to be made more complicated, to look ahead and behind for nearby
ptes which are sharing the ref count.  But you can add (N - 1) to the
ref count in one go once you know what N is.

(In looking at your do_no_page() code briefly then, I notice addr_min
and addr_max are first set up with page-table-limits, then immediately
overwritten with vma-limits - I think you meant to take max and min.)

> The next step is to try out Hugh's approach and see what differences there
> are and how the patches work together.  I also suspect that these changes
> will have a larger impact on performance with ia64 where we can use a
> single tlb entry to map all the page cache pages at the same time.  Hmmm,
> perhaps I should try making anonymous pages use the larger allocations
> where possible...

I'm interested you're having trouble with the anonymous->swap pages,
they're one of the reasons I went the large PAGE_SIZE instead of the
large PAGE_CACHE_SIZE route.  I think there's a lot in my mm/memory.c
mods which you could apply in yours, so even anonymous pages could use
PAGE_CACHE_SIZE pages efficiently.

I'll proceed with porting mine forward to 2.4.6 and make that available
to you a.s.a.p. - or else decide it'll take me too long, and make the
2.4.4 available instead - you're going much faster than I can manage.

I agree that our approaches are complementary, with a large overlap.
Shall we aim towards one patch combining configurable PAGE_CACHE_SIZE
and configurable PAGE_SIZE?  and later discard one or the other if
it proves redundant.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
