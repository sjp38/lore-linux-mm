From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008171907.MAA37675@google.engr.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Thu, 17 Aug 2000 12:07:12 -0700 (PDT)
In-Reply-To: <20000817101121.G4037@redhat.com> from "Stephen C. Tweedie" at Aug 17, 2000 10:11:21 AM
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
> On Wed, Aug 16, 2000 at 03:22:07PM -0700, Kanoj Sarcar wrote:
> 
> > > It's part of what is necessary if we want to push kiobufs into the
> > > driver layers.  page_to_pfn is needed to for PAE36 support so that
> > > PCI64 or dual-address-cycle drivers can handle physical addresses
> > > longer than 32 bits long.
> > 
> > While we are on this topic, something like
> > 
> > #define page_to_phys(page) \
> > 	((((page)-(page)->zone->zone_mem_map) << PAGE_SHIFT) \
> > 	+ ((page)->zone->zone_start_paddr))
> > 
> > should work on all platforms on 2.4. (You might have to add in an
> > unsigned long long somewhere in there for PAE36).
> 
> The long long is exactly what we need to avoid: PAE36 still has
> pointers as 32-bit values.  Only ptes get the 64-bit treatment.
> 
> Adding a BUG() test to detect illegal accesses to >4GB pages on PAE36
> would be fine.  If we have the appropriate bounce buffer support in
> place in pci_dma or wherever suits it, then by the time a driver is
> doing page_to_phys() it should already have created the appropriate
> bounce buffers and so the BUG() test is fine. 
> 
> For DAC/PCI64 drivers, though, we need a separate macro like
> page_to_pfn so that we can identify the physical address via a 32-bit

Or, use a 64 bit value to represent physical addresses. Which is why
I am proposing paddr_t. In that case,

#define page_to_phys(page)
	((((unsigned long long)((page)-(page)->zone->zone_mem_map)) \
	<< PAGE_SHIFT) + ((page)->zone->zone_start_paddr))

This would "work" (on i386) despite the fact that zone->zone_start_paddr is
"unsigned long" not "unsigned long long". 

Things would be much easier with paddr_t.

#define page_to_phys(page)
	((((paddr_t)((page)-(page)->zone->zone_mem_map)) \
	<< PAGE_SHIFT) + ((page)->zone->zone_start_paddr))

and we would change zone->zone_start_paddr to be paddr_t too.

> value.  The driver can then shift that into a 64-bit long long if it
> wants to --- there's no need to introduce new 64-bit macros into the
> mm just for this special case.

Whatever you do, you either have to introduce paddr_t (which to me seems
more intuitive) or page_to_pfn. We can argue one way or another, but 
paddr_t might give you type checking for free too ...

Kanoj

> 
> Cheers,
>  Stephen
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
