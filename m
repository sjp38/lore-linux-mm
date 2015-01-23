Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8AE6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 14:59:41 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id l6so8063697qcy.13
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 11:59:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n3si3272489qga.55.2015.01.23.11.59.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 11:59:39 -0800 (PST)
Date: Fri, 23 Jan 2015 20:18:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: incorporate read-only pages into transparent huge
 pages
Message-ID: <20150123191816.GN11755@redhat.com>
References: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com

Hello everyone,

On Fri, Jan 23, 2015 at 09:47:36AM +0200, Ebru Akagunduz wrote:
> This patch aims to improve THP collapse rates, by allowing
> THP collapse in the presence of read-only ptes, like those
> left in place by do_swap_page after a read fault.
> 
> Currently THP can collapse 4kB pages into a THP when
> there are up to khugepaged_max_ptes_none pte_none ptes
> in a 2MB range. This patch applies the same limit for
> read-only ptes.
> 
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. I force
> the system to swap out all but 190MB of the program by
> touching other memory. Afterwards, the test program does
> a mix of reads and writes to its memory, and the memory
> gets swapped back in.
> 
> Without the patch, only the memory that did not get
> swapped out remained in THPs, which corresponds to 24% of
> the memory of the program. The percentage did not increase
> over time.
> 
> With this patch, after 5 minutes of waiting khugepaged had
> collapsed 55% of the program's memory back into THPs.

This is a nice improvement, thanks!

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 817a875..af750d9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2158,7 +2158,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  			else
>  				goto out;
>  		}
> -		if (!pte_present(pteval) || !pte_write(pteval))
> +		if (!pte_present(pteval))
>  			goto out;
>  		page = vm_normal_page(vma, address, pteval);
>  		if (unlikely(!page))
> @@ -2169,7 +2169,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
>  
>  		/* cannot use mapcount: can't collapse if there's a gup pin */
> -		if (page_count(page) != 1)
> +		if (page_count(page) != 1 + !!PageSwapCache(page))
>  			goto out;
>  		/*
>  		 * We can do it before isolate_lru_page because the
> @@ -2179,6 +2179,17 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  		 */
>  		if (!trylock_page(page))
>  			goto out;

No gup pin can be taken from under us because we hold the mmap_sem for
writing, PT lock and stopped any gup-fast with pmdp_clear_flush.

Problem is PageSwapCache if read before taking the page lock is
unstable/racy and so page_count could return 2 because there's a real
gup-pin, but then the page is added to swapcache by another CPU and we
pass the check because !!PageSwapCache becomes 1 (despite page_count
also become 3, but we happened to read that just a bit earlier).

Not sure if we should keep a fast path check before trylock_page that
can reduce the cacheline bouncing on the trylock operation. We already
had a fast path check in the scanning loop before invoking
collapse_huge_page. We may just move the check after trylock page
after adding a comment about the need of the pagelock for
pageswapcache to be stable.

The PageSwapCache (and matching page count increase) cannot appear or
disappear from under us if we hold the page lock.

> +		if (!pte_write(pteval)) {
> +			if (++ro > khugepaged_max_ptes_none)
> +				goto out_unmap;
> +		}

It's true this is maxed out at 511, so there must be at least one
writable and not none pte (as results of the two "ro" and "none"
counters checks).

However this is applied only to the "mmap_sem hold for reading"
"fast-path" scanning loop to identify candidate THP to collapse.

After this check, we release the mmap_sem (hidden in up_read) and then
we take it for writing. After the mmap_sem is released all vma state
can change from under us.

So this check alone doesn't guarantee we won't collapse THP inside
VM_READ vmas I'm afraid.

We've got two ++none checks too, for the same reason, or we'd
potentially allocate THP by mistake after a concurrent MADV_DONTNEED
(which would be even less problematic as it'd just allocate a THP by
mistake and no other side effect).

critical check:

static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
					unsigned long address,
					pte_t *pte)
		if (pte_none(pteval)) {
			if (++none <= khugepaged_max_ptes_none)
				continue;
			else
				goto out;
		}

fast path optimistic check:

static int khugepaged_scan_pmd(struct mm_struct *mm,
		pte_t pteval = *_pte;
		if (pte_none(pteval)) {
			if (++none <= khugepaged_max_ptes_none)
				continue;
			else
				goto out_unmap;

We need 2 of them for ++ro too I think.

The +!!PageSwapCache addition to the khugepaged_scan_pmd is instead
fine as it's just optimistic and if we end up in collapse_huge_page
because the race hits is no problem (it's incredibly low probability
event). Only in __collapse_huge_page_isolate we need fully accuracy.

Aside from these two points which shouldn't be problematic to adjust,
the rest looks fine!

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
