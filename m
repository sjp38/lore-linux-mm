Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B10166B0370
	for <linux-mm@kvack.org>; Wed, 16 May 2018 19:33:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v26-v6so946415pgc.14
        for <linux-mm@kvack.org>; Wed, 16 May 2018 16:33:21 -0700 (PDT)
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com. [15.241.140.75])
        by mx.google.com with ESMTPS id u123-v6si3544569pfu.322.2018.05.16.16.33.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 16:33:20 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 0/3] fix free pmd/pte page handlings on x86
Date: Wed, 16 May 2018 17:32:04 -0600
Message-Id: <20180516233207.1580-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

This series fixes two issues in the x86 ioremap free page handlings
for pud/pmd mappings.

Patch 01 fixes BUG_ON on x86-PAE reported by Joerg.  It disables
the free page handling on x86-PAE.

Patch 02-03 fixes a possible issue with speculation which can cause
stale page-directory cache.
 - Patch 02 is from Chintan's v9 01/04 patch [1], which adds a new arg
   'addr', with my merge change to patch 01.
 - Patch 03 adds a TLB purge (INVLPG) to purge page-structure caches
   that may be cached by speculation.  See the patch descriptions for
   more detal.

[1] https://patchwork.kernel.org/patch/10371015/

v3:
 - Fixed a build error in v2.

v2:
 - Reordered patch-set, so that patch 01 can be applied independently.
 - Added a NULL pointer check for the page alloc in patch 03. 

---
Toshi Kani (2):
  1/3 x86/mm: disable ioremap free page handling on x86-PAE
  3/3 x86/mm: add TLB purge to free pmd/pte page interfaces

Chintan Pandya (1):
  2/3 ioremap: Update pgtable free interfaces with addr

---
 arch/arm64/mm/mmu.c           |  4 +--
 arch/x86/mm/pgtable.c         | 59 +++++++++++++++++++++++++++++++++++++------
 include/asm-generic/pgtable.h |  8 +++---
 lib/ioremap.c                 |  4 +--
 4 files changed, 59 insertions(+), 16 deletions(-)
