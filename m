Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 78C396B0254
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 03:02:46 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so112716850pab.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 00:02:46 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id ua10si17370442pab.236.2015.11.20.00.02.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 00:02:43 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 00/16] MADV_FREE support
Date: Fri, 20 Nov 2015 17:02:32 +0900
Message-Id: <1448006568-16031-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>

I have been spent a lot of time to land MADV_FREE feature
by request of userland people(esp, Daniel and Jason, jemalloc guys.
Thanks for the pushing me! ;-)

There are some issues from reviewrs.

1) Swap dependency

In old version, MADV_FREE is fallback to MADV_DONTNEED on swapless
system because we don't have aged anonymous LRU list.
So there are requests for MADV_FREE to support on swapless system.

For addressing the issue, it includes new LRU list for lazyfree
pages. With that, we could support MADV_FREE on swapless system.

2) Hotness

Someone think MADV_FREEed pages are really cold while others are not.
By judging what it is, it affects reclaim policy.
For addressing the issue, it includes new knob "lazyfreeness" like
swappiness. Look at detail in decscription of mm: add knob to tune
lazyfreeing.

I have been tested it on v4.3-rc7 and couldn't find any problem so far.

git: git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git
branch: mm/madv_free-v4.3-rc7-v4rc2

In this stage, I don't think we need to write man page.
It could be done after solid policy and implementation.

 * Change from v3
   * some bug fix
   * code refactoring
   * lazyfree reclaim logic change
   * reordering patch

 * Change from v2
   * vm_lazyfreeness tuning knob
   * add new LRU list - Johannes, Shaohua
   * support swapless - Johannes

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

Minchan Kim (15):
  mm: support madvise(MADV_FREE)
  mm: define MADV_FREE for some arches
  mm: free swp_entry in madvise_free
  mm: move lazily freed pages to inactive list
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

 Documentation/sysctl/vm.txt               |  13 ++
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
 include/linux/huge_mm.h                   |   6 +
 include/linux/memcontrol.h                |   1 +
 include/linux/mm_inline.h                 |  85 ++++++++++-
 include/linux/mmzone.h                    |  26 +++-
 include/linux/page-flags.h                |   5 +
 include/linux/rmap.h                      |   1 +
 include/linux/swap.h                      |  19 ++-
 include/linux/vm_event_item.h             |   3 +-
 include/trace/events/vmscan.h             |  38 ++---
 include/uapi/asm-generic/mman-common.h    |   1 +
 kernel/sysctl.c                           |   9 ++
 mm/compaction.c                           |  14 +-
 mm/huge_memory.c                          |  60 +++++++-
 mm/ksm.c                                  |   6 +
 mm/madvise.c                              | 181 ++++++++++++++++++++++
 mm/memcontrol.c                           |  44 +++++-
 mm/memory-failure.c                       |   7 +-
 mm/memory_hotplug.c                       |   3 +-
 mm/mempolicy.c                            |   3 +-
 mm/migrate.c                              |  28 ++--
 mm/page_alloc.c                           |   7 +
 mm/rmap.c                                 |  14 ++
 mm/swap.c                                 |  84 +++++++++--
 mm/swap_state.c                           |  11 +-
 mm/vmscan.c                               | 240 ++++++++++++++++++++----------
 mm/vmstat.c                               |   4 +
 39 files changed, 767 insertions(+), 175 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
