Date: Fri, 27 Feb 1998 17:28:33 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [2x PATCH] page map aging & improved kswap logic
In-Reply-To: <199802271952.TAA01195@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980227164636.13161A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, "Dr. Werner Fink" <werner@suse.de>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Feb 1998, Stephen C. Tweedie wrote:
...
> The biggest problem is avoiding blocking while we do the work in
> try_to_swap_out().  That is a rather tricky piece of code, since it has
> to deal with the fact that the process it is swapping can actually be
> killed if we sleep for any reason, so it will not necessarily still be
> there when we wake up again.  We've really got to do the entire
> custering operation for write within try_to_swap_out() and then start up
> the IO for those pages.

The code I'm hoping to complete this weekend should solve this problem
nicely -- vm_ops->swapout is now completely integrated within the swapper
for 'normal' shared/private pages and won't sleep until all ptes that
reference a page have been replaced with the swap entry.  So it's just a
small step to batch up the pages to be written out.

> However, at least with the new swap cache stuff we can make things
> easier, since it is now possible to set up swap cache associations
> atomically on all the pages we want to swapout, and then take as much
> time as we want performing the actual writes.  All we need to do is make
> sure that we lock all the pages for IO without the risk of blocking.

At your suggestion, my work in progress now includes a per private vma
inode, which essentially makes the swap-cache disappear since all pages
are now in the page cache.  There is a concern with this: on swapin, each
pte that pointed to the page on disk has to be replaced with the page's
entry.  Unfortunately this means that the swap entry is now lost!  I'm
tempted to revert back to the old swap_cache_entry, and will have to
unless someone has an ingenious idea about where the swap entry could be
stored.  (The inode, offset pair can't be used for the swap cache as
they're used to find the appropriate pte in the page tables.)

One possibility is to store the swap entries in a structure attached to
the inode - right now affs is using a whopping ~80 longs for its private
inode data.  Or the data could just be stored in swap-cache entries tied
to the inode - actually that might work well as a page would need to be
allocated on swapin of an entry.  Hmmm...

		-ben
