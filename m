From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14281.20264.576540.243956@dukat.scot.redhat.com>
Date: Sun, 29 Aug 1999 16:18:00 +0100 (BST)
Subject: Re: question on remap_page_range()
In-Reply-To: <199908281003.MAA29351@zange.cs.tu-berlin.de>
References: <199908281003.MAA29351@zange.cs.tu-berlin.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gilles Pokam <pokam@cs.tu-berlin.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 28 Aug 1999 12:03:41 +0200 (MET DST), Gilles Pokam
<pokam@cs.tu-berlin.de> said:

> I have some questions about the behavior of the remap_page_range function as 
> well as the ioremap. 

> 1. remap_page_range (as well as ioremap or vremap) takes a "physical address"
>    as argument. 

Yes.

>    In Rubini's book it is said that the so-called "physical
>    address" is in reality a virtual address offset by PAGE_OFFSET from the 
>    real physical address:

No.  Either Rubini is wrong or you have misinterpreted.  A physical
address is just that --- the physical address of the memory as it
appears on the cpu bus when the cpu goes to read from ram.  It is
completely untranslated.  The first physical address in the system is
usually zero, not PAGE_OFFSET.  

> 	phys = real_phys + PAGE_OFFSET 

No, phys == real_phys.  The *virtual* address is real_phys +
PAGE_OFFSET.  You can convert between the two using phys_to_virt() and
virt_to_phys().

>    In x86 2.0.x kernel i had no problems with this convertion because the
>    PAGE_OFFSET is almost defined to be 0, so that phys = virt address.

That is because 2.0 hid the physical/virtual translation behind a layer
of i386 segmentation tricks.

> 2. But now i have tried to run my code on a x86 2.2.x kernel and the 
>    remap_page_range function fails! When i ignore the PAGE_OFFSET macro
>    it works strangely ...! 

Yes.  remap_page_range is designed to remap real, honest physical
addresses.  These addresses have no translation applied:
remap_page_range is supposed to be able to work even if applied to some
physical address that is outside the normal kernel virtual address
translation pages (eg. video framebuffers).

>   My question is, what is the definition of the physical address in the
>   remap_page_range and vremap functions ?

Physical == physical.  There's nothing fancy going on.  Only when you
start using virtual addresses do the numbers change.

Read linux/Documentation/IO-mapping.txt for all the gory details.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
