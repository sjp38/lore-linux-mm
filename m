Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 524986B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 08:03:25 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so17247000wiw.16
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 05:03:24 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id do3si45340302wib.48.2014.12.01.05.03.24
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 05:03:24 -0800 (PST)
Date: Mon, 1 Dec 2014 15:03:16 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/5] mm: Refactor do_wp_page handling of shared vma into
 a function
Message-ID: <20141201130316.GE13856@node.dhcp.inet.fi>
References: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
 <1417435485-24629-5-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417435485-24629-5-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

On Mon, Dec 01, 2014 at 02:04:44PM +0200, Shachar Raindel wrote:
> The do_wp_page function is extremely long. Extract the logic for
> handling a page belonging to a shared vma into a function of its own.
> 
> This helps the readability of the code, without doing any functional
> change in it.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>
> ---
>  mm/memory.c | 87 ++++++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 49 insertions(+), 38 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 436012d..8023cf3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2248,6 +2248,53 @@ oom:
>  	return VM_FAULT_OOM;
>  }
>  
> +static int wp_page_shared_vma(struct mm_struct *mm, struct vm_area_struct *vma,

wp_page_shared() is enough. no need in _vma.

> +			      unsigned long address, pte_t *page_table,
> +			      pmd_t *pmd, spinlock_t *ptl, pte_t orig_pte,
> +			      struct page *old_page)
> +	__releases(ptl)
> +{
> +	int page_mkwrite = 0;
> +
> +	/*
> +	 * Only catch write-faults on shared writable pages,
> +	 * read-only shared pages can get COWed by
> +	 * get_user_pages(.write=1, .force=1).
> +	 */
> +	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {

Inversion of the check would help indentation level of the code below.

> +		int tmp;
> +
> +		page_cache_get(old_page);
> +		pte_unmap_unlock(page_table, ptl);
> +		tmp = do_page_mkwrite(vma, old_page, address);
> +		if (unlikely(!tmp || (tmp &
> +				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
> +			page_cache_release(old_page);
> +			return tmp;
> +		}
> +		/*
> +		 * Since we dropped the lock we need to revalidate
> +		 * the PTE as someone else may have changed it.  If
> +		 * they did, we just return, as we can count on the
> +		 * MMU to tell us if they didn't also make it writable.
> +		 */
> +		page_table = pte_offset_map_lock(mm, pmd, address,
> +						 &ptl);
> +		if (!pte_same(*page_table, orig_pte)) {
> +			unlock_page(old_page);
> +			return wp_page_unlock(mm, vma, page_table, ptl,
> +					      0, 0,
> +					      old_page, 0);
> +		}
> +
> +		page_mkwrite = 1;
> +	}
> +	get_page(old_page);
> +
> +	return wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte,
> +			     old_page, 1, page_mkwrite);
> +}
> +
>  /*
>   * This routine handles present pages, when users try to write
>   * to a shared page. It is done by copying the page to a new address
> @@ -2324,44 +2371,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		unlock_page(old_page);
>  	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
>  					(VM_WRITE|VM_SHARED))) {
> -		int page_mkwrite = 0;
> -
> -		/*
> -		 * Only catch write-faults on shared writable pages,
> -		 * read-only shared pages can get COWed by
> -		 * get_user_pages(.write=1, .force=1).
> -		 */
> -		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
> -			int tmp;
> -			page_cache_get(old_page);
> -			pte_unmap_unlock(page_table, ptl);
> -			tmp = do_page_mkwrite(vma, old_page, address);
> -			if (unlikely(!tmp || (tmp &
> -					(VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
> -				page_cache_release(old_page);
> -				return tmp;
> -			}
> -			/*
> -			 * Since we dropped the lock we need to revalidate
> -			 * the PTE as someone else may have changed it.  If
> -			 * they did, we just return, as we can count on the
> -			 * MMU to tell us if they didn't also make it writable.
> -			 */
> -			page_table = pte_offset_map_lock(mm, pmd, address,
> -							 &ptl);
> -			if (!pte_same(*page_table, orig_pte)) {
> -				unlock_page(old_page);
> -				return wp_page_unlock(mm, vma, page_table, ptl,
> -						      0, 0,
> -						      old_page, 0);
> -			}
> -
> -			page_mkwrite = 1;
> -		}
> -		get_page(old_page);
> -
> -		return wp_page_reuse(mm, vma, address, page_table, ptl,
> -				     orig_pte, old_page, 1, page_mkwrite);
> +		return wp_page_shared_vma(mm, vma, address, page_table, pmd,
> +					  ptl, orig_pte, old_page);
>  	}
>  
>  	/*
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
