Message-Id: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:03 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [00/14] Virtual Compound Page Support V3
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Allocations of larger pages are not reliable in Linux. If larger
pages have to be allocated then one faces various choices of allowing
graceful fallback or using vmalloc with a performance penalty due
to the use of a page table. Virtual Compound pages are
a simple solution out of this dilemma.

A virtual compound allocation means that there will be first of all
an attempt to satisfy the request with physically contiguous memory.
If that is not possible then a virtually contiguous memory will be
created.

This has two advantages:

1. Current uses of vmalloc can be converted to allocate virtual
   compounds instead. In most cases physically contiguous
   memory can be used which avoids the vmalloc performance
   penalty. See f.e. the e1000 driver patch.

2. Uses of higher order allocations (stacks, buffers etc) can be
   converted to use virtual compounds instead. Physically contiguous
   memory will still be used for those higher order allocs in general
   but the system can degrade to the use of vmalloc should memory
   become heavily fragmented.

There is a compile time option to switch on fallback for
testing purposes. Virtually mapped mmemory may behave differently
and the CONFIG_FALLBACK_ALWAYS option will ensure that the code is
tested to deal with virtual memory.

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
