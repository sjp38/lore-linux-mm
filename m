Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6078C6B0037
	for <linux-mm@kvack.org>; Sun,  6 Jul 2014 20:52:28 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so4437121pad.41
        for <linux-mm@kvack.org>; Sun, 06 Jul 2014 17:52:26 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id cc3si39880671pad.47.2014.07.06.17.52.24
        for <linux-mm@kvack.org>;
        Sun, 06 Jul 2014 17:52:25 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 0/7] MADV_FREE support
Date: Mon,  7 Jul 2014 09:53:51 +0900
Message-Id: <1404694438-10272-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>

This patch enable MADV_FREE hint for madvise syscall, which have
been supported by other OSes. [PATCH 1] includes the details.

[1] support MADVISE_FREE for !THP page so if VM encounter
THP page in syscall context, it splits THP page.
[2-6] is to preparing to call madvise syscall without THP plitting
[7] enable THP page support for MADV_FREE.

* From v9
 * Add Acked-by - Rik
 * Add THP page support - Kirill
 * Rebased-on v3.16-rc3-mmotm-2014-07-02-15-07

* From v8
 * Rebased-on v3.16-rc2-mmotm-2014-06-25-16-44

* From v7
 * Rebased-on next-20140613

* From v6
 * Remove page from swapcache in syscal time
 * Move utility functions from memory.c to madvise.c - Johannes
 * Rename untilify functtions - Johannes
 * Remove unnecessary checks from vmscan.c - Johannes
 * Rebased-on v3.15-rc5-mmotm-2014-05-16-16-56
 * Drop Reviewe-by because there was some changes since then.

* From v5
 * Fix PPC problem which don't flush TLB - Rik
 * Remove unnecessary lazyfree_range stub function - Rik
 * Rebased on v3.15-rc5

* From v4
 * Add Reviewed-by: Zhang Yanfei
 * Rebase on v3.15-rc1-mmotm-2014-04-15-16-14

* From v3
 * Add "how to work part" in description - Zhang
 * Add page_discardable utility function - Zhang
 * Clean up

* From v2
 * Remove forceful dirty marking of swap-readed page - Johannes
 * Remove deactivation logic of lazyfreed page
 * Rebased on 3.14
 * Remove RFC tag

* From v1
 * Use custom page table walker for madvise_free - Johannes
 * Remove PG_lazypage flag - Johannes
 * Do madvise_dontneed instead of madvise_freein swapless system


Minchan Kim (7):
  [1] mm: support madvise(MADV_FREE)
  [2] x86: add pmd_[dirty|mkclean] for THP
  [3] sparc: add pmd_[dirty|mkclean] for THP
  [4] powerpc: add pmd_[dirty|mkclean] for THP
  [5] s390: add pmd_[dirty|mkclean] for THP
  [6] ARM: add pmd_[dirty|mkclean] for THP
  [7] mm: Don't split THP page when syscall is called

 arch/arm64/include/asm/pgtable.h         |   2 +
 arch/powerpc/include/asm/pgtable-ppc64.h |   2 +
 arch/s390/include/asm/pgtable.h          |  12 ++
 arch/sparc/include/asm/pgtable_64.h      |  16 +++
 arch/x86/include/asm/pgtable.h           |  10 ++
 include/linux/huge_mm.h                  |   3 +
 include/linux/rmap.h                     |   8 +-
 include/linux/vm_event_item.h            |   1 +
 include/uapi/asm-generic/mman-common.h   |   1 +
 mm/huge_memory.c                         |  25 ++++
 mm/madvise.c                             | 189 +++++++++++++++++++++++++++++++
 mm/rmap.c                                |  38 ++++++-
 mm/vmscan.c                              |  57 +++++++---
 mm/vmstat.c                              |   1 +
 14 files changed, 348 insertions(+), 17 deletions(-)

-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
