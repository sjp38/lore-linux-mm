Message-Id: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:35 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [00/18] Virtual Compound Page Support V2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Allocations of larger pages are not reliable in Linux. If larger
pages have to be allocated then one faces various choices of allowing
graceful fallback or using vmalloc with a performance penalty due
to the use of a page table. Virtual Compound pages are
a simple solution out of this dilemma. If an allocation specifies
GFP_VFALLBACK then the page allocator will first attempt to satisfy
the request with physically contiguous memory. If that is not possible
then the page allocator will create a virtually contiguous memory
area for the caller. That way large allocations may perhaps be
considered "reliable" indepedent of the memory fragmentation situation.

This means that memory with optimal performance is used when available.
We are currently gradually introducing methods to reduce memory
defragmentation. The better these methods become the less the
chances that fallback will occur.

Fallback is rare in particular on machines with contemporary memory
sizes of 1G or more. It seems to take special load situations that
pin a lot of memory and systems with low memory in order to get
system memory so fragmented that the fallback scheme must kick in.

There is therefore a compile time option to switch on fallback for
testing purposes. Virtually mapped mmemory may behave differently
and the CONFIG_FALLBACK_ALWAYS option will insure that the code is
tested to deal with virtual memory.

The patchset then addresses a series of issues in the current code
through the use of fallbacks:

- Fallback for x86_64 stack allocations. The default stack size
  is 8k which requires an order 1 allocation.

- Removes the manual fallback to vmalloc for sparsemem
  through the use of GFP_VFALLBACK.

- Uses a compound page for the wait table in the zone thereby
  avoiding having to go through a page table to get to the
  data structures used for waiting on events in pages.

- Allows fallback for the order 2 allocation in the crypto
  subsystem.

- Allows fallback for the caller table used by SLUB when determining
  the call sites for slab caches for sysfs output.

- Allows a configurable stack size on x86_64 (up to 32k).

More uses are possible by simply adding GFP_VFALLBACK to the page
flags or by converting vmalloc calls to regular page allocator calls.

It is likely that we have had to avoid the use of larger memory areas
because of the reliability issues. The patch may simplify future coding
of handling large memoryh areas because these issues are taken care of
by the page allocator. For HPC uses we constantly have to deal with
demands for larger and larger memory areas to speed up various loads.

Additional patches exist to enable SLUB and the Large Blocksize Patchset
to use these fallbacks.

The patchset is also available via git from the largeblock git tree via

git pull
  git://git.kernel.org/pub/scm/linux/kernel/git/christoph/largeblocksize.git
    vcompound

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
