Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6636B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:32:47 -0500 (EST)
Received: by igl9 with SMTP id 9so90036965igl.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:32:47 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id m2si15677947igv.76.2015.11.11.20.32.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 20:32:44 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 00/17] MADFV_FREE support
Date: Thu, 12 Nov 2015 13:32:56 +0900
Message-Id: <1447302793-5376-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Minchan Kim <minchan@kernel.org>

MADV_FREE is on linux-next so long time. The reason was two, I think.

1. MADV_FREE code on reclaim path was really mess.

2. Andrew really want to see voice of userland people who want to use
   the syscall.

A few month ago, Daniel Micay(jemalloc active contributor) requested me
to make progress upstreaming but I was busy at that time so it took
so long time for me to revist the code and finally, I clean it up the
mess recently so it solves the #2 issue.

As well, Daniel and Jason(jemalloc maintainer) requested it to Andrew
again recently and they said it would be great to have even though
it has swap dependency now so Andrew decided he will do that for v4.4.

However, there were some concerns, still.

* hotness

Someone think MADV_FREEed pages are really cold while others are not.
Look at detail in decscription of mm: add knob to tune lazyfreeing.

* swap dependency

In old version, MADV_FREE is equal to MADV_DONTNEED on swapless
system because we don't have aged anonymous LRU list on swapless.
So there are requests for MADV_FREE to support swapless system.

For addressing issues, this version includes new LRU list for
hinted pages and tuning knob. With that, we could support swapless
without zapping hinted pages instantly.

Please, review and comment.

I have been tested it on v4.3-rc7 and couldn't find any problem so far.

git: git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git
branch: mm/madv_free-v4.3-rc7-v3-lazyfreelru

In this stage, I don't think we need to write man page.
It could be done after solid policy and implementation.

 * Change from v2
   * add new LRU list and tuning knob
   * support swapless

 * Change from v1
   * Don't do unnecessary TLB flush - Shaohua
   * Added Acked-by - Hugh, Michal
   * Merge deactivate_page and deactivate_file_page
   * Add pmd_dirty/pmd_mkclean patches for several arches
   * Add lazy THP split patch
   * Drop zhangyanfei@cn.fujitsu.com - Delivery Failure

Chen Gang (1):
  arch: uapi: asm: mman.h: Let MADV_FREE have same value for all
    architectures

Minchan Kim (16):
  mm: support madvise(MADV_FREE)
  mm: define MADV_FREE for some arches
  mm: free swp_entry in madvise_free
  mm: move lazily freed pages to inactive list
  mm: clear PG_dirty to mark page freeable
  mm: mark stable page dirty in KSM
  x86: add pmd_[dirty|mkclean] for THP
  sparc: add pmd_[dirty|mkclean] for THP
  powerpc: add pmd_[dirty|mkclean] for THP
  arm: add pmd_mkclean for THP
  arm64: add pmd_mkclean for THP
  mm: don't split THP page when syscall is called
  mm: introduce wrappers to add new LRU
  mm: introduce lazyfree LRU list
  mm: support MADV_FREE on swapless system
  mm: add knob to tune lazyfreeing

 Documentation/sysctl/vm.txt               |  13 +++
 arch/alpha/include/uapi/asm/mman.h        |   1 +
 arch/arm/include/asm/pgtable-3level.h     |   1 +
 arch/arm64/include/asm/pgtable.h          |   1 +
 arch/mips/include/uapi/asm/mman.h         |   1 +
 arch/parisc/include/uapi/asm/mman.h       |   1 +
 arch/powerpc/include/asm/pgtable-ppc64.h  |   2 +
 arch/sparc/include/asm/pgtable_64.h       |   9 ++
 arch/x86/include/asm/pgtable.h            |   5 +
 arch/xtensa/include/uapi/asm/mman.h       |   1 +
 drivers/base/node.c                       |   2 +
 drivers/staging/android/lowmemorykiller.c |   3 +-
 fs/proc/meminfo.c                         |   2 +
 include/linux/huge_mm.h                   |   3 +
 include/linux/memcontrol.h                |   1 +
 include/linux/mm_inline.h                 |  83 ++++++++++++++-
 include/linux/mmzone.h                    |  16 ++-
 include/linux/page-flags.h                |   5 +
 include/linux/rmap.h                      |   1 +
 include/linux/swap.h                      |  18 +++-
 include/linux/vm_event_item.h             |   3 +-
 include/trace/events/vmscan.h             |  38 ++++---
 include/uapi/asm-generic/mman-common.h    |   1 +
 kernel/sysctl.c                           |   9 ++
 mm/compaction.c                           |  14 ++-
 mm/huge_memory.c                          |  51 +++++++--
 mm/ksm.c                                  |   6 ++
 mm/madvise.c                              | 171 ++++++++++++++++++++++++++++++
 mm/memcontrol.c                           |  44 +++++++-
 mm/memory-failure.c                       |   7 +-
 mm/memory_hotplug.c                       |   3 +-
 mm/mempolicy.c                            |   3 +-
 mm/migrate.c                              |  28 ++---
 mm/page_alloc.c                           |   3 +
 mm/rmap.c                                 |  14 +++
 mm/swap.c                                 | 128 +++++++++++++++-------
 mm/swap_state.c                           |  11 +-
 mm/truncate.c                             |   2 +-
 mm/vmscan.c                               | 157 ++++++++++++++++++++-------
 mm/vmstat.c                               |   4 +
 40 files changed, 713 insertions(+), 153 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
