Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCAE8E0004
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:26:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id m197-v6so1703466oig.18
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 03:26:04 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h64-v6si437451oif.211.2018.09.12.03.26.02
        for <linux-mm@kvack.org>;
        Wed, 12 Sep 2018 03:26:02 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH 0/5] Clean up huge vmap and ioremap code
Date: Wed, 12 Sep 2018 11:26:09 +0100
Message-Id: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org, Will Deacon <will.deacon@arm.com>

Hi all,

The recent introduction of break-before-make on the huge vmap path in
b6bdb7517c3d ("mm/vmalloc: add interfaces to free unmapped page table")
introduced a pair of arch functions for freeing a child level of page
table before putting down a huge mapping at the parent level.

Whilst this works well, the semantics of the pXd_free_pYd_table() function
are slightly confusing, and this led to an over-eager VM_WARN_ON in the
arm64 code that we fixed in -rc3 [1]. Linus suggested that the interface
could be tidied up so that the pXd_present() checks are moved into the
caller, so I've implemented that and generally cleaned up the ioremap code
so that it's easier to follow. I also extended the break-before-make code
to cover the huge p4d case, although this remains unused by any architectures.

Feedback welcome.

Cheers,

Will

[1] https://lkml.org/lkml/2018/9/7/898

--->8

Will Deacon (5):
  ioremap: Rework pXd_free_pYd_page() API
  arm64: mmu: Drop pXd_present() checks from pXd_free_pYd_table()
  x86: pgtable: Drop pXd_none() checks from pXd_free_pYd_table()
  lib/ioremap: Ensure phys_addr actually corresponds to a physical
    address
  lib/ioremap: Ensure break-before-make is used for huge p4d mappings

 arch/arm64/mm/mmu.c           |  13 +++---
 arch/x86/mm/pgtable.c         |  14 +++---
 include/asm-generic/pgtable.h |   5 ++
 lib/ioremap.c                 | 103 +++++++++++++++++++++++++++++-------------
 4 files changed, 91 insertions(+), 44 deletions(-)

-- 
2.1.4
