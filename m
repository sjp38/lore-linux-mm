Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2F06B000D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:15:48 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id h3-v6so1588114otj.15
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 07:15:48 -0700 (PDT)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id h9-v6si1261440oti.357.2018.06.27.07.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 07:15:46 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 0/3] fix free pmd/pte page handlings on x86
Date: Wed, 27 Jun 2018 08:13:45 -0600
Message-Id: <20180627141348.21777-1-toshi.kani@hpe.com>
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

The patches are based off from the tip tree.

[1] https://patchwork.kernel.org/patch/10371015/

v4:
 - Re-wrote patch 2/3 description. (v3-UPDATE)
 - Added NOTE to pud_free_pmd_page().

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
 arch/x86/mm/pgtable.c         | 61 +++++++++++++++++++++++++++++++++++++------
 include/asm-generic/pgtable.h |  8 +++---
 lib/ioremap.c                 |  4 +--
 4 files changed, 61 insertions(+), 16 deletions(-)
