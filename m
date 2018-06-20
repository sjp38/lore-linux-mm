Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9F16B0007
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 06:57:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z69-v6so2239692wrb.20
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 03:57:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 20-v6si1070399edt.303.2018.06.20.03.57.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 03:57:51 -0700 (PDT)
Subject: Re: [PATCH] thp: use mm_file_counter to determine update which rss
 counter
References: <1529442518-17398-1-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <000df63e-2f67-a1a3-42e6-c45d93d960cd@suse.cz>
Date: Wed, 20 Jun 2018 12:57:48 +0200
MIME-Version: 1.0
In-Reply-To: <1529442518-17398-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, hughd@google.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.orgAndrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>

On 06/19/2018 11:08 PM, Yang Shi wrote:
> Since commit eca56ff906bdd0239485e8b47154a6e73dd9a2f3 ("mm, shmem: add
> internal shmem resident memory accounting"), MM_SHMEMPAGES is added to
> separate the shmem accounting from regular files. So, all shmem pages
> should be accounted to MM_SHMEMPAGES instead of MM_FILEPAGES.
> 
> And, normal 4K shmem pages have been accounted to MM_SHMEMPAGES, so
> shmem thp pages should be not treated differently. Accouting them to
> MM_SHMEMPAGES via mm_counter_file() since shmem pages are swap backed
> to keep consistent with normal 4K shmem pages.
> 
> This will not change the rss counter of processes since shmem pages are
> still a part of it.

<Andrew>So what are the user-visible effects of the patch then?</Andrew>

Let's add this?:

The /proc/pid/status and /proc/pid/statm counters will however be more
accurate wrt shmem usage, as originally intended.

> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Good catch, thanks. I guess the discrepancy happened due to the
thp-tmpfs patchset existing externally for a long time and number of
iterations, while commit eca56ff906bdd was merged, and nobody noticed
that the thp case added more MM_FILEPAGES users.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/huge_memory.c | 4 ++--
>  mm/memory.c      | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 1cd7c1a..2687f7c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1740,7 +1740,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		} else {
>  			if (arch_needs_pgtable_deposit())
>  				zap_deposited_table(tlb->mm, pmd);
> -			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
> +			add_mm_counter(tlb->mm, mm_counter_file(page), -HPAGE_PMD_NR);
>  		}
>  
>  		spin_unlock(ptl);
> @@ -2088,7 +2088,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  			SetPageReferenced(page);
>  		page_remove_rmap(page, true);
>  		put_page(page);
> -		add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
> +		add_mm_counter(mm, mm_counter_file(page), -HPAGE_PMD_NR);
>  		return;
>  	} else if (is_huge_zero_pmd(*pmd)) {
>  		/*
> diff --git a/mm/memory.c b/mm/memory.c
> index 7206a63..4a2f2a8 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3372,7 +3372,7 @@ static int do_set_pmd(struct vm_fault *vmf, struct page *page)
>  	if (write)
>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>  
> -	add_mm_counter(vma->vm_mm, MM_FILEPAGES, HPAGE_PMD_NR);
> +	add_mm_counter(vma->vm_mm, mm_counter_file(page), HPAGE_PMD_NR);
>  	page_add_file_rmap(page, true);
>  	/*
>  	 * deposit and withdraw with pmd lock held
> 
