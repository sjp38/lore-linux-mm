Date: Mon, 4 Dec 2000 08:56:31 -0500 (EST)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [RFC] gfp_mask for address_space
In-Reply-To: <20001204134045.B8700@redhat.com>
Message-ID: <Pine.GSO.4.21.0012040850150.5153-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Jens Axboe <axboe@suse.de>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 4 Dec 2000, Stephen C. Tweedie wrote:

> However, it doesn't actually fix all of the problems.  We still have
> balance_dirty() deadlocks even if we avoid memory allocation loops.

I know. However, these are somewhat easier to kill. E.g. we could give
weights to devices (normal => 0, loopback over file on device of level
n => n+1) and split bdflush into per-weight threads. Then we have an
obvious hierarchy (activity of bdflush[n] can't lead to new dirty bh
of weight n and above).
 
> The problem right now is that the balance_dirty() inside the nbd
> server can result in it attempting to flush out dirty nbd buffers, so
> we have the nbd device blocked on the nbd server, the nbd server
> dirtying local disk buffer_heads, and the dirty buffer code blocking
> on other dirty nbd buffers.)

Ditto for loop and the same method can be applied... 

I'm actually more interested in experimenting with bitmaps in page
cache - making it GFP_BUFFER should be deadlock-safe, AFAICS, and
ext2/balloc.c would benefit big way from switching to that...
							Cheers,
								Al

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
