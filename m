Date: Tue, 7 Aug 2001 10:04:05 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.31.0108070920440.31117-100000@cesium.transmeta.com>
Message-ID: <Pine.LNX.4.31.0108070932400.31167-100000@cesium.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Linus Torvalds wrote:
>
> Sorry, I should have warned people: pre5 is a test-release that was
> intended solely for Leonard Zubkoff who has been helping with trying to
> debug a FS livelock condition.

In case people are interested, the livelock _seems_ to be rather simple:
when we run out of immediately available memory in "refill_freelist()", we
seem to do all the wrong things.

This condition doesn't happen under normal load, because under normal load
most allocators are of the regular "GFP_USER" kind. But it looks like
under certain loads you get into the situation that the system isn't doing
much else than just doing alloc_pages(GFP_NOFS), and that one seems to be
giving up really easily.

Apparently so easily, in fact, that kswapd doesn't even bother to try to
make things better. I _know_ that it doesn't show up as
"inactive_shortage()", because the machine has tons of inactive_dirty
pages (buffers), and I suspect that "free_shortage()" also decides that we
have enough pages.

So I _think_ that what happens is:
 - alloc_pages() itself isn't making any progress, because it's called
   with GFP_NOFS and thus cannot touch a lot of the pages.
 - we wake up kswapd to try to help, but kswapd doesn't do anything
   because it thinks things are fine.

At least that's my current theory - I can't really reproduce it on any of
my own machines. Can anybody see which test is wrong that would allow
this? I don't see how it can happen.

Something reasonably simple like adding

	if (memory_pressure)
		do_try_to_free_pages(GFP_KSWAPD,0);

to kswapd might be sufficient, but I'd like to understand how we get into
this situation a bit better first.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
