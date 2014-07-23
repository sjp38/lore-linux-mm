Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id E6D776B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 05:10:48 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so859757wev.13
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 02:10:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ee6si3572884wic.28.2014.07.23.02.10.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 02:10:45 -0700 (PDT)
Date: Wed, 23 Jul 2014 11:10:40 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v8 05/22] Add vm_replace_mixed()
Message-ID: <20140723091040.GC15688@quack.suse.cz>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <b1052af08b49965fd0e6b87b6733b89294c8cc1e.1406058387.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1052af08b49965fd0e6b87b6733b89294c8cc1e.1406058387.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>

On Tue 22-07-14 15:47:53, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> vm_insert_mixed() will fail if there is already a valid PTE at that
> location.  The DAX code would rather replace the previous value with
> the new PTE.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
  This looks good to me although I'm not an expert in this area. So just:
Acked-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/mm.h |  8 ++++++--
>  mm/memory.c        | 34 +++++++++++++++++++++-------------
>  2 files changed, 27 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index e04f531..8d1194c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1958,8 +1958,12 @@ int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>  int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
>  int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  			unsigned long pfn);
> -int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
> -			unsigned long pfn);
> +int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
> +			unsigned long pfn, bool replace);
> +#define vm_insert_mixed(vma, addr, pfn)	\
> +	__vm_insert_mixed(vma, addr, pfn, false)
> +#define vm_replace_mixed(vma, addr, pfn)	\
> +	__vm_insert_mixed(vma, addr, pfn, true)
>  int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
>  
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 42bf429..cf06c97 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1476,7 +1476,7 @@ pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
>   * pages reserved for the old functions anyway.
>   */
>  static int insert_page(struct vm_area_struct *vma, unsigned long addr,
> -			struct page *page, pgprot_t prot)
> +			struct page *page, pgprot_t prot, bool replace)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	int retval;
> @@ -1492,8 +1492,12 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>  	if (!pte)
>  		goto out;
>  	retval = -EBUSY;
> -	if (!pte_none(*pte))
> -		goto out_unlock;
> +	if (!pte_none(*pte)) {
> +		if (!replace)
> +			goto out_unlock;
> +		VM_BUG_ON(!mutex_is_locked(&vma->vm_file->f_mapping->i_mmap_mutex));
> +		zap_page_range_single(vma, addr, PAGE_SIZE, NULL);
> +	}
>  
>  	/* Ok, finally just insert the thing.. */
>  	get_page(page);
> @@ -1549,12 +1553,12 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
>  		BUG_ON(vma->vm_flags & VM_PFNMAP);
>  		vma->vm_flags |= VM_MIXEDMAP;
>  	}
> -	return insert_page(vma, addr, page, vma->vm_page_prot);
> +	return insert_page(vma, addr, page, vma->vm_page_prot, false);
>  }
>  EXPORT_SYMBOL(vm_insert_page);
>  
>  static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> -			unsigned long pfn, pgprot_t prot)
> +			unsigned long pfn, pgprot_t prot, bool replace)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	int retval;
> @@ -1566,8 +1570,12 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  	if (!pte)
>  		goto out;
>  	retval = -EBUSY;
> -	if (!pte_none(*pte))
> -		goto out_unlock;
> +	if (!pte_none(*pte)) {
> +		if (!replace)
> +			goto out_unlock;
> +		VM_BUG_ON(!mutex_is_locked(&vma->vm_file->f_mapping->i_mmap_mutex));
> +		zap_page_range_single(vma, addr, PAGE_SIZE, NULL);
> +	}
>  
>  	/* Ok, finally just insert the thing.. */
>  	entry = pte_mkspecial(pfn_pte(pfn, prot));
> @@ -1620,14 +1628,14 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  	if (track_pfn_insert(vma, &pgprot, pfn))
>  		return -EINVAL;
>  
> -	ret = insert_pfn(vma, addr, pfn, pgprot);
> +	ret = insert_pfn(vma, addr, pfn, pgprot, false);
>  
>  	return ret;
>  }
>  EXPORT_SYMBOL(vm_insert_pfn);
>  
> -int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
> -			unsigned long pfn)
> +int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
> +			unsigned long pfn, bool replace)
>  {
>  	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
>  
> @@ -1645,11 +1653,11 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
>  		struct page *page;
>  
>  		page = pfn_to_page(pfn);
> -		return insert_page(vma, addr, page, vma->vm_page_prot);
> +		return insert_page(vma, addr, page, vma->vm_page_prot, replace);
>  	}
> -	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
> +	return insert_pfn(vma, addr, pfn, vma->vm_page_prot, replace);
>  }
> -EXPORT_SYMBOL(vm_insert_mixed);
> +EXPORT_SYMBOL(__vm_insert_mixed);
>  
>  /*
>   * maps a range of physical memory into the requested pages. the old
> -- 
> 2.0.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
