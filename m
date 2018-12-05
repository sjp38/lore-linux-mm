Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 772E16B754A
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:41:57 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id k76so12757748oih.13
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:41:57 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y8si9647963ota.237.2018.12.05.08.41.56
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 08:41:56 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V4 0/6] 52-bit userspace VAs
Date: Wed,  5 Dec 2018 16:41:39 +0000
Message-Id: <20181205164145.24568-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com, Steve Capper <steve.capper@arm.com>

This patch series brings support for 52-bit userspace VAs to systems that
have ARMv8.2-LVA and are running with a 48-bit VA_BITS and a 64KB
PAGE_SIZE.

If no hardware support is present, the kernel runs with a 48-bit VA space
for userspace.

Userspace can exploit this feature by providing an address hint to mmap
where addr[51:48] != 0. Otherwise all the VA mappings will behave in the
same way as a 48-bit VA system (this is to maintain compatibility with
software that assumes the maximum VA size on arm64 is 48-bit).

This patch series applies to 4.20-rc1.

Testing was in a model with Trusted Firmware and UEFI for boot.

Changed in V4, pgd_index changes dropped in favour of offsetting the
ttbr1. This is performed in a new patch, #4.

Changed in V3, COMPAT fixes added (and tested with 32-bit userspace code).
Extra patch added to allow forcing all userspace allocations to come from
52-bits (to allow for debugging and testing).

The major change to V2 of the series is that mm/mmap.c is altered in the
first patch of the series (rather than copied over to arch/arm64).


Steve Capper (6):
  mm: mmap: Allow for "high" userspace addresses
  arm64: mm: Introduce DEFAULT_MAP_WINDOW
  arm64: mm: Define arch_get_mmap_end, arch_get_mmap_base
  arm64: mm: Offset TTBR1 to allow 52-bit PTRS_PER_PGD
  arm64: mm: introduce 52-bit userspace support
  arm64: mm: Allow forcing all userspace addresses to 52-bit

 arch/arm64/Kconfig                      | 17 ++++++++++++
 arch/arm64/include/asm/asm-uaccess.h    |  4 +++
 arch/arm64/include/asm/assembler.h      | 30 ++++++++++++++++++---
 arch/arm64/include/asm/elf.h            |  4 +++
 arch/arm64/include/asm/mmu_context.h    |  3 +++
 arch/arm64/include/asm/pgtable-hwdef.h  |  9 +++++++
 arch/arm64/include/asm/processor.h      | 36 ++++++++++++++++++++-----
 arch/arm64/include/asm/uaccess.h        |  4 +++
 arch/arm64/kernel/head.S                | 14 ++++++++++
 arch/arm64/kernel/hibernate-asm.S       |  1 +
 arch/arm64/mm/fault.c                   |  2 +-
 arch/arm64/mm/init.c                    |  2 +-
 arch/arm64/mm/mmu.c                     |  1 +
 arch/arm64/mm/proc.S                    | 14 +++++++++-
 drivers/firmware/efi/arm-runtime.c      |  2 +-
 drivers/firmware/efi/libstub/arm-stub.c |  2 +-
 mm/mmap.c                               | 25 ++++++++++++-----
 17 files changed, 148 insertions(+), 22 deletions(-)

-- 
2.19.2
