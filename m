Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00F186B04F4
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:42:02 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d193so266330743pgc.0
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 23:42:01 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y5si12227206pgq.414.2017.07.27.23.41.59
        for <linux-mm@kvack.org>;
        Thu, 27 Jul 2017 23:42:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/3] fix several TLB batch races
Date: Fri, 28 Jul 2017 15:41:49 +0900
Message-Id: <1501224112-23656-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team <kernel-team@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

Nadav and Mel founded several subtle races caused by TLB batching.
This patchset aims for solving thoses problems using embedding
[set|clear]_tlb_flush_pending to TLB batching API.
With that, places to know TLB flush pending catch it up by
using mm_tlb_flush_pending.

Each patch includes detailed description.

This patchset is based on v4.13-rc2-mmots-2017-07-26-16-16 +
revert: "mm: prevent racy access to tlb_flush_pending" +
adding: "[PATCH v3 0/2] mm: fixes of tlb_flush_pending races".

Minchan Kim (3):
  mm: make tlb_flush_pending global
  mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem
  mm: fix KSM data corruption

 arch/arm/include/asm/tlb.h  | 15 ++++++++++++++-
 arch/ia64/include/asm/tlb.h | 12 ++++++++++++
 arch/s390/include/asm/tlb.h | 15 +++++++++++++++
 arch/sh/include/asm/tlb.h   |  4 +++-
 arch/um/include/asm/tlb.h   |  8 ++++++++
 fs/proc/task_mmu.c          |  4 +++-
 include/linux/mm_types.h    | 22 +++++-----------------
 kernel/fork.c               |  2 --
 mm/debug.c                  |  2 --
 mm/ksm.c                    |  3 ++-
 mm/memory.c                 | 24 ++++++++++++------------
 11 files changed, 74 insertions(+), 37 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
