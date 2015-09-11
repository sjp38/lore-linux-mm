Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 594A46B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 09:22:18 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so64077141wic.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 06:22:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xb8si430486wjb.75.2015.09.11.06.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Sep 2015 06:22:16 -0700 (PDT)
Subject: Re: [PATCHv10 37/36, RFC] thp: allow mlocked THP again
References: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1441293388-137552-1-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F2D586.3040204@suse.cz>
Date: Fri, 11 Sep 2015 15:22:14 +0200
MIME-Version: 1.0
In-Reply-To: <1441293388-137552-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/03/2015 05:16 PM, Kirill A. Shutemov wrote:
> This patch brings back mlocked THP. Instead of forbidding mlocked pages
> altogether, we just avoid mlocking PTE-mapped THPs and munlock THPs on
> split_huge_pmd().
>
> This means PTE-mapped THPs will be on normal lru lists and will be
> split under memory pressure by vmscan. After the split vmscan will
> detect unevictable small pages and mlock them.

Yeah that sounds like a compromise that should work.

> This way we can void leaking mlocked pages into non-VM_LOCKED VMAs.

                  avoid

But mlocked page in non-mlocked VMA's is a normal thing for shared pages 
when only one of the sharing mm's did mlock(), right? So this 
description doesn't explain the whole issue. I admit I forgot the exact 
details already :(

>
> Not-Yet-Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>
> I'm not yet 100% certain that this approch is correct. Review would be appriciated.
> More testing is required.
>
> ---
>   mm/gup.c         |  6 ++++--
>   mm/huge_memory.c | 33 +++++++++++++++++++++++-------
>   mm/memory.c      |  3 +--
>   mm/mlock.c       | 61 +++++++++++++++++++++++++++++++++++++-------------------
>   4 files changed, 71 insertions(+), 32 deletions(-)
>
> diff --git a/mm/gup.c b/mm/gup.c
> index 70d65e4015a4..e95b0cb6ed81 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -143,6 +143,10 @@ retry:
>   		mark_page_accessed(page);
>   	}
>   	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
> +		/* Do not mlock pte-mapped THP */
> +		if (PageTransCompound(page))
> +			goto out;
> +
>   		/*
>   		 * The preliminary mapping check is mainly to avoid the
>   		 * pointless overhead of lock_page on the ZERO_PAGE
> @@ -920,8 +924,6 @@ long populate_vma_page_range(struct vm_area_struct *vma,
>   	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
>   	if (vma->vm_flags & VM_LOCKONFAULT)
>   		gup_flags &= ~FOLL_POPULATE;
> -	if (vma->vm_flags & VM_LOCKED)
> -		gup_flags |= FOLL_SPLIT;
>   	/*
>   	 * We want to touch writable mappings with a write fault in order
>   	 * to break COW, except for shared mappings because these don't COW
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 2cc99f9096a8..d714de02473b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -846,8 +846,6 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>
>   	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
>   		return VM_FAULT_FALLBACK;
> -	if (vma->vm_flags & VM_LOCKED)
> -		return VM_FAULT_FALLBACK;
>   	if (unlikely(anon_vma_prepare(vma)))
>   		return VM_FAULT_OOM;
>   	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
> @@ -1316,7 +1314,16 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>   			update_mmu_cache_pmd(vma, addr, pmd);
>   	}
>   	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
> -		if (page->mapping && trylock_page(page)) {
> +		/*
> +		 * We don't mlock() pte-mapped THPs. This way we can avoid
> +		 * leaking mlocked pages into non-VM_LOCKED VMAs.
> +		 * In most cases the pmd is the only mapping of the page: we
> +		 * break COW for the mlock(). The only scenario when we have

I don't understand what's meant by "we break COW for the mlock()"?

> +		 * the page shared here is if we mlocking read-only mapping
> +		 * shared over fork(). We skip mlocking such pages.

Why do we skip them? There's no PTE mapping involved, just multiple PMD 
mappings? Why are those a problem?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
