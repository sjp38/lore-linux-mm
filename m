Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id A5CBD6B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 07:44:11 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id hi2so17156490wib.11
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 04:44:11 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id fb7si45260917wid.47.2014.12.01.04.44.09
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 04:44:09 -0800 (PST)
Date: Mon, 1 Dec 2014 14:43:58 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/5] mm: Refactor do_wp_page - extract the unlock flow
Message-ID: <20141201124358.GB13856@node.dhcp.inet.fi>
References: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
 <1417435485-24629-3-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417435485-24629-3-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

On Mon, Dec 01, 2014 at 02:04:42PM +0200, Shachar Raindel wrote:
> When do_wp_page is ending, in several cases it needs to unlock the
> pages and ptls it was accessing.
> 
> Currently, this logic was "called" by using a goto jump. This makes
> following the control flow of the function harder. It is also
> against the coding style guidelines for using goto.
> 
> As the code can easily be refactored into a specialized function,
> refactor it out and simplify the callsites code flow.
> 
> Using goto for cleanup is generally allowed. However, extracting the
> cleanup to a separate function will allow deeper refactoring in the
> next patch.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>
> ---
>  mm/memory.c | 66 +++++++++++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 45 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 61334e9..dd3bb13 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2089,6 +2089,40 @@ static int wp_page_reuse(struct mm_struct *mm, struct vm_area_struct *vma,
>  }
>  
>  /*
> + * Release the ptl locking, as well as page references do_wp_page took.
> + *
> + * This function releases any locking and references remaining in the
> + * end of do_wp_page. The ptl lock is taken before do_wp_page is
> + * called. The old_page page reference is taken early in the execution
> + * of do_wp_page. However, in the OOM case we need to cleanup only the
> + * page-cache reference and not the ptl lock, which was dropped
> + * earlier. This results in highly assymetric release path.
> + */
> +static int wp_page_unlock(struct mm_struct *mm, struct vm_area_struct *vma,
> +			  pte_t *page_table, spinlock_t *ptl,
> +			  unsigned long mmun_start, unsigned long mmun_end,
> +			  struct page *old_page, int page_copied)
> +	__releases(ptl)
> +{
> +	pte_unmap_unlock(page_table, ptl);
> +	if (mmun_end > mmun_start)
> +		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	if (old_page) {
> +		/*
> +		 * Don't let another task, with possibly unlocked vma,
> +		 * keep the mlocked page.
> +		 */
> +		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
> +			lock_page(old_page);	/* LRU manipulation */
> +			munlock_vma_page(old_page);
> +			unlock_page(old_page);
> +		}
> +		page_cache_release(old_page);
> +	}
> +	return page_copied ? VM_FAULT_WRITE : 0;
> +}
> +
> +/*
>   * This routine handles present pages, when users try to write
>   * to a shared page. It is done by copying the page to a new address
>   * and decrementing the shared-page counter for the old page.
> @@ -2113,7 +2147,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  {
>  	struct page *old_page, *new_page = NULL;
>  	pte_t entry;
> -	int ret = 0;
> +	int page_copied = 0;
>  	unsigned long mmun_start = 0;	/* For mmu_notifiers */
>  	unsigned long mmun_end = 0;	/* For mmu_notifiers */
>  	struct mem_cgroup *memcg;
> @@ -2148,7 +2182,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  							 &ptl);
>  			if (!pte_same(*page_table, orig_pte)) {
>  				unlock_page(old_page);
> -				goto unlock;
> +				return wp_page_unlock(mm, vma, page_table, ptl,
> +						      0, 0,
> +						      old_page, 0);

For me, it makes code more cunfusing, not less.
Here we could just do something plain like:

				pte_unmap_unlock(page_table, ptl);
				page_cache_release(old_page);
				return 0;


>  			}
>  			page_cache_release(old_page);
>  		}
> @@ -2193,7 +2229,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  							 &ptl);
>  			if (!pte_same(*page_table, orig_pte)) {
>  				unlock_page(old_page);
> -				goto unlock;
> +				return wp_page_unlock(mm, vma, page_table, ptl,
> +						      0, 0,
> +						      old_page, 0);

Ditto.

>  			}
>  
>  			page_mkwrite = 1;
> @@ -2293,29 +2331,15 @@ gotten:
>  
>  		/* Free the old page.. */
>  		new_page = old_page;
> -		ret |= VM_FAULT_WRITE;
> +		page_copied = 1;
>  	} else
>  		mem_cgroup_cancel_charge(new_page, memcg);
>  
>  	if (new_page)
>  		page_cache_release(new_page);
> -unlock:

And now we don't need the label and can leave code in place.

> -	pte_unmap_unlock(page_table, ptl);
> -	if (mmun_end > mmun_start)
> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> -	if (old_page) {
> -		/*
> -		 * Don't let another task, with possibly unlocked vma,
> -		 * keep the mlocked page.
> -		 */
> -		if ((ret & VM_FAULT_WRITE) && (vma->vm_flags & VM_LOCKED)) {
> -			lock_page(old_page);	/* LRU manipulation */
> -			munlock_vma_page(old_page);
> -			unlock_page(old_page);
> -		}
> -		page_cache_release(old_page);
> -	}
> -	return ret;
> +
> +	return wp_page_unlock(mm, vma, page_table, ptl, mmun_start,
> +			      mmun_end, old_page, page_copied);
>  oom_free_new:
>  	page_cache_release(new_page);
>  oom:
> -- 
> 1.7.11.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
