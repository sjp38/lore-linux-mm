Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3A126B0007
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 14:00:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x22so2962976pfn.3
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 11:00:23 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id 7-v6si7910419plc.164.2018.04.30.11.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 11:00:22 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 0/3] fix free pmd/pte page handlings on x86
Date: Mon, 30 Apr 2018 11:59:22 -0600
Message-Id: <20180430175925.2657-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

This series fixes x86 ioremap free page handlings when setting up
pud/pmd maps.

Patch 01 is from Chintan's v9 01/04 patch [1], which adds a new arg 'addr'.
This avoids merge conflicts with his series.

Patch 02 adds a TLB purge (INVLPG) to purge page-structure caches that
may be cached by speculation.  See patch 2/2 for the detals.

Patch 03 disables free page handling on x86-PAE to address BUG_ON reported
by Joerg.

[1] https://patchwork.kernel.org/patch/10371015/

---
Chintan Pandya (1):
  1/3 ioremap: Update pgtable free interfaces with addr

Toshi Kani (2):
  2/3 x86/mm: add TLB purge to free pmd/pte page interfaces
  3/3 x86/mm: disable ioremap free page handling on x86-PAE

---
 arch/arm64/mm/mmu.c           |  4 +--
 arch/x86/mm/pgtable.c         | 57 +++++++++++++++++++++++++++++++++++++------
 include/asm-generic/pgtable.h |  8 +++---
 lib/ioremap.c                 |  4 +--
 4 files changed, 57 insertions(+), 16 deletions(-)
