Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE8E6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 05:04:10 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k30so4224633wrc.9
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 02:04:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si4972160wmh.10.2017.06.08.02.04.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 02:04:09 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: numa: avoid waiting on freed migrated pages
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-2-git-send-email-will.deacon@arm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c7000523-7b2b-06ed-6273-886978efaab5@suse.cz>
Date: Thu, 8 Jun 2017 11:04:05 +0200
MIME-Version: 1.0
In-Reply-To: <1496771916-28203-2-git-send-email-will.deacon@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On 06/06/2017 07:58 PM, Will Deacon wrote:
> From: Mark Rutland <mark.rutland@arm.com>
> 
> In do_huge_pmd_numa_page(), we attempt to handle a migrating thp pmd by
> waiting until the pmd is unlocked before we return and retry. However,
> we can race with migrate_misplaced_transhuge_page():
> 
> // do_huge_pmd_numa_page                // migrate_misplaced_transhuge_page()
> // Holds 0 refs on page                 // Holds 2 refs on page
> 
> vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
> /* ... */
> if (pmd_trans_migrating(*vmf->pmd)) {
>         page = pmd_page(*vmf->pmd);
>         spin_unlock(vmf->ptl);
>                                         ptl = pmd_lock(mm, pmd);
>                                         if (page_count(page) != 2)) {
>                                                 /* roll back */
>                                         }
>                                         /* ... */
>                                         mlock_migrate_page(new_page, page);
>                                         /* ... */
>                                         spin_unlock(ptl);
>                                         put_page(page);
>                                         put_page(page); // page freed here
>         wait_on_page_locked(page);
>         goto out;
> }
> 
> This can result in the freed page having its waiters flag set
> unexpectedly, which trips the PAGE_FLAGS_CHECK_AT_PREP checks in the
> page alloc/free functions. This has been observed on arm64 KVM guests.
> 
> We can avoid this by having do_huge_pmd_numa_page() take a reference on
> the page before dropping the pmd lock, mirroring what we do in
> __migration_entry_wait().
> 
> When we hit the race, migrate_misplaced_transhuge_page() will see the
> reference and abort the migration, as it may do today in other cases.
> 
> Acked-by: Steve Capper <steve.capper@arm.com>
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Nice catch! Stable candidate? Fixes: the commit that added waiters flag?
Assuming it was harmless before that?

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/huge_memory.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a84909cf20d3..88c6167f194d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1426,8 +1426,11 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
>  	 */
>  	if (unlikely(pmd_trans_migrating(*vmf->pmd))) {
>  		page = pmd_page(*vmf->pmd);
> +		if (!get_page_unless_zero(page))
> +			goto out_unlock;
>  		spin_unlock(vmf->ptl);
>  		wait_on_page_locked(page);
> +		put_page(page);
>  		goto out;
>  	}
>  
> @@ -1459,9 +1462,12 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
>  
>  	/* Migration could have started since the pmd_trans_migrating check */
>  	if (!page_locked) {
> +		page_nid = -1;
> +		if (!get_page_unless_zero(page))
> +			goto out_unlock;
>  		spin_unlock(vmf->ptl);
>  		wait_on_page_locked(page);
> -		page_nid = -1;
> +		put_page(page);
>  		goto out;
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
