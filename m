Date: Sat, 13 May 2000 20:41:24 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <m12qjP0-000OVtC@amadeus.home.nl>
Message-ID: <Pine.LNX.4.10.10005132035370.2422-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@fenrus.demon.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ Thanks for looking at this., ]

On Sat, 13 May 2000, Arjan van de Ven wrote:
> 
> My idea is (but I have not tested this) that for priority == 0 (aka "Uh oh")
> shrink_mmap or do_try_to_free_pages have to block while waiting for pages to
> be commited to disk. As far as I can see, shrink_mmap just skips pages that
> are being commited to disk, while these could be freed when they are waited
> upon. 

That's what I did in one ofthe pre-7's, and it ended up being quite bad
for performance. But that was before I put sync-out pages at the head of
the LRU queue, so what ended up happening is that that particular pre-7
tried to write out the block, and then next time around when shrink_mmap()
rolled around, because the page was still at the end of the LRU queue, so
we immediately ended up synchronously waiting for it.

With the current behaviour, which always moves a page to the front of the
LRU list if it cannot be free'd, the synchronous wait in shrink_mmap() is
probably fine, and you could try to just change "sync_page_buffers()" back
to the code that did 

	if (buffer_locked(p))
		__wait_on_buffer(p);
	else if (buffer_dirty(p))
		ll_rw_block(WRITE, 1, &p);

(instead of the current "buffer_dirty(p) && !buffer_locked(p)" test that
only starts the IO).

It's clear that at some point we _have_ to wait for pages to actually get
written out, whether they were written for paging or just because they
were dirty data buffers.

Does the above make it ok? How does it feel performance-wise?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
