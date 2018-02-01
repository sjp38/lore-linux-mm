Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 504906B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 13:19:39 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id c188so4005126ith.7
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 10:19:39 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id v12si381928iti.125.2018.02.01.10.19.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 10:19:37 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v11 00/10] Application Data Integrity feature introduced by SPARC M7
Date: Thu,  1 Feb 2018 11:01:08 -0700
Message-Id: <cover.1517497017.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net, dave.hansen@linux.intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, aarcange@redhat.com, akpm@linux-foundation.org, allen.pais@oracle.com, anthony.yznaga@oracle.com, arnd@arndb.de, babu.moger@oracle.com, benh@kernel.crashing.org, bob.picco@oracle.com, bsingharora@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, dave.jiang@intel.com, david.j.aldridge@oracle.com, ebiederm@xmission.com, elena.reshetova@intel.com, glx@linutronix.de, gregkh@linuxfoundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, hpa@zytor.com, hughd@google.com, imbrenda@linux.vnet.ibm.com, jack@suse.cz, jag.raman@oracle.com, jane.chu@oracle.com, jglisse@redhat.com, jroedel@suse.de, khalid@gonehiking.org, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, kstewart@linuxfoundation.org, ktkhai@virtuozzo.com, liam.merwick@oracle.com, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux@roeck-us.net, me@tobin.cc, mgorman@suse.de, mgorman@techsingularity.net, mhocko@suse.com, mike.kravetz@oracle.com, minchan@kernel.org, mingo@kernel.org, mingo@redhat.com, mpe@ellerman.id.au, nadav.amit@gmail.com, nagarathnam.muthusamy@oracle.com, nborisov@suse.com, n-horiguchi@ah.jp.nec.com, nick.alcock@oracle.com, nitin.m.gupta@oracle.com, ombredanne@nexb.com, pasha.tatashin@oracle.com, paulus@samba.org, pombredanne@nexb.com, punit.agrawal@arm.com, rob.gardner@oracle.com, ross.zwisler@linux.intel.com, shannon.nelson@oracle.com, shli@fb.com, sparclinux@vger.kernel.org, steven.sistare@oracle.com, tglx@linutronix.de, thomas.tai@oracle.com, tklauser@distanz.ch, tom.hromatka@oracle.com, vegard.nossum@oracle.com, vijay.ac.kumar@oracle.com, willy@infradead.org, x86@kernel.org, zi.yan@cs.rutgers.edu

V11 changes:
This series is same as v10 and was simply rebased on 4.15 kernel. Can
mm maintainers please review patches 2, 7, 8 and 9 which are arch
independent, and include/linux/mm.h and mm/ksm.c changes in patch 10
and ack these if everything looks good? 


SPARC M7 processor adds additional metadata for memory address space
that can be used to secure access to regions of memory. This additional
metadata is implemented as a 4-bit tag attached to each cacheline size
block of memory. A task can set a tag on any number of such blocks.
Access to such block is granted only if the virtual address used to
access that block of memory has the tag encoded in the uppermost 4 bits
of VA. Since sparc processor does not implement all 64 bits of VA, top 4
bits are available for ADI tags. Any mismatch between tag encoded in VA
and tag set on the memory block results in a trap. Tags are verified in
the VA presented to the MMU and tags are associated with the physical
page VA maps on to. If a memory page is swapped out and page frame gets
reused for another task, the tags are lost and hence must be saved when
swapping or migrating the page.

A userspace task enables ADI through mprotect(). This patch series adds
a page protection bit PROT_ADI and a corresponding VMA flag
VM_SPARC_ADI. VM_SPARC_ADI is used to trigger setting TTE.mcd bit in the
sparc pte that enables ADI checking on the corresponding page. MMU
validates the tag embedded in VA for every page that has TTE.mcd bit set
in its pte. After enabling ADI on a memory range, the userspace task can
set ADI version tags using stxa instruction with ASI_MCD_PRIMARY or
ASI_MCD_ST_BLKINIT_PRIMARY ASI.

Once userspace task calls mprotect() with PROT_ADI, kernel takes
following overall steps:

1. Find the VMAs covering the address range passed in to mprotect and
set VM_SPARC_ADI flag. If address range covers a subset of a VMA, the
VMA will be split.

2. When a page is allocated for a VA and the VMA covering this VA has
VM_SPARC_ADI flag set, set the TTE.mcd bit so MMU will check the
vwersion tag.

