Date: Tue, 15 Aug 2000 20:26:37 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: filemap.c SMP bug in 2.4.0-test*
In-Reply-To: <Pine.LNX.4.21.0008151845550.2466-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10008152018100.3600-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>


On Tue, 15 Aug 2000, Rik van Riel wrote:
> 
> The backtrace I got points to some place deep inside
> mm/filemap.c, in code I really didn't touch and I
> wouldn't want to touch if this bug wasn't here ;)
> 
> >>EIP; c012e370 <lru_cache_add+5c/d4>   <=====
> Trace; c021b33e <tvecs+1dde/19f60>
> Trace; c021b579 <tvecs+2019/19f60>
> Trace; c0127823 <add_to_page_cache_locked+cb/dc>
> Trace; c0130a3c <add_to_swap_cache+84/8c>
> Trace; c0130d00 <read_swap_cache_async+68/98>
> Trace; c0125c8b <handle_mm_fault+143/1c0>
> Trace; c0113d33 <do_page_fault+143/3f0>

Look at this back-trace again.

In particular, look at which page read_swap_cache_async() adds to the swap
cache.

The code is:

        /*
         * Look for the page in the swap cache.
         */
        found_page = lookup_swap_cache(entry);
        if (found_page)
                goto out_free_swap;

*****   new_page_addr = __get_free_page(GFP_USER);		*******
        if (!new_page_addr)
                goto out_free_swap;     /* Out of memory */
        new_page = virt_to_page(new_page_addr);

        /*
         * Check the swap cache again, in case we stalled above.
         */
        found_page = lookup_swap_cache(entry);
        if (found_page)
                goto out_free_page;
        /*
         * Add it to the swap cache and read its contents.
         */
        lock_page(new_page);
        add_to_swap_cache(new_page, entry);
        rw_swap_page(READ, new_page, wait);
        return new_page;

In short, read_swap_cache_async() allocates a new page that nobody else
has access to. There's no way in hell that page is going to be on any LRU
lists. 

(The page allocation and type switching is silly - it should really do
"new_page = page_cache_alloc()" and not have that "new_page_addr" thing
at all, but that's a silly inefficiency, not a bug).

The bug pretty much has to be in the new page flag handling. No, I don't
see anything wrong in your patch, but we're talking about a code-path that
has it's own very private page that cannot be shared unless there are some
pretty major bugs (if __get_free_page() returns a page that is still in
use somewhere, we're _soo_ screwed).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
