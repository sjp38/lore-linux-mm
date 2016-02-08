Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id E8FBE8309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:20:57 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id y9so109051729qgd.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:20:57 -0800 (PST)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id g203si3569660qhg.1.2016.02.08.01.20.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:20:56 -0800 (PST)
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 04:20:56 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2B2696E803F
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:07:46 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189Ksv330801974
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:20:54 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189Krjl009903
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:20:53 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 00/29] Book3s abstraction in preparation for new MMU model
Date: Mon,  8 Feb 2016 14:50:12 +0530
Message-Id: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Hello,

This is a large series, mostly consisting of code movement. No new features
are done in this series. The changes are done to accomodate the upcoming new memory
model in future powerpc chips. The details of the new MMU model can be found at

 http://ibm.biz/power-isa3 (Needs registration). I am including a summary of the changes below.

ISA 3.0 adds support for the radix tree style of MMU with full
virtualization and related control mechanisms that manage its
coexistence with the HPT. Radix-using operating systems will
manage their own translation tables instead of relying on hcalls.

Radix style MMU model requires us to do a 4 level page table
with 64K and 4K page size. The table index size different page size
is listed below

PGD -> 13 bits
PUD -> 9 (1G hugepage)
PMD -> 9 (2M huge page)
PTE -> 5 (for 64k), 9 (for 4k)

We also require the page table to be in big endian format.

The changes proposed in this series enables us to support both
hash page table and radix tree style MMU using a single kernel
with limited impact. The idea is to change core page table
accessors to static inline functions and later hotpatch them
to switch to hash or radix tree functions. For ex:

static inline int pte_write(pte_t pte)
{
       if (radix_enabled())
               return rpte_write(pte);
        return hlpte_write(pte);
}

On boot we will hotpatch the code so as to avoid conditional operation.

The other two major change propsed in this series is to switch hash
linux page table to a 4 level table in big endian format. This is
done so that functions like pte_val(), pud_populate() doesn't need
hotpatching and thereby helps in limiting runtime impact of the changes.

I didn't included the radix related changes in this series. You can
find them at https://github.com/kvaneesh/linux/commits/radix-mmu-v1

Changes from V1:
* move patches adding helpers to the next series

-aneesh


