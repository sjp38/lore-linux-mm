Date: Mon, 25 Nov 2002 14:10:04 +0100
From: Gerd Knorr <kraxel@bytesex.org>
Subject: Re: [PATCH] Really start using the page walking API
Message-ID: <20021125131004.GA5725@bytesex.org>
References: <20021124233449.F5263@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021124233449.F5263@nightmaster.csn.tu-chemnitz.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Andrew Morton <akpm@digeo.com>, Kai Makisara <Kai.Makisara@kolumbus.fi>, Douglas Gilbert <dougg@torque.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 24, 2002 at 11:34:49PM +0100, Ingo Oeser wrote:
> Hi all,
> 
> here come some improvements of the page walking API code.

Is the API already in linus tree?

> Gerd: Your video-buf.[ch] is next on my list and I must coalesce 
>    videobuf_pages_to_sg() and videobuf_init_user() to do it
>    efficiently. May be you can come up with a better solution for
>    this or are already working on sth. here. If not, I'll do it
>    my way first and wait for your approval ;-)

Hmm.  I'm looking at the code, and it doesn't make much sense to do
it the current way (i.e. have page walking and scatter list building
splitted up).  As I'm not a vm expert I'm not sure what the right way to
handle this is.

The videobuf_init_*() functions are called when the video buffer is
setup, i.e. if some video4linux application calls mmap().

The videobuf_dma_pci_map() function (the one which calls
videobuf_pages_to_sg()) is called to prepare the video buffer for DMA,
i.e. if the application asked the driver to actually capture an video
frame into that buffer.


Right now it works basically that way, party for historical reasons
because the code used to use kiobufs:

videobuf_init_user():
	get_user_pages()

videobuf_dma_pci_map():
	lock pages for DMA	[videobuf_lock()]
	build scatter list	[videobuf_pages_to_sg()]
	pci_map_sg()


I think it can be cleaned up to work this way:

videobuf_init_user():
	walk pages & build scatter list (using the new API in 2.5 and
		the existing videobuf_* functions in 2.4).

videobuf_dma_pci_map():
	lock pages for DMA
	pci_map_sg()

Will this work correctly?  Ou should the page walking better be done in
the videobuf_dma_pci_map() function?

A generic function which accepts a scatter list and locks the pages in
there for DMA would be nice btw.

  Gerd

-- 
You can't please everybody.  And usually if you _try_ to please
everybody, the end result is one big mess.
				-- Linus Torvalds, 2002-04-20
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
