Date: Fri, 3 Aug 2001 21:47:16 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108040026490.14842-100000@touchme.toronto.redhat.com>
Message-ID: <Pine.LNX.4.33.0108032141370.894-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 4 Aug 2001, Ben LaHaise wrote:
>
> Using the number of queued sectors in the io queues is, imo, the right way
> to throttle io.  The high/low water marks give us decent batching as well
> as the delays that we need for throttling writers.  If we remove that,
> we'll need another way to wait for io to complete.

Well, we actually _do_ have that other way already - that should be, after
all, the whole point in the request allocation.

It's when we allocate the request that we know whether we already have too
many requests pending.. And we have the batching there too. Maybe the
current maximum number of requests is just way too big?

[ Quick grep later ]

On my 1GB machine, we apparently allocate 1792 requests for _each_ queue.
Considering that a single request can have hundreds of buffers allocated
to it, that is just _ridiculous_.

How about capping the number of requests to something sane, like 128? Then
the natural request allocation (together with the batching that we already
have) should work just dandy.

Ben, willing to do some quick benchmarks?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
