Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8961B6B0275
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 17:00:59 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id x190so27212006qkb.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 14:00:59 -0700 (PDT)
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com. [209.85.220.181])
        by mx.google.com with ESMTPS id n66si2168328qka.157.2016.11.02.14.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 14:00:58 -0700 (PDT)
Received: by mail-qk0-f181.google.com with SMTP id o68so33678225qkf.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 14:00:58 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv2 0/6] CONFIG_DEBUG_VIRTUAL for arm64
Date: Wed,  2 Nov 2016 15:00:48 -0600
Message-Id: <20161102210054.16621-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

Hi,

This is v2 of the series to add CONFIG_DEBUG_VIRTUAL support from arm64. This
has been split out into a number of patches:

Patch #1 Adds ARCH_HAS_DEBUG_VIRTUAL to avoid the need for adding arch
dependencies for DEBUG_VIRTUAL. This touches arch/x86/Kconfig

Patch #2 Cleans up cma to not rely on __pa_nodebug and have an #ifdef inline
in the function.

Patch #3 Adjust some macros in arm64 memory.h to be under __ASSEMBLY__
protection

Patch #4 Adds a cast for virt_to_pfn since __virt_to_phys for DEBUG_VIRTUAL no
longer has a cast.

Patch #5 Switches to using __pa_symbol for _end to avoid erroneously triggering
a bounds error with the debugging.

Patch #6 is the actual implementation of DEBUG_VIRTUAL. The biggest change from
the RFCv1 is the addition of __phys_addr_symbol. This is to handle several
places where the physical address of _end is needed. x86 avoids this problem by
doing its bounds check based on the entire possible image space which is well
beyond where _end would end up.

There are a few dependencies outside of arm64, so I don't know if
it will be easier for this to eventually go through arm64 or the mm tree.

Thanks,
Laura




Laura Abbott (6):
  lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
  mm/cma: Cleanup highmem check
  arm64: Move some macros under #ifndef __ASSEMBLY__
  arm64: Add cast for virt_to_pfn
  arm64: Use __pa_symbol for _end
  arm64: Add support for CONFIG_DEBUG_VIRTUAL

 arch/arm64/Kconfig              |  1 +
 arch/arm64/include/asm/memory.h | 50 ++++++++++++++++++++++++-----------------
 arch/arm64/mm/Makefile          |  2 ++
 arch/arm64/mm/init.c            |  4 ++--
 arch/arm64/mm/physaddr.c        | 34 ++++++++++++++++++++++++++++
 arch/x86/Kconfig                |  1 +
 lib/Kconfig.debug               |  5 ++++-
 mm/cma.c                        | 15 +++++--------
 8 files changed, 79 insertions(+), 33 deletions(-)
 create mode 100644 arch/arm64/mm/physaddr.c

-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
