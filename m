Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA4E280250
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 13:33:23 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id p9so36902565vkd.7
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 10:33:23 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f18si2996441uab.59.2016.11.03.10.33.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 10:33:22 -0700 (PDT)
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-16-git-send-email-aarcange@redhat.com>
 <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
Date: Thu, 3 Nov 2016 10:33:09 -0700
MIME-Version: 1.0
In-Reply-To: <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On 11/03/2016 03:15 AM, Hillf Danton wrote:
> [out of topic] Cc list is edited to quite mail agent warning:  
> -"Dr. David Alan Gilbert"@v2.random; " <dgilbert@redhat.com> 
> +"Dr. David Alan Gilbert" <dgilbert@redhat.com>
> -Pavel Emelyanov <xemul@parallels.com>"@v2.random
> +Pavel Emelyanov <xemul@parallels.com>
> -Michael Rapoport <RAPOPORT@il.ibm.com>
> +Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> 
> On Thursday, November 03, 2016 3:34 AM Andrea Arcangeli wrote: 
>> +
>> +#ifdef CONFIG_HUGETLB_PAGE
>> +/*
>> + * __mcopy_atomic processing for HUGETLB vmas.  Note that this routine is
>> + * called with mmap_sem held, it will release mmap_sem before returning.
>> + */
>> +static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
>> +					      struct vm_area_struct *dst_vma,
>> +					      unsigned long dst_start,
>> +					      unsigned long src_start,
>> +					      unsigned long len,
>> +					      bool zeropage)
>> +{
>> +	ssize_t err;
>> +	pte_t *dst_pte;
>> +	unsigned long src_addr, dst_addr;
>> +	long copied;
>> +	struct page *page;
>> +	struct hstate *h;
>> +	unsigned long vma_hpagesize;
>> +	pgoff_t idx;
>> +	u32 hash;
>> +	struct address_space *mapping;
>> +
>> +	/*
>> +	 * There is no default zero huge page for all huge page sizes as
>> +	 * supported by hugetlb.  A PMD_SIZE huge pages may exist as used
>> +	 * by THP.  Since we can not reliably insert a zero page, this
>> +	 * feature is not supported.
>> +	 */
>> +	if (zeropage)
>> +		return -EINVAL;
> 
> Release mmap_sem before return?
> 
>> +
>> +	src_addr = src_start;
>> +	dst_addr = dst_start;
>> +	copied = 0;
>> +	page = NULL;
>> +	vma_hpagesize = vma_kernel_pagesize(dst_vma);
>> +
>> +retry:
>> +	/*
>> +	 * On routine entry dst_vma is set.  If we had to drop mmap_sem and
>> +	 * retry, dst_vma will be set to NULL and we must lookup again.
>> +	 */
>> +	err = -EINVAL;
>> +	if (!dst_vma) {
>> +		dst_vma = find_vma(dst_mm, dst_start);
> 
> In case of retry, s/dst_start/dst_addr/?
> And check if we find a valid vma?
> 
>> @@ -182,6 +355,13 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>>  		goto out_unlock;
>>
>>  	/*
>> +	 * If this is a HUGETLB vma, pass off to appropriate routine
>> +	 */
>> +	if (dst_vma->vm_flags & VM_HUGETLB)
>> +		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
>> +						src_start, len, false);
> 
> Use is_vm_hugetlb_page()? 
> 
> 

Thanks Hillf, all valid points.  I will create another version of
this patch.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
