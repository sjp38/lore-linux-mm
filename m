Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E79016B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 04:53:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t17-v6so1592336edr.21
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 01:53:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15-v6si484544eda.179.2018.08.03.01.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 01:53:36 -0700 (PDT)
Date: Fri, 3 Aug 2018 10:53:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v6 PATCH 1/2] mm: refactor do_munmap() to extract the
 common part
Message-ID: <20180803085335.GH27245@dhcp22.suse.cz>
References: <1532628614-111702-1-git-send-email-yang.shi@linux.alibaba.com>
 <1532628614-111702-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532628614-111702-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-07-18 02:10:13, Yang Shi wrote:
> Introduces three new helper functions:
>   * munmap_addr_sanity()
>   * munmap_lookup_vma()
>   * munmap_mlock_vma()
> 
> They will be used by do_munmap() and the new do_munmap with zapping
> large mapping early in the later patch.
> 
> There is no functional change, just code refactor.
> 
> Reviewed-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  mm/mmap.c | 120 ++++++++++++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 82 insertions(+), 38 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index d1eb87e..2504094 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2686,34 +2686,44 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
>  	return __split_vma(mm, vma, addr, new_below);
>  }
>  
> -/* Munmap is split into 2 main parts -- this part which finds
> - * what needs doing, and the areas themselves, which do the
> - * work.  This now handles partial unmappings.
> - * Jeremy Fitzhardinge <jeremy@goop.org>
> - */
> -int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
> -	      struct list_head *uf)
> +static inline bool munmap_addr_sanity(unsigned long start, size_t len)

munmap_check_addr? Btw. why does this need to have munmap prefix at all?
This is a general address space check.

>  {
> -	unsigned long end;
> -	struct vm_area_struct *vma, *prev, *last;
> -
>  	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE-start)
> -		return -EINVAL;
> +		return false;
>  
> -	len = PAGE_ALIGN(len);
> -	if (len == 0)
> -		return -EINVAL;
> +	if (PAGE_ALIGN(len) == 0)
> +		return false;
> +
> +	return true;
> +}
> +
> +/*
> + * munmap_lookup_vma: find the first overlap vma and split overlap vmas.
> + * @mm: mm_struct
> + * @vma: the first overlapping vma
> + * @prev: vma's prev
> + * @start: start address
> + * @end: end address

This really doesn't help me to understand how to use the function.
Why do we need both prev and vma etc...

> + *
> + * returns 1 if successful, 0 or errno otherwise

This is a really weird calling convention. So what does 0 tell? /me
checks the code. Ohh, it is nothing to do. Why cannot you simply return
the vma. NULL implies nothing to do, ERR_PTR on error.

> + */
> +static int munmap_lookup_vma(struct mm_struct *mm, struct vm_area_struct **vma,
> +			     struct vm_area_struct **prev, unsigned long start,
> +			     unsigned long end)
> +{
> +	struct vm_area_struct *tmp, *last;
>  
>  	/* Find the first overlapping VMA */
> -	vma = find_vma(mm, start);
> -	if (!vma)
> +	tmp = find_vma(mm, start);
> +	if (!tmp)
>  		return 0;
> -	prev = vma->vm_prev;
> -	/* we have  start < vma->vm_end  */
> +
> +	*prev = tmp->vm_prev;

Why do you set prev here. We might "fail" with 0 right after this

> +
> +	/* we have start < vma->vm_end  */
>  
>  	/* if it doesn't overlap, we have nothing.. */
> -	end = start + len;
> -	if (vma->vm_start >= end)
> +	if (tmp->vm_start >= end)
>  		return 0;
>  
>  	/*
> @@ -2723,7 +2733,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  	 * unmapped vm_area_struct will remain in use: so lower split_vma
>  	 * places tmp vma above, and higher split_vma places tmp vma below.
>  	 */
> -	if (start > vma->vm_start) {
> +	if (start > tmp->vm_start) {
>  		int error;
>  
>  		/*
> @@ -2731,13 +2741,14 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  		 * not exceed its limit; but let map_count go just above
>  		 * its limit temporarily, to help free resources as expected.
>  		 */
> -		if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
> +		if (end < tmp->vm_end &&
> +		    mm->map_count > sysctl_max_map_count)
>  			return -ENOMEM;
>  
> -		error = __split_vma(mm, vma, start, 0);
> +		error = __split_vma(mm, tmp, start, 0);
>  		if (error)
>  			return error;
> -		prev = vma;
> +		*prev = tmp;
>  	}
>  
>  	/* Does it split the last one? */
> @@ -2747,7 +2758,48 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  		if (error)
>  			return error;
>  	}
> -	vma = prev ? prev->vm_next : mm->mmap;
> +
> +	*vma = *prev ? (*prev)->vm_next : mm->mmap;
> +
> +	return 1;
> +}

the patch would be much more easier to read if you didn't do vma->tmp
renaming.

-- 
Michal Hocko
SUSE Labs
