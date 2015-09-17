Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id D2AD86B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:27:13 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so20192750obb.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:27:13 -0700 (PDT)
Received: from g1t6213.austin.hp.com (g1t6213.austin.hp.com. [15.73.96.121])
        by mx.google.com with ESMTPS id j185si2425902oif.53.2015.09.17.11.27.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 11:27:13 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 RESEND 0/11] x86/mm: Handle large PAT bit in pud/pmd interfaces
Date: Thu, 17 Sep 2015 12:24:13 -0600
Message-Id: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com

The PAT bit gets relocated to bit 12 when PUD/PMD mappings are used.  This
bit 12, however, is not covered by PTE_FLAGS_MASK, which is corrently used
by masking pfn and flags for all levels.  This patch-set updates pud/pmd
interfaces and multiple functions to handle the large PAT bit properly.

Patch 1/11-2/11 make changes necessary for patch 3/11 to use P?D_PAGE_MASK.

Patch 3/11-4/11 fix pud/pmd interfaces to handle the PAT bit properly.

Patch 5/11 adds p?d_pgprot() interfaces for PUD/PMD.

Patch 6/11 fixes /sys/kernel/debug/kernel_page_tables to show the PAT bit
properly.

Patch 7/11-10/11 fix multiple functions to handle the large PAT bit properly.

Patch 11/11 fixes the no-change case in try_preserve_large_page() by
leveraging the changes made in patch 9/11.

Note, the PAT bit is first enabled in 4.2-rc1 with WT mapping.  The functions
fixed by patch 7/11-10/11 are not used with WT mapping yet.  These fixes will
protect them from the future use of the PAT bit set.

The patchset is based on the -tip branch.

---
RESEND:
 - Rebased to 4.3-rc1 -tip branch. No conflict.

v4:
 - Add descriptions of the issue fixed by patch 01/11 (Thomas Gleixner).
 - Split patch 03 into two patches, mask changes & pud/pmd interface changes.
   (Thomas Gleixner).

v3:
 - Add patch 4/11 and 6/11-9/11 for multiple interfaces to handle the large
   PAT bit.
 - Add patch 11/11 to fix the same pgprot handling in
   try_preserve_large_page().

v2:
 - Change p?n_pfn() to handle the PAT bit. (Juergen Gross)
 - Mask pfn and flags with P?D_PAGE_MASK. (Juergen Gross)
 - Change p?d_page_vaddr() and p?d_page() to handle the PAT bit.

---
Toshi Kani (11):
  1/11 x86/vdso32: Define PGTABLE_LEVELS to 32bit VDSO
  2/11 x86/asm: Move PUD_PAGE macros to page_types.h
  3/11 x86/asm: Add pud/pmd mask interfaces to handle large PAT bit
  4/11 x86/asm: Fix pud/pmd interfaces to handle large PAT bit
  5/11 x86/asm: Add pud_pgprot() and pmd_pgprot()
  6/11 x86/mm: Fix page table dump to show PAT bit
  7/11 x86/mm: Fix slow_virt_to_phys() to handle large PAT bit
  8/11 x86/mm: Fix gup_huge_p?d() to handle large PAT bit
  9/11 x86/mm: Fix try_preserve_large_page() to handle large PAT bit
 10/11 x86/mm: Fix __split_large_page() to handle large PAT bit
 11/11 x86/mm: Fix no-change case in try_preserve_large_page()

---
 arch/x86/entry/vdso/vdso32/vclock_gettime.c |  2 +
 arch/x86/include/asm/page_64_types.h        |  3 --
 arch/x86/include/asm/page_types.h           |  3 ++
 arch/x86/include/asm/pgtable.h              | 18 ++++---
 arch/x86/include/asm/pgtable_types.h        | 40 +++++++++++++--
 arch/x86/mm/dump_pagetables.c               | 39 +++++++-------
 arch/x86/mm/gup.c                           | 18 +++----
 arch/x86/mm/pageattr.c                      | 79 ++++++++++++++++++-----------
 8 files changed, 131 insertions(+), 71 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
