Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63AAE6B02C5
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 06:15:51 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rt15so20804005pab.5
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 03:15:51 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id f6si8766879pga.83.2016.11.03.03.15.49
        for <linux-mm@kvack.org>;
        Thu, 03 Nov 2016 03:15:50 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com> <1478115245-32090-16-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-16-git-send-email-aarcange@redhat.com>
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb for huge page UFFDIO_COPY
Date: Thu, 03 Nov 2016 18:15:34 +0800
Message-ID: <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

[out of topic] Cc list is edited to quite mail agent warning:  
-"Dr. David Alan Gilbert"@v2.random; " <dgilbert@redhat.com> 
+"Dr. David Alan Gilbert" <dgilbert@redhat.com>
-Pavel Emelyanov <xemul@parallels.com>"@v2.random
+Pavel Emelyanov <xemul@parallels.com>
-Michael Rapoport <RAPOPORT@il.ibm.com>
+Mike Rapoport <rppt@linux.vnet.ibm.com>


On Thursday, November 03, 2016 3:34 AM Andrea Arcangeli wrote: 
> +
> +#ifdef CONFIG_HUGETLB_PAGE
> +/*
> + * __mcopy_atomic processing for HUGETLB vmas.  Note that this routine is
> + * called with mmap_sem held, it will release mmap_sem before returning.
> + */
> +static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
> +					      struct vm_area_struct *dst_vma,
> +					      unsigned long dst_start,
> +					      unsigned long src_start,
> +					      unsigned long len,
> +					      bool zeropage)
> +{
> +	ssize_t err;
> +	pte_t *dst_pte;
> +	unsigned long src_addr, dst_addr;
> +	long copied;
> +	struct page *page;
> +	struct hstate *h;
> +	unsigned long vma_hpagesize;
> +	pgoff_t idx;
> +	u32 hash;
> +	struct address_space *mapping;
> +
> +	/*
> +	 * There is no default zero huge page for all huge page sizes as
> +	 * supported by hugetlb.  A PMD_SIZE huge pages may exist as used
> +	 * by THP.  Since we can not reliably insert a zero page, this
> +	 * feature is not supported.
> +	 */
> +	if (zeropage)
> +		return -EINVAL;

Release mmap_sem before return?

> +
> +	src_addr = src_start;
> +	dst_addr = dst_start;
> +	copied = 0;
> +	page = NULL;
> +	vma_hpagesize = vma_kernel_pagesize(dst_vma);
> +
> +retry:
> +	/*
> +	 * On routine entry dst_vma is set.  If we had to drop mmap_sem and
> +	 * retry, dst_vma will be set to NULL and we must lookup again.
> +	 */
> +	err = -EINVAL;
> +	if (!dst_vma) {
> +		dst_vma = find_vma(dst_mm, dst_start);

In case of retry, s/dst_start/dst_addr/?
And check if we find a valid vma?

> @@ -182,6 +355,13 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  		goto out_unlock;
> 
>  	/*
> +	 * If this is a HUGETLB vma, pass off to appropriate routine
> +	 */
> +	if (dst_vma->vm_flags & VM_HUGETLB)
> +		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
> +						src_start, len, false);

Use is_vm_hugetlb_page()? 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
