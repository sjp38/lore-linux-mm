Date: Tue, 3 Mar 1998 00:37:53 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: reverse pte lookups and anonymous private mappings; avl trees?
In-Reply-To: <199803022303.XAA03640@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980303003031.5566B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 1998, Stephen C. Tweedie wrote:

[second option == linear memory scanning a`la shrink_mmap()]

> My personal feeling at the moment is that the second option is going
> to give us lower overhead swapping and a much fairer balance between
> private data and the page cache.  However, there are are other
> arguments; in particular, it is much easier to do RSS quotas and
> guarantees if we are swapping on a per page-table basis.

RSS quotas and guarantees are quite easy. The guarantee
can be looked up when we do the swapout scan, and the RSS
limit can be enforced at allocation time (once we have an
inactive list, we can simply enforce a maximum number of
active pages per-process. Normally, no extra thrashing
will occur, because those pages will be reactivated soon).

> If we do make this change, then some of the new swap cache code
> becomes redundant.  The next question is, how do we cache swap pages
> in this new scenario?  We still need a swap cache mechanism, both to

Personally, I would use NRU paging on the active pages, and
LRU paging on the inactive list. That is, if a page hasn't
been touched since the last time, it's deactivated, and once
on the inactive list, it'll be deallocated in a LRU fashion
(unless we reactivate it or we're short on big-order pages).

> support proper readahead for swap and to allow us to defer the freeing
> of swapped out pages until the last possible moment.  Now, if we know
> we can atomically remove a page from all ptes at once, then it is
> probably sufficient to unhook the struct page from the (inode-vma,
> offset) hash and rehash it as (swapper-inode, entry).  It gets harder
> if we want per-process control of RSS, since in that case we want to
> use the same physical page for both vma and swap, and we will really
> need a quick lookup from both indexes.
> 
> I'm not at all averse to growing the struct page if we absolutely have
> to, however.  If we can effectively keep several hundred more pages in
> memory as a result of not having to throw data away just to cope with
> the worst-case interrupt memory requirements, then we will still see a
> great overall performance improvement.

And a better aging / minimum RSS / maximum RSS will help
quite a lot too. I'll be working on a swapper daemon RSN,
once the free_memory_available() thingy is sorted I'll start
on the page_struct and the scheduler (to add sleep_time
registration) to do the support work.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
