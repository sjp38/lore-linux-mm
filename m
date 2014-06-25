Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 44DAB6B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 11:40:39 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so2767161wib.15
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 08:40:38 -0700 (PDT)
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
        by mx.google.com with ESMTPS id dc5si7438460wib.85.2014.06.25.08.40.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 08:40:37 -0700 (PDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so2219408wgh.12
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 08:40:35 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Date: Wed, 25 Jun 2014 16:40:18 +0100
Message-Id: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>

Hello,
This series implements general forms of get_user_pages_fast and
__get_user_pages_fast and activates them for arm and arm64.

These are required for Transparent HugePages to function correctly, as
a futex on a THP tail will otherwise result in an infinite loop (due to
the core implementation of __get_user_pages_fast always returning 0).

This series may also be beneficial for direct-IO heavy workloads and
certain KVM workloads.

The main changes since RFC V5 are:
 * Rebased against 3.16-rc1.
 * pmd_present no longer tested for by gup_huge_pmd and gup_huge_pud,
   because the entry must be present for these leaf functions to be
   called. 
 * Rather than assume puds can be re-cast as pmds, a separate
   function pud_write is instead used by the core gup.
 * ARM activation logic changed, now it will only activate
   RCU_TABLE_FREE and RCU_GUP when running with LPAE.

The main changes since RFC V4 are:
 * corrected the arm64 logic so it now correctly rcu-frees page
   table backing pages.
 * rcu free logic relaxed for pre-ARMv7 ARM as we need an IPI to
   invalidate TLBs anyway.
 * rebased to 3.15-rc3 (some minor changes were needed to allow it to merge).
 * dropped Catalin's mmu_gather patch as that's been merged already.

This series has been tested with LTP and some custom futex tests that
exacerbate the futex on THP tail case. Also debug counters were
temporarily employed to ensure that the RCU_TABLE_FREE logic was
behaving as expected.

I would really appreciate any testers or comments (especially on the
validity or otherwise of the core fast_gup implementation).

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

 arch/arm/Kconfig                      |   5 +
 arch/arm/include/asm/pgtable-2level.h |   2 +
 arch/arm/include/asm/pgtable-3level.h |  16 ++
 arch/arm/include/asm/pgtable.h        |   6 +-
 arch/arm/include/asm/tlb.h            |  38 ++++-
 arch/arm/mm/flush.c                   |  19 +++
 arch/arm64/Kconfig                    |   4 +
 arch/arm64/include/asm/pgtable.h      |  11 +-
 arch/arm64/include/asm/tlb.h          |  18 ++-
 arch/arm64/mm/flush.c                 |  19 +++
 mm/Kconfig                            |   3 +
 mm/gup.c                              | 278 ++++++++++++++++++++++++++++++++++
 12 files changed, 410 insertions(+), 9 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
