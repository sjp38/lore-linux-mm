Date: Tue, 4 Apr 2000 12:46:30 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004041647150.921-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004041230200.23401-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2000, Andrea Arcangeli wrote:
> On Mon, 3 Apr 2000, Ben LaHaise wrote:
> 
> >The following one-liner is a painful bug present in recent kernels: swap
> >cache pages left in the LRU lists and subsequently reclaimed by
> >shrink_mmap were resulting in new pages having the PG_swap_entry bit set.  
> 
> The patch is obviously wrong and shouldn't be applied. You missed the
> semantics of the PG_swap_entry bitflage enterely.

[snip]

> Said the above, I obviously agree free pages shouldn't have such
> bit set, since they aren't mapped anymore and so it make no
> sense to provide persistence on the swap space to not allocated
> pages :). I seen where we have a problem in not clearing such
> bit, but the fix definitely isn't to clear the bit in the
> swapin-modify path.

You might want to have read _where_ Ben's patch applies.

void __delete_from_swap_cache(struct page *page)
{
        swp_entry_t entry;

        entry.val = page->index;

#ifdef SWAP_CACHE_INFO
        swap_cache_del_total++;
#endif
        remove_from_swap_cache(page);
        swap_free(entry);
+	clear_bit(PG_swap_entry, &page->flags);
}

When we remove a page from the swap cache, it seems fair to me
that we _really_ remove it from the swap cache.
If __delete_from_swap_cache() is called from a wrong code path,
that's something that should be fixed, of course (but that's
orthogonal to this).

To quote from memory.c::do_swap_page() :

        if (write_access && !is_page_shared(page)) {
                delete_from_swap_cache_nolock(page);
                UnlockPage(page);

If you think this is a bug, please fix it here...

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