Aneesh Kumar K.V (29):
  powerpc/mm: add _PAGE_HASHPTE similar to 4K hash
  powerpc/mm: Split pgtable types to separate header
  powerpc/mm: Switch book3s 64 with 64K page size to 4 level page table
  powerpc/mm: Copy pgalloc (part 1)
  powerpc/mm: Copy pgalloc (part 2)
  powerpc/mm: Copy pgalloc (part 3)
  mm: Make vm_get_page_prot arch specific.
  mm: Some arch may want to use HPAGE_PMD related values as variables
  powerpc/mm: Hugetlbfs is book3s_64 and fsl_book3e (32 or 64)
  powerpc/mm: free_hugepd_range split to hash and nonhash
  powerpc/mm: Use helper instead of opencoding
  powerpc/mm: Move hash64 specific defintions to seperate header
  powerpc/mm: Move swap related definition ot hash64 header
  powerpc/mm: Move hash page table related functions to pgtable-hash64.c
  powerpc/mm: Rename hash specific page table bits (_PAGE* -> H_PAGE*)
  powerpc/mm: Use flush_tlb_page in ptep_clear_flush_young
  powerpc/mm: THP is only available on hash64 as of now
  powerpc/mm: Use generic version of pmdp_clear_flush_young
  powerpc/mm: Create a new headers for tlbflush for hash64
  powerpc/mm: Hash linux abstraction for page table accessors
  powerpc/mm: Hash linux abstraction for functions in pgtable-hash.c
  powerpc/mm: Hash linux abstraction for mmu context handling code
  powerpc/mm: Move hash related mmu-*.h headers to book3s/
  powerpc/mm: Hash linux abstractions for early init routines
  powerpc/mm: Hash linux abstraction for THP
  powerpc/mm: Hash linux abstraction for HugeTLB
  powerpc/mm: Hash linux abstraction for page table allocator
  powerpc/mm: Hash linux abstraction for tlbflush routines
  powerpc/mm: Hash linux abstraction for pte swap encoding

 arch/arm/include/asm/pgtable-3level.h              |   8 +
 arch/arm64/include/asm/pgtable.h                   |   7 +
 arch/mips/include/asm/pgtable.h                    |   8 +
 arch/powerpc/Kconfig                               |   1 +
 .../asm/{mmu-hash32.h => book3s/32/mmu-hash.h}     |   6 +-
 arch/powerpc/include/asm/book3s/32/pgalloc.h       | 109 ++++
 arch/powerpc/include/asm/book3s/32/pgtable.h       |  13 +
 arch/powerpc/include/asm/book3s/64/hash-4k.h       | 103 ++-
 arch/powerpc/include/asm/book3s/64/hash-64k.h      | 165 ++---
 arch/powerpc/include/asm/book3s/64/hash.h          | 525 ++++++++-------
 .../asm/{mmu-hash64.h => book3s/64/mmu-hash.h}     |  67 +-
 arch/powerpc/include/asm/book3s/64/mmu.h           |  92 +++
 .../include/asm/book3s/64/pgalloc-hash-4k.h        |  92 +++
 .../include/asm/book3s/64/pgalloc-hash-64k.h       |  48 ++
 arch/powerpc/include/asm/book3s/64/pgalloc-hash.h  |  82 +++
 arch/powerpc/include/asm/book3s/64/pgalloc.h       | 158 +++++
 arch/powerpc/include/asm/book3s/64/pgtable.h       | 713 ++++++++++++++++++---
 arch/powerpc/include/asm/book3s/64/tlbflush-hash.h |  96 +++
 arch/powerpc/include/asm/book3s/64/tlbflush.h      |  56 ++
 arch/powerpc/include/asm/book3s/pgalloc.h          |  19 +
 arch/powerpc/include/asm/book3s/pgtable.h          |   4 -
 arch/powerpc/include/asm/hugetlb.h                 |   5 +-
 arch/powerpc/include/asm/kvm_book3s_64.h           |  10 +-
 arch/powerpc/include/asm/mman.h                    |   6 -
 arch/powerpc/include/asm/mmu.h                     |  27 +-
 arch/powerpc/include/asm/mmu_context.h             |  63 +-
 .../asm/{pgalloc-32.h => nohash/32/pgalloc.h}      |   0
 .../asm/{pgalloc-64.h => nohash/64/pgalloc.h}      |  24 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h       |   4 +
 arch/powerpc/include/asm/nohash/pgalloc.h          |  30 +
 arch/powerpc/include/asm/nohash/pgtable.h          |  11 +
 arch/powerpc/include/asm/page.h                    | 104 +--
 arch/powerpc/include/asm/page_64.h                 |   2 +-
 arch/powerpc/include/asm/pgalloc.h                 |  19 +-
 arch/powerpc/include/asm/pgtable-types.h           | 103 +++
 arch/powerpc/include/asm/pgtable.h                 |  13 -
 arch/powerpc/include/asm/pte-common.h              |   3 +
 arch/powerpc/include/asm/tlbflush.h                |  92 +--
 arch/powerpc/kernel/asm-offsets.c                  |   9 +-
 arch/powerpc/kernel/idle_power7.S                  |   2 +-
 arch/powerpc/kernel/pci_64.c                       |   3 +-
 arch/powerpc/kernel/swsusp.c                       |   2 +-
 arch/powerpc/kvm/book3s_32_mmu_host.c              |   2 +-
 arch/powerpc/kvm/book3s_64_mmu.c                   |   2 +-
 arch/powerpc/kvm/book3s_64_mmu_host.c              |   4 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c                |   2 +-
 arch/powerpc/kvm/book3s_64_vio.c                   |   2 +-
 arch/powerpc/kvm/book3s_64_vio_hv.c                |   2 +-
 arch/powerpc/kvm/book3s_hv_rm_mmu.c                |   2 +-
 arch/powerpc/kvm/book3s_hv_rmhandlers.S            |   2 +-
 arch/powerpc/mm/Makefile                           |   3 +-
 arch/powerpc/mm/copro_fault.c                      |   8 +-
 arch/powerpc/mm/hash64_4k.c                        |  25 +-
 arch/powerpc/mm/hash64_64k.c                       |  61 +-
 arch/powerpc/mm/hash_native_64.c                   |  10 +-
 arch/powerpc/mm/hash_utils_64.c                    | 118 +++-
 arch/powerpc/mm/hugepage-hash64.c                  |  22 +-
 arch/powerpc/mm/hugetlbpage-book3e.c               | 480 ++++++++++++++
 arch/powerpc/mm/hugetlbpage-hash64.c               | 296 ++++++++-
 arch/powerpc/mm/hugetlbpage.c                      | 603 +----------------
 arch/powerpc/mm/init_64.c                          | 102 +--
 arch/powerpc/mm/mem.c                              |  29 +-
 arch/powerpc/mm/mmu_context_hash64.c               |  20 +-
 arch/powerpc/mm/mmu_context_nohash.c               |   3 +-
 arch/powerpc/mm/mmu_decl.h                         |   4 -
 arch/powerpc/mm/pgtable-book3e.c                   | 163 +++++
 arch/powerpc/mm/pgtable-hash64.c                   | 615 ++++++++++++++++++
 arch/powerpc/mm/pgtable.c                          |   9 +
 arch/powerpc/mm/pgtable_64.c                       | 513 ++-------------
 arch/powerpc/mm/ppc_mmu_32.c                       |  30 +
 arch/powerpc/mm/slb.c                              |   9 +-
 arch/powerpc/mm/slb_low.S                          |   4 +-
 arch/powerpc/mm/slice.c                            |   2 +-
 arch/powerpc/mm/tlb_hash64.c                       |  10 +-
 arch/powerpc/platforms/cell/spu_base.c             |   6 +-
 arch/powerpc/platforms/cell/spufs/fault.c          |   4 +-
 arch/powerpc/platforms/ps3/spu.c                   |   2 +-
 arch/powerpc/platforms/pseries/lpar.c              |  12 +-
 arch/s390/include/asm/pgtable.h                    |   8 +
 arch/sparc/include/asm/pgtable_64.h                |   7 +
 arch/tile/include/asm/pgtable.h                    |   9 +
 arch/x86/include/asm/pgtable.h                     |   8 +
 drivers/char/agp/uninorth-agp.c                    |   9 +-
 drivers/cpufreq/pmac32-cpufreq.c                   |   2 +-
 drivers/macintosh/via-pmu.c                        |   4 +-
 drivers/misc/cxl/fault.c                           |   6 +-
 include/linux/huge_mm.h                            |   3 -
 include/linux/mman.h                               |   4 -
 mm/huge_memory.c                                   |   8 +-
 mm/mmap.c                                          |   9 +-
 90 files changed, 4013 insertions(+), 2149 deletions(-)
 rename arch/powerpc/include/asm/{mmu-hash32.h => book3s/32/mmu-hash.h} (94%)
 create mode 100644 arch/powerpc/include/asm/book3s/32/pgalloc.h
 rename arch/powerpc/include/asm/{mmu-hash64.h => book3s/64/mmu-hash.h} (90%)
 create mode 100644 arch/powerpc/include/asm/book3s/64/mmu.h
 create mode 100644 arch/powerpc/include/asm/book3s/64/pgalloc-hash-4k.h
 create mode 100644 arch/powerpc/include/asm/book3s/64/pgalloc-hash-64k.h
 create mode 100644 arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
 create mode 100644 arch/powerpc/include/asm/book3s/64/pgalloc.h
 create mode 100644 arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
 create mode 100644 arch/powerpc/include/asm/book3s/64/tlbflush.h
 create mode 100644 arch/powerpc/include/asm/book3s/pgalloc.h
 rename arch/powerpc/include/asm/{pgalloc-32.h => nohash/32/pgalloc.h} (100%)
 rename arch/powerpc/include/asm/{pgalloc-64.h => nohash/64/pgalloc.h} (91%)
 create mode 100644 arch/powerpc/include/asm/nohash/pgalloc.h
 create mode 100644 arch/powerpc/include/asm/pgtable-types.h
 create mode 100644 arch/powerpc/mm/pgtable-book3e.c
 create mode 100644 arch/powerpc/mm/pgtable-hash64.c

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
