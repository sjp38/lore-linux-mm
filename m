Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06E136B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 10:42:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b15so3429421wrb.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 07:42:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si285344wme.117.2017.06.15.07.42.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 07:42:07 -0700 (PDT)
Date: Thu, 15 Jun 2017 16:42:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 1/3] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170615144204.GN1764@quack2.suse.cz>
References: <20170614172211.19820-1-ross.zwisler@linux.intel.com>
 <20170614172211.19820-2-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614172211.19820-2-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed 14-06-17 11:22:09, Ross Zwisler wrote:
> To be able to use the common 4k zero page in DAX we need to have our PTE
> fault path look more like our PMD fault path where a PTE entry can be
> marked as dirty and writeable as it is first inserted, rather than waiting
> for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
> 
> Right now we can rely on having a dax_pfn_mkwrite() call because we can
> distinguish between these two cases in do_wp_page():
> 
> 	case 1: 4k zero page => writable DAX storage
> 	case 2: read-only DAX storage => writeable DAX storage
> 
> This distinction is made by via vm_normal_page().  vm_normal_page() returns
> false for the common 4k zero page, though, just as it does for DAX ptes.
> Instead of special casing the DAX + 4k zero page case, we will simplify our
> DAX PTE page fault sequence so that it matches our DAX PMD sequence, and
> get rid of dax_pfn_mkwrite() completely.
> 
> This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
> and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set insert_pfn()
> will do the work that was previously done by wp_page_reuse() as part of the
> dax_pfn_mkwrite() call path.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

So I agree that getting rid of dax_pfn_mkwrite() and using fault handler in
that case is a way to go. However I somewhat dislike the
vm_insert_mixed_mkwrite() thing - it looks like a hack - and I'm aware that
we have a similar thing for PMD which is ugly as well. Besides being ugly
I'm also concerned that when 'mkwrite' is set, we just silently overwrite
whatever PTE was installed at that position. Not that I'd see how that
could screw us for DAX but still a concern that e.g. some PTE flag could
get discarded by this is there... In fact, for !HAVE_PTE_SPECIAL
architectures, you will leak zero page references by just overwriting the
PTE - for those archs you really need to unmap zero page before replacing
PTE (and the same for PMD I suppose).

So how about some vmf_insert_pfn(vmf, pe_size, pfn) helper that would
properly detect PTE / PMD case, read / write case etc., check that PTE did
not change from orig_pte, and handle all the nasty details instead of
messing with insert_pfn?

								Honza

> ---
>  include/linux/mm.h |  2 ++
>  mm/memory.c        | 49 +++++++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 47 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b892e95..0ea79e6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2296,6 +2296,8 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
>  			unsigned long pfn, pgprot_t pgprot);
>  int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
>  			pfn_t pfn);
> +int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
> +			pfn_t pfn);
>  int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
>  
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 2e65df1..38d7c4f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1646,7 +1646,7 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
>  EXPORT_SYMBOL(vm_insert_page);
>  
>  static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> -			pfn_t pfn, pgprot_t prot)
> +			pfn_t pfn, pgprot_t prot, bool mkwrite)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	int retval;
> @@ -1658,7 +1658,7 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  	if (!pte)
>  		goto out;
>  	retval = -EBUSY;
> -	if (!pte_none(*pte))
> +	if (!pte_none(*pte) && !mkwrite)
>  		goto out_unlock;
>  
>  	/* Ok, finally just insert the thing.. */
> @@ -1666,6 +1666,12 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  		entry = pte_mkdevmap(pfn_t_pte(pfn, prot));
>  	else
>  		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
> +
> +	if (mkwrite) {
> +		entry = pte_mkyoung(entry);
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +	}
> +
>  	set_pte_at(mm, addr, pte, entry);
>  	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
>  
> @@ -1736,7 +1742,8 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
>  
>  	track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV));
>  
> -	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);
> +	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot,
> +			false);
>  
>  	return ret;
>  }
> @@ -1772,10 +1779,44 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
>  		page = pfn_to_page(pfn_t_to_pfn(pfn));
>  		return insert_page(vma, addr, page, pgprot);
>  	}
> -	return insert_pfn(vma, addr, pfn, pgprot);
> +	return insert_pfn(vma, addr, pfn, pgprot, false);
>  }
>  EXPORT_SYMBOL(vm_insert_mixed);
>  
> +int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
> +			pfn_t pfn)
> +{
> +	pgprot_t pgprot = vma->vm_page_prot;
> +
> +	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
> +
> +	if (addr < vma->vm_start || addr >= vma->vm_end)
> +		return -EFAULT;
> +
> +	track_pfn_insert(vma, &pgprot, pfn);
> +
> +	/*
> +	 * If we don't have pte special, then we have to use the pfn_valid()
> +	 * based VM_MIXEDMAP scheme (see vm_normal_page), and thus we *must*
> +	 * refcount the page if pfn_valid is true (hence insert_page rather
> +	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
> +	 * without pte special, it would there be refcounted as a normal page.
> +	 */
> +	if (!HAVE_PTE_SPECIAL && !pfn_t_devmap(pfn) && pfn_t_valid(pfn)) {
> +		struct page *page;
> +
> +		/*
> +		 * At this point we are committed to insert_page()
> +		 * regardless of whether the caller specified flags that
> +		 * result in pfn_t_has_page() == false.
> +		 */
> +		page = pfn_to_page(pfn_t_to_pfn(pfn));
> +		return insert_page(vma, addr, page, pgprot);
> +	}
> +	return insert_pfn(vma, addr, pfn, pgprot, true);
> +}
> +EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
> +
>  /*
>   * maps a range of physical memory into the requested pages. the old
>   * mappings are removed. any references to nonexistent pages results
> -- 
> 2.9.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
