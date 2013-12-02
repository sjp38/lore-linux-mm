Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 196E16B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 18:01:11 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so20164035pbc.27
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 15:01:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sw1si49392001pbc.192.2013.12.02.15.01.09
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 15:01:09 -0800 (PST)
Date: Mon, 2 Dec 2013 15:01:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/9] mm/rmap: use rmap_walk() in try_to_unmap()
Message-Id: <20131202150107.7a814d0753356afc47b58b09@linux-foundation.org>
In-Reply-To: <1385624926-28883-7-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1385624926-28883-7-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 28 Nov 2013 16:48:43 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> Now, we have an infrastructure in rmap_walk() to handle difference
> from variants of rmap traversing functions.
> 
> So, just use it in try_to_unmap().
> 
> In this patch, I change following things.
> 
> 1. enable rmap_walk() if !CONFIG_MIGRATION.
> 2. mechanical change to use rmap_walk() in try_to_unmap().
> 
> ...
>
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -190,7 +190,7 @@ int page_referenced_one(struct page *, struct vm_area_struct *,
>  
>  int try_to_unmap(struct page *, enum ttu_flags flags);
>  int try_to_unmap_one(struct page *, struct vm_area_struct *,
> -			unsigned long address, enum ttu_flags flags);
> +			unsigned long address, void *arg);

This change is ugly and unchangelogged.

Also, "enum ttu_flags flags" was nice and meaningful, but "void *arg"
conveys far less information.  A suitable way to address this
shortcoming is to document `arg' at the try_to_unmap_one() definition
site.  try_to_unmap_one() doesn't actually have any documentation at
this stage - let's please fix that?

>
> ...
>
> @@ -1509,6 +1510,11 @@ bool is_vma_temporary_stack(struct vm_area_struct *vma)
>  	return false;
>  }
>  
> +static int skip_vma_temporary_stack(struct vm_area_struct *vma, void *arg)
> +{
> +	return (int)is_vma_temporary_stack(vma);
> +}

The (int) cast is unneeded - the compiler will turn a bool into an int.

Should this function (and rmap_walk_control.skip()) really be returning
a bool?

The name of this function is poor: "skip_foo" implies that the function
will skip over a foo.  But that isn't what this function does.  Please
choose something which accurately reflects the function's behavior.

>  /**
>   * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
>   * rmap method
> @@ -1554,7 +1560,7 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
>  			continue;
>  
>  		address = vma_address(page, vma);
> -		ret = try_to_unmap_one(page, vma, address, flags);
> +		ret = try_to_unmap_one(page, vma, address, (void *)flags);
>  		if (ret != SWAP_AGAIN || !page_mapped(page))
>  			break;
>  	}
>
> ...
>
>  /**
>   * try_to_unmap - try to remove all page table mappings to a page
>   * @page: the page to get unmapped
> @@ -1630,16 +1641,30 @@ out:
>  int try_to_unmap(struct page *page, enum ttu_flags flags)
>  {
>  	int ret;
> +	struct rmap_walk_control rwc;
>  
> -	BUG_ON(!PageLocked(page));
>  	VM_BUG_ON(!PageHuge(page) && PageTransHuge(page));
>  
> -	if (unlikely(PageKsm(page)))
> -		ret = try_to_unmap_ksm(page, flags);
> -	else if (PageAnon(page))
> -		ret = try_to_unmap_anon(page, flags);
> -	else
> -		ret = try_to_unmap_file(page, flags);
> +	memset(&rwc, 0, sizeof(rwc));
> +	rwc.main = try_to_unmap_one;
> +	rwc.arg = (void *)flags;
> +	rwc.main_done = page_not_mapped;
> +	rwc.file_nonlinear = try_to_unmap_nonlinear;
> +	rwc.anon_lock = page_lock_anon_vma_read;

	struct rmap_walk_control rwc = {
		...
	};

> +	/*
> +	 * During exec, a temporary VMA is setup and later moved.
> +	 * The VMA is moved under the anon_vma lock but not the
> +	 * page tables leading to a race where migration cannot
> +	 * find the migration ptes. Rather than increasing the
> +	 * locking requirements of exec(), migration skips
> +	 * temporary VMAs until after exec() completes.
> +	 */
> +	if (flags & TTU_MIGRATION && !PageKsm(page) && PageAnon(page))
> +		rwc.vma_skip = skip_vma_temporary_stack;
> +
> +	ret = rmap_walk(page, &rwc);
> +
>  	if (ret != SWAP_MLOCK && !page_mapped(page))
>  		ret = SWAP_SUCCESS;
>  	return ret;
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
