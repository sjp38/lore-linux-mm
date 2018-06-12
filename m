Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 29B006B0007
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z5-v6so12019586pfz.6
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:26 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d191-v6si257904pga.192.2018.06.12.07.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 00/17] MKTME enabling
Date: Tue, 12 Jun 2018 17:38:58 +0300
Message-Id: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Multikey Total Memory Encryption (MKTME)[1] is a technology that allows
transparent memory encryption in upcoming Intel platforms. See overview
below.

Here's updated version of my patchset that brings support of MKTME.
Please review and consider applying.

The patchset provides in-kernel infrastructure for MKTME, but doesn't yet
have userspace interface.

First 4 patches are for core-mm. The rest is x86-specific.

The patchset is on top of page_ext cleanups I've posted earlier[2].

v3:
 - Kernel now can access encrypted pages via per-KeyID direct mapping.

 - Rework page allocation for encrypted memory to minimize overhead on
   non-encrypted pages. It comes with cost for allocation of encrypted
   pages: we have to flush cache on every time we allocate *and* free
   encrypted page. We will need to optimize it later.

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

 - CPU does not enforce coherency between mappings of the same physical
   page with different KeyIDs or encryption keys. We wound need to take
   care about flushing cache on allocation of encrypted page and on
   returning it back to free pool.

 - For managing keys, there's MKTME_KEY_PROGRAM leaf of the new PCONFIG
   (platform configuration) instruction. It allows load and clear keys
   associated with a KeyID. You can also ask CPU to generate a key for
   you or disable memory encryption when a KeyID is used.

[1] https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf
[2] https://lkml.kernel.org/r/20180531135457.20167-1-kirill.shutemov@linux.intel.com

Kirill A. Shutemov (17):
  mm: Do no merge VMAs with different encryption KeyIDs
  mm/khugepaged: Do not collapse pages in encrypted VMAs
  mm/ksm: Do not merge pages with different KeyIDs
  mm/page_alloc: Handle allocation for encrypted memory
  x86/mm: Mask out KeyID bits from page table entry pfn
  x86/mm: Introduce variables to store number, shift and mask of KeyIDs
  x86/mm: Preserve KeyID on pte_modify() and pgprot_modify()
  x86/mm: Implement vma_is_encrypted() and vma_keyid()
  x86/mm: Implement page_keyid() using page_ext
  x86/mm: Implement prep_encrypted_page() and arch_free_page()
  x86/mm: Rename CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING
  x86/mm: Allow to disable MKTME after enumeration
  x86/mm: Detect MKTME early
  x86/mm: Introduce direct_mapping_size
  x86/mm: Implement sync_direct_mapping()
  x86/mm: Handle encrypted memory in page_to_virt() and __pa()
  x86: Introduce CONFIG_X86_INTEL_MKTME

 arch/alpha/include/asm/page.h        |   2 +-
 arch/x86/Kconfig                     |  21 +-
 arch/x86/include/asm/mktme.h         |  60 +++
 arch/x86/include/asm/page.h          |   1 +
 arch/x86/include/asm/page_64.h       |   3 +-
 arch/x86/include/asm/pgtable_types.h |   7 +-
 arch/x86/kernel/cpu/intel.c          |  40 +-
 arch/x86/kernel/head64.c             |   2 +
 arch/x86/mm/Makefile                 |   2 +
 arch/x86/mm/init_64.c                |   6 +
 arch/x86/mm/kaslr.c                  |  21 +-
 arch/x86/mm/mktme.c                  | 583 +++++++++++++++++++++++++++
 include/linux/gfp.h                  |  38 +-
 include/linux/migrate.h              |   8 +-
 include/linux/mm.h                   |  21 +
 include/linux/page_ext.h             |  11 +-
 mm/compaction.c                      |   4 +
 mm/khugepaged.c                      |   2 +
 mm/ksm.c                             |   3 +
 mm/mempolicy.c                       |  25 +-
 mm/migrate.c                         |   4 +-
 mm/mmap.c                            |   3 +-
 mm/page_alloc.c                      |  63 +++
 mm/page_ext.c                        |   3 +
 24 files changed, 893 insertions(+), 40 deletions(-)
 create mode 100644 arch/x86/include/asm/mktme.h
 create mode 100644 arch/x86/mm/mktme.c

-- 
2.17.1
