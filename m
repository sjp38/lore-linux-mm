Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4798E6B0255
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 17:45:21 -0400 (EDT)
Received: by obdeg2 with SMTP id eg2so42081522obd.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 14:45:21 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id j82si2981590oig.140.2015.08.05.14.45.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 14:45:20 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 0/10] x86/mm: Handle large PAT bit in pud/pmd interfaces
Date: Wed,  5 Aug 2015 15:43:23 -0600
Message-Id: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com

The PAT bit gets relocated to bit 12 when PUD/PMD mappings are used.  This
bit 12, however, is not covered by PTE_FLAGS_MASK, which is corrently used
for masking pfn and flags for all levels.  This patch-set updates pud/pmd
interfaces and multiple functions to handle the large PAT bit properly.

Patch 1/10-2/10 make changes necessary for patch 3/10 to use P?D_PAGE_MASK.

Patch 3/10 fixes pud/pmd interfaces to handle the PAT bit properly, and
patch 4/10 adds p?d_pgprot() interfaces for PUD/PMD.

Patch 5/10 fixes /sys/kernel/debug/kernel_page_tables to show the PAT bit
properly.

Patch 6/10-9/10 fix multiple functions to handle the large PAT bit properly.

Patch 10/10 fix the same pgprot handling in try_preserve_large_page() by
leveraging the changes made in patch 8/10.

Note, the PAT bit is first enabled in 4.2-rc1 with WT mappings.  The functions
fixed by patch 6/10-9/10 are not used with WT mappings yet.  These fixes will
protect them from future use with the PAT bit set.

---
v3:
 - Add patch 4/10 and 6/10-9/10 for multiple interfaces to handle the large
   PAT bit.
 - Add patch 10/10 to fix the same pgprot handling in
   try_preserve_large_page().

v2:
 - Change p?n_pfn() to handle the PAT bit. (Juergen Gross)
 - Mask pfn and flags with P?D_PAGE_MASK. (Juergen Gross)
 - Change p?d_page_vaddr() and p?d_page() to handle the PAT bit.

---
Toshi Kani (10):
  1/10 x86/vdso32: Define PGTABLE_LEVELS to 32bit VDSO
  2/10 x86/asm: Move PUD_PAGE macros to page_types.h
  3/10 x86/asm: Fix pud/pmd interfaces to handle large PAT bit
  4/10 x86/asm: Add pud_pgprot() and pmd_pgprot()
  5/10 x86/mm: Fix page table dump to show PAT bit
  6/10 x86/mm: Fix slow_virt_to_phys() to handle large PAT bit
  7/10 x86/mm: Fix gup_huge_p?d() to handle large PAT bit
  8/10 x86/mm: Fix try_preserve_large_page() to handle large PAT bit
  9/10 x86/mm: Fix __split_large_page() to handle large PAT bit
 10/10 x86/mm: Fix the same pgprot handling in try_preserve_large_page()

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
