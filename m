Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0705B6B0253
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 20:26:08 -0500 (EST)
Received: by pasz6 with SMTP id z6so35617208pas.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 17:26:07 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id or8si3601237pbc.63.2015.11.03.17.26.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Nov 2015 17:26:07 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 00/13] MADV_FREE support
Date: Wed,  4 Nov 2015 10:25:54 +0900
Message-Id: <1446600367-7976-1-git-send-email-minchan@kernel.org>
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

When I test MADV_FREE patches on recent mmotm, there is some
problem with THP-refcount redesign so it's hard for long running
test. Even, there is some dependency with it because patch ordering of
MADV_FREE in mmotm is after THP refcount redesign so I discussed it
with Andrew in hallway this kernel summit and decided to send
patchset based on v4.3-rc7.

I have been tested it on v4.3-rc7 and couldn't find any problem so far.

In the meanwhile, Hugh reviewed all of code and asked me to tidy up
a lot patches related MADV_FREE on mmotm so this is the result of
the request.

A final modification since I sent clean up patchset(ie, MADV_FREE
refactoring and fix KSM page), there are four.

 1. Replace description and comment of KSM fix patch with Hugh's suggestion
 2. Avoid forcing SetPageDirty in try_to_unmap_one to avoid clean
    page swapout from Yalin
 3. Adding uapi patch to make value of MADV_FREE for all arches same
    from Chen
 4. Does lazy split of THP when MADV_FREE is called

About 3, I include it because I thought it was good but Andrew
just missed the patch at that time. But when I read quilt series
file now, it seems Shaohua had some problem with it but I couldn't
find any mail in my mailbox. If it has something wrong,
please tell us.

About 4(ie, mm: don't split THP page when syscall is called),
it is new implementation so need to review.
I don't understand why it added both SetPageDirty and pte_mkdirty
to subpages unconditionally in split code of THP from the beginning.
I guess at that time, there was no MADV_FREE so it was no problem
and would be more safe to mark both.

#mm-support-madvisemadv_free.patch: other-arch syscall numbering mess ("arch: uapi: asm: mman.h: Let MADV_FREE have same value for all architectures"). Shaohua Li <shli@kernel.org> testing disasters.

TODO: I will send man page patch if it would land for v4.4.

Andrew, you could replace all of MADV_FREE related patches with
this. IOW, these are

	# MADV_FREE stuff:
	x86-add-pmd_-for-thp.patch
	x86-add-pmd_-for-thp-fix.patch
	sparc-add-pmd_-for-thp.patch
	sparc-add-pmd_-for-thp-fix.patch
	powerpc-add-pmd_-for-thp.patch
	arm-add-pmd_mkclean-for-thp.patch
	arm64-add-pmd_-for-thp.patch

	mm-support-madvisemadv_free.patch
	mm-support-madvisemadv_free-fix.patch
	mm-support-madvisemadv_free-fix-2.patch
	mm-support-madvisemadv_free-fix-3.patch
	mm-support-madvisemadv_free-vs-thp-rename-split_huge_page_pmd-to-split_huge_pmd.patch
	mm-support-madvisemadv_free-fix-5.patch
	mm-support-madvisemadv_free-fix-6.patch
	mm-mark-stable-page-dirty-in-ksm.patch
	mm-dont-split-thp-page-when-syscall-is-called.patch
	mm-dont-split-thp-page-when-syscall-is-called-fix.patch
	mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
	mm-dont-split-thp-page-when-syscall-is-called-fix-3.patch
	mm-dont-split-thp-page-when-syscall-is-called-fix-4.patch
	mm-dont-split-thp-page-when-syscall-is-called-fix-5.patch
	mm-dont-split-thp-page-when-syscall-is-called-fix-6.patch
	mm-dont-split-thp-page-when-syscall-is-called-fix-6-fix.patch
	mm-free-swp_entry-in-madvise_free.patch
	mm-move-lazy-free-pages-to-inactive-list.patch
	mm-move-lazy-free-pages-to-inactive-list-fix.patch
	mm-move-lazy-free-pages-to-inactive-list-fix-fix.patch
	mm-move-lazy-free-pages-to-inactive-list-fix-fix-fix.patch

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

Minchan Kim (12):
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

 arch/alpha/include/uapi/asm/mman.h       |   1 +
 arch/arm/include/asm/pgtable-3level.h    |   1 +
 arch/arm64/include/asm/pgtable.h         |   1 +
 arch/mips/include/uapi/asm/mman.h        |   1 +
 arch/parisc/include/uapi/asm/mman.h      |   1 +
 arch/powerpc/include/asm/pgtable-ppc64.h |   2 +
 arch/sparc/include/asm/pgtable_64.h      |   9 ++
 arch/x86/include/asm/pgtable.h           |   5 +
 arch/xtensa/include/uapi/asm/mman.h      |   1 +
 include/linux/huge_mm.h                  |   3 +
 include/linux/rmap.h                     |   1 +
 include/linux/swap.h                     |   2 +-
 include/linux/vm_event_item.h            |   1 +
 include/uapi/asm-generic/mman-common.h   |   1 +
 mm/huge_memory.c                         |  46 +++++++-
 mm/ksm.c                                 |   6 ++
 mm/madvise.c                             | 177 +++++++++++++++++++++++++++++++
 mm/rmap.c                                |   7 ++
 mm/swap.c                                |  62 ++++++-----
 mm/swap_state.c                          |   5 +-
 mm/truncate.c                            |   2 +-
 mm/vmscan.c                              |  10 +-
 mm/vmstat.c                              |   1 +
 23 files changed, 308 insertions(+), 38 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
