Date: Tue, 4 Apr 2000 18:50:07 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004041230200.23401-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0004041824020.921-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2000, Rik van Riel wrote:

>You might want to have read _where_ Ben's patch applies.
>
>void __delete_from_swap_cache(struct page *page)
>{
>        swp_entry_t entry;
>
>        entry.val = page->index;
>
>#ifdef SWAP_CACHE_INFO
>        swap_cache_del_total++;
>#endif
>        remove_from_swap_cache(page);
>        swap_free(entry);
>+	clear_bit(PG_swap_entry, &page->flags);
>}
>
>When we remove a page from the swap cache, it seems fair to me
>that we _really_ remove it from the swap cache.

Are you sure you didn't mistaken PG_swap_entry for PG_swap_cache?

We're here talking about PG_swap_entry. The only object of that bit is to
remains set on anonymous pages that aren't in the swap cache, so next time
we'll re-add them to the swap cache we'll try to swap out them in the same
swap entry as the page were before.

>If __delete_from_swap_cache() is called from a wrong code path,
>that's something that should be fixed, of course (but that's
>orthogonal to this).

__delete_from_swap_cache is called by delete_from_swap_cache_nolock that
is called by do_swap_page that does the swapin.

>To quote from memory.c::do_swap_page() :
>
>        if (write_access && !is_page_shared(page)) {
>                delete_from_swap_cache_nolock(page);
>                UnlockPage(page);
>
>If you think this is a bug, please fix it here...

The above quoted code is correct.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
