Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A499D82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 10:22:06 -0500 (EST)
Received: by wmec75 with SMTP id c75so116001174wme.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 07:22:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q142si7495024wmg.87.2015.11.04.07.22.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 07:22:05 -0800 (PST)
Subject: Re: [RESEND PATCH v2] thp: Remove unused vma parameter from
 khugepaged_alloc_page
References: <1446641335-5603-1-git-send-email-atomlin@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <563A229A.4030000@suse.cz>
Date: Wed, 4 Nov 2015 16:22:02 +0100
MIME-Version: 1.0
In-Reply-To: <1446641335-5603-1-git-send-email-atomlin@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Tomlin <atomlin@redhat.com>, akpm@linux-foundation.org
Cc: riel@redhat.com, lwoodman@redhat.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, willy@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/04/2015 01:48 PM, Aaron Tomlin wrote:
> Resending due to incomplete subject.
>
> Changes since v2:
>
>   - Fixed incorrect commit message
>
> The "vma" parameter to khugepaged_alloc_page() is unused.
> It has to remain unused or the drop read lock 'map_sem' optimisation
> introduce by commit 8b1645685acf ("mm, THP: don't hold mmap_sem in
> khugepaged when allocating THP") wouldn't be safe. So let's remove it.
>
> Signed-off-by: Aaron Tomlin <atomlin@redhat.com>

Pretty sure the compiler inlines it away anyway, but sure, why not.
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/huge_memory.c | 8 +++-----
>   1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index bbac913..490fa81 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2413,8 +2413,7 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
>
>   static struct page *
>   khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
> -		       struct vm_area_struct *vma, unsigned long address,
> -		       int node)
> +		       unsigned long address, int node)
>   {
>   	VM_BUG_ON_PAGE(*hpage, *hpage);
>
> @@ -2481,8 +2480,7 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
>
>   static struct page *
>   khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
> -		       struct vm_area_struct *vma, unsigned long address,
> -		       int node)
> +		       unsigned long address, int node)
>   {
>   	up_read(&mm->mmap_sem);
>   	VM_BUG_ON(!*hpage);
> @@ -2530,7 +2528,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>   		__GFP_THISNODE;
>
>   	/* release the mmap_sem read lock. */
> -	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
> +	new_page = khugepaged_alloc_page(hpage, gfp, mm, address, node);
>   	if (!new_page)
>   		return;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
