Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3049F2803E9
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 10:04:02 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j124so8835916qke.6
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 07:04:02 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0062.outbound.protection.outlook.com. [104.47.33.62])
        by mx.google.com with ESMTPS id 49si1646852qtq.306.2017.08.04.07.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 07:04:01 -0700 (PDT)
Subject: Re: A possible bug: Calling mutex_lock while holding spinlock
References: <2d442de2-c5d4-ecce-2345-4f8f34314247@amd.com>
 <20170803153902.71ceaa3b435083fc2e112631@linux-foundation.org>
 <20170804134928.l4klfcnqatni7vsc@black.fi.intel.com>
From: axie <axie@amd.com>
Message-ID: <6027ba44-d3ca-9b0b-acdf-f2ec39f01929@amd.com>
Date: Fri, 4 Aug 2017 10:03:49 -0400
MIME-Version: 1.0
In-Reply-To: <20170804134928.l4klfcnqatni7vsc@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Deucher <alexander.deucher@amd.com>, "Writer, Tim" <Tim.Writer@amd.com>, linux-mm@kvack.org, "Xie, AlexBin" <AlexBin.Xie@amd.com>

Hi Kirill,


Thanks for the patch. I have sent the patch to the user asking whether 
he can give it a try.


Regards,

Alex (Bin) Xie



On 2017-08-04 09:49 AM, Kirill A. Shutemov wrote:
> On Thu, Aug 03, 2017 at 03:39:02PM -0700, Andrew Morton wrote:
>> (cc Kirill)
>>
>> On Thu, 3 Aug 2017 12:35:28 -0400 axie <axie@amd.com> wrote:
>>
>>> Hi Andrew,
>>>
>>>
>>> I got a report yesterday with "BUG: sleeping function called from
>>> invalid context at kernel/locking/mutex.c"
>>>
>>> I checked the relevant functions for the issue. Function
>>> page_vma_mapped_walk did acquire spinlock. Later, in MMU notifier,
>>> amdgpu_mn_invalidate_page called function mutex_lock, which triggered
>>> the "bug".
>>>
>>> Function page_vma_mapped_walk was introduced recently by you in commit
>>> c7ab0d2fdc840266b39db94538f74207ec2afbf6 and
>>> ace71a19cec5eb430207c3269d8a2683f0574306.
>>>
>>> Would you advise how to proceed with this bug? Change
>>> page_vma_mapped_walk not to use spinlock? Or change
>>> amdgpu_mn_invalidate_page to use spinlock to meet the change, or
>>> something else?
>>>
>> hm, as far as I can tell this was an unintended side-effect of
>> c7ab0d2fd ("mm: convert try_to_unmap_one() to use
>> page_vma_mapped_walk()").  Before that patch,
>> mmu_notifier_invalidate_page() was not called under page_table_lock.
>> After that patch, mmu_notifier_invalidate_page() is called under
>> page_table_lock.
>>
>> Perhaps Kirill can suggest a fix?
> Sorry for this.
>
> What about the patch below?
>
>  From f48dbcdd0ed83dee9a157062b7ca1e2915172678 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Fri, 4 Aug 2017 16:37:26 +0300
> Subject: [PATCH] rmap: do not call mmu_notifier_invalidate_page() under ptl
>
> MMU notifiers can sleep, but in page_mkclean_one() we call
> mmu_notifier_invalidate_page() under page table lock.
>
> Let's instead use mmu_notifier_invalidate_range() outside
> page_vma_mapped_walk() loop.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use page_vma_mapped_walk()")
> ---
>   mm/rmap.c | 21 +++++++++++++--------
>   1 file changed, 13 insertions(+), 8 deletions(-)
>
> diff --git a/mm/rmap.c b/mm/rmap.c
> index ced14f1af6dc..b4b711a82c01 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -852,10 +852,10 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>   		.flags = PVMW_SYNC,
>   	};
>   	int *cleaned = arg;
> +	bool invalidation_needed = false;
>   
>   	while (page_vma_mapped_walk(&pvmw)) {
>   		int ret = 0;
> -		address = pvmw.address;
>   		if (pvmw.pte) {
>   			pte_t entry;
>   			pte_t *pte = pvmw.pte;
> @@ -863,11 +863,11 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>   			if (!pte_dirty(*pte) && !pte_write(*pte))
>   				continue;
>   
> -			flush_cache_page(vma, address, pte_pfn(*pte));
> -			entry = ptep_clear_flush(vma, address, pte);
> +			flush_cache_page(vma, pvmw.address, pte_pfn(*pte));
> +			entry = ptep_clear_flush(vma, pvmw.address, pte);
>   			entry = pte_wrprotect(entry);
>   			entry = pte_mkclean(entry);
> -			set_pte_at(vma->vm_mm, address, pte, entry);
> +			set_pte_at(vma->vm_mm, pvmw.address, pte, entry);
>   			ret = 1;
>   		} else {
>   #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
> @@ -877,11 +877,11 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>   			if (!pmd_dirty(*pmd) && !pmd_write(*pmd))
>   				continue;
>   
> -			flush_cache_page(vma, address, page_to_pfn(page));
> -			entry = pmdp_huge_clear_flush(vma, address, pmd);
> +			flush_cache_page(vma, pvmw.address, page_to_pfn(page));
> +			entry = pmdp_huge_clear_flush(vma, pvmw.address, pmd);
>   			entry = pmd_wrprotect(entry);
>   			entry = pmd_mkclean(entry);
> -			set_pmd_at(vma->vm_mm, address, pmd, entry);
> +			set_pmd_at(vma->vm_mm, pvmw.address, pmd, entry);
>   			ret = 1;
>   #else
>   			/* unexpected pmd-mapped page? */
> @@ -890,11 +890,16 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>   		}
>   
>   		if (ret) {
> -			mmu_notifier_invalidate_page(vma->vm_mm, address);
>   			(*cleaned)++;
> +			invalidation_needed = true;
>   		}
>   	}
>   
> +	if (invalidation_needed) {
> +		mmu_notifier_invalidate_range(vma->vm_mm, address,
> +				address + (1UL << compound_order(page)));
> +	}
> +
>   	return true;
>   }
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
