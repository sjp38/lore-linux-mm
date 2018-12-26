Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57F718E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 00:37:26 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 82so16795478pfs.20
        for <linux-mm@kvack.org>; Tue, 25 Dec 2018 21:37:26 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w15si32157833plk.357.2018.12.25.21.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Dec 2018 21:37:25 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm, swap: Fix swapoff with KSM pages
References: <20181226051522.28442-1-ying.huang@intel.com>
Date: Wed, 26 Dec 2018 13:37:22 +0800
In-Reply-To: <20181226051522.28442-1-ying.huang@intel.com> (Huang Ying's
	message of "Wed, 26 Dec 2018 13:15:22 +0800")
Message-ID: <8736qku9v1.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Hugh Dickins <hughd@google.com>

Hi, Andrew,

This patch is based on linus' tree instead of the head of mmotm tree
because it is to fix a bug there.

The bug is introduced by commit e07098294adf ("mm, THP, swap: support to
reclaim swap space for THP swapped out"), which is merged by v4.14-rc1.
So I think we should backport the fix to from 4.14 on.  But Hugh thinks
it may be rare for the KSM pages being in the swap device when swapoff,
so nobody reports the bug so far.

Best Regards,
Huang, Ying

Huang Ying <ying.huang@intel.com> writes:

> KSM pages may be mapped to the multiple VMAs that cannot be reached
> from one anon_vma.  So during swapin, a new copy of the page need to
> be generated if a different anon_vma is needed, please refer to
> comments of ksm_might_need_to_copy() for details.
>
> During swapoff, unuse_vma() uses anon_vma (if available) to locate VMA
> and virtual address mapped to the page, so not all mappings to a
> swapped out KSM page could be found.  So in try_to_unuse(), even if
> the swap count of a swap entry isn't zero, the page needs to be
> deleted from swap cache, so that, in the next round a new page could
> be allocated and swapin for the other mappings of the swapped out KSM
> page.
>
> But this contradicts with the THP swap support.  Where the THP could
> be deleted from swap cache only after the swap count of every swap
> entry in the huge swap cluster backing the THP has reach 0.  So
> try_to_unuse() is changed in commit e07098294adf ("mm, THP, swap:
> support to reclaim swap space for THP swapped out") to check that
> before delete a page from swap cache, but this has broken KSM swapoff
> too.
>
> Fortunately, KSM is for the normal pages only, so the original
> behavior for KSM pages could be restored easily via checking
> PageTransCompound().  That is how this patch works.
>
> Fixes: e07098294adf ("mm, THP, swap: support to reclaim swap space for THP swapped out")
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Reported-and-Tested-and-Acked-by: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  mm/swapfile.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 8688ae65ef58..20d3c0f47a5f 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2197,7 +2197,8 @@ int try_to_unuse(unsigned int type, bool frontswap,
>  		 */
>  		if (PageSwapCache(page) &&
>  		    likely(page_private(page) == entry.val) &&
> -		    !page_swapped(page))
> +		    (!PageTransCompound(page) ||
> +		     !swap_page_trans_huge_swapped(si, entry)))
>  			delete_from_swap_cache(compound_head(page));
>  
>  		/*
