Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2F77F28029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:25:00 -0400 (EDT)
Received: by obbop1 with SMTP id op1so29806244obb.2
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:24:59 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id i3si4178653oif.60.2015.07.15.09.24.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 09:24:59 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 0/4] x86, mm: Handle large PAT bit in pud/pmd interfaces
Date: Wed, 15 Jul 2015 10:23:51 -0600
Message-Id: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com

The PAT bit gets relocated to bit 12 when PUD and PMD mappings are used.
This bit 12, however, is not covered by PTE_FLAGS_MASK, which is corrently
used for masking pfn and flags for all cases.

Patch 1/4-2/4 make changes necessary for patch 3/4 to use P?D_PAGE_MASK.

Patch 3/4 fixes pud/pmd interfaces to handle the PAT bit when PUD and PMD
mappings are used.

Patch 3/4 fixes /sys/kernel/debug/kernel_page_tables to show the PAT bit
properly.

Note, the PAT bit is first enabled in 4.2-rc1 with WT mappings.

---
v2:
 - Change p?n_pfn() to handle the PAT bit. (Juergen Gross)
 - Mask pfn and flags with P?D_PAGE_MASK. (Juergen Gross)
 - Change p?d_page_vaddr() and p?d_page() to handle the PAT bit.

---
Toshi Kani (4):
  1/4 x86/vdso32: Define PGTABLE_LEVELS to 32bit VDSO
  2/4 x86, asm: Move PUD_PAGE macros to page_types.h
  3/4 x86: Fix pud/pmd interfaces to handle large PAT bit
  4/4 x86, mm: Fix page table dump to show PAT bit

---
4fa1ff9a08c...dd58e3d52618b00dd768de1753c35611906fcbee --stat
 arch/x86/entry/vdso/vdso32/vclock_gettime.c |  2 ++
 arch/x86/include/asm/page_64_types.h        |  3 ---
 arch/x86/include/asm/page_types.h           |  3 +++
 arch/x86/include/asm/pgtable.h              | 14 +++++-----
 arch/x86/include/asm/pgtable_types.h        | 40 ++++++++++++++++++++++++++---
 arch/x86/mm/dump_pagetables.c               | 39 +++++++++++++++-------------
 6 files changed, 70 insertions(+), 31 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
