Date: Thu, 4 May 2000 11:43:22 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <3911BF09.653D9A2@sgi.com>
Message-ID: <Pine.LNX.4.10.10005041137320.1388-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>


On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> 
> You may have something here. It's the burstiness of
> the demand.

The way bursty demand is _supposed_ to be handled is that the "demander"
just ends up doing the "try_to_free_pages()" call itself at that point.
There's no way kswapd can handle these cases sanely, and at some point we
just need to start freeing memory synchronously.

So what's probably started happening is that "try_to_free_pages()" is not
trying hard enough to free stuff (probably the counters changed, and it
now only scans half the memory it used to under pressure), so when we get
into the bursty demand situation, the allocator ends up giving up in
disgust.

This is something you'll never see under non-busrty load, simply because
kswapd doesn't care - it will continue to page stuff out whether
try_to_free_pages() returns happy or not. So if try_to_free_pages() isn't
trying hard enough, kswapd will compensate by just calling it more.

Note that changing how hard try_to_free_pages() tries to free a page is
exactly part of what Rik has been doing, so this is something that has
changed recently. It's not trivial to get right, for a very simple reason:
we need to balance the "hardness" between the VM area scanning and the RLU
list scanning.

Rik probably balanced it ok, but ended up making it too soft, giving up
much too easily even when memory really would be available if it were to
just try a bit harder..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
