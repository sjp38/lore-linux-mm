Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 15D476B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 17:55:14 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ao6so222857224pac.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 14:55:14 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 2si9068146pfu.115.2016.06.24.14.55.13
        for <linux-mm@kvack.org>;
        Fri, 24 Jun 2016 14:55:13 -0700 (PDT)
Date: Fri, 24 Jun 2016 15:55:12 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/3] mm: Export follow_pte()
Message-ID: <20160624215512.GB20730@linux.intel.com>
References: <1466523915-14644-1-git-send-email-jack@suse.cz>
 <1466523915-14644-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466523915-14644-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Jun 21, 2016 at 05:45:14PM +0200, Jan Kara wrote:
> DAX will need to implement its own version of check_page_address(). To
						page_check_address()

> avoid duplicating page table walking code, export follow_pte() which
> does what we need.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/mm.h | 2 ++
>  mm/memory.c        | 5 +++--
>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5df5feb49575..989f5d949db3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1193,6 +1193,8 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
>  			struct vm_area_struct *vma);
>  void unmap_mapping_range(struct address_space *mapping,
>  		loff_t const holebegin, loff_t const holelen, int even_cows);
> +int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
> +	       spinlock_t **ptlp);
>  int follow_pfn(struct vm_area_struct *vma, unsigned long address,
>  	unsigned long *pfn);
>  int follow_phys(struct vm_area_struct *vma, unsigned long address,
> diff --git a/mm/memory.c b/mm/memory.c
> index 15322b73636b..f6175d63c2e9 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3647,8 +3647,8 @@ out:
>  	return -EINVAL;
>  }
>  
> -static inline int follow_pte(struct mm_struct *mm, unsigned long address,
> -			     pte_t **ptepp, spinlock_t **ptlp)
> +int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
> +	       spinlock_t **ptlp)
>  {
>  	int res;
>  
> @@ -3657,6 +3657,7 @@ static inline int follow_pte(struct mm_struct *mm, unsigned long address,
>  			   !(res = __follow_pte(mm, address, ptepp, ptlp)));
>  	return res;
>  }
> +EXPORT_SYMBOL(follow_pte);
>  
>  /**
>   * follow_pfn - look up PFN at a user virtual address
> -- 
> 2.6.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
