Date: Sun, 21 Apr 2002 12:12:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: your mail
Message-ID: <20020421191254.GJ23767@holomorphy.com>
References: <1019400841.10817.7.camel@voyager>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <1019400841.10817.7.camel@voyager>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raciel <raciel@x0und.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 21, 2002 at 02:54:00PM +0000, raciel wrote:
> Hello all :)
> 	I have been trying to understand the rmap patch from Rik Van Riel, but
> i dont undertand what the rmap patch do. Somebody can explain me or know
> a good site where i can get documentation?
> Regards Raciel 

The largest piece of functionality is additional accounting that enables
the kernel to find all users of a given page. This is known as physical
scanning, and other OS's call similar functionality "pmap", "ptov" (for
physical to virtual), and "HAT" (Hardware Address Translation), though
the interfaces are just as different as the names.

There are two very important translation mechanisms:
	(1) physical page to page table entry
	(2) 3rd-level pagetable to address space (mm_struct)

(1) is accomplished by using a singly linked list of page table entry
	addresses attached to a per-physical-page structure (struct page).

(2) is accomplished by reusing one of the fields of struct page for the
	3rd-level pagetable to hold the pointer to the mm_struct.


To clarify how a physical page is handled, the page replacement
algorithm might decide that a given physical page is targeted for
eviction. It then calls try_to_unmap(), which traverses the list of
3rd-level pagetable entries, and then rounds their addresses to
obtain the physical page occupied by the 3rd-level pagetable, then
it finds the struct page for that physical page, and then it tries
to obtain locks on the address space's pagetable lock and when it
does, it just removes the thing from the pagetable, otherwise it
returns an error code saying "try again later" (SWAP_AGAIN).

All this requires is

(1) putting an entry onto the per-page list when entering a page
	into pagetables

(2) pulling things off the per-page list when removing a page
	 from pagetables

(3) marking a 3rd-level pagetable's struct page with the mm_struct


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
