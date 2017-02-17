Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id E98C66B0481
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 19:19:01 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id 123so39860294ybe.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 16:19:01 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k132si2670319ywb.135.2017.02.16.16.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 16:19:00 -0800 (PST)
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
 <20170216184100.GS25530@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c9c8cafe-baa7-05b4-34ea-1dfa5523a85f@oracle.com>
Date: Thu, 16 Feb 2017 16:18:51 -0800
MIME-Version: 1.0
In-Reply-To: <20170216184100.GS25530@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On 02/16/2017 10:41 AM, Andrea Arcangeli wrote:
> On Wed, Feb 15, 2017 at 01:46:50PM -0800, Mike Kravetz wrote:
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index d0d1d08..41f6c51 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -4029,6 +4029,18 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>>  	__SetPageUptodate(page);
>>  	set_page_huge_active(page);
>>  
>> +	/*
>> +	 * If shared, add to page cache
>> +	 */
>> +	if (dst_vma->vm_flags & VM_SHARED) {
> 
> Minor nitpick, this could be a:
> 
>       int vm_shared = dst_vma->vm_flags & VM_SHARED;
> 
> (int faster than bool here as VM_SHARED won't have to be converted into 0|1)
> 
>> @@ -386,7 +413,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>>  		goto out_unlock;
>>  
>>  	err = -EINVAL;
>> -	if (!vma_is_shmem(dst_vma) && dst_vma->vm_flags & VM_SHARED)
>> +	if (!vma_is_shmem(dst_vma) && !is_vm_hugetlb_page(dst_vma) &&
>> +	    dst_vma->vm_flags & VM_SHARED)
>>  		goto out_unlock;
> 
> Other minor nitpick, this could have been faster as:
> 
>      if (vma_is_anonymous(dst_vma) && dst_vma->vm_flags & VM_SHARED)
> 
> Thinking twice, the only case we need to rule out is shmem_zero_setup
> (it's not anon vmas can be really VM_SHARED or they wouldn't be anon
> vmas in the first place) so even the above is superfluous because
> shmem_zero_setup does:
> 
> 	vma->vm_ops = &shmem_vm_ops;
> 
> So I would turn it into:
> 
> 
>      /*
>       * shmem_zero_setup is invoked in mmap for MAP_ANONYMOUS|MAP_SHARED but
>       * it will overwrite vm_ops, so vma_is_anonymous must return false.
>       */
>      if (WARN_ON_ONCE(vma_is_anonymous(dst_vma) && dst_vma->vm_flags & VM_SHARED))
>  		goto out_unlock;
> 
> 
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> ---

Thanks Andrea, I incorporated your suggestions into a new version of the patch. 
While changing (dst_vma->vm_flags & VM_SHARED) to integers, I noticed an issue
in the error path of __mcopy_atomic_hugetlb().

>                */
> -             ClearPagePrivate(page);
> +             if (dst_vma->vm_flags & VM_SHARED)
> +                     SetPagePrivate(page);
> +             else
> +                     ClearPagePrivate(page);
>               put_page(page);

We can not use dst_vma here as it may be different than the vma for which the
page was originally allocated, or even NULL.  Remember, we may drop mmap_sem
and look up dst_vma again.  Therefore, we need to save the value of
(dst_vma->vm_flags & VM_SHARED) for the vma which was used when the page was
allocated.  This change as well as your suggestions are in the patch below:
