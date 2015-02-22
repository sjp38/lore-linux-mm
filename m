Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C146F6B0071
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 08:10:04 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id l15so11418315wiw.3
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 05:10:04 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cd11si4829933wib.102.2015.02.22.05.10.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 05:10:03 -0800 (PST)
Date: Sun, 22 Feb 2015 08:09:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V4 1/4] mm: Refactor do_wp_page, extract the reuse case
Message-ID: <20150222130952.GA5324@phnom.home.cmpxchg.org>
References: <1424609241-20106-1-git-send-email-raindel@mellanox.com>
 <1424609241-20106-2-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424609241-20106-2-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, sagig@mellanox.com, walken@google.com, Dave Hansen <dave.hansen@intel.com>

On Sun, Feb 22, 2015 at 02:47:18PM +0200, Shachar Raindel wrote:
> @@ -1983,6 +1983,66 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
>  }
>  
>  /*
> + * Handle write page faults for pages that can be reused in the current vma
> + *
> + * This can happen either due to the mapping being with the VM_SHARED flag,
> + * or due to us being the last reference standing to the page. In either
> + * case, all we need to do here is to mark the page as writable and update
> + * any related book-keeping.
> + */
> +static int wp_page_reuse(struct mm_struct *mm, struct vm_area_struct *vma,
> +			 unsigned long address, pte_t *page_table,
> +			 spinlock_t *ptl, pte_t orig_pte,
> +			 struct page *page, int dirty_page,
> +			 int page_mkwrite, int dirty_shared)

The dirty_page parameter is not used in the function below.  Is it
maybe a vestige of a previous patch version?

> +	__releases(ptl)
> +{
> +	pte_t entry;
> +	/*
> +	 * Clear the pages cpupid information as the existing
> +	 * information potentially belongs to a now completely
> +	 * unrelated process.
> +	 */
> +	if (page)
> +		page_cpupid_xchg_last(page, (1 << LAST_CPUPID_SHIFT) - 1);
> +
> +	flush_cache_page(vma, address, pte_pfn(orig_pte));
> +	entry = pte_mkyoung(orig_pte);
> +	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +	if (ptep_set_access_flags(vma, address, page_table, entry, 1))
> +		update_mmu_cache(vma, address, page_table);
> +	pte_unmap_unlock(page_table, ptl);
> +
> +

Spurious newline.

> +	if (dirty_shared) {
> +		struct address_space *mapping;
> +		int dirtied;
> +
> +		if (!page_mkwrite)
> +			lock_page(page);
> +
> +		dirtied = set_page_dirty(page);
> +		VM_BUG_ON_PAGE(PageAnon(page), page);
> +		mapping = page->mapping;
> +		unlock_page(page);
> +		page_cache_release(page);
> +
> +		if ((dirtied || page_mkwrite) && mapping) {
> +			/*
> +			 * Some device drivers do not set page.mapping
> +			 * but still dirty their pages
> +			 */
> +			balance_dirty_pages_ratelimited(mapping);
> +		}
> +
> +		if (!page_mkwrite)
> +			file_update_time(vma->vm_file);
> +	}
> +
> +	return VM_FAULT_WRITE;
> +}
> +
> +/*
>   * This routine handles present pages, when users try to write
>   * to a shared page. It is done by copying the page to a new address
>   * and decrementing the shared-page counter for the old page.

> @@ -2055,12 +2114,15 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			 */
>  			page_move_anon_rmap(old_page, vma, address);
>  			unlock_page(old_page);
> -			goto reuse;
> +			return wp_page_reuse(mm, vma, address, page_table, ptl,
> +					     orig_pte, old_page, 0, 0, 0);
>  		}
>  		unlock_page(old_page);
>  	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
>  					(VM_WRITE|VM_SHARED))) {
> +		int page_mkwrite = 0;
>  		page_cache_get(old_page);
> +

Can you please insert a newline between variable decl and code?

Otherwise, the patch looks good to me.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
