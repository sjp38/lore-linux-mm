From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14283.46406.589808.626933@dukat.scot.redhat.com>
Date: Tue, 31 Aug 1999 11:58:14 +0100 (BST)
Subject: Re: question on remap_page_range()
In-Reply-To: <Pine.SOL.4.10.9908311000590.16664-100000@elf>
References: <14281.20264.576540.243956@dukat.scot.redhat.com>
	<Pine.SOL.4.10.9908311000590.16664-100000@elf>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gilles Pokam <pokam@cs.tu-berlin.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 31 Aug 1999 10:23:37 +0200 (MET DST), Gilles Pokam
<pokam@cs.tu-berlin.de> said:

>> No.  Either Rubini is wrong or you have misinterpreted.  A physical
>> address is just that --- the physical address of the memory as it
>> appears on the cpu bus when the cpu goes to read from ram.  It is
>> completely untranslated.  The first physical address in the system is
>> usually zero, not PAGE_OFFSET.  

> Sorry, i forget to said "from the kernel point of vue" :

> Rubini's book, page 274 about PAGE_OFFSET:

> " (...) PAGE_OFFSET must be considered whenever "physical" addresses are
> used. What the kernel considers to be a physical address is actually a
> virtual address, offset by PAGE_OFFSET from the real physical
> address.(..)"

That is wrong.  A physical address is a physical address is a physical
address.  Even from the kernel's point of view.  We need to know
physical addresses when we are setting up page tables, for example, and
these do NOT have a PAGE_OFFSET applied.  Ever.

However, the kernel cannot directly access the contents of a physical
address in memory: all memory accesses, without exception, go through
virtual address translation, and _that_ is where PAGE_OFFSET comes in.

Physical addresses do not, ever, include the PAGE_OFFSET bias.

It would be true to say that "What the kernel uses to *access* a
physicall address is actually a virtual address, offset by PAGE_OFFSET
from the real physical addres."  However, the kernel still calls that
latter, offset address a virtual address, not a physical address.  It's
a kernel virtual address as opposed to a user virtual address, but it is
still virtual, not physical.

> About remap_page_range Rubini said: (page 280-281)
> " remap_page_range(unsigned long virt_addr,unsigned long phys_add,
> 	          unsigned log size,pgprot_t prot);
>  unsigned long phys_add:
>     The phyical address to which the virtual address should be mapped. The
>     address is physical in the sense outline above" (in PAGE_OFFSET)

That is nonsense, the physaddr in remap_page_range does not include
PAGE_OFFSET bias.  It makes no sense at all for it to do so.

> To map to user space a region of memory beginning at physical address
> simple_region_start with size = simple_region_size he used the following
> example:
> unsigned long physical = simple_region_start + off + PAGE_OFFSET

That will work on 2.0, but only because PAGE_OFFSET is zero.  It won't
work on 2.2.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
