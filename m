Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA14350
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 12:14:12 -0500
Date: Mon, 23 Nov 1998 17:13:34 GMT
Message-Id: <199811231713.RAA17361@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Linux-2.1.129..
In-Reply-To: <Pine.LNX.3.95.981119143242.13021A-100000@penguin.transmeta.com>
References: <19981119223434.00625@boole.suse.de>
	<Pine.LNX.3.95.981119143242.13021A-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 19 Nov 1998 14:33:59 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> On Thu, 19 Nov 1998, Dr. Werner Fink wrote:
>> 
>> Yes on a 512MB system it's a great win ... on a 64 system I see
>> something like a ``swapping weasel'' under high load.

> The reason the page aging was removed was that I had people who did
> studies and told me that the page aging hurts on low-memory machines.

> On something like the machine I have, page aging makes absolutely
> no difference whatsoever, either positive or negative.

> Stephen, you're the one who did the studies. Comments?

Hmm.  The vast majority of the old studies I did with page aging assumed
that the kswap side of things still did aging.  I was primarily
disabling the page cache aging in those experiments, and I had a number
of other people testing it too.

With the 2.1.129 prepatches, Linus removed the page aging from the swap
logic.  That makes it much easier to find free pages in swap.  Given
that the page cache still used aging, the try_to_free_pages() loop was
essentially being instructed to concentrate all of its effort on swap.
This looked "obviously" wrong, since in all the previous experiments, I
had disabled the cache aging but kept swap aging, and that improved
things.  Swinging the balance the other way would obviously cause us to
swap too much.

So, rather than back out Linus's removal of the swap aging, I just
removed the page cache aging to compensate and revalidated my original
tests, especially on a low memory machine.  That still showed that
performance with no page cache aging on 2.1.129-prewhatever was better
than performance with page cache aging.

So, I have still seen no cases where overall performance with no page
cache aging was better than performance with it.  However, with the swap
aging removed as well, we seem to have a page/swap balance which doesn't
work well on 64MB.  To be honest, I just haven't spent much time playing
with swap page aging since the early kswap work, and that was all done
before the page cache was added.

On Thu, 19 Nov 1998 22:58:30 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> It was certainly a huge win when page aging was implemented, but we
> mainly felt that because there used to be an obscure bug in vmscan.c,
> causing the kernel to always start scanning at the start of the
> process' address space.

Rik, you keep asserting this but I have never understood it.  I have
asked you several times for a precise description of what benchmarks
improved when page cache aging was added, but I've only ever seen
performance degradation with it in.  The only test you've given me where
page cache aging helped was a case of a readahead bug which had an
obvious fix elsewhere.

And the "obscure bug" you describe was never there: I've said to you
more than once that you were misreading the source, and that the field
you pointed to which was being reset to zero at the start of the swapout
loop was *guaranteed* to be overwritten with the last address scanned
before we exited that loop.  Look at 2.0's mm/vmscan.c: in
swap_out_pmd(), there is a line

		tsk->swap_address = address + PAGE_SIZE;

which is executed unconditionally as soon as we start the pmd scan.  It
is simply impossible for the "p->swap_address = 0" assignment you were
worried about to have any effect at all unless we never get as far as
swap_out_pmd(), and that can only happen if we never find a vma to swap
out.  So, the end result is that p->swap_address only gets left at zero
if we have nothing left beyond the current swap address to swap.  This
was correct in the first place.

> Now that bug is fixed, it might just be better to switch to a
> multi-queue system. A full implementation of that will have to wait
> until 2.3, but we can easily do an el-cheapo simulation of it by
> simply not freeing swap cached pages on the first pass of
> shrink_mmap().

Right now, that will achieve precisely nothing, since the
free_page_and_swap_cache() call in try_to_swap_out() already deletes
swap cache after we start swap IO.  (That's precisely why we check the
page_free_after bit on the page in is_page_shared(), so that we still
remove the swap cache when doing async swapout.)  Except for the recent
changes in the behaviour of shared COW pages, shrink_mmap() should never
ever see a swap cache page.

> This gives the process a chance of reclaiming the page without
> incurring any I/O and it gives the kernel the possibility of keeping a
> lot of easily-freeable pages around.

That would be true if we didn't do the free_page_and_swap_cache trick.
However, doing that would require two passes: once by the swapper, and
once by shrink_mmap(): before actually freeing a page.  This actually
sounds like a *very* good idea to explore, since it means that vmscan.c
will be concerned exclusively with returning mapped and anonymous pages
to the page cache.  As a result, all of the actual freeing of pages will
be done in shrink_mmap(), which is the closest we can get to a true
self-balancing system for freeing memory.

I'm going to check this out: I'll post preliminary benchmarks and a
patch for other people to test tomorrow.  Getting the balancing right
will then just be a matter of making sure that try_to_swap_out gets
called often enough under normal running conditions.  I'm open to
suggestions about that: we've never tried that sort of behaviour in the
vm to my knowledge.

> Maybe we even want to keep a 3:1 ratio or something like that for
> mapped:swap_cached pages and a semi- FIFO reclamation of swap cached
> pages so we can simulate a bit of (very cheap) page aging.

I will just restate my profound conviction that any VM balancing which
works by imposing precalculated limits on resources is fundamentally
wrong.

Cheers,
  Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
