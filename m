Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25B8A8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 21:55:58 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so22231723pfr.6
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 18:55:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l8si4466327pgm.250.2018.12.27.18.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 18:55:56 -0800 (PST)
Date: Thu, 27 Dec 2018 18:55:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, swap: Fix swapoff with KSM pages
Message-Id: <20181227185553.81928247d95418191b063d40@linux-foundation.org>
In-Reply-To: <20181226051522.28442-1-ying.huang@intel.com>
References: <20181226051522.28442-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Hugh Dickins <hughd@google.com>, Vineeth Remanan Pillai <vpillai@digitalocean.com>, Kelley Nielsen <kelleynnn@gmail.com>

On Wed, 26 Dec 2018 13:15:22 +0800 Huang Ying <ying.huang@intel.com> wrote:

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
> ...
>
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

The patch "mm, swap: rid swapoff of quadratic complexity" changes this
code significantly.  There are a few issues with that patch so I'll
drop it for now.

Vineeth, please ensure that future versions retain the above fix,
thanks.
