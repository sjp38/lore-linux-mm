Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 157A46B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 12:22:18 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g11-v6so1941407edi.8
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:22:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p11-v6si953036edl.126.2018.07.24.09.22.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 09:22:16 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6OGLX8R035309
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 12:22:14 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ke5n6f4qw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 12:22:14 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 24 Jul 2018 17:22:11 +0100
Subject: Re: [RFC v5 PATCH 1/2] mm: refactor do_munmap() to extract the common
 part
References: <1531956101-8526-1-git-send-email-yang.shi@linux.alibaba.com>
 <1531956101-8526-2-git-send-email-yang.shi@linux.alibaba.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 24 Jul 2018 18:22:06 +0200
MIME-Version: 1.0
In-Reply-To: <1531956101-8526-2-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <32ce6f0e-2c48-a54f-9839-baf7d11c48fe@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 19/07/2018 01:21, Yang Shi wrote:
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
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

FWIW : Reviewed-by : Laurent Dufour <ldufour@linux.vnet.ibm.com>

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
> + *
> + * returns 1 if successful, 0 or errno otherwise
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
> +
> +static inline void munmap_mlock_vma(struct vm_area_struct *vma,
> +				    unsigned long end)
> +{
> +	struct vm_area_struct *tmp = vma;
> +
> +	while (tmp && tmp->vm_start < end) {
> +		if (tmp->vm_flags & VM_LOCKED) {
> +			vma->vm_mm->locked_vm -= vma_pages(tmp);
> +			munlock_vma_pages_all(tmp);
> +		}
> +		tmp = tmp->vm_next;
> +	}
> +}
> +
> +/* Munmap is split into 2 main parts -- this part which finds
> + * what needs doing, and the areas themselves, which do the
> + * work.  This now handles partial unmappings.
> + * Jeremy Fitzhardinge <jeremy@goop.org>
> + */
> +int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
> +	      struct list_head *uf)
> +{
> +	unsigned long end;
> +	struct vm_area_struct *vma = NULL, *prev;
> +	int ret = 0;
> +
> +	if (!munmap_addr_sanity(start, len))
> +		return -EINVAL;
> +
> +	len = PAGE_ALIGN(len);
> +
> +	end = start + len;
> +
> +	ret = munmap_lookup_vma(mm, &vma, &prev, start, end);
> +	if (ret != 1)
> +		return ret;
> 
>  	if (unlikely(uf)) {
>  		/*
> @@ -2759,24 +2811,16 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  		 * split, despite we could. This is unlikely enough
>  		 * failure that it's not worth optimizing it for.
>  		 */
> -		int error = userfaultfd_unmap_prep(vma, start, end, uf);
> -		if (error)
> -			return error;
> +		ret = userfaultfd_unmap_prep(vma, start, end, uf);
> +		if (ret)
> +			return ret;
>  	}
> 
>  	/*
>  	 * unlock any mlock()ed ranges before detaching vmas
>  	 */
> -	if (mm->locked_vm) {
> -		struct vm_area_struct *tmp = vma;
> -		while (tmp && tmp->vm_start < end) {
> -			if (tmp->vm_flags & VM_LOCKED) {
> -				mm->locked_vm -= vma_pages(tmp);
> -				munlock_vma_pages_all(tmp);
> -			}
> -			tmp = tmp->vm_next;
> -		}
> -	}
> +	if (mm->locked_vm)
> +		munmap_mlock_vma(vma, end);
> 
>  	/*
>  	 * Remove the vma's, and unmap the actual pages
> 
