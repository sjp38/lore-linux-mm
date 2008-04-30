Message-Id: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:42:51 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [00/11] Virtualizable Compound Page Support V5
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Allocations of larger pages are not reliable in Linux. If larger
pages have to be allocated then one faces various choices of allowing
graceful fallback or using vmalloc with a performance penalty due
to the use of a page table. Virtualizable Compound Pages are
a simple solution out of this dilemma.

A virtualizable compound allocation means that there will be first
an attempt to satisfy the request with physically contiguous memory
through a traditional compound page. If that is not possible then
virtually contiguous memory will be used for the page.

This has two advantages:

1. Current uses of vmalloc can be converted to request for virtualizable
   compounds instead. In most cases physically contiguous memory can be
   used which avoids the vmalloc performance penalty. See f.e. the
   e1000 driver patch.

2. Uses of higher order allocations (stacks, buffers etc) can be
   converted to use virtualizable compounds instead. Physically contiguous
   memory will still be used for those higher order allocs in general
   but the system can degrade to the use of vmalloc should memory
   become heavily fragmented.

There is a compile time option to switch on fallback for
testing purposes. Virtually mapped memory may behave differently
and the CONFIG_VIRTUALIZE_ALWAYS option can be used ensure that the code is
tested to deal with virtualized compound page.

This patchset contains first of all the core pieces to make virtualizable
compound pages possible and then a set of example uses of virtualizable
compound pages.

V4->V5
- Cleanup various portions
- Simplify code
- Complete documentation
- Limit the number of example uses.

V3->V4:
- Drop fallback for IA64 stack (arches with software tlb handlers
  could get into deep trouble if a tlb needs to be installed
  for the stack that is needed by the tlb fault handler).
- Drop ehash_lock vcompound patch.

V2->V3:
- Put the code into mm/vmalloc.c and leave the page allocator alone.
- Add a series of examples where virtual compound pages can be used.
- Diffed on top of the page flags and the vmalloc info patches
  already in mm.
- Simplify things by omitting some of the more complex code
  that used to be in there.

V1->V2
- Remove some cleanup patches and the SLUB patches from this set.
- Transparent vcompound support through page_address() and
  virt_to_head_page().
- Additional use cases.
- Factor the code better for an easier read
- Add configurable stack size.
- Follow up on various suggestions made for V1

RFC->V1
- Complete support for all compound functions for virtual compound pages
  (including the compound_nth_page() necessary for LBS mmap support)
- Fix various bugs
- Fix i386 build

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
