Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id D106338C89
	for <linux-mm@kvack.org>; Mon, 30 Jul 2001 16:10:16 -0300 (EST)
Date: Mon, 30 Jul 2001 16:10:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: strange locking __find_get_swapcache_page()
Message-ID: <Pine.LNX.4.33L.0107301542230.5582-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Andrew Morton <andrewm@uow.edu.au>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

I've encountered a suspicious piece of code in filemap.c:

struct page * __find_get_swapcache_page( ... )
...
        /*
         * We need the LRU lock to protect against page_launder().
         */

        spin_lock(&pagecache_lock);
        page = __find_page_nolock(mapping, offset, *hash);
        if (page) {
                spin_lock(&pagemap_lru_lock);
                if (PageSwapCache(page))
                        page_cache_get(page);
                else
                        page = NULL;
                spin_unlock(&pagemap_lru_lock);
        }
        spin_unlock(&pagecache_lock);


Question is ... WHY do we need the pagemap_lru_lock ?

Page_launder() never removes the page from the swap
cache, that is only done by reclaim_page(), and done
while holding the pagecache_lock.

The other places where pages are removed from the
swap cache (tmpfs and free_page_and_swap_cache)
also hold the pagecache_lock.

Taking the pagemap_lru_lock seems unneeded to me...

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
