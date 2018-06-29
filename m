Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14F1C6B026B
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:05:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e1-v6so4289030pgp.20
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 12:05:35 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id b7-v6si8508195pgt.642.2018.06.29.12.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 12:05:34 -0700 (PDT)
Subject: Re: [PATCH] mm: thp: passing correct vm_flags to hugepage_vma_check
References: <20180629181752.792831-1-songliubraving@fb.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <62dec816-b004-a563-bdc7-6fa09b8d2247@linux.alibaba.com>
Date: Fri, 29 Jun 2018 12:05:15 -0700
MIME-Version: 1.0
In-Reply-To: <20180629181752.792831-1-songliubraving@fb.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Song Liu <songliubraving@fb.com>, linux-mm@kvack.org
Cc: kernel-team@fb.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>



On 6/29/18 11:17 AM, Song Liu wrote:
> Back in May, I sent patch similar to 02b75dc8160d:
>
> https://patchwork.kernel.org/patch/10416233/  (v1)
>
> This patch got positive feedback. However, I realized there is a problem,
> that vma->vm_flags in khugepaged_enter_vma_merge() is stale. The separate
> argument vm_flags contains the latest value. Therefore, it is
> necessary to pass this vm_flags into hugepage_vma_check(). To fix this
> problem,  I resent v2 and v3 of the work:
>
> https://patchwork.kernel.org/patch/10419527/   (v2)
> https://patchwork.kernel.org/patch/10433937/   (v3)
>
> To my surprise, after I thought we all agreed on v3 of the work. Yang's
> patch, which is similar to correct looking (but wrong) v1, got applied.
> So we still have the issue of stale vma->vm_flags. This patch fixes this
> issue. Please apply.

Thanks for catching this.

Reviewed-by: Yang Shi <yang.shi@linux.alibaba.com>

>
> Fixes: 02b75dc8160d ("mm: thp: register mm for khugepaged when merging vma for shmem")
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>   mm/khugepaged.c | 15 ++++++++-------
>   1 file changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index b2c328030aa2..38b7db1933a3 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -397,10 +397,11 @@ static inline int khugepaged_test_exit(struct mm_struct *mm)
>   	return atomic_read(&mm->mm_users) == 0;
>   }
>   
> -static bool hugepage_vma_check(struct vm_area_struct *vma)
> +static bool hugepage_vma_check(struct vm_area_struct *vma,
> +			       unsigned long vm_flags)
>   {
> -	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
> -	    (vma->vm_flags & VM_NOHUGEPAGE) ||
> +	if ((!(vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
> +	    (vm_flags & VM_NOHUGEPAGE) ||
>   	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
>   		return false;
>   	if (shmem_file(vma->vm_file)) {
> @@ -413,7 +414,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
>   		return false;
>   	if (is_vma_temporary_stack(vma))
>   		return false;
> -	return !(vma->vm_flags & VM_NO_KHUGEPAGED);
> +	return !(vm_flags & VM_NO_KHUGEPAGED);
>   }
>   
>   int __khugepaged_enter(struct mm_struct *mm)
> @@ -458,7 +459,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>   	 * khugepaged does not yet work on non-shmem files or special
>   	 * mappings. And file-private shmem THP is not supported.
>   	 */
> -	if (!hugepage_vma_check(vma))
> +	if (!hugepage_vma_check(vma, vm_flags))
>   		return 0;
>   
>   	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
> @@ -861,7 +862,7 @@ static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address,
>   	hend = vma->vm_end & HPAGE_PMD_MASK;
>   	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
>   		return SCAN_ADDRESS_RANGE;
> -	if (!hugepage_vma_check(vma))
> +	if (!hugepage_vma_check(vma, vma->vm_flags))
>   		return SCAN_VMA_CHECK;
>   	return 0;
>   }
> @@ -1660,7 +1661,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>   			progress++;
>   			break;
>   		}
> -		if (!hugepage_vma_check(vma)) {
> +		if (!hugepage_vma_check(vma, vma->vm_flags)) {
>   skip:
>   			progress++;
>   			continue;
