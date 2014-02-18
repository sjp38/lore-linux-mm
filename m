Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A26D66B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 10:27:32 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id l18so3352910wgh.0
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:27:31 -0800 (PST)
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
        by mx.google.com with ESMTPS id gf8si12394979wjc.150.2014.02.18.07.27.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 07:27:30 -0800 (PST)
Received: by mail-we0-f182.google.com with SMTP id u57so11944252wes.27
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:27:29 -0800 (PST)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 0/5] Huge pages for short descriptors on ARM
Date: Tue, 18 Feb 2014 15:27:10 +0000
Message-Id: <1392737235-27286-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-mm@kvack.org
Cc: will.deacon@arm.com, catalin.marinas@arm.com, arnd@arndb.de, dsaxena@linaro.org, robherring2@gmail.com, Steve Capper <steve.capper@linaro.org>

Hello,
This series brings HugeTLB pages and Transparent Huge Pages (THP) to
ARM on short descriptors.

We use a pair of 1MB sections to represent a 2MB huge page. Both
HugeTLB and THP entries are represented by PMDs with the same bit
layout.

The short descriptor page table manipulation code on ARM makes a
distinction between Linux and hardware ptes and performs the necessary
translation in the assembler pte setter functions. The huge page code
instead manipulates the hardware entries directly.

There is one small bit of translation that takes place to populate an
appropriate pgprot_t value for the VMA containing the huge page. Once
we have that pgprot_t, we can manipulate huge ptes/pmds as normal with
the bit and modify funcs.

In order to be able to manipulate huge ptes directly, I've introduced
three new manipulation functions: huge_pte_page, huge_present and
huge_pte_young. If undefined, these will default to the standard pte
analogues.

I have tested this series on an Arndale board running 3.14-rc3. The
libhugetlbfs checks, LTP and some custom THP PROT_NONE tests were used
to test this series.

Since the RFC in December, I have rebased the code against 3.14-rc3 and
tidied up the code.

Cheers,
--
Steve

Steve Capper (5):
  mm: hugetlb: Introduce huge_pte_{page,present,young}
  arm: mm: Adjust the parameters for __sync_icache_dcache
  arm: mm: Make mmu_gather aware of huge pages
  arm: mm: HugeTLB support for non-LPAE systems
  arm: mm: Add Transparent HugePage support for non-LPAE

 arch/arm/Kconfig                      |   4 +-
 arch/arm/include/asm/hugetlb-2level.h | 121 +++++++++++++++++++++++++++++++
 arch/arm/include/asm/hugetlb-3level.h |   6 ++
 arch/arm/include/asm/hugetlb.h        |  10 +--
 arch/arm/include/asm/pgtable-2level.h | 133 +++++++++++++++++++++++++++++++++-
 arch/arm/include/asm/pgtable-3level.h |   3 +-
 arch/arm/include/asm/pgtable.h        |   9 +--
 arch/arm/include/asm/tlb.h            |  14 +++-
 arch/arm/kernel/head.S                |  10 ++-
 arch/arm/mm/fault.c                   |  13 ----
 arch/arm/mm/flush.c                   |   9 +--
 arch/arm/mm/fsr-2level.c              |   4 +-
 arch/arm/mm/hugetlbpage.c             |   2 +-
 arch/arm/mm/mmu.c                     |  51 +++++++++++++
 include/linux/hugetlb.h               |  12 +++
 mm/hugetlb.c                          |  22 +++---
 16 files changed, 370 insertions(+), 53 deletions(-)
 create mode 100644 arch/arm/include/asm/hugetlb-2level.h

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
