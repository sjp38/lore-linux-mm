Date: Sun, 5 Aug 2001 13:33:26 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <E15TURJ-0008Jy-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.33.0108051325070.7988-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Mike Black <mblack@csihq.com>, Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Aug 2001, Alan Cox wrote:

> > On Sun, 5 Aug 2001, Mike Black wrote:
> > And quite frankly, if your disk can push 50MB/s through a 1kB
> > non-contiguous filesystem, then my name is Bugs Bunny.
>
> Hi Bugs 8), previously Frodo Rabbit, .. I think you watch too much kids tv
> 8)

Three kids will do that to you. Some day, you too will be there.

> [To be fair I can do this through a raid controller with write back caches
> and the like ..]

Note that this was _read_ performance.

I agree that writing is easier, and contiguous buffers do not mean much if
you have a big write cache.

> One problem I saw with scsi was that non power of two readaheads were
> causing lots of small I/O requests to actual hit the disk controller (which
> hurt big time on hardware raid as it meant reading/rewriting chunks). I
> ended up seeing 128/127/1 128/127/1 128/127/1 with a 255 block queue.

Uhhuh. I think the read-ahead is actually a power-of-two, because it ends
up being "127 pages plus the current one", but hey, I could easily be
off-by-one.

I would actually love to see the read-ahead code just pass down the
knowledge that it is a read-ahead to the IO layer, and let the IO layer do
whatever it wants. In the case of block devices, for example, the READA
code is still there and looks very simple and functional - so it should be
trivial for generic_block_read_page() to pass down the READA information
and just return "no point in doing read-ahead, the queue is full"..

That way we'd never have the situation that we end up breaking up large
reads into badly sized entities.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
