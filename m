Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7931B6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 08:45:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v104so38190343wrb.6
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 05:45:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b39si900533wrd.211.2017.06.14.05.45.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 05:45:23 -0700 (PDT)
Date: Wed, 14 Jun 2017 14:45:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: improve readability of
 transparent_hugepage_enabled()
Message-ID: <20170614124520.GA8537@dhcp22.suse.cz>
References: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 13-06-17 16:08:26, Dan Williams wrote:
> Turn the macro into a static inline and rewrite the condition checks for
> better readability in preparation for adding another condition.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> [ross: fix logic to make conversion equivalent]
> Acked-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

This is really a nice deobfuscation! Please note this will conflict with
http://lkml.kernel.org/r/1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com

Trivial to resolve but I thought I should give you a heads up.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/huge_mm.h |   32 +++++++++++++++++++++-----------
>  1 file changed, 21 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index a3762d49ba39..c8119e856eb1 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -85,14 +85,23 @@ extern struct kobj_attribute shmem_enabled_attr;
>  
>  extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>  
> -#define transparent_hugepage_enabled(__vma)				\
> -	((transparent_hugepage_flags &					\
> -	  (1<<TRANSPARENT_HUGEPAGE_FLAG) ||				\
> -	  (transparent_hugepage_flags &					\
> -	   (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&			\
> -	   ((__vma)->vm_flags & VM_HUGEPAGE))) &&			\
> -	 !((__vma)->vm_flags & VM_NOHUGEPAGE) &&			\
> -	 !is_vma_temporary_stack(__vma))
> +extern unsigned long transparent_hugepage_flags;
> +
> +static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
> +{
> +	if ((vma->vm_flags & VM_NOHUGEPAGE) || is_vma_temporary_stack(vma))
> +		return false;
> +
> +	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
> +		return true;
> +
> +	if (transparent_hugepage_flags &
> +				(1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
> +		return !!(vma->vm_flags & VM_HUGEPAGE);
> +
> +	return false;
> +}
> +
>  #define transparent_hugepage_use_zero_page()				\
>  	(transparent_hugepage_flags &					\
>  	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
> @@ -104,8 +113,6 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>  #define transparent_hugepage_debug_cow() 0
>  #endif /* CONFIG_DEBUG_VM */
>  
> -extern unsigned long transparent_hugepage_flags;
> -
>  extern unsigned long thp_get_unmapped_area(struct file *filp,
>  		unsigned long addr, unsigned long len, unsigned long pgoff,
>  		unsigned long flags);
> @@ -223,7 +230,10 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
>  
>  #define hpage_nr_pages(x) 1
>  
> -#define transparent_hugepage_enabled(__vma) 0
> +static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
> +{
> +	return false;
> +}
>  
>  static inline void prep_transhuge_page(struct page *page) {}
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
