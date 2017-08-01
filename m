Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 971DB6B04EB
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 01:56:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 83so7353792pgb.14
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 22:56:21 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 7si16989248pgf.609.2017.07.31.22.56.19
        for <linux-mm@kvack.org>;
        Mon, 31 Jul 2017 22:56:20 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 0/4] fix several TLB batch races
Date: Tue,  1 Aug 2017 14:56:13 +0900
Message-Id: <1501566977-20293-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

Nadav and Mel founded several subtle races caused by TLB batching.
This patchset aims for solving thoses problems using embedding
[inc|dec]_tlb_flush_pending to TLB batching API.
With that, places to know TLB flush pending catch it up by
using mm_tlb_flush_pending.

Each patch includes detailed description.

This patchset is based on v4.13-rc2-mmots-2017-07-28-16-10 +
"[PATCH v5 0/3] mm: fixes of tlb_flush_pending races" from Nadav

* from v1
  * TLB batching API separation core part from arch specific one - Mel
  * introduce mm_tlb_flush_nested - Mel

Minchan Kim (4):
  mm: refactoring TLB gathering API
  mm: make tlb_flush_pending global
  mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem
  mm: fix KSM data corruption

 arch/arm/include/asm/tlb.h  | 11 ++++++--
 arch/ia64/include/asm/tlb.h |  8 ++++--
 arch/s390/include/asm/tlb.h | 17 ++++++++-----
 arch/sh/include/asm/tlb.h   |  8 +++---
 arch/um/include/asm/tlb.h   | 13 +++++++---
 fs/proc/task_mmu.c          |  4 ++-
 include/asm-generic/tlb.h   |  7 ++---
 include/linux/mm_types.h    | 35 ++++++++++---------------
 mm/debug.c                  |  2 --
 mm/ksm.c                    |  3 ++-
 mm/memory.c                 | 62 +++++++++++++++++++++++++++++++--------------
 11 files changed, 107 insertions(+), 63 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