3. Userspace can now set version tags on the memory it has enabled ADI
on. Userspace accesses ADI enabled memory using a virtual address that
has the version tag embedded in the high bits. MMU validates this
version tag against the actual tag set on the memory. If tag matches,
MMU performs the VA->PA translation and access is granted. If there is a
mismatch, hypervisor sends a data access exception or precise memory
corruption detected exception depending upon whether precise exceptions
are enabled or not (controlled by MCDPERR register). Kernel sends
SIGSEGV to the task with appropriate si_code.

4. If a page is being swapped out or migrated, kernel must save any ADI
tags set on the page. Kernel maintains a page worth of tag storage
descriptors. Each descriptors pointsto a tag storage space and the
address range it covers. If the page being swapped out or migrated has
ADI enabled on it, kernel finds a tag storage descriptor that covers the
address range for the page or allocates a new descriptor if none of the
existing descriptors cover the address range. Kernel saves tags from the
page into the tag storage space descriptor points to.

5. When the page is swapped back in or reinstantiated after migration,
kernel restores the version tags on the new physical page by retrieving
the original tag from tag storage pointed to by a tag storage descriptor
for the virtual address range for new page.

User task can disable ADI by calling mprotect() again on the memory
range with PROT_ADI bit unset. Kernel clears the VM_SPARC_ADI flag in
VMAs, merges adjacent VMAs if necessary, and clears TTE.mcd bit in the
corresponding ptes.

IOMMU does not support ADI checking. Any version tags embedded in the
top bits of VA meant for IOMMU, are cleared and replaced with sign
extension of the first non-version tag bit (bit 59 for SPARC M7) for
IOMMU addresses.

This patch series adds support for this feature in 10 patches:

Patch 1/10
  Tag mismatch on access by a task results in a trap from hypervisor as
  data access exception or a precide memory corruption detected
  exception. As part of handling these exceptions, kernel sends a
  SIGSEGV to user process with special si_code to indicate which fault
  occurred. This patch adds three new si_codes to differentiate between
  various mismatch errors.

Patch 2/10
  When a page is swapped or migrated, metadata associated with the page
  must be saved so it can be restored later. This patch adds a new
  function that saves/restores this metadata when updating pte upon a
  swap/migration.

Patch 3/10
  SPARC M7 processor adds new fields to control registers to support ADI
  feature. It also adds a new exception for precise traps on tag
  mismatch. This patch adds definitions for the new control register
  fields, new ASIs for ADI and an exception handler for the precise trap
  on tag mismatch.

Patch 4/10
  New hypervisor fault types were added by sparc M7 processor to support
  ADI feature. This patch adds code to handle these fault types for data
  access exception handler.

Patch 5/10
  When ADI is in use for a page and a tag mismatch occurs, processor
  raises "Memory corruption Detected" trap. This patch adds a handler
  for this trap.

Patch 6/10
  ADI usage is governed by ADI properties on a platform. These
  properties are provided to kernel by firmware. Thsi patch adds new
  auxiliary vectors that provide these values to userpsace.

Patch 7/10
  arch_validate_prot() is used to validate the new protection bits asked
  for by the userspace app. Validating protection bits may need the
  context of address space the bits are being applied to. One such
  example is PROT_ADI bit on sparc processor that enables ADI protection
  on an address range. ADI protection applies only to addresses covered
  by physical RAM and not other PFN mapped addresses or device
  addresses. This patch adds "address" to the parameters being passed to
  arch_validate_prot() to provide that context.

Patch 8/10
  When protection bits are changed on a page, kernel carries forward all
  protection bits except for read/write/exec. Additional code was added
  to allow kernel to clear PKEY bits on x86 but this requirement to
  clear other bits is not unique to x86. This patch extends the existing
  code to allow other architectures to clear any other protection bits
  as well on protection bit change.

Patch 9/10
  When a processor supports additional metadata on memory pages, that
  additional metadata needs to be copied to new memory pages when those
  pages are moved. This patch allows architecture specific code to
  replace the default copy_highpage() routine with arch specific
  version that copies the metadata as well besides the data on the page.

Patch 10/10
  This patch adds support for a user space task to enable ADI and enable
  tag checking for subsets of its address space. As part of enabling
  this feature, this patch adds to support manipulation of precise
  exception for memory corruption detection, adds code to save and
  restore tags on page swap and migration, and adds code to handle ADI
  tagged addresses for DMA.


Changelog v11:

	- Rebased to 4.15

