Date: Tue, 15 Aug 2000 19:43:05 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: filemap.c SMP bug in 2.4.0-test*
In-Reply-To: <Pine.LNX.4.21.0008151845550.2466-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10008151938240.3600-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>


On Tue, 15 Aug 2000, Rik van Riel wrote:
> 
> The debugging check (in mm/swap.c::lru_cache_add(), line 232)
> checks if the page which is to be added to the page lists is
> already on one of the lists. In case it is, a nice backtrace
> follows...

Why do you think your "PageActive()"/"PageInactiveDirty()"/
"PageInactiveClean()" tests are right?

I don't see any reason to assume that you just don't clear the flags
correctly.

In fact, if this bug really existed in the standard kernel, you'd see
machines locking up left and right. Adding a page to a the LRU list  when
it already is on the LRU list would cause immediate and severe list
corruption. It wouldn't just go silently in the night, it would _scream_. 

I would suggest that you add something like DEBUG_ADD_PAGE to
__free_pages_ok(), and see if somebody frees the page without clearing the
flags. Sounds like a bug in your code.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
