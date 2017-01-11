Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81CF16B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:14:30 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id x2so165372446itf.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:14:30 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x69si15909353ite.19.2017.01.11.08.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 08:14:29 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v4 0/4] Application Data Integrity feature introduced by SPARC M7
Date: Wed, 11 Jan 2017 09:12:50 -0700
Message-Id: <cover.1483999591.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: Khalid Aziz <khalid.aziz@oracle.com>, hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, dave.hansen@linux.intel.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

SPARC M7 processor adds additional metadata for memory address space
that can be used to secure access to regions of memory. This additional
metadata is implemented as a 4-bit tag attached to each cacheline size
block of memory. A task can set a tag on any number of such blocks.
Access to such block is granted only if the virtual address used to
access that block of memory has the tag encoded in the uppermost 4 bits
of VA. Any mismatch between tag encoded in VA and tag set on the memory
block results in a trap. Tags are verified in the VA presented to the
MMU and tags are associated with the physical page VA maps on to. If a
memory page is swapped out and page frame gets reused for another task,
the tags are lost and hence must be saved when swapping or migrating the
page.

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
MMU performs the VA->PA translation and access is granted. If there is
a mismatch, hypervisor sends a data access exception or precise memory
corruption detected exception depending upon whether precise exceptions
are enabled or not (controlled by MCDPERR register). Kernel sends
SIGSEGV to the task with appropriate si_code.

4. If a page is being swapped out or migrated, kernel builds a swap pte
for the page. If the page is ADI enabled and has version tags set on it,
set_swp_pte_at() function introduced by this patch series allows kernel
to save the version tags. set_swp_pte_at() replaces the calls to
set_pte_at() in functions that unmap and map a page. On architectures
that do not require special handling on a page being swapped,
set_swp_pte_at() defaults to set_pte_at(). In this initial
implementation, kernel supports saving one version tag per page and top
bits of swap offset in swap pte are used to store the tag.

5. When the page is swapped back in or reinstantiated after migration,
set_swp_pte_at() function allows kernel to restore the version tags on
the new physical page by retrieving the original tag from swap offset in
swap pte.

User task can disable ADI by calling mprotect() again on the memory
range with PROT_ADI bit unset. Kernel clears the VM_SPARC_ADI flag in
VMAs, merges adjacent VMAs if necessary, and clears TTE.mcd bit in the
corresponding ptes.

IOMMU does not support ADI checking. Any version tags
embedded in the top bits of VA meant for IOMMU, are cleared and replaced
with sign extension of the first non-version tag bit (bit 59 for SPARC
M7) for IOMMU addresses.

This patch series adds support for this feature in 4 patches:

Patch 1/4
  Tag mismatch on access by a task results in a trap from hypervisor as
  data access exception or a precide memory corruption detected
  exception. As part of handling these exceptions, kernel sends a
  SIGSEGV to user process with special si_code to indicate which fault
  occurred. This patch adds three new si_codes to differentiate between
  various mismatch errors.

Patch 2/4
  When a page is swapped or migrated, metadata associated with the page
  must be saved so it can be restored later. This patch adds a new
  function that saves/restores this metadata when updating pte upon a
  swap/migration.

Patch 3/4
  SPARC M7 processor adds new fields to control registers to support ADI
  feature. It also adds a new exception for precise traps on tag
  mismatch. This patch adds definitions for the new control register
  fields, new ASIs for ADI and an exception handler for the precise trap
  on tag mismatch.

Patch 4/4
  This patch adds support for a user space task to enable ADI and enable
  tag checking for subsets of its address space. As part of enabling
  this feature, this patch also extends exception handlers to handler
  tag mismatch exceptions, adds code to save and restore tags on page
  swap and migration, and adds code to return ADI parameters to
  userspace.


Testing:

- All functionality was tested with 8K normal pages as well as hugepages
  using malloc, mmap and shm.
- Multiple long duration stress tests were run using hugepages over 2+
  months. Normal pages were tested with shorter duration stress tests.
- Tested swapping with malloc and shm by reducing max memory and
  allocating three times the available system memory by active processes
  using ADI on allocated memory. Ran through multiple hour long runs of
  this test.
- Tested page migration with malloc and shm by migrating data pages of
  active ADI test process using migratepages, back and forth between two
  nodes every few seconds over an hour long run. Verified page migration
  through /proc/<pid>/numa_maps.

---
Khalid Aziz (4):
  signals, sparc: Add signal codes for ADI violations
  mm: Add function to support extra actions on swap in/out
  sparc64: Add support for ADI register fields, ASIs and traps
  sparc64: Add support for ADI (Application Data Integrity)

 Documentation/sparc/adi.txt             | 288 ++++++++++++++++++++++++++++++++
 arch/sparc/include/asm/adi.h            |   6 +
 arch/sparc/include/asm/adi_64.h         |  46 +++++
 arch/sparc/include/asm/elf_64.h         |   8 +
 arch/sparc/include/asm/hugetlb.h        |  13 ++
 arch/sparc/include/asm/hypervisor.h     |   2 +
 arch/sparc/include/asm/mman.h           |  40 ++++-
 arch/sparc/include/asm/mmu_64.h         |   2 +
 arch/sparc/include/asm/mmu_context_64.h |  32 ++++
 arch/sparc/include/asm/pgtable_64.h     |  96 ++++++++++-
 arch/sparc/include/asm/ttable.h         |  10 ++
 arch/sparc/include/asm/uaccess_64.h     | 120 ++++++++++++-
 arch/sparc/include/uapi/asm/asi.h       |   5 +
 arch/sparc/include/uapi/asm/auxvec.h    |   8 +
 arch/sparc/include/uapi/asm/mman.h      |   2 +
 arch/sparc/include/uapi/asm/pstate.h    |  10 ++
 arch/sparc/kernel/Makefile              |   1 +
 arch/sparc/kernel/adi_64.c              |  93 +++++++++++
 arch/sparc/kernel/entry.h               |   3 +
 arch/sparc/kernel/head_64.S             |   1 +
 arch/sparc/kernel/mdesc.c               |   4 +
 arch/sparc/kernel/process_64.c          |  21 +++
 arch/sparc/kernel/sun4v_mcd.S           |  16 ++
 arch/sparc/kernel/traps_64.c            | 142 +++++++++++++++-
 arch/sparc/kernel/ttable_64.S           |   6 +-
 arch/sparc/mm/gup.c                     |  37 ++++
 arch/sparc/mm/tlb.c                     |  28 ++++
 arch/x86/kernel/signal_compat.c         |   2 +-
 include/asm-generic/pgtable.h           |   5 +
 include/linux/mm.h                      |   2 +
 include/uapi/asm-generic/siginfo.h      |   5 +-
 mm/memory.c                             |   2 +-
 mm/rmap.c                               |   4 +-
 33 files changed, 1041 insertions(+), 19 deletions(-)
 create mode 100644 Documentation/sparc/adi.txt
 create mode 100644 arch/sparc/include/asm/adi.h
 create mode 100644 arch/sparc/include/asm/adi_64.h
 create mode 100644 arch/sparc/kernel/adi_64.c
 create mode 100644 arch/sparc/kernel/sun4v_mcd.S

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
