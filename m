Date: Tue, 4 Apr 2000 13:06:49 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004041824020.921-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004041256250.12374-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2000, Andrea Arcangeli wrote:

> On Tue, 4 Apr 2000, Rik van Riel wrote:

> >When we remove a page from the swap cache, it seems fair to me
> >that we _really_ remove it from the swap cache.
> 
> Are you sure you didn't mistaken PG_swap_entry for PG_swap_cache?

Yes I'm sure.  What's happening is that the presence of PG_swap_entry on
the page means that page->index is being returned as the swap entry.  This
is completely bogus after the page has been freed and reallocated.  Just
try running a swap test under any recent devel kernel -- eventually you
will see an invalid swap entry show up in someone's pte causing a random
SIGSEGV (it's as if the entry was marked PROT_NONE -- present, but no
user access).
 
> We're here talking about PG_swap_entry. The only object of that bit is to
> remains set on anonymous pages that aren't in the swap cache, so next time
> we'll re-add them to the swap cache we'll try to swap out them in the same
> swap entry as the page were before.

Which is bogus.  If it's an anonymous page that we want to swap out to the
same swap entry, leave it in the swap cache.

> >If __delete_from_swap_cache() is called from a wrong code path,
> >that's something that should be fixed, of course (but that's
> >orthogonal to this).
> 
> __delete_from_swap_cache is called by delete_from_swap_cache_nolock that
> is called by do_swap_page that does the swapin.

As well as from shrink_mmap.

> >To quote from memory.c::do_swap_page() :
> >
> >        if (write_access && !is_page_shared(page)) {
> >                delete_from_swap_cache_nolock(page);
> >                UnlockPage(page);
> >
> >If you think this is a bug, please fix it here...
> 
> The above quoted code is correct.

The code path that this patch really affects is shrink_mmap ->
__delete_from_swap_cache.  Clearing the bit from shrink_mmap is an option,
but it doesn't make that much sense to me; if we're removing a page from
the swap cache, why aren't we clearing the PG_swap_entry bit?  I'd rather
leave the page in the swap cache and set PG_dirty on it that have such
obscure sematics.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
