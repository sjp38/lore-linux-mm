Date: Fri, 6 Apr 2001 21:48:34 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.31.0104061245320.25931-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0104062104220.1484-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Apr 2001, Linus Torvalds wrote:
> On Fri, 6 Apr 2001, Hugh Dickins wrote:
> >
> > swapper_space.nrpages, that's neat, but I insist it's not right.
> 
> It's not "right", but I suspect it's actually good enough.

Yes, even before Andrea's final email, I found myself warming to
his point of view.  As you both point out, vm_enough_pages() is
merely a heuristic for rejecting the impossible, and overcommit
laughs in the face of strict calculation here.  And it does a
better job than the comparison with infinity I was implying.

> Also, note that when if get _really_ low on memory, the swap cache effect
> should be going away: if we still have the swap cache pages in memory,
> we've obviously not paged everything out yet. So the double accounting
> should have a limit error of zero as we approach being truly low on
> memory. And that, I suspect, is the most important thing - making sure
> that we allow programs to run when they can, but at least having _some_
> concept of "enough is enough".

I've been rehearsing this same "limit error of zero" argument to
myself here, since your call for "Ideas?" which shut us up.  It's
plausible, I bet it's not strictly true, but it feels good enough:
we all know there are cases where it will go wrong, nothing new there.

But maybe a comment in vm_enough_pages() to make the false accounting
explicit?  And pace those who hate multiple returns, why add all those
pages every time, including call to nr_free_pages(), when most often
it can succeed right away?  I haven't got your "num_physpages >> 6"
in there: sounds very reasonable - but there's a 23/11/98 NJC comment
(omitted from mine below, since no such code recently) to suggest it
was tried once before, anyone remember why that was abandoned?

Hugh

int vm_enough_memory(long pages)
{
	/* Stupid algorithm to decide if we have enough memory: while
	 * simple, it hopefully works in most obvious cases.. Easy to
	 * fool it, but this should catch most mistakes.
	 */
	long free;
	
        /* Sometimes we want to use more memory than we have. */
	if (sysctl_overcommit_memory)
		return 1;

	free = nr_swap_pages;
	if (free > pages)
		return 1;
	free += atomic_read(&page_cache_size);
	if (free > pages)
		return 1;
	free += atomic_read(&buffermem_pages);
	if (free > pages)
		return 1;
	/*
	 * swapper_space.nrpages is the number of swap pages cached:
	 * they have already been included in page_cache_size, but
	 * this compensates for recently unmapped and freeable pages
	 * of swap not yet included in nr_swap_pages: when in doubt,
	 * let vm_enough_memory() err towards success.
	 */
	free += swapper_space.nrpages;
	if (free > pages)
		return 1;
	free += nr_free_pages();
	if (free > pages)
		return 1;
	/*
	 * The code below doesn't account for free space in the inode
	 * and dentry slab cache, slab cache fragmentation, inodes and
	 * dentries which will become freeable under VM load, etc.
	 * Lets just hope all these (complex) factors balance out...
	 */
	free += (dentry_stat.nr_unused * sizeof(struct dentry)) >> PAGE_SHIFT;
	free += (inodes_stat.nr_unused * sizeof(struct inode)) >> PAGE_SHIFT;

	return free > pages;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
