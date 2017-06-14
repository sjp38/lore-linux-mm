Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA1676B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 06:05:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q97so37237414wrb.14
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 03:05:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j133si1027045wmg.152.2017.06.14.03.05.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 03:05:47 -0700 (PDT)
Date: Wed, 14 Jun 2017 12:05:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/2] mm: always enable thp for dax mappings
Message-ID: <20170614100546.GC20247@quack2.suse.cz>
References: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149739531127.20686.15813586620597484283.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <149739531127.20686.15813586620597484283.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 13-06-17 16:08:31, Dan Williams wrote:
> The madvise policy for transparent huge pages is meant to avoid unwanted
> allocations of transparent huge pages. It allows a policy of disabling
> the extra memory pressure and effort to arrange for a huge page when it
> is not needed.
> 
> DAX by definition never incurs this overhead since it is statically
> allocated. The policy choice makes even less sense for device-dax which
> tries to guarantee a given tlb-fault size. Specifically, the following
> setting:
> 
> 	echo never > /sys/kernel/mm/transparent_hugepage/enabled
> 
> ...violates that guarantee and silently disables all device-dax
> instances with a 2M or 1G alignment. So, let's avoid that non-obvious
> side effect by force enabling thp for dax mappings in all cases.
> 
> It is worth noting that the reason this uses vma_is_dax(), and the
> resulting header include changes, is that previous attempts to add a
> VM_DAX flag were NAKd.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

OK, makes sense. I can imagine some people would like to tune whether DAX
uses huge pages or not but that would make sense as a separate knob
(possibly on per-fs basis) and let's wait for real requests for this
functionality. So:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/dax.h     |    5 -----
>  include/linux/fs.h      |    6 ++++++
>  include/linux/huge_mm.h |    5 +++++
>  3 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index 1f6b6072af64..cbaf3d53d66b 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -151,11 +151,6 @@ static inline unsigned int dax_radix_order(void *entry)
>  #endif
>  int dax_pfn_mkwrite(struct vm_fault *vmf);
>  
> -static inline bool vma_is_dax(struct vm_area_struct *vma)
> -{
> -	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
> -}
> -
>  static inline bool dax_mapping(struct address_space *mapping)
>  {
>  	return mapping->host && IS_DAX(mapping->host);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 803e5a9b2654..5916ab3a12d5 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -18,6 +18,7 @@
>  #include <linux/bug.h>
>  #include <linux/mutex.h>
>  #include <linux/rwsem.h>
> +#include <linux/mm_types.h>
>  #include <linux/capability.h>
>  #include <linux/semaphore.h>
>  #include <linux/fiemap.h>
> @@ -3042,6 +3043,11 @@ static inline bool io_is_direct(struct file *filp)
>  	return (filp->f_flags & O_DIRECT) || IS_DAX(filp->f_mapping->host);
>  }
>  
> +static inline bool vma_is_dax(struct vm_area_struct *vma)
> +{
> +	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
> +}
> +
>  static inline int iocb_flags(struct file *file)
>  {
>  	int res = 0;
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index c8119e856eb1..5a86f615f3cb 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -1,6 +1,8 @@
>  #ifndef _LINUX_HUGE_MM_H
>  #define _LINUX_HUGE_MM_H
>  
> +#include <linux/fs.h> /* only for vma_is_dax() */
> +
>  extern int do_huge_pmd_anonymous_page(struct vm_fault *vmf);
>  extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
> @@ -95,6 +97,9 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>  	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
>  		return true;
>  
> +	if (vma_is_dax(vma))
> +		return true;
> +
>  	if (transparent_hugepage_flags &
>  				(1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
>  		return !!(vma->vm_flags & VM_HUGEPAGE);
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
