Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF2E6B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:25 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q13so7505752pgt.17
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:25 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p12-v6si7098404plk.295.2018.03.05.08.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:24 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 00/22] Partial MKTME enabling
Date: Mon,  5 Mar 2018 19:25:48 +0300
Message-Id: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi everybody,

Here's updated version of my patchset that brings support of MKTME.
It's not yet complete, but I think it worth sharing to get early feedback.

Things that are missing:

 - kmap() is not yet wired up to support tempoprary mappings of encrypted
   pages. It's requried to allow kernel to access encrypted memory.

 - Interface to manipulate encryption keys.

 - Interface to create encrypted userspace mappings.

 - IOMMU support.

What has been done:

 - PCONFIG, TME and MKTME enumeration.

 - In-kernel helper that allows to program encryption keys into CPU.

 - Allocation and freeing encrypted pages.

 - Helpers to find out if a VMA/anon_vma/page is encrypted and with what
   KeyID.

Any feedback is welcome.

------------------------------------------------------------------------------

Multikey Total Memory Encryption (MKTME)[1] is a technology that allows
transparent memory encryption in upcoming Intel platforms.

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

Kirill A. Shutemov (22):
  x86/cpufeatures: Add Intel Total Memory Encryption cpufeature
  x86/tme: Detect if TME and MKTME is activated by BIOS
  x86/cpufeatures: Add Intel PCONFIG cpufeature
  x86/pconfig: Detect PCONFIG targets
  x86/pconfig: Provide defines and helper to run MKTME_KEY_PROG leaf
  x86/mm: Decouple dynamic __PHYSICAL_MASK from AMD SME
  x86/mm: Mask out KeyID bits from page table entry pfn
  mm: Introduce __GFP_ENCRYPT
  mm, rmap: Add arch-specific field into anon_vma
  mm/shmem: Zero out unused vma fields in shmem_pseudo_vma_init()
  mm: Use __GFP_ENCRYPT for pages in encrypted VMAs
  mm: Do no merge vma with different encryption KeyIDs
  mm, rmap: Free encrypted pages once mapcount drops to zero
  mm, khugepaged: Do not collapse pages in encrypted VMAs
  x86/mm: Introduce variables to store number, shift and mask of KeyIDs
  x86/mm: Preserve KeyID on pte_modify() and pgprot_modify()
  x86/mm: Implement vma_is_encrypted() and vma_keyid()
  x86/mm: Handle allocation of encrypted pages
  x86/mm: Implement free_encrypt_page()
  x86/mm: Implement anon_vma_encrypted() and anon_vma_keyid()
  x86/mm: Introduce page_keyid() and page_encrypted()
  x86: Introduce CONFIG_X86_INTEL_MKTME

 arch/x86/Kconfig                     |  21 +++++++
 arch/x86/boot/compressed/kaslr_64.c  |   3 +
 arch/x86/include/asm/cpufeatures.h   |   2 +
 arch/x86/include/asm/intel_pconfig.h |  65 +++++++++++++++++++
 arch/x86/include/asm/mktme.h         |  56 +++++++++++++++++
 arch/x86/include/asm/page.h          |  13 +++-
 arch/x86/include/asm/page_types.h    |   8 ++-
 arch/x86/include/asm/pgtable_types.h |   7 ++-
 arch/x86/kernel/cpu/Makefile         |   2 +-
 arch/x86/kernel/cpu/intel.c          | 119 +++++++++++++++++++++++++++++++++++
 arch/x86/kernel/cpu/intel_pconfig.c  |  82 ++++++++++++++++++++++++
 arch/x86/mm/Makefile                 |   2 +
 arch/x86/mm/mem_encrypt_identity.c   |   3 +
 arch/x86/mm/mktme.c                  | 101 +++++++++++++++++++++++++++++
 arch/x86/mm/pgtable.c                |   5 ++
 include/linux/gfp.h                  |  29 +++++++--
 include/linux/mm.h                   |  17 +++++
 include/linux/rmap.h                 |   6 ++
 include/trace/events/mmflags.h       |   1 +
 mm/Kconfig                           |   3 +
 mm/khugepaged.c                      |   2 +
 mm/mempolicy.c                       |   3 +
 mm/mmap.c                            |   3 +-
 mm/page_alloc.c                      |   3 +
 mm/rmap.c                            |  49 +++++++++++++--
 mm/shmem.c                           |   3 +-
 tools/perf/builtin-kmem.c            |   1 +
 27 files changed, 590 insertions(+), 19 deletions(-)
 create mode 100644 arch/x86/include/asm/intel_pconfig.h
 create mode 100644 arch/x86/include/asm/mktme.h
 create mode 100644 arch/x86/kernel/cpu/intel_pconfig.c
 create mode 100644 arch/x86/mm/mktme.c

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
