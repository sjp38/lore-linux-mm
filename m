Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA21A6B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 08:39:41 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id p29so11271305ote.3
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 05:39:41 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n125si2503216oig.113.2018.11.14.05.39.40
        for <linux-mm@kvack.org>;
        Wed, 14 Nov 2018 05:39:40 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V3 0/5] 52-bit userspace VAs
Date: Wed, 14 Nov 2018 13:39:15 +0000
Message-Id: <20181114133920.7134-1-steve.capper@arm.com>
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

Changed in V3, COMPAT fixes added (and tested with 32-bit userspace code).
Extra patch added to allow forcing all userspace allocations to come from
52-bits (to allow for debugging and testing).

The major change to V2 of the series is that mm/mmap.c is altered in the
first patch of the series (rather than copied over to arch/arm64).


Steve Capper (5):
  mm: mmap: Allow for "high" userspace addresses
  arm64: mm: Introduce DEFAULT_MAP_WINDOW
  arm64: mm: Define arch_get_mmap_end, arch_get_mmap_base
  arm64: mm: introduce 52-bit userspace support
  arm64: mm: Allow forcing all userspace addresses to 52-bit

 arch/arm64/Kconfig                      | 18 ++++++++++++++++++
 arch/arm64/include/asm/assembler.h      |  7 +++----
 arch/arm64/include/asm/elf.h            |  4 ++++
 arch/arm64/include/asm/mmu_context.h    |  3 +++
 arch/arm64/include/asm/pgalloc.h        |  4 ++++
 arch/arm64/include/asm/pgtable.h        | 16 +++++++++++++---
 arch/arm64/include/asm/processor.h      | 33 ++++++++++++++++++++++++++++-----
 arch/arm64/kernel/head.S                | 13 +++++++++++++
 arch/arm64/mm/fault.c                   |  2 +-
 arch/arm64/mm/init.c                    |  2 +-
 arch/arm64/mm/mmu.c                     |  1 +
 arch/arm64/mm/proc.S                    | 10 +++++++++-
 drivers/firmware/efi/arm-runtime.c      |  2 +-
 drivers/firmware/efi/libstub/arm-stub.c |  2 +-
 mm/mmap.c                               | 25 ++++++++++++++++++-------
 15 files changed, 118 insertions(+), 24 deletions(-)

-- 
2.11.0
