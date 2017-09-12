Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3E26B0268
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 11:40:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q75so21153900pfl.1
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 08:40:23 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s11si8859312plj.104.2017.09.12.08.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 08:40:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 00/11] Do not loose dirty bit on THP pages
Date: Tue, 12 Sep 2017 18:39:30 +0300
Message-Id: <20170912153941.47012-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Vlastimil noted that pmdp_invalidate() is not atomic and we can loose
dirty and access bits if CPU sets them after pmdp dereference, but
before set_pmd_at().

The bug can lead to data loss, but the race window is tiny and I haven't
seen any reports that suggested that it happens in reality. So I don't
think it worth sending it to stable.

Unfortunately, there's no way to address the issue in a generic way. We need to
fix all architectures that support THP one-by-one.

All architectures that have THP supported have to provide atomic
pmdp_invalidate() that returns previous value.

If generic implementation of pmdp_invalidate() is used, architecture needs to
provide atomic pmdp_estabish().

pmdp_estabish() is not used out-side generic implementation of
pmdp_invalidate() so far, but I think this can change in the future.

Aneesh Kumar K.V (2):
  powerpc/mm: update pmdp_invalidate to return old pmd value
  sparc64: update pmdp_invalidate to return old pmd value

Catalin Marinas (1):
  arm64: Provide pmdp_establish() helper

Kirill A. Shutemov (7):
  asm-generic: Provide generic_pmdp_establish()
  arc: Use generic_pmdp_establish as pmdp_establish
  arm/mm: Provide pmdp_establish() helper
  mips: Use generic_pmdp_establish as pmdp_establish
  x86/mm: Provide pmdp_establish() helper
  mm: Do not loose dirty and access bits in pmdp_invalidate()
  mm: Use updated pmdp_invalidate() interface to track dirty/accessed
    bits

Martin Schwidefsky (1):
  s390/mm: Modify pmdp_invalidate to return old value.

 arch/arc/include/asm/hugepage.h              |  3 +++
 arch/arm/include/asm/pgtable-3level.h        |  3 +++
 arch/arm64/include/asm/pgtable.h             |  7 ++++++
 arch/mips/include/asm/pgtable.h              |  3 +++
 arch/powerpc/include/asm/book3s/64/pgtable.h |  4 +--
 arch/powerpc/mm/pgtable-book3s64.c           |  7 ++++--
 arch/s390/include/asm/pgtable.h              |  5 ++--
 arch/sparc/include/asm/pgtable_64.h          |  2 +-
 arch/sparc/mm/tlb.c                          | 23 +++++++++++++----
 arch/x86/include/asm/pgtable-3level.h        | 37 +++++++++++++++++++++++++++-
 arch/x86/include/asm/pgtable.h               | 15 +++++++++++
 fs/proc/task_mmu.c                           |  8 +++---
 include/asm-generic/pgtable.h                | 17 ++++++++++++-
 mm/huge_memory.c                             | 29 +++++++++-------------
 mm/pgtable-generic.c                         |  6 ++---
 15 files changed, 131 insertions(+), 38 deletions(-)

-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
