Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6576B0258
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 01:39:35 -0500 (EST)
Received: by ioir85 with SMTP id r85so163478891ioi.1
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 22:39:35 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id i5si4064108igv.17.2015.11.29.22.39.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 29 Nov 2015 22:39:29 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 00/12] MADV_FREE support
Date: Mon, 30 Nov 2015 15:39:31 +0900
Message-Id: <1448865583-2446-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>

In v4, Andrew wanted to settle in old basic MADV_FREE and introduces
new stuffs(ie, lazyfree LRU, swapless support and lazyfreeness) later
so this version doesn't include them.

I have been tested it on mmotm-2015-11-25-17-08 with additional
patch[1] from Kirill to prevent BUG_ON which he didn't send to
linux-mm yet as formal patch. With it, I couldn't find any
problem so far.

Note that this version is based on THP refcount redesign so
I needed some modification on MADV_FREE because split_huge_pmd
doesn't split a THP page any more and pmd_trans_huge(pmd) is not
enough to guarantee the page is not THP page.
As well, for MAVD_FREE lazy-split, THP split should respect
pmd's dirtiness rather than marking ptes of all subpages dirty
unconditionally. Please, review last patch in this patchset.

	mm: don't split THP page when syscall is called

[1] https://lkml.org/lkml/2015/11/17/134

git: git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git
branch: mm/madv_free-v4.4-rc2-mmotm-2015-11-25-17-08-v5r2

In this stage, I don't think we need to write man page.
It could be done after solid policy and implementation.

 * Change from v4
   * drop lazyfree LRU
   * drop swapless support
   * drop lazyfreeness
   * rebase on recent mmotom with THP refcount redesign

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

Minchan Kim (11):
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

 arch/alpha/include/uapi/asm/mman.h       |   2 +
 arch/arm/include/asm/pgtable-3level.h    |   1 +
 arch/arm64/include/asm/pgtable.h         |   1 +
 arch/mips/include/uapi/asm/mman.h        |   2 +
 arch/parisc/include/uapi/asm/mman.h      |   2 +
 arch/powerpc/include/asm/pgtable-ppc64.h |   2 +
 arch/sparc/include/asm/pgtable_64.h      |   9 ++
 arch/x86/include/asm/pgtable.h           |   5 +
 arch/xtensa/include/uapi/asm/mman.h      |   2 +
 include/linux/huge_mm.h                  |   3 +
 include/linux/rmap.h                     |   1 +
 include/linux/swap.h                     |   1 +
 include/linux/vm_event_item.h            |   1 +
 include/uapi/asm-generic/mman-common.h   |   1 +
 mm/huge_memory.c                         |  87 +++++++++++++-
 mm/ksm.c                                 |   6 +
 mm/madvise.c                             | 199 +++++++++++++++++++++++++++++++
 mm/rmap.c                                |   8 ++
 mm/swap.c                                |  44 +++++++
 mm/swap_state.c                          |   5 +-
 mm/vmscan.c                              |  10 +-
 mm/vmstat.c                              |   1 +
 22 files changed, 383 insertions(+), 10 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
