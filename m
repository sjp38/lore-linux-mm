Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFDB6B0038
	for <linux-mm@kvack.org>; Fri, 19 Sep 2014 02:17:34 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id fa1so3212528pad.30
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 23:17:34 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id lp3si1141235pab.230.2014.09.18.23.17.32
        for <linux-mm@kvack.org>;
        Thu, 18 Sep 2014 23:17:33 -0700 (PDT)
Date: Fri, 19 Sep 2014 15:17:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v16 0/7] MADV_FREE support
Message-ID: <20140919061755.GC6227@bbox>
References: <1409556048-5045-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1409556048-5045-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>

Ping.

On Mon, Sep 01, 2014 at 04:20:41PM +0900, Minchan Kim wrote:
> This patch enable MADV_FREE hint for madvise syscall, which have
> been supported by other OSes. [PATCH 1] includes the details.
> 
> [1] support MADVISE_FREE for !THP page so if VM encounter
> THP page in syscall context, it splits THP page.
> [2-6] is to preparing to call madvise syscall without THP plitting
> [7] enable THP page support for MADV_FREE.
> 
> * from v15
>  * Add more Acked-by - Rik van Riel
>  * Rebased on mmotom-08-29-15-15
> 
> * from v14
>  * Add more Ackedy-by from arch people(sparc, arm64 and arm)
>  * Drop s390 since pmd_dirty/clean was merged
> 
> * from v13
>  * Add more Ackedy-by from arch people(arm, arm64 and ppc)
>  * Rebased on mmotm 2014-08-13-14-29
> 
> * from v12
>  * Fix - skip to mark free pte on try_to_free_swap failed page - Kirill
>  * Add more Acked-by from arch maintainers and Kirill
> 
> * From v11
>  * Fix arm build - Steve
>  * Separate patch for arm and arm64 - Steve
>  * Remove unnecessary check - Kirill
>  * Skip non-vm_normal page - Kirill
>  * Add Acked-by - Zhang
>  * Sparc64 build fix
>  * Pagetable walker THP handling fix
> 
> * From v10
>  * Add Acked-by from arch stuff(x86, s390)
>  * Pagewalker based pagetable working - Kirill
>  * Fix try_to_unmap_one broken with hwpoison - Kirill
>  * Use VM_BUG_ON_PAGE in madvise_free_pmd - Kirill
>  * Fix pgtable-3level.h for arm - Steve
> 
> * From v9
>  * Add Acked-by - Rik
>  * Add THP page support - Kirill
> 
> * From v8
>  * Rebased-on v3.16-rc2-mmotm-2014-06-25-16-44
> 
> * From v7
>  * Rebased-on next-20140613
> 
> * From v6
>  * Remove page from swapcache in syscal time
>  * Move utility functions from memory.c to madvise.c - Johannes
>  * Rename untilify functtions - Johannes
>  * Remove unnecessary checks from vmscan.c - Johannes
>  * Rebased-on v3.15-rc5-mmotm-2014-05-16-16-56
>  * Drop Reviewe-by because there was some changes since then.
> 
> * From v5
>  * Fix PPC problem which don't flush TLB - Rik
>  * Remove unnecessary lazyfree_range stub function - Rik
>  * Rebased on v3.15-rc5
> 
> * From v4
>  * Add Reviewed-by: Zhang Yanfei
>  * Rebase on v3.15-rc1-mmotm-2014-04-15-16-14
> 
> * From v3
>  * Add "how to work part" in description - Zhang
>  * Add page_discardable utility function - Zhang
>  * Clean up
> 
> * From v2
>  * Remove forceful dirty marking of swap-readed page - Johannes
>  * Remove deactivation logic of lazyfreed page
>  * Rebased on 3.14
>  * Remove RFC tag
> 
> * From v1
>  * Use custom page table walker for madvise_free - Johannes
>  * Remove PG_lazypage flag - Johannes
>  * Do madvise_dontneed instead of madvise_freein swapless system
> 
> Minchan Kim (7):
>   mm: support madvise(MADV_FREE)
>   x86: add pmd_[dirty|mkclean] for THP
>   sparc: add pmd_[dirty|mkclean] for THP
>   powerpc: add pmd_[dirty|mkclean] for THP
>   arm: add pmd_mkclean for THP
>   arm64: add pmd_[dirty|mkclean] for THP
>   mm: Don't split THP page when syscall is called
> 
>  arch/arm/include/asm/pgtable-3level.h    |   1 +
>  arch/arm64/include/asm/pgtable.h         |   2 +
>  arch/powerpc/include/asm/pgtable-ppc64.h |   2 +
>  arch/sparc/include/asm/pgtable_64.h      |  16 ++++
>  arch/x86/include/asm/pgtable.h           |  10 ++
>  include/linux/huge_mm.h                  |   4 +
>  include/linux/rmap.h                     |   9 +-
>  include/linux/vm_event_item.h            |   1 +
>  include/uapi/asm-generic/mman-common.h   |   1 +
>  mm/huge_memory.c                         |  35 +++++++
>  mm/madvise.c                             | 159 +++++++++++++++++++++++++++++++
>  mm/rmap.c                                |  46 ++++++++-
>  mm/vmscan.c                              |  64 +++++++++----
>  mm/vmstat.c                              |   1 +
>  14 files changed, 331 insertions(+), 20 deletions(-)
> 
> -- 
> 2.0.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
