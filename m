Date: Tue, 24 Feb 1998 23:38:14 GMT
Message-Id: <199802242338.XAA03262@dax.dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <Pine.LNX.3.91.980224102818.1909A-100000@mirkwood.dummy.home>
References: <199802232317.XAA06136@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.91.980224102818.1909A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linus Torvalds <torvalds@transmeta.com>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 24 Feb 1998 10:42:48 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> [linux-kernel trimmed from f-ups]
> On Mon, 23 Feb 1998, Stephen C. Tweedie wrote:

>> The patch below, against 2.1.88, adds a bunch of new functionality to
>> the swapper.  The main changes are:
>> 
>> * All swapping goes through the swap cache (aka. page cache) now.

> Does this mean that _after_ the pages are properly aged
> as user-pages, they'll be aged again as page-cache pages?
> (when proper aging is added to the page cache, by eg. my patch)

No --- the swap cache is using the same data structures as the page
cache, but mainly to get lookup of swap entries still in physical
memory.  The swapout code does not leave swapped pages around in memory
unnecessarily (although it does leave the door open to performing
readahead of swap, which _would_ look very much like the current page
cache readahead and would be reclaimed by shrink_mmap()).

The page cache swapout creates a page cache association for a page when
swapping begins, and clears the link when the swapping is finished.  The
swap cache does not linger.

> I think it might be far better to:
> - put user-pages in the swap cache after they haven't been used
>   for two aging rounds
> - free swap-cache pages and page-cache pages after they haven't
>   been used for eight aging rounds (so the real aging and waiting
>   takes place here)
> - use right-shift aging here {age << 1; if(touched) age |= 0x80}
> - adapt the get_free_pages so it can allocate clean page-cache and
>   swap-cache pages when:
>   - a bigorder area can't be found
>   - there are no free pages left (and kswapd hasn't found new ones)

That is already scheduled as part of phase 4 of this work.  The patch I
have just posted is phase 2, modifying the swapper for shared pages.
Phase three is to implement MAP_SHARED | MAP_ANONYMOUS, and part four is
to do much what you describe, proactively soft-swapping data out
into the swap cache up to a predefined limit, and allowing get_free_page
to reclaim these pages atomically even from within an interrupt.  I have
already begun the work of spin-irq-locking the relevant page cache
structures.

> For more improvements, we could use Ben's pte_list <name?>
> patch so we could force-free bigorder areas and run somewhat
> more efficiently.

Ben has already been talking about some similar ideas, and I think that
yes, we do want to upgrade the swapout policy layer to work on a
physical page basis, using the pte_list walking to do its work.  The
swap cache mechanism will still be needed to perform readahead and
writeahead, but the only reason I have had to integrate it so tightly
into the policy code right now is that without pte-walking there is no
other way to properly keep pages shared over swapping.

Ideally, we really want to have just one function walking over physical
pages for reclamation, and that function should be able to deal with
swap/filemap pages, page/swap cache, buffer cache and SysV shm pages as
they come up.  I think that is achievable without too much more work
now, and it ought to give us much better performance from the swapper.

Cheers,
 Stephen.
