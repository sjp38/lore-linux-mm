Date: Wed, 16 Aug 2000 19:17:00 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Message-ID: <20000816191700.J19260@redhat.com>
References: <200008101718.KAA33467@google.engr.sgi.com> <20000815171954.U12218@redhat.com> <399A4FE4.FA5C397A@augan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <399A4FE4.FA5C397A@augan.com>; from roman@augan.com on Wed, Aug 16, 2000 at 10:25:08AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <roman@augan.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davem@redhat.com, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Aug 16, 2000 at 10:25:08AM +0200, Roman Zippel wrote:
> 
> > Excellent, this will make it _tons_ easier for me to create new zones
> > of mem_map arrays on the fly to allow us to create struct pages for
> > PCI IO-aperture memory (necessary for kiobuf mappings of IO memory).
> 
> A related question: do you already have an idea how the driver interface
> for that could look like? I mean, some drivers need a virtual address,
> some need the physical address for dma and some of them might need
> bounce buffers.

It's even more complicated than that --- you can't even assume that
the pages concerned have got valid pointers in _any_ address space,
because they might be high memory pages on PAE36 which exist above the
4GB boundary and which aren't mapped into virtual memory anywhere.

We will need to make sure that there is a clean way to convert any
struct page * into (a) a kernel virtual address (that's easy, kmap()
does it already); (b) a physical address (which can be translated
easily into a bus address); or (c) a page frame number which can
identify pages above 4GB even though a ulong pointer/address can't
cope with such pages as addresses directly.  

However, the kiobuf code will not do anything fancy with _any_ of this
--- it will continue just to carry struct page *s.  It will be up to
the users of the kiobufs to do anything further with them.  I already
have bounce buffer support for kiobufs in 2.2 (as a quick hack to let
highmem raw IO work on 2.2; 2.4 is much cleaner and doesn't need that
particular hack).  I'll make sure that 2.4 has a clean way of doing
bounce buffers too, probably by means of a clone_kiobuf() function
which creates a new kiobuf by cloning the pages of the original if
they satisfy some constraint (such as <1GB, <4GB), and
pre/post-copying them if they do not.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