Changelog v10:

	- Patch 1/10: Updated si_codes definitions for SEGV to match 4.14
	- Patch 2/10: No changes
	- Patch 3/10: Updated copyright
	- Patch 4/10: No changes
	- Patch 5/10: No changes
	- Patch 6/10: Updated copyright
	- Patch 7/10: No changes
	- Patch 8/10: No changes
	- Patch 9/10: No changes
	- Patch 10/10: Added code to return from kernel path to set
	  PSTATE.mcde if kernel continues execution in another thread
	  (Suggested by Anthony)

Changelog v9:

	- Patch 1/10: No changes
	- Patch 2/10: No changes
	- Patch 3/10: No changes
	- Patch 4/10: No changes
	- Patch 5/10: No changes
	- Patch 6/10: No changes
	- Patch 7/10: No changes
	- Patch 8/10: No changes
	- Patch 9/10: New patch
	- Patch 10/10: Patch 9 from v8. Added code to copy ADI tags when
	  pages are migrated. Updated code to detect overflow and underflow
	  of addresses when allocating tag storage.

Changelog v8:

	- Patch 1/9: No changes
	- Patch 2/9: Fixed and erroneous "}"
	- Patch 3/9: Minor print formatting change
	- Patch 4/9: No changes
	- Patch 5/9: No changes
	- Patch 6/9: Added AT_ADI_UEONADI back
	- Patch 7/9: Added addr parameter to powerpc arch_validate_prot()
	- Patch 8/9: No changes
	- Patch 9/9:
		- Documentation updates
		- Added an IPI on mprotect(...PROT_ADI...) call and
		  restore of TSTATE.MCDE on context switch
		- Removed restriction on enabling ADI on read-only
		  memory
		- Changed kzalloc() for tag storage to use GFP_NOWAIT
		- Added code to handle overflow and underflow when
		  allocating tag storage
		- Replaced sun_m7_patch_1insn_range() with
		  sun4v_patch_1insn_range()
		- Added membar after restoring ADI tags in
		  copy_user_highpage()

Changelog v7:

	- Patch 1/9: No changes
	- Patch 2/9: Updated parameters to arch specific swap in/out
	  handlers
	- Patch 3/9: No changes
	- Patch 4/9: new patch split off from patch 4/4 in v6
	- Patch 5/9: new patch split off from patch 4/4 in v6
	- Patch 6/9: new patch split off from patch 4/4 in v6
	- Patch 7/9: new patch
	- Patch 8/9: new patch
	- Patch 9/9:
		- Enhanced arch_validate_prot() to enable ADI only on
		  writable addresses backed by physical RAM
		- Added support for saving/restoring ADI tags for each
		  ADI block size address range on a page on swap in/out
		- copy ADI tags on COW
		- Updated values for auxiliary vectors to not conflict
		  with values on other architectures to avoid conflict
		  in glibc
		- Disable same page merging on ADI enabled pages
		- Enable ADI only on writable addresses backed by
		  physical RAM
		- Split parts of patch off into separate patches

Changelog v6:
	- Patch 1/4: No changes
	- Patch 2/4: No changes
	- Patch 3/4: Added missing nop in the delay slot in
	  sun4v_mcd_detect_precise
	- Patch 4/4: Eliminated instructions to read and write PSTATE
	  as well as MCDPER and PMCDPER on every access to userspace
	  addresses by setting PSTATE and PMCDPER correctly upon entry
	  into kernel

Changelog v5:
	- Patch 1/4: No changes
	- Patch 2/4: Replaced set_swp_pte_at() with new architecture
	  functions arch_do_swap_page() and arch_unmap_one() that
	  suppoprt architecture specific actions to be taken on page
	  swap and migration
	- Patch 3/4: Fixed indentation issues in assembly code
	- Patch 4/4:
		- Fixed indentation issues and instrcuctions in assembly
		  code
		- Removed CONFIG_SPARC64 from mdesc.c
		- Changed to maintain state of MCDPER register in thread
		  info flags as opposed to in mm context. MCDPER is a
		  per-thread state and belongs in thread info flag as
		  opposed to mm context which is shared across threads.
		  Added comments to clarify this is a lazily maintained
		  state and must be updated on context switch and
		  copy_process() 
		- Updated code to use the new arch_do_swap_page() and
		  arch_unmap_one() functions

Testing:

- All functionality was tested with 8K normal pages as well as hugepages
  using malloc, mmap and shm.
- Multiple long duration stress tests were run using hugepages over 2+
  months. Normal pages were tested with shorter duration stress tests.
- Tested swapping with malloc and shm by reducing max memory and
  allocating three times the available system memory by active processes
  using ADI on allocated memory. Ran through multiple hours long runs of
  this test.
