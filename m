From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008161847.LAA84163@google.engr.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Wed, 16 Aug 2000 11:47:49 -0700 (PDT)
In-Reply-To: <20000816192012.K19260@redhat.com> from "Stephen C. Tweedie" at Aug 16, 2000 07:20:12 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Roman Zippel <roman@augan.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davem@redhat.com, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Wed, Aug 16, 2000 at 10:13:21AM -0700, Kanoj Sarcar wrote:
> > 
> > FWIW, Linus was mildly suggesting I implement page_to_phys, to complement
> > virt_to_page.
> 
> It's part of what is necessary if we want to push kiobufs into the
> driver layers.  page_to_pfn is needed to for PAE36 support so that
> PCI64 or dual-address-cycle drivers can handle physical addresses
> longer than 32 bits long.
> 
> > BTW, I am not sure I understand when you say "some drivers need a virtual 
> > address, some need the physical address for dma and some of them might need
> > bounce buffers". I believe, the goal should be to pass in either a. struct
> > page or b. physical address
> 
> Yes, but different drivers have different requirements on those struct
> page *s.  Drivers which do programmed IO need to be able to turn the
> page into a kernel virtual address.  Drivers which can access >32-bit
> addresses need to turn the page into an index which fits inside 32
> bits.  Drivers which do DMA but only to <4GB addresses need bounce
> buffers.
> 
> That is irrelevant as far as the kiobuf data structure is concerned,
> but it is very important for the internals of the drivers, so this
> sort of functionality must be made available for drivers to use
> internally as needed.
> 
> Cheers, 
>  Stephen
> 

It might be easier all around if we could all agree to what drivers
need to do. As David Miller points out, whether a driver can dma into
>32-bit addresses etc is also a function of the architecture, so this
is best hidden under per architecture PCI-DMA layer. So, if the driver 
writer codes according to this, he will transparently get the best 
performance for any architecure ...

I guess finally, drivers will either get one or a list of

1. struct page or
2. pfn or
3. paddr_t (unsigned long long on PAE36, unsigned long on other platforms)

The PCI-DMA layer should be able to handle this type of input. The driver
must not attempt to convert this to PCI bus addresses. The driver must call
an arcitecture hook, like kmap(), to get a kernel virtual address for
the underlying page. It should be able to do without needing the physical
address of the page, the PCI-DMA routines will know how to do that.

kiobufs might need to get some hooks into PCI-DMA, but shouldn't this
suffice, mostly? Or is this being too restrictive for some drivers?

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
