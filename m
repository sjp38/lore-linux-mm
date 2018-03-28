Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5F46B002F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:55:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t10-v6so2097657plr.12
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:55:50 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x10si2625159pgo.58.2018.03.28.09.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 09:55:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 00/14] Partial MKTME enabling
Date: Wed, 28 Mar 2018 19:55:26 +0300
Message-Id: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Multikey Total Memory Encryption (MKTME)[1] is a technology that allows
transparent memory encryption in upcoming Intel platforms. See overview
below.

Here's updated version of my patchset that brings support of MKTME.
Functionally it matches what I posted as RFC before, but I changed few
things under hood.

Please review.

It's not yet full enabling, but all patches except the last one should be
ready to be applied.

v2:
 - Store KeyID of page in page_ext->flags rather than in anon_vma.
   anon_vma approach turned out to be problematic. The main problem is
   that anon_vma of the page is no longer stable after last mapcount has
   gone. We would like to preserve last used KeyID even for freed
   pages as it allows to avoid unneccessary cache flushing on allocation
   of an encrypted page. page_ext serves this well enough.

 - KeyID is now propagated through page allocator. No need in GFP_ENCRYPT
   anymore.

 - Patch "Decouple dynamic __PHYSICAL_MASK from AMD SME" has been fix to
   work with AMD SEV (need to be confirmed by AMD folks).

------------------------------------------------------------------------------

MKTME is built on top of TME. TME allows encryption of the entirety of
system memory using a single key. MKTME allows to have multiple encryption
domains, each having own key -- different memory pages can be encrypted
with different keys.

Key design points of Intel MKTME:

 - Initial HW implementation would support upto 63 keys (plus one default
   TME key). But the number of keys may be as low as 3, depending to SKU
   and BIOS settings

 - To access encrypted memory you need to use mapping with proper KeyID
   int the page table entry. KeyID is encoded in upper bits of PFN in page
   table entry.

   This means we cannot use direct map to access encrypted memory from
   kernel side. My idea is to re-use kmap() interface to get proper
   temporary mapping on kernel side.

 - CPU does not enforce coherency between mappings of the same physical
   page with different KeyIDs or encryption keys. We wound need to take
   care about flushing cache on allocation of encrypted page and on
   returning it back to free pool.

 - For managing keys, there's MKTME_KEY_PROGRAM leaf of the new PCONFIG
   (platform configuration) instruction. It allows load and clear keys
   associated with a KeyID. You can also ask CPU to generate a key for
   you or disable memory encryption when a KeyID is used.

[1] https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf

