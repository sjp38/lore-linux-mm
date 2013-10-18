Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 230956B0148
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 09:07:38 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so1556255pdj.24
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 06:07:37 -0700 (PDT)
Received: from psmtp.com ([74.125.245.159])
        by mx.google.com with SMTP id gn4si875608pbc.171.2013.10.18.06.07.36
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 06:07:37 -0700 (PDT)
Received: by mail-wg0-f44.google.com with SMTP id n12so3717307wgh.35
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 06:07:34 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH 0/2] Implement get_user_pages_fast for ARM
Date: Fri, 18 Oct 2013 14:07:11 +0100
Message-Id: <1382101634-4723-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoffer Dall <christoffer.dall@linaro.org>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, Zi Shen Lim <zishen.lim@linaro.org>, patches@linaro.org, linaro-kernel@lists.linaro.org, Steve Capper <steve.capper@linaro.org>

This patch series implements get_user_pages_fast on ARM. Unlike other
architectures, we do not use IPIs/disabled IRQs as a blocking
mechanism to protect the page table walker. Instead an atomic counter
is used to indicate how many fast gup walkers are active on an address
space, and any code that would cause them problems (THP splitting or
code that could free a page table page) spins on positive values of
this counter.

This series also addresses an assumption made in kernel/futex.c that
THP page splitting can be blocked by disabling the IRQs on a processor
by introducing arch_block_thp_split and arch_unblock_thp_split.

As well as fixing a problem where futexes on THP tails cause hangs on
ARM, I expect this series to also be beneficial for direct-IO, and for
KVM (the hva_to_pfn fast path uses __get_user_pages_fast).

Any comments would be greatly appreciated.

Steve Capper (2):
  thp: Introduce arch_(un)block_thp_split
  arm: mm: implement get_user_pages_fast

 arch/arm/include/asm/mmu.h            |   1 +
 arch/arm/include/asm/pgalloc.h        |   9 ++
 arch/arm/include/asm/pgtable-2level.h |   1 +
 arch/arm/include/asm/pgtable-3level.h |  21 +++
 arch/arm/include/asm/pgtable.h        |  18 +++
 arch/arm/include/asm/tlb.h            |   8 ++
 arch/arm/mm/Makefile                  |   2 +-
 arch/arm/mm/gup.c                     | 234 ++++++++++++++++++++++++++++++++++
 include/linux/huge_mm.h               |  16 +++
 kernel/futex.c                        |   6 +-
 10 files changed, 312 insertions(+), 4 deletions(-)
 create mode 100644 arch/arm/mm/gup.c

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
