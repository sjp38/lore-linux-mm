Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2249A6B025F
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 04:09:06 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y192so21057657pgd.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 01:09:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c16si9806691pli.820.2017.10.03.01.09.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 01:09:05 -0700 (PDT)
Date: Tue, 3 Oct 2017 10:09:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 3/4] dax: stop using VM_MIXEDMAP for dax
Message-ID: <20171003080901.GD11879@quack2.suse.cz>
References: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150664807800.36094.3685385297224300424.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150664807800.36094.3685385297224300424.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu 28-09-17 18:21:18, Dan Williams wrote:
> VM_MIXEDMAP is used by dax to direct mm paths like vm_normal_page() that
> the memory page it is dealing with is not typical memory from the linear
> map. The get_user_pages_fast() path, since it does not resolve the vma,
> is already using {pte,pmd}_devmap() as a stand-in for VM_MIXEDMAP, so we
> use that as a VM_MIXEDMAP replacement in some locations. In the cases
> where there is no pte to consult we fallback to using vma_is_dax() to
> detect the VM_MIXEDMAP special case.

Well, I somewhat dislike the vma_is_dax() checks sprinkled around. That
seems rather errorprone (easy to forget about it when adding new check
somewhere). Can we possibly also create a helper vma_is_special() (or some
other name) which would do ((vma->vm_flags & VM_SPECIAL) || vma_is_dax(vma)
|| is_vm_hugetlb_page(vma)) and then use it in all those places?

								Honza

> diff --git a/mm/ksm.c b/mm/ksm.c
> index 15dd7415f7b3..787dfe4f3d44 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -2358,6 +2358,9 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
>  				 VM_HUGETLB | VM_MIXEDMAP))
>  			return 0;		/* just ignore the advice */
>  
> +		if (vma_is_dax(vma))
> +			return 0;
> +
>  #ifdef VM_SAO
>  		if (*vm_flags & VM_SAO)
>  			return 0;
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 21261ff0466f..40344d43e565 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -95,7 +95,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  		new_flags |= VM_DONTDUMP;
>  		break;
>  	case MADV_DODUMP:
> -		if (new_flags & VM_SPECIAL) {
> +		if (vma_is_dax(vma) || (new_flags & VM_SPECIAL)) {
>  			error = -EINVAL;
>  			goto out;
>  		}
> diff --git a/mm/memory.c b/mm/memory.c
> index ec4e15494901..771acaf54fe6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -830,6 +830,8 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  			return vma->vm_ops->find_special_page(vma, addr);
>  		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
>  			return NULL;
> +		if (pte_devmap(pte))
> +			return NULL;
>  		if (is_zero_pfn(pfn))
>  			return NULL;
>  
> @@ -917,6 +919,8 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
>  		}
>  	}
>  
> +	if (pmd_devmap(pmd))
> +		return NULL;
>  	if (is_zero_pfn(pfn))
>  		return NULL;
>  	if (unlikely(pfn > highest_memmap_pfn))
> @@ -1227,7 +1231,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	 * efficient than faulting.
>  	 */
>  	if (!(vma->vm_flags & (VM_HUGETLB | VM_PFNMAP | VM_MIXEDMAP)) &&
> -			!vma->anon_vma)
> +			!vma->anon_vma && !vma_is_dax(vma))
>  		return 0;
>  
>  	if (is_vm_hugetlb_page(vma))
> @@ -1896,12 +1900,24 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_pfn_prot);
>  
> +static bool vm_mixed_ok(struct vm_area_struct *vma, pfn_t pfn)
> +{
> +	/* these checks mirror the abort conditions in vm_normal_page */
> +	if (vma->vm_flags & VM_MIXEDMAP)
> +		return true;
> +	if (pfn_t_devmap(pfn))
> +		return true;
> +	if (is_zero_pfn(pfn_t_to_pfn(pfn)))
> +		return true;
> +	return false;
> +}
> +
>  static int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
>  			pfn_t pfn, bool mkwrite)
>  {
>  	pgprot_t pgprot = vma->vm_page_prot;
>  
> -	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
> +	BUG_ON(!vm_mixed_ok(vma, pfn));
>  
>  	if (addr < vma->vm_start || addr >= vma->vm_end)
>  		return -EFAULT;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 6954c1435833..179a84a311f6 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2927,7 +2927,8 @@ int migrate_vma(const struct migrate_vma_ops *ops,
>  	/* Sanity check the arguments */
>  	start &= PAGE_MASK;
>  	end &= PAGE_MASK;
> -	if (!vma || is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
> +	if (!vma || is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)
> +			|| vma_is_dax(dma))
>  		return -EINVAL;
>  	if (start < vma->vm_start || start >= vma->vm_end)
>  		return -EINVAL;
> diff --git a/mm/mlock.c b/mm/mlock.c
> index dfc6f1912176..4d009350893f 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -520,7 +520,8 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
>  	vm_flags_t old_flags = vma->vm_flags;
>  
>  	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
> -	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
> +	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm) ||
> +	    vma_is_dax(vma))
>  		/* don't set VM_LOCKED or VM_LOCKONFAULT and don't count */
>  		goto out;
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 680506faceae..2f3971a051c6 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1723,7 +1723,8 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
>  	if (vm_flags & VM_LOCKED) {
>  		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
> -					vma == get_gate_vma(current->mm)))
> +					vma == get_gate_vma(current->mm) ||
> +					vma_is_dax(vma)))
>  			mm->locked_vm += (len >> PAGE_SHIFT);
>  		else
>  			vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
