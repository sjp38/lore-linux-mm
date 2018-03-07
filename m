Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B08916B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 12:47:34 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id a144so2337042qkb.3
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 09:47:34 -0800 (PST)
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com. [15.233.44.27])
        by mx.google.com with ESMTPS id 21si3789379qkk.313.2018.03.07.09.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 09:47:33 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 0/2] fix memory leak / panic in ioremap huge pages
Date: Wed,  7 Mar 2018 11:32:25 -0700
Message-Id: <20180307183227.17983-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com
Cc: guohanjun@huawei.com, will.deacon@arm.com, wxf.wang@hisilicon.com, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

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

Patch 01 adds new interfaces as stubs, which work as workaround of
this issue.  This patch 01 was leveraged from Hanjun's patch. [1]
Patch 02 fixes the issue on x86 by implementing the interfaces.

[1] https://patchwork.kernel.org/patch/10134581/

---
Toshi Kani (2):
 1/2 mm/vmalloc: Add interfaces to free unused page table
 2/2 x86/mm: implement free pmd/pte page interfaces

---
 arch/arm64/mm/mmu.c           | 10 ++++++++++
 arch/x86/mm/pgtable.c         | 44 +++++++++++++++++++++++++++++++++++++++++++
 include/asm-generic/pgtable.h | 10 ++++++++++
 lib/ioremap.c                 |  6 ++++--
 4 files changed, 68 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
