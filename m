Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57471681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 12:53:00 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id an2so4509526wjc.3
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 09:53:00 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v53si10184645wrb.38.2017.02.16.09.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 09:52:59 -0800 (PST)
Date: Thu, 16 Feb 2017 12:52:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 2/7] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170216175253.GB20791@cmpxchg.org>
References: <cover.1487100204.git.shli@fb.com>
 <5c38c5f4d91e92ce86ee4f253e49c78708094632.1487100204.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5c38c5f4d91e92ce86ee4f253e49c78708094632.1487100204.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Tue, Feb 14, 2017 at 11:36:08AM -0800, Shaohua Li wrote:
> @@ -126,4 +126,24 @@ static __always_inline enum lru_list page_lru(struct page *page)
>  
>  #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
>  
> +/*
> + * lazyfree pages are clean anonymous pages. They have SwapBacked flag cleared
> + * to destinguish normal anonymous pages.
> + */
> +static inline void set_page_lazyfree(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageAnon(page) || !PageSwapBacked(page), page);
> +	ClearPageSwapBacked(page);
> +}
> +
> +static inline void clear_page_lazyfree(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageAnon(page) || PageSwapBacked(page), page);
> +	SetPageSwapBacked(page);
> +}
> +
> +static inline bool page_is_lazyfree(struct page *page)
> +{
> +	return PageAnon(page) && !PageSwapBacked(page);
> +}

Sorry for not getting to v2 in time, but I have to say I strongly
agree with your first iterations and would much prefer this to be
open-coded.

IMO this needlessly introduces a new state opaquely called "lazyfree",
when really that's just anonymous pages that don't need to be swapped
before reclaim - PageAnon && !PageSwapBacked. Very simple MM concept.

That especially shows when we later combine it with page_is_file_cache
checks like the next patch does.

The rest of the patch looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
