From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/8] Sparsemem Virtual Memmap V4
Message-ID: <exportbomb.1179873917@pinky>
Date: Tue, 22 May 2007 23:57:55 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Following this email is the current state of the Sparsemem Virtual
Memory Map support (description below).  This update represents
fixes from testing as well as style checks plus changes based on
review feedback.  The major changes are the generic initialisation
has been overhauled (the PMD initialisation was very x86 centric),
configuration selection now works properly without SPARSEMEM, and
preliminary PPC64 support has been added.  Changelog is at the end
of this email.

Still to sort out:

 - ia64 support needs finalising (there are two implementations here)
 - PPC64 needs review
 - s390 support
 - HOTPLUG review and regression testing

It is worth noting that the ia64 support exposes an essentially
private Kconfig option to allow selection of the two implementations.
Once the 16Mb support is complete it should become the one and only
implementation and that this option would no longer be exposed.

This PPC64 implementation is all new.  It slices a chunk (1/16th)
off the end of the kernel linear space to hold the vmemmap.  Need
to make sure that this location makes sense.

I do not have performance data on this round of patches yet, but
measurements on the initial PPC64 implementation showed a small
but measurable improvement.

This stack is against v2.6.22-rc1-mm1.  It has been compile, boot
and lightly tested on x86_64, ia64 and PPC64.  Sparc64 as been
compiled but not booted.

-apw

===
SPARSEMEM is a pretty nice framework that unifies quite a bit of
code over all the arches. It would be great if it could be the
default so that we can get rid of various forms of DISCONTIG and
other variations on memory maps. So far what has hindered this are
the additional lookups that SPARSEMEM introduces for virt_to_page
and page_address. This goes so far that the code to do this has to
be kept in a separate function and cannot be used inline.

This patch introduces a virtual memmap mode for SPARSEMEM, in which
the memmap is mapped into a virtually contigious area, only the
active sections are physically backed.  This allows virt_to_page
page_address and cohorts become simple shift/add operations.
No page flag fields, no table lookups, nothing involving memory
is required.

The two key operations pfn_to_page and page_to_page become:

   #define __pfn_to_page(pfn)      (vmemmap + (pfn))
   #define __page_to_pfn(page)     ((page) - vmemmap)

By having a virtual mapping for the memmap we allow simple access
without wasting physical memory.  As kernel memory is typically
already mapped 1:1 this introduces no additional overhead.
The virtual mapping must be big enough to allow a struct page to
be allocated and mapped for all valid physical pages.  This vill
make a virtual memmap difficult to use on 32 bit platforms that
support 36 address bits.

However, if there is enough virtual space available and the arch
already maps its 1-1 kernel space using TLBs (f.e. true of IA64
and x86_64) then this technique makes SPARSEMEM lookups even more
efficient than CONFIG_FLATMEM.  FLATMEM needs to read the contents
of the mem_map variable to get the start of the memmap and then add
the offset to the required entry.  vmemmap is a constant to which
we can simply add the offset.

This patch has the potential to allow us to make SPARSMEM the default
(and even the only) option for most systems.  It should be optimal
on UP, SMP and NUMA on most platforms.  Then we may even be able
to remove the other memory models: FLATMEM, DISCONTIG etc.

V3->V4
 - SPARC64 support -- from Dave Miller
 - PPC64 support -- from Andy Whitcroft
 - sparsemem precense/valid split
 - rename Kconfig options into SPARSEMEM configuration name space
 - redundant vmemmap alignment removed
 - split out PMD support to x86_64
 - x86_64 Kconfig dependancies
 - ia64 Kconfig dependancies
 - sparc64 dependancies, cleanup defines
 - cleanup function names _pop_ -> _populate_
 - markup __meminit
 - cleanup style
 - whitespace cleanups

V2->V3
 - Add IA64 16M vmemmap size support (reduces TLB pressure)
 - Add function to test for eventual node/node vmemmap overlaps
 - Upper / Lower boundary fix.

V1->V2
 - Support for PAGE_SIZE vmemmap which allows the general use of
   of virtual memmap on any MMU capable platform (enabled IA64
   support).
 - Fix various issues as suggested by Dave Hansen.
 - Add comments and error handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
