From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008161713.KAA54085@google.engr.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Wed, 16 Aug 2000 10:13:21 -0700 (PDT)
In-Reply-To: <399A4FE4.FA5C397A@augan.com> from "Roman Zippel" at Aug 16, 2000 10:25:08 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <roman@augan.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davem@redhat.com, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> > Excellent, this will make it _tons_ easier for me to create new zones
> > of mem_map arrays on the fly to allow us to create struct pages for
> > PCI IO-aperture memory (necessary for kiobuf mappings of IO memory).
> 
> A related question: do you already have an idea how the driver interface
> for that could look like? I mean, some drivers need a virtual address,
> some need the physical address for dma and some of them might need
> bounce buffers. E.g. I don't know how to get (quickly) from a page
> struct which represents an io mapping to the physical address. Will we
> add some generic funtions for this which can be used by drivers or even
> let the drivers only specify its requirements and the buffer code will
> generate an appropriate io request. I have a few ideas, but I don't know
> if already concrete plans exists.
> 
> bye, Roman
> 

FWIW, Linus was mildly suggesting I implement page_to_phys, to complement
virt_to_page. I didn't see an immediate need for it, so I just did the
bit I am interested in for now. If you look, most of the mk_pte() definitions
should actually use page_to_phys ...

Of course, I am talking about struct pages that represent memory, not io
devices, I don't think either one of us was thinking about that ...

I also thought about whether page_to_phys would be useful for drivers,
decided against it, since the PCI-DMA apis which are quite a standard
now want to go to the PCI bus addresses, instead of physical addresses.

BTW, I am not sure I understand when you say "some drivers need a virtual 
address, some need the physical address for dma and some of them might need
bounce buffers". I believe, the goal should be to pass in either a. struct
page or b. physical address, then the driver makes the PCI-DMA calls to 
determine whether it can dma directly into the page (or transparently 
get a page which it can dma into, and the PCI-DMA layer handles the 
bouncing completely). Passing in virtual addresses into drivers is not
good, if you think about the i386 class machines which can not direct 
map the entire memory (hence would need kmap addresses for high pages).

Finally, whether the drivers accept virtual addresses or struct pages, 
they should not be trying to interpret their input, rather treat the input
as opaque cookies, to be passed on to the PCI-DMA layer ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
