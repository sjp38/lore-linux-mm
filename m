Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id EA47D8299E
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:30:26 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id f8so3715230wiw.8
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:30:25 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
        by mx.google.com with ESMTPS id sg12si4647849wic.23.2014.05.06.08.30.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 08:30:24 -0700 (PDT)
Received: by mail-wi0-f173.google.com with SMTP id bs8so7515201wib.0
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:30:24 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH V5 0/6] get_user_pages_fast for ARM and ARM64
Date: Tue,  6 May 2014 16:30:03 +0100
Message-Id: <1399390209-1756-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>

Hello,
This RFC series implements get_user_pages_fast and __get_user_pages_fast.
These are required for Transparent HugePages to function correctly, as
a futex on a THP tail will otherwise result in an infinite loop (due to
the core implementation of __get_user_pages_fast always returning 0).
This series may also be beneficial for direct-IO heavy workloads and
certain KVM workloads.

The main changes since RFC V4 are:
 * corrected the arm64 logic so it now correctly rcu-frees page
   table backing pages.
 * rcu free logic relaxed for pre-ARMv7 ARM as we need an IPI to
   invalidate TLBs anyway.
 * rebased to 3.15-rc3 (some minor changes were needed to allow it to merge).
 * dropped Catalin's mmu_gather patch as that's been merged already.

I would really appreciate any comments (especially on the validity or
otherwise of the core fast_gup implementation) and/or testers.

Cheers,
--
Steve



Steve Capper (6):
  mm: Introduce a general RCU get_user_pages_fast.
  arm: mm: Introduce special ptes for LPAE
  arm: mm: Enable HAVE_RCU_TABLE_FREE logic
  arm: mm: Enable RCU fast_gup
  arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
  arm64: mm: Enable RCU fast_gup

 arch/arm/Kconfig                      |   4 +
 arch/arm/include/asm/pgtable-2level.h |   2 +
 arch/arm/include/asm/pgtable-3level.h |  14 ++
 arch/arm/include/asm/pgtable.h        |   6 +-
 arch/arm/include/asm/tlb.h            |  38 ++++-
 arch/arm/mm/flush.c                   |  19 +++
 arch/arm64/Kconfig                    |   4 +
 arch/arm64/include/asm/pgtable.h      |   8 +-
 arch/arm64/include/asm/tlb.h          |  18 ++-
 arch/arm64/mm/flush.c                 |  19 +++
 mm/Kconfig                            |   3 +
 mm/Makefile                           |   1 +
 mm/gup.c                              | 297 ++++++++++++++++++++++++++++++++++
 13 files changed, 424 insertions(+), 9 deletions(-)
 create mode 100644 mm/gup.c

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
