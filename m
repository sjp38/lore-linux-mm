Date: Wed, 16 Aug 2000 19:20:12 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Message-ID: <20000816192012.K19260@redhat.com>
References: <399A4FE4.FA5C397A@augan.com> <200008161713.KAA54085@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200008161713.KAA54085@google.engr.sgi.com>; from kanoj@google.engr.sgi.com on Wed, Aug 16, 2000 at 10:13:21AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Roman Zippel <roman@augan.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davem@redhat.com, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Aug 16, 2000 at 10:13:21AM -0700, Kanoj Sarcar wrote:
> 
> FWIW, Linus was mildly suggesting I implement page_to_phys, to complement
> virt_to_page.

It's part of what is necessary if we want to push kiobufs into the
driver layers.  page_to_pfn is needed to for PAE36 support so that
PCI64 or dual-address-cycle drivers can handle physical addresses
longer than 32 bits long.

> BTW, I am not sure I understand when you say "some drivers need a virtual 
> address, some need the physical address for dma and some of them might need
> bounce buffers". I believe, the goal should be to pass in either a. struct
> page or b. physical address

Yes, but different drivers have different requirements on those struct
page *s.  Drivers which do programmed IO need to be able to turn the
page into a kernel virtual address.  Drivers which can access >32-bit
addresses need to turn the page into an index which fits inside 32
bits.  Drivers which do DMA but only to <4GB addresses need bounce
buffers.

That is irrelevant as far as the kiobuf data structure is concerned,
but it is very important for the internals of the drivers, so this
sort of functionality must be made available for drivers to use
internally as needed.

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