- Tested page migration with malloc and shm by migrating data pages of
  active ADI test process using migratepages, back and forth between two
  nodes every few seconds over an hour long run. Verified page migration
  through /proc/<pid>/numa_maps.
- Tested COW support using test that forks children that read from
  ADI enabled pages shared with parent and other children and write to
  them as well forcing COW.


---------

Khalid Aziz (10):
  signals, sparc: Add signal codes for ADI violations
  mm, swap: Add infrastructure for saving page metadata on swap
  sparc64: Add support for ADI register fields, ASIs and traps
  sparc64: Add HV fault type handlers for ADI related faults
  sparc64: Add handler for "Memory Corruption Detected" trap
  sparc64: Add auxiliary vectors to report platform ADI properties
  mm: Add address parameter to arch_validate_prot()
  mm: Clear arch specific VM flags on protection change
  mm: Allow arch code to override copy_highpage()
  sparc64: Add support for ADI (Application Data Integrity)

 Documentation/sparc/adi.txt             | 278 ++++++++++++++++++++++
 arch/powerpc/include/asm/mman.h         |   4 +-
 arch/powerpc/kernel/syscalls.c          |   2 +-
 arch/sparc/include/asm/adi.h            |   6 +
 arch/sparc/include/asm/adi_64.h         |  47 ++++
 arch/sparc/include/asm/elf_64.h         |   5 +
 arch/sparc/include/asm/hypervisor.h     |   2 +
 arch/sparc/include/asm/mman.h           |  84 ++++++-
 arch/sparc/include/asm/mmu_64.h         |  17 ++
 arch/sparc/include/asm/mmu_context_64.h |  50 ++++
 arch/sparc/include/asm/page_64.h        |   6 +
 arch/sparc/include/asm/pgtable_64.h     |  48 ++++
 arch/sparc/include/asm/thread_info_64.h |   2 +-
 arch/sparc/include/asm/trap_block.h     |   2 +
 arch/sparc/include/asm/ttable.h         |  10 +
 arch/sparc/include/uapi/asm/asi.h       |   5 +
 arch/sparc/include/uapi/asm/auxvec.h    |  11 +
 arch/sparc/include/uapi/asm/mman.h      |   2 +
 arch/sparc/include/uapi/asm/pstate.h    |  10 +
 arch/sparc/kernel/Makefile              |   1 +
 arch/sparc/kernel/adi_64.c              | 397 ++++++++++++++++++++++++++++++++
 arch/sparc/kernel/entry.h               |   3 +
 arch/sparc/kernel/etrap_64.S            |  27 ++-
 arch/sparc/kernel/head_64.S             |   1 +
 arch/sparc/kernel/mdesc.c               |   2 +
 arch/sparc/kernel/process_64.c          |  25 ++
 arch/sparc/kernel/rtrap_64.S            |  33 ++-
 arch/sparc/kernel/setup_64.c            |   2 +
 arch/sparc/kernel/sun4v_mcd.S           |  18 ++
 arch/sparc/kernel/traps_64.c            | 142 +++++++++++-
 arch/sparc/kernel/ttable_64.S           |   6 +-
 arch/sparc/kernel/urtt_fill.S           |   7 +-
 arch/sparc/kernel/vmlinux.lds.S         |   5 +
 arch/sparc/mm/gup.c                     |  37 +++
 arch/sparc/mm/hugetlbpage.c             |  14 +-
 arch/sparc/mm/init_64.c                 |  69 ++++++
 arch/sparc/mm/tsb.c                     |  21 ++
 arch/x86/kernel/signal_compat.c         |   2 +-
 include/asm-generic/pgtable.h           |  36 +++
 include/linux/highmem.h                 |   4 +
 include/linux/mm.h                      |   9 +
 include/linux/mman.h                    |   2 +-
 include/uapi/asm-generic/siginfo.h      |   5 +-
 mm/ksm.c                                |   4 +
 mm/memory.c                             |   1 +
 mm/mprotect.c                           |   4 +-
 mm/rmap.c                               |  14 ++
 47 files changed, 1461 insertions(+), 21 deletions(-)
 create mode 100644 Documentation/sparc/adi.txt
 create mode 100644 arch/sparc/include/asm/adi.h
 create mode 100644 arch/sparc/include/asm/adi_64.h
 create mode 100644 arch/sparc/kernel/adi_64.c
 create mode 100644 arch/sparc/kernel/sun4v_mcd.S

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
