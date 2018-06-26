Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42A166B026B
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:22:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j13-v6so6511215pgp.16
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:22:54 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y16-v6si1608398pfl.11.2018.06.26.07.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 07:22:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 00/18] MKTME enabling
Date: Tue, 26 Jun 2018 17:22:27 +0300
Message-Id: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
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

First 5 patches are for core-mm. The rest is x86-specific.

The patchset is on top of tip- tree plus page_ext cleanups I've posted
earlier[2]. page_ext cleanups are in -mm tree now.

Below is performance numbers for kernel build. Enabling MKTME doesn't
affect performance of non-encrypted memory allocation.

For encrypted memory allocation requires cache flush on allocation and
freeing encrypted memory. For kernel build it results in ~20% performance
degradation if we allocate all anonymous memory as encrypted.

We would need to maintain per-KeyID pool of free pages to minimize cache
flushing. I'm going to work on the optimization on top of this patchset.

The patchset also can be found here:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git mktme/wip

v4:
 - Address Dave's feedback.

 - Add performance numbers.

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
   pages as it allows to avoid unnecessary cache flushing on allocation
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

Performance numbers for kernel build:

Base (tip- tree):

 Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):

    5664711.936917      task-clock (msec)         #   34.815 CPUs utilized            ( +-  0.02% )
         1,033,886      context-switches          #    0.183 K/sec                    ( +-  0.37% )
           189,308      cpu-migrations            #    0.033 K/sec                    ( +-  0.39% )
       104,951,554      page-faults               #    0.019 M/sec                    ( +-  0.01% )
16,907,670,543,945      cycles                    #    2.985 GHz                      ( +-  0.01% )
12,662,345,427,578      stalled-cycles-frontend   #   74.89% frontend cycles idle     ( +-  0.02% )
 9,936,469,878,830      instructions              #    0.59  insn per cycle
                                                  #    1.27  stalled cycles per insn  ( +-  0.00% )
 2,179,100,082,611      branches                  #  384.680 M/sec                    ( +-  0.00% )
    91,235,200,652      branch-misses             #    4.19% of all branches          ( +-  0.01% )

     162.706797586 seconds time elapsed                                          ( +-  0.04% )

CONFIG_X86_INTEL_MKTME=y, no encrypted memory:

 Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):

    5668508.245004      task-clock (msec)         #   34.872 CPUs utilized            ( +-  0.02% )
         1,032,034      context-switches          #    0.182 K/sec                    ( +-  0.90% )
           188,098      cpu-migrations            #    0.033 K/sec                    ( +-  1.15% )
       104,964,084      page-faults               #    0.019 M/sec                    ( +-  0.01% )
16,919,270,913,026      cycles                    #    2.985 GHz                      ( +-  0.02% )
12,672,067,815,805      stalled-cycles-frontend   #   74.90% frontend cycles idle     ( +-  0.02% )
 9,942,560,135,477      instructions              #    0.59  insn per cycle
                                                  #    1.27  stalled cycles per insn  ( +-  0.00% )
 2,180,800,745,687      branches                  #  384.722 M/sec                    ( +-  0.00% )
    91,167,857,700      branch-misses             #    4.18% of all branches          ( +-  0.02% )

     162.552503629 seconds time elapsed                                          ( +-  0.10% )

CONFIG_X86_INTEL_MKTME=y, all anonymous memory encrypted with KeyID-1, pay
cache flush overhead on allocation and free:

 Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):

    7041851.999259      task-clock (msec)         #   35.915 CPUs utilized            ( +-  0.01% )
         1,118,938      context-switches          #    0.159 K/sec                    ( +-  0.49% )
           197,039      cpu-migrations            #    0.028 K/sec                    ( +-  0.80% )
       104,970,021      page-faults               #    0.015 M/sec                    ( +-  0.00% )
21,025,639,251,627      cycles                    #    2.986 GHz                      ( +-  0.01% )
16,729,451,765,492      stalled-cycles-frontend   #   79.57% frontend cycles idle     ( +-  0.02% )
10,010,727,735,588      instructions              #    0.48  insn per cycle
                                                  #    1.67  stalled cycles per insn  ( +-  0.00% )
 2,197,110,181,421      branches                  #  312.007 M/sec                    ( +-  0.00% )
    91,119,463,513      branch-misses             #    4.15% of all branches          ( +-  0.01% )

     196.072361087 seconds time elapsed                                          ( +-  0.14% )

[1] https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf
[2] https://lkml.kernel.org/r/20180531135457.20167-1-kirill.shutemov@linux.intel.com

Kirill A. Shutemov (18):
  mm: Do no merge VMAs with different encryption KeyIDs
  mm/ksm: Do not merge pages with different KeyIDs
  mm/page_alloc: Unify alloc_hugepage_vma()
  mm/page_alloc: Handle allocation for encrypted memory
  mm/khugepaged: Handle encrypted pages
  x86/mm: Mask out KeyID bits from page table entry pfn
  x86/mm: Introduce variables to store number, shift and mask of KeyIDs
  x86/mm: Preserve KeyID on pte_modify() and pgprot_modify()
  x86/mm: Implement page_keyid() using page_ext
  x86/mm: Implement vma_keyid()
  x86/mm: Implement prep_encrypted_page() and arch_free_page()
  x86/mm: Rename CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING
  x86/mm: Allow to disable MKTME after enumeration
  x86/mm: Detect MKTME early
  x86/mm: Calculate direct mapping size
  x86/mm: Implement sync_direct_mapping()
  x86/mm: Handle encrypted memory in page_to_virt() and __pa()
  x86: Introduce CONFIG_X86_INTEL_MKTME

 Documentation/x86/x86_64/mm.txt      |   4 +
 arch/alpha/include/asm/page.h        |   2 +-
 arch/x86/Kconfig                     |  21 +-
 arch/x86/include/asm/mktme.h         |  47 +++
 arch/x86/include/asm/page.h          |   1 +
 arch/x86/include/asm/page_64.h       |   3 +-
 arch/x86/include/asm/pgtable_types.h |  15 +-
 arch/x86/include/asm/setup.h         |   6 +
 arch/x86/kernel/cpu/intel.c          |  32 +-
 arch/x86/kernel/head64.c             |   2 +
 arch/x86/kernel/setup.c              |   3 +
 arch/x86/mm/Makefile                 |   2 +
 arch/x86/mm/init_64.c                |  50 +++
 arch/x86/mm/kaslr.c                  |  11 +-
 arch/x86/mm/mktme.c                  | 546 +++++++++++++++++++++++++++
 include/linux/gfp.h                  |  54 ++-
 include/linux/migrate.h              |  12 +-
 include/linux/mm.h                   |  14 +
 include/linux/page_ext.h             |  11 +-
 mm/compaction.c                      |   1 +
 mm/khugepaged.c                      |  10 +
 mm/ksm.c                             |   3 +
 mm/mempolicy.c                       |  28 +-
 mm/migrate.c                         |   4 +-
 mm/mmap.c                            |   3 +-
 mm/page_alloc.c                      |  47 +++
 mm/page_ext.c                        |   3 +
 27 files changed, 901 insertions(+), 34 deletions(-)
 create mode 100644 arch/x86/include/asm/mktme.h
 create mode 100644 arch/x86/mm/mktme.c

-- 
2.18.0
