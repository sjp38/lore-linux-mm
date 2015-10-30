Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2D58C82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 03:01:15 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so59548180pad.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 00:01:14 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id re6si8677913pab.143.2015.10.30.00.01.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Oct 2015 00:01:14 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/8] MADV_FREE support
Date: Fri, 30 Oct 2015 16:01:36 +0900
Message-Id: <1446188504-28023-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

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

In this version, I drop a enhance patch.

        mm: don't split THP page when syscall is called

Because it could delay split of THP page until reclaim path but it
made madvise_free void due to marking all pages(head + sub pages)
PG_dirty and pte_mkdirty when split happens.

I will see we could make THP split inheriting pmd's dirtiness to
subpages and remove adding PG_dirty part unconditionally in
__split_huge_page_refcount but it's rather risky to do it in
this moment(ie, close to merge window and Kirill is changing
that a lot) so I want to do it after closing merge window.
If we dont't do it now, we don't need following patches, either.

	x86-add-pmd_-for-thp.patch
	x86-add-pmd_-for-thp-fix.patch
	sparc-add-pmd_-for-thp.patch
	sparc-add-pmd_-for-thp-fix.patch
	powerpc-add-pmd_-for-thp.patch
	arm-add-pmd_mkclean-for-thp.patch
	arm64-add-pmd_-for-thp.patch

So, I drop those patch too in this version and will resend it
when I send a lazy split patch of THP page.

A final modification since I sent clean up patchset(ie, MADV_FREE
refactoring and fix KSM page), there are three.

 1. Replace description and comment of KSM fix patch with Hugh's suggestion
 2. Avoid forcing SetPageDirty in try_to_unmap_one to avoid clean
    page swapout from Yalin
 3. Adding uapi patch to make value of MADV_FREE for all arches same
    from Chen

About 3, I include it because I thought it was good but Andrew
just missed the patch at that time. But when I read quilt series
file now, it seems Shaohua had some problem with it but I couldn't
find any mail in my mailbox. If it has something wrong,
please tell us.

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

Chen Gang (1):
  arch: uapi: asm: mman.h: Let MADV_FREE have same value for all
    architectures

Minchan Kim (7):
  mm: support madvise(MADV_FREE)
  mm: define MADV_FREE for some arches
  mm: free swp_entry in madvise_free
  mm: move lazily freed pages to inactive list
  mm: lru_deactivate_fn should clear PG_referenced
  mm: clear PG_dirty to mark page freeable
  mm: mark stable page dirty in KSM

 arch/alpha/include/uapi/asm/mman.h     |   1 +
 arch/mips/include/uapi/asm/mman.h      |   1 +
 arch/parisc/include/uapi/asm/mman.h    |   1 +
 arch/xtensa/include/uapi/asm/mman.h    |   1 +
 include/linux/rmap.h                   |   1 +
 include/linux/swap.h                   |   1 +
 include/linux/vm_event_item.h          |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/ksm.c                               |   6 ++
 mm/madvise.c                           | 162 +++++++++++++++++++++++++++++++++
 mm/rmap.c                              |   7 ++
 mm/swap.c                              |  44 +++++++++
 mm/swap_state.c                        |   5 +-
 mm/vmscan.c                            |  10 +-
 mm/vmstat.c                            |   1 +
 15 files changed, 238 insertions(+), 5 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
