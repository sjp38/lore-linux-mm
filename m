Date: Thu, 9 Dec 1999 22:19:15 -0600 (CST)
From: Oliver Xymoron <oxymoron@waste.org>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <E11wDK1-0002nT-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.10.9912092158400.31069-100000@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "William J. Earl" <wje@cthulhu.engr.sgi.com>, mingo@chiara.csoma.elte.hu, jgarzik@mandrakesoft.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 1999, Alan Cox wrote:

> > for higher-bandwidth targets, such as a graphics controller or a 
> > HDTV camera.
> 
> I don't know of any capture cards that don't do scatter gather. Most of them
> do scatter gather with skipping and byte alignment so you can DMA around
> other windows.

I know of one, built internally, using a standard PCI controller. And it
pumps data a lot faster than a typical frame grabber. But it's not a big
deal, because as I mentioned before, most if not all PCI board chipsets
can send you an interrupt at the end of a short DMA transfer, which means
you can program another transfer immediately afterwards and thereby do
scatter-gather in your driver.

If your driver preallocs a large virtual space, locks it down, and then
scans it to create a list of fragments of contiguous memory, the interrupt
handler can be made pretty fast and simple. Alternately you can ask for
chunks of linear memory in smaller and smaller sizes until you've gathered
enough.

The overhead here is usually not a big deal at all unless your device has
no buffering, in which case it had better be able to do scatter-gather on
its own anyway. In some ways, the latency is better because you can start
processing the data from partial transfers before you'd be able to with a
single notification s-g setup.
 
> This is the main point. There are so so few devices that actually _have_ to
> have lots of linear memory it is questionable that it is worth paying the
> price to allow modules to allocate that way

Especially when many of the exceptions can be handled in another way.

--
 "Love the dolphins," she advised him. "Write by W.A.S.T.E.." 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
