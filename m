Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 55A0E6B0031
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 05:04:56 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so145504pde.38
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 02:04:55 -0700 (PDT)
Message-ID: <523C0FAF.10401@suse.cz>
Date: Fri, 20 Sep 2013 11:04:47 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH RESEND] mm: munlock: Prevent walking off the end of
 a pagetable in no-pmd configuration
References: <52385A59.2080304@suse.cz> <1379427739-31451-1-git-send-email-vbabka@suse.cz> <5238FF3A.2070500@oracle.com>
In-Reply-To: <5238FF3A.2070500@oracle.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?SsO2cm4gRW5nZWw=?= <joern@logfs.org>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 09/18/2013 03:17 AM, Bob Liu wrote:
> On 09/17/2013 10:22 PM, Vlastimil Babka wrote:

>> --- a/mm/mlock.c
>> +++ b/mm/mlock.c
>> @@ -379,10 +379,14 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>>  
>>  	/*
>>  	 * Initialize pte walk starting at the already pinned page where we
>> -	 * are sure that there is a pte.
>> +	 * are sure that there is a pte, as it was pinned under the same
>> +	 * mmap_sem write op.
>>  	 */
>>  	pte = get_locked_pte(vma->vm_mm, start,	&ptl);
>> -	end = min(end, pmd_addr_end(start, end));
>> +	/* Make sure we do not cross the page table boundary */
>> +	end = pgd_addr_end(start, end);
>> +	end = pud_addr_end(start, end);
>> +	end = pmd_addr_end(start, end);
>>  
> 
> Nitpick, how about unfolding pmd_addr_end(start, end) directly? Like:
> 
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -376,13 +376,14 @@ static unsigned long __munlock_pagevec_fill(struct
> pagevec *pvec,
>  {
>         pte_t *pte;
>         spinlock_t *ptl;
> +       unsigned long pmd_end = (start + PMD_SIZE) & PMD_MASK;
> +       end = (pmd_end - 1 < end - 1) ? pmd_end : end;
> 
>         /*
>          * Initialize pte walk starting at the already pinned page where we
>          * are sure that there is a pte.
>          */
>         pte = get_locked_pte(vma->vm_mm, start, &ptl);
> -       end = min(end, pmd_addr_end(start, end));
> 
>         /* The page next to the pinned page is the first we will try to
> get */
>         start += PAGE_SIZE;
> 

That should also work but for maintainability reasons I wouldn't like to
special case it like this, instead of using standard functions as they
would be used in a full pagewalk.

> Anyway,
> Reviewed-by: Bob Liu <bob.liu@oracle.com>

Thanks.

Vlastimil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
