Date: Sat, 22 Apr 2000 12:58:17 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004221520310.16974-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.10.10004221254100.1014-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Andrea Arcangeli <andrea@suse.de>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 22 Apr 2000, Rik van Riel wrote:
> 
> It all depends on the source code. If we're holding the page
> lock anyway in places where we play with the other flags, that's
> probably the best strategy, but if we're updating the page flags
> in a lot of places without holding the page lock, then it's
> probably better to just do everything with the current atomic
> bitops.

I suspect that we hold the page lock already. And it just seems wrong that
we could ever alter some of the flags (like dirty or uptodate) without
holding the page lock. So the logic is more than just "bitfield
coherency": it's also a higher-level coherency guarantee.

> Btw, here's a result from 2.3.99-pre6-3 ... line number 3 and
> 4 are extremely suspect...
> 
> [riel@duckman mm]$ grep 'page->flags' *.c
> filemap.c:              if (test_and_clear_bit(PG_referenced, &page->flags)) 
> filemap.c:      set_bit(PG_referenced, &page->flags);
> filemap.c:      flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_dirty));
> filemap.c:      page->flags = flags | (1 << PG_locked) | (1 << PG_referenced);

Both 3 and 4 are from the same sequence: it's the initialization code for
the page. They are run before the page is added to the page cache, so
atomicity is not even an issue, because nobody can get at the page
beforeit ison any of the page lists. Think of it as an anonymous page that
is just about to get truly instantiated into the page cache.

It's also one of the few timeswhere we truly touch many bits. In most
other caseswe touch just one or two at a time.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
