Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 695426B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 13:41:59 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v9-v6so5772289pff.4
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 10:41:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w26-v6si10681361pgk.372.2018.08.10.10.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 Aug 2018 10:41:58 -0700 (PDT)
Date: Fri, 10 Aug 2018 10:41:50 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v7 PATCH 1/4] mm: refactor do_munmap() to extract the
 common part
Message-ID: <20180810174150.GA6487@bombadil.infradead.org>
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
 <1533857763-43527-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533857763-43527-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 10, 2018 at 07:36:00AM +0800, Yang Shi wrote:
> +static inline bool addr_ok(unsigned long start, size_t len)

Maybe munmap_range_ok()?  Otherwise some of the conditions here don't make
sense for such a generic sounding function.

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
> + * @start: start address
> + * @end: end address
> + *
> + * returns the pointer to vma, NULL or err ptr when spilt_vma returns error.

kernel-doc prefers:

 * Return: %NULL if no VMA overlaps this range.  An ERR_PTR if an
 * overlapping VMA could not be split.  Otherwise a pointer to the first
 * VMA which overlaps the range.

> + */
> +static struct vm_area_struct *munmap_lookup_vma(struct mm_struct *mm,
> +			unsigned long start, unsigned long end)
> +{
> +	struct vm_area_struct *vma, *prev, *last;
>  
>  	/* Find the first overlapping VMA */
>  	vma = find_vma(mm, start);
>  	if (!vma)
> -		return 0;
> -	prev = vma->vm_prev;
> -	/* we have  start < vma->vm_end  */
> +		return NULL;
>  
> +	/* we have  start < vma->vm_end  */

Can you remove the duplicate spaces here?
