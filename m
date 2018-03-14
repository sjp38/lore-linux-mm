Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 107FA6B0010
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 14:11:32 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e17so1753746pgv.5
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:11:32 -0700 (PDT)
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com. [15.241.140.75])
        by mx.google.com with ESMTPS id n11-v6si2312061plg.565.2018.03.14.11.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 11:11:30 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 0/2] fix memory leak / panic in ioremap huge pages
Date: Wed, 14 Mar 2018 12:01:53 -0600
Message-Id: <20180314180155.19492-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com
Cc: guohanjun@huawei.com, will.deacon@arm.com, wxf.wang@hisilicon.com, willy@infradead.org, cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

On architectures with CONFIG_HAVE_ARCH_HUGE_VMAP set, ioremap()
may create pud/pmd mappings.  Kernel panic was observed on arm64
systems with Cortex-A75 in the following steps as described by
Hanjun Guo. [1]

 1. ioremap a 4K size, valid page table will build,
 2. iounmap it, pte0 will set to 0;
 3. ioremap the same address with 2M size, pgd/pmd is unchanged,
    then set the a new value for pmd;
 4. pte0 is leaked;
 5. CPU may meet exception because the old pmd is still in TLB,
    which will lead to kernel panic.

This panic is not reproducible on x86.  INVLPG, called from iounmap,
purges all levels of entries associated with purged address on x86.
x86 still has memory leak.

The patch changes the ioremap path to free unmapped page table(s) since
doing so in the unmap path has the following issues:

 - The iounmap() path is shared with vunmap().  Since vmap() only
   supports pte mappings, making vunmap() to free a pte page is an
   overhead for regular vmap users as they do not need a pte page
   freed up.
 - Checking if all entries in a pte page are cleared in the unmap path
   is racy, and serializing this check is expensive.
 - The unmap path calls free_vmap_area_noflush() to do lazy TLB purges.
   Clearing a pud/pmd entry before the lazy TLB purges needs extra TLB
   purge.

Patch 01 adds new interfaces as stubs, which work as workaround of
this issue.  This patch 01 was leveraged from Hanjun's patch. [1]

Patch 02 fixes the issue on x86 by implementing the interfaces.
A separate patch (not included in this series) is necessary for arm64.

[1] https://patchwork.kernel.org/patch/10134581/

---
v2
 - Added cc to stable (Andrew Morton)
 - Added proper function headers (Matthew Wilcox)
 - Added descriptions why fixing in the ioremap path. (Will Deacon)

---
Toshi Kani (2):
 1/2 mm/vmalloc: Add interfaces to free unmapped page table
 2/2 x86/mm: implement free pmd/pte page interfaces

---
 arch/arm64/mm/mmu.c           | 10 ++++++++++
 arch/x86/mm/pgtable.c         | 44 +++++++++++++++++++++++++++++++++++++++++++
 include/asm-generic/pgtable.h | 10 ++++++++++
 lib/ioremap.c                 |  6 ++++--
 4 files changed, 68 insertions(+), 2 deletions(-)
