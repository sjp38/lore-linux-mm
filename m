Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id EA0E56B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 14:03:47 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id h18so561168igc.7
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 11:03:47 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id z7si21982411ign.25.2014.07.02.11.03.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 11:03:46 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv4 0/5] DMA Atomic pool for arm64
Date: Wed,  2 Jul 2014 11:03:33 -0700
Message-Id: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>

Hi,

This is the latest in a series to add support for atomic DMA allocations
for non-coherent/CMA code paths in arm64. I did some refactoring to have
arm also use genalloc and pull out some of the remapping code.

This could probably use more testing on other platforms, especially those
that have CONFIG_ARM_DMA_USE_IOMMU set.

Thanks,
Laura

v4: Simplified the logic in gen_pool_first_fit_order_align which makes the
data argument actually unused.

v3: Now a patch series due to refactoring of arm code. arm and arm64 now both
use genalloc for atomic pool management. genalloc extensions added.
DMA remapping code factored out as well.

v2: Various bug fixes pointed out by David and Ritesh (CMA dependency, swapping
coherent, noncoherent). I'm still not sure how to address the devicetree
suggestion by Will [1][2]. I added the devicetree mailing list this time around
to get more input on this.

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2014-April/249180.html
[2] http://lists.infradead.org/pipermail/linux-arm-kernel/2014-April/249528.html


Laura Abbott (5):
  lib/genalloc.c: Add power aligned algorithm
  lib/genalloc.c: Add genpool range check function
  common: dma-mapping: Introduce common remapping functions
  arm: use genalloc for the atomic pool
  arm64: Add atomic pool for non-coherent and CMA allocations.

 arch/arm/Kconfig                         |   1 +
 arch/arm/mm/dma-mapping.c                | 200 ++++++++-----------------------
 arch/arm64/Kconfig                       |   1 +
 arch/arm64/mm/dma-mapping.c              | 154 +++++++++++++++++++++---
 drivers/base/dma-mapping.c               |  67 +++++++++++
 include/asm-generic/dma-mapping-common.h |   9 ++
 include/linux/genalloc.h                 |   7 ++
 lib/genalloc.c                           |  49 ++++++++
 8 files changed, 323 insertions(+), 165 deletions(-)

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
