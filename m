Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E19886B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 00:34:07 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so4485820pdj.40
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:34:07 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id dd3si5144063pdb.47.2014.09.29.21.34.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 21:34:06 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so8436563pab.34
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:34:06 -0700 (PDT)
Date: Mon, 29 Sep 2014 21:32:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 2/5] mm/hugetlb: take page table lock in
 follow_huge_pmd()
In-Reply-To: <1410820799-27278-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1409292041540.4640@eggly.anvils>
References: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1410820799-27278-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, stable@vger.kernel.org

On Mon, 15 Sep 2014, Naoya Horiguchi wrote:
> We have a race condition between move_pages() and freeing hugepages,

I've been looking through these 5 today, and they're much better now,
thank you.  But a new concern below, and a minor correction to 3/5.

> --- mmotm-2014-09-09-14-42.orig/mm/gup.c
> +++ mmotm-2014-09-09-14-42/mm/gup.c
> @@ -162,33 +162,16 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  
>  	pmd = pmd_offset(pud, address);
>  	if (pmd_none(*pmd))
>  		return no_page_table(vma, flags);
> -	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
> -		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
> -		if (flags & FOLL_GET) {
> -			/*
> -			 * Refcount on tail pages are not well-defined and
> -			 * shouldn't be taken. The caller should handle a NULL
> -			 * return when trying to follow tail pages.
> -			 */
> -			if (PageHead(page))
> -				get_page(page);
> -			else
> -				page = NULL;
> -		}
> -		return page;
> -	}
> +	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB)
> +		return follow_huge_pmd(mm, address, pmd, flags);

This code here allows for pmd_none() and pmd_huge(), and for pmd_numa()
and pmd_trans_huge() below; but makes no explicit allowance for !present
migration and hwpoison entries.

Is it assumed that the pmd_bad() test in follow_page_pte() will catch
those?  But what of races? migration entries are highly volatile.  And
is it assumed that a migration entry cannot pass the pmd_huge() test?

That may be true of x86 today, I'm not certain; but if the soft-dirty
people catch up with the hugetlb-migration people, that might change
(they #define _PAGE_SWP_SOFT_DIRTY _PAGE_PSE).

Why pmd_huge() does not itself test for present, I cannot say; but it
probably didn't matter at all before hwpoison and migration were added.

Mind you, with __get_user_pages()'s is_vm_hugtlb_page() test avoiding
all this code, maybe the only thing that can stumble here is your own
hugetlb migration code; but that appears to be guarded only by
down_read of mmap_sem, so races would be possible (if userspace
is silly enough or malicious enough to do so).

What we have here today looks too fragile to me, but it's probably
best dealt with by a separate patch.

Or I may be over-anxious, and there may be something "obvious"
that I'm missing, which saves us from further change.

>  	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
>  		return no_page_table(vma, flags);
>  	if (pmd_trans_huge(*pmd)) {
> diff --git mmotm-2014-09-09-14-42.orig/mm/hugetlb.c mmotm-2014-09-09-14-42/mm/hugetlb.c
> index 34351251e164..941832ee3d5a 100644
> --- mmotm-2014-09-09-14-42.orig/mm/hugetlb.c
> +++ mmotm-2014-09-09-14-42/mm/hugetlb.c
> @@ -3668,26 +3668,34 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address,
>  
>  struct page * __weak
>  follow_huge_pmd(struct mm_struct *mm, unsigned long address,
> -		pmd_t *pmd, int write)
> +		pmd_t *pmd, int flags)
>  {
> -	struct page *page;
> +	struct page *page = NULL;
> +	spinlock_t *ptl;
>  
> -	page = pte_page(*(pte_t *)pmd);
> -	if (page)
> -		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
> +	ptl = pmd_lockptr(mm, pmd);
> +	spin_lock(ptl);
> +
> +	if (!pmd_huge(*pmd))
> +		goto out;

And similarly here.  Though at least here we now have the necessary
lock, so it's no longer racy, and maybe this pmd_huge() test just needs
to be replaced by a pmd_present() test?  Or are both needed?

> +
> +	page = pte_page(*(pte_t *)pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
> +
> +	if (flags & FOLL_GET)
> +		get_page(page);
> +out:
> +	spin_unlock(ptl);
>  	return page;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
