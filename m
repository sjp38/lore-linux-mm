Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 85E426B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 10:56:11 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so7071371wiv.7
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 07:56:11 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
        by mx.google.com with ESMTPS id e2si4916395wiy.97.2014.08.20.07.56.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Aug 2014 07:56:10 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so7060291wib.17
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 07:56:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
References: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
Date: Wed, 20 Aug 2014 08:56:09 -0600
Message-ID: <CALdTtns6+MRb=Z7i0ncq_c2u7QZWo1mUxD824bvNF==q-_+BiQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] RCU get_user_pages_fast and __get_user_pages_fast
From: Dann Frazier <dann.frazier@canonical.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, anders.roxell@linaro.org, peterz@infradead.org, gary.robertson@linaro.org, Will Deacon <will.deacon@arm.com>, akpm@linux-foundation.org, Christoffer Dall <christoffer.dall@linaro.org>

On Wed, Jun 25, 2014 at 9:40 AM, Steve Capper <steve.capper@linaro.org> wrote:
> Hello,
> This series implements general forms of get_user_pages_fast and
> __get_user_pages_fast and activates them for arm and arm64.
>
> These are required for Transparent HugePages to function correctly, as
> a futex on a THP tail will otherwise result in an infinite loop (due to
> the core implementation of __get_user_pages_fast always returning 0).
>
> This series may also be beneficial for direct-IO heavy workloads and
> certain KVM workloads.
>
> The main changes since RFC V5 are:
>  * Rebased against 3.16-rc1.
>  * pmd_present no longer tested for by gup_huge_pmd and gup_huge_pud,
>    because the entry must be present for these leaf functions to be
>    called.
>  * Rather than assume puds can be re-cast as pmds, a separate
>    function pud_write is instead used by the core gup.
>  * ARM activation logic changed, now it will only activate
>    RCU_TABLE_FREE and RCU_GUP when running with LPAE.
>
> The main changes since RFC V4 are:
>  * corrected the arm64 logic so it now correctly rcu-frees page
>    table backing pages.
>  * rcu free logic relaxed for pre-ARMv7 ARM as we need an IPI to
>    invalidate TLBs anyway.
>  * rebased to 3.15-rc3 (some minor changes were needed to allow it to merge).
>  * dropped Catalin's mmu_gather patch as that's been merged already.
>
> This series has been tested with LTP and some custom futex tests that
> exacerbate the futex on THP tail case. Also debug counters were
> temporarily employed to ensure that the RCU_TABLE_FREE logic was
> behaving as expected.
>
> I would really appreciate any testers or comments (especially on the
> validity or otherwise of the core fast_gup implementation).

I have a test case that can reliably hit the THP issue on arm64, which
hits it on both 3.16 and 3.17-rc1. I do a "juju bootstrap local" w/
THP disabled at boot. Then I reboot with THP enabled. At this point
you'll see jujud spin at 200% CPU. gccgo binaries seem to have a nack
for hitting it.

I validated that your patches resolve this issue on 3.16, so:

Tested-by: dann frazier <dann.frazier@canonical.com>

I haven't done the same for 3.17-rc1 because they no longer apply
cleanly, but I'm happy to test future submissions w/ hopefully a
shorter feedback loop (please add me to the CC). btw, should we
consider something like this until your patches go in?

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index fd4e81a..820e3d9 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -306,6 +306,7 @@ config ARCH_WANT_HUGE_PMD_SHARE

 config HAVE_ARCH_TRANSPARENT_HUGEPAGE
        def_bool y
+       depends on BROKEN

 config ARCH_HAS_CACHE_LINE_SIZE
        def_bool y

  -dann

> Cheers,
> --
> Steve
>
> Steve Capper (6):
>   mm: Introduce a general RCU get_user_pages_fast.
>   arm: mm: Introduce special ptes for LPAE
>   arm: mm: Enable HAVE_RCU_TABLE_FREE logic
>   arm: mm: Enable RCU fast_gup
>   arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
>   arm64: mm: Enable RCU fast_gup
>
>  arch/arm/Kconfig                      |   5 +
>  arch/arm/include/asm/pgtable-2level.h |   2 +
>  arch/arm/include/asm/pgtable-3level.h |  16 ++
>  arch/arm/include/asm/pgtable.h        |   6 +-
>  arch/arm/include/asm/tlb.h            |  38 ++++-
>  arch/arm/mm/flush.c                   |  19 +++
>  arch/arm64/Kconfig                    |   4 +
>  arch/arm64/include/asm/pgtable.h      |  11 +-
>  arch/arm64/include/asm/tlb.h          |  18 ++-
>  arch/arm64/mm/flush.c                 |  19 +++
>  mm/Kconfig                            |   3 +
>  mm/gup.c                              | 278 ++++++++++++++++++++++++++++++++++
>  12 files changed, 410 insertions(+), 9 deletions(-)
>
> --
> 1.9.3
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
