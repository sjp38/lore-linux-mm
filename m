Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C04656B03AB
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:29:10 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so7670799wmw.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 23:29:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ah5si6340869wjc.171.2016.11.17.23.29.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 23:29:09 -0800 (PST)
Date: Fri, 18 Nov 2016 08:29:07 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/9] mm: khugepaged: close use-after-free race during
 shmem collapsing
Message-ID: <20161118072907.GA18676@quack2.suse.cz>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
 <20161117191138.22769-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117191138.22769-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 17-11-16 14:11:30, Johannes Weiner wrote:
> When a radix tree iteration drops the tree lock, another thread might
> swoop in and free the node holding the current slot. The iteration
> needs to do another tree lookup from the current index to continue.
> 
> [kirill.shutemov@linux.intel.com: re-lookup for replacement]
> Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/khugepaged.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 728d7790dc2d..bdfdab40a813 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1401,6 +1401,9 @@ static void collapse_shmem(struct mm_struct *mm,
>  
>  		spin_lock_irq(&mapping->tree_lock);
>  
> +		slot = radix_tree_lookup_slot(&mapping->page_tree, index);
> +		VM_BUG_ON_PAGE(page != radix_tree_deref_slot_protected(slot,
> +					&mapping->tree_lock), page);
>  		VM_BUG_ON_PAGE(page_mapped(page), page);
>  
>  		/*
> @@ -1424,6 +1427,7 @@ static void collapse_shmem(struct mm_struct *mm,
>  		radix_tree_replace_slot(slot,
>  				new_page + (index % HPAGE_PMD_NR));
>  
> +		slot = radix_tree_iter_next(&iter);
>  		index++;
>  		continue;
>  out_lru:
> @@ -1535,6 +1539,7 @@ static void collapse_shmem(struct mm_struct *mm,
>  			putback_lru_page(page);
>  			unlock_page(page);
>  			spin_lock_irq(&mapping->tree_lock);
> +			slot = radix_tree_iter_next(&iter);
>  		}
>  		VM_BUG_ON(nr_none);
>  		spin_unlock_irq(&mapping->tree_lock);
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
