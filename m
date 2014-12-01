Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA286B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 12:59:32 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so14930234wgh.34
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 09:59:31 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id h10si32466804wiv.42.2014.12.01.09.59.30
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 09:59:31 -0800 (PST)
Date: Mon, 1 Dec 2014 19:59:18 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1 4/4] mm: Refactor do_wp_page handling of shared vma
 into a function
Message-ID: <20141201175918.GA16334@node.dhcp.inet.fi>
References: <1417452977-11337-1-git-send-email-raindel@mellanox.com>
 <1417452977-11337-5-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417452977-11337-5-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

On Mon, Dec 01, 2014 at 06:56:17PM +0200, Shachar Raindel wrote:
> The do_wp_page function is extremely long. Extract the logic for
> handling a page belonging to a shared vma into a function of its own.
> 
> This helps the readability of the code, without doing any functional
> change in it.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>

Few nitpicks below.

> ---
>  mm/memory.c | 90 +++++++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 52 insertions(+), 38 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index c7c0df2..c0dd47a 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2227,6 +2227,56 @@ oom:
>  	return VM_FAULT_OOM;
>  }
>  
> +static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
> +			  unsigned long address, pte_t *page_table,
> +			  pmd_t *pmd, spinlock_t *ptl, pte_t orig_pte,
> +			  struct page *old_page)
> +	__releases(ptl)
> +{
> +	int page_mkwrite = 0;
> +	int ret;
> +
> +	/*
> +	 * Only catch write-faults on shared writable pages,
> +	 * read-only shared pages can get COWed by
> +	 * get_user_pages(.write=1, .force=1).
> +	 */

Reformat of the comment and comment below would safe few lines.

> +	if (!vma->vm_ops || !vma->vm_ops->page_mkwrite)
> +		goto no_mkwrite;
> +
> +

Redundant newline.

> +	page_cache_get(old_page);
> +	pte_unmap_unlock(page_table, ptl);
> +	ret = do_page_mkwrite(vma, old_page, address);
> +	if (unlikely(!ret || (ret &
> +			      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {

This would fit one line now.

> +		page_cache_release(old_page);
> +		return ret;
> +	}
> +	/*
> +	 * Since we dropped the lock we need to revalidate
> +	 * the PTE as someone else may have changed it.  If
> +	 * they did, we just return, as we can count on the
> +	 * MMU to tell us if they didn't also make it writable.
> +	 */
> +	page_table = pte_offset_map_lock(mm, pmd, address,
> +					 &ptl);

ditto.

> +	if (!pte_same(*page_table, orig_pte)) {
> +		unlock_page(old_page);
> +		pte_unmap_unlock(page_table, ptl);
> +		page_cache_release(old_page);
> +		return 0;
> +	}
> +
> +	page_mkwrite = 1;
> +
> +no_mkwrite:
> +	get_page(old_page);
> +
> +	return wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte,
> +			     old_page, 1, page_mkwrite);
> +}
> +
>  /*
>   * This routine handles present pages, when users try to write
>   * to a shared page. It is done by copying the page to a new address

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
