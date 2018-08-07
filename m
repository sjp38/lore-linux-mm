Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF2F6B000E
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 10:59:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d18-v6so5505356edp.0
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 07:59:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1-v6si2382716edj.389.2018.08.07.07.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 07:59:47 -0700 (PDT)
Subject: Re: [RFC v6 PATCH 1/2] mm: refactor do_munmap() to extract the common
 part
References: <1532628614-111702-1-git-send-email-yang.shi@linux.alibaba.com>
 <1532628614-111702-2-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0289d239-80f1-23e1-331d-6d83f762aeb4@suse.cz>
Date: Tue, 7 Aug 2018 16:59:46 +0200
MIME-Version: 1.0
In-Reply-To: <1532628614-111702-2-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/26/2018 08:10 PM, Yang Shi wrote:
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

Since it's returning bool, the proper naming scheme would be something
like "munmap_addr_ok()". I don't know how I would replace the "munmap_"
prefix myself though.

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

Agree with Michal that you could simply return vma, NULL, or error.
Caller can easily find out prev from that, it's not like we have to
count each cpu cycle here. It will be a bit less tricky code as well,
which is a plus.

...
> +static inline void munmap_mlock_vma(struct vm_area_struct *vma,
> +				    unsigned long end)

This function does munlock, not mlock. You could call it e.g.
munlock_vmas().

> +{
> +	struct vm_area_struct *tmp = vma;
> +
> +	while (tmp && tmp->vm_start < end) {
> +		if (tmp->vm_flags & VM_LOCKED) {
> +			vma->vm_mm->locked_vm -= vma_pages(tmp);

You keep 'vma' just for the vm_mm? Better extract mm pointer first and
then you don't need the 'tmp'.

> +			munlock_vma_pages_all(tmp);
> +		}
> +		tmp = tmp->vm_next;
> +	}
> +}