Kirill A. Shutemov (14):
  x86/mm: Decouple dynamic __PHYSICAL_MASK from AMD SME
  x86/mm: Mask out KeyID bits from page table entry pfn
  mm/shmem: Zero out unused vma fields in shmem_pseudo_vma_init()
  mm: Do no merge vma with different encryption KeyIDs
  mm/khugepaged: Do not collapse pages in encrypted VMAs
  mm/page_alloc: Propagate encryption KeyID through page allocator
  mm/page_alloc: Add hook in page allocation path for encrypted pages
  mm/page_ext: Drop definition of unused PAGE_EXT_DEBUG_POISON
  x86/mm: Introduce variables to store number, shift and mask of KeyIDs
  x86/mm: Preserve KeyID on pte_modify() and pgprot_modify()
  x86/mm: Implement vma_is_encrypted() and vma_keyid()
  x86/mm: Implement page_keyid() using page_ext
  x86/mm: Implement prep_encrypted_page()
  x86: Introduce CONFIG_X86_INTEL_MKTME

 arch/ia64/hp/common/sba_iommu.c                    |  2 +-
 arch/ia64/include/asm/thread_info.h                |  2 +-
 arch/ia64/kernel/uncached.c                        |  2 +-
 arch/ia64/sn/pci/pci_dma.c                         |  2 +-
 arch/ia64/sn/pci/tioca_provider.c                  |  2 +-
 arch/powerpc/kernel/dma.c                          |  2 +-
 arch/powerpc/kernel/iommu.c                        |  4 +-
 arch/powerpc/perf/imc-pmu.c                        |  4 +-
 arch/powerpc/platforms/cell/iommu.c                |  6 +-
 arch/powerpc/platforms/cell/ras.c                  |  2 +-
 arch/powerpc/platforms/powernv/pci-ioda.c          |  6 +-
 arch/powerpc/sysdev/xive/common.c                  |  2 +-
 arch/sparc/kernel/iommu.c                          |  6 +-
 arch/sparc/kernel/pci_sun4v.c                      |  2 +-
 arch/tile/kernel/machine_kexec.c                   |  2 +-
 arch/tile/mm/homecache.c                           |  2 +-
 arch/x86/Kconfig                                   | 21 ++++++
 arch/x86/boot/compressed/kaslr_64.c                |  5 ++
 arch/x86/events/intel/ds.c                         |  2 +-
 arch/x86/events/intel/pt.c                         |  2 +-
 arch/x86/include/asm/mktme.h                       | 40 ++++++++++++
 arch/x86/include/asm/page.h                        |  1 +
 arch/x86/include/asm/page_types.h                  |  8 ++-
 arch/x86/include/asm/pgtable_types.h               |  7 +-
 arch/x86/kernel/cpu/intel.c                        | 27 ++++++++
 arch/x86/kernel/espfix_64.c                        |  6 +-
 arch/x86/kernel/irq_32.c                           |  4 +-
 arch/x86/kvm/vmx.c                                 |  2 +-
 arch/x86/mm/Makefile                               |  2 +
 arch/x86/mm/mem_encrypt_identity.c                 |  3 +
 arch/x86/mm/mktme.c                                | 63 ++++++++++++++++++
 arch/x86/mm/pgtable.c                              |  5 ++
 block/blk-mq.c                                     |  2 +-
 drivers/char/agp/sgi-agp.c                         |  2 +-
 drivers/edac/thunderx_edac.c                       |  2 +-
 drivers/hv/channel.c                               |  2 +-
 drivers/iommu/dmar.c                               |  3 +-
 drivers/iommu/intel-iommu.c                        |  2 +-
 drivers/iommu/intel_irq_remapping.c                |  2 +-
 drivers/misc/sgi-gru/grufile.c                     |  2 +-
 drivers/misc/sgi-xp/xpc_uv.c                       |  2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  5 +-
 drivers/net/ethernet/mellanox/mlx4/icm.c           |  2 +-
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  2 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  2 +-
 include/linux/gfp.h                                | 35 +++++-----
 include/linux/migrate.h                            |  2 +-
 include/linux/mm.h                                 | 21 ++++++
 include/linux/page_ext.h                           | 22 +++----
 include/linux/skbuff.h                             |  2 +-
 kernel/events/ring_buffer.c                        |  4 +-
 kernel/fork.c                                      |  2 +-
 kernel/profile.c                                   |  2 +-
 kernel/trace/ring_buffer.c                         |  6 +-
 kernel/trace/trace.c                               |  2 +-
 kernel/trace/trace_uprobe.c                        |  2 +-
 lib/dma-direct.c                                   |  2 +-
 mm/compaction.c                                    |  2 +-
 mm/filemap.c                                       |  2 +-
 mm/hugetlb.c                                       |  2 +-
 mm/internal.h                                      |  2 +-
 mm/khugepaged.c                                    |  4 +-
 mm/mempolicy.c                                     | 33 ++++++----
 mm/migrate.c                                       | 12 ++--
 mm/mmap.c                                          |  3 +-
 mm/page_alloc.c                                    | 75 ++++++++++++----------
 mm/page_ext.c                                      |  3 +
 mm/page_isolation.c                                |  2 +-
 mm/percpu-vm.c                                     |  2 +-
 mm/shmem.c                                         |  3 +-
 mm/slab.c                                          |  2 +-
 mm/slob.c                                          |  2 +-
 mm/slub.c                                          |  4 +-
 mm/sparse-vmemmap.c                                |  2 +-
 mm/vmalloc.c                                       |  8 ++-
 net/core/pktgen.c                                  |  2 +-
 net/sunrpc/svc.c                                   |  2 +-
 80 files changed, 388 insertions(+), 163 deletions(-)
 create mode 100644 arch/x86/include/asm/mktme.h
 create mode 100644 arch/x86/mm/mktme.c

-- 
2.16.2
