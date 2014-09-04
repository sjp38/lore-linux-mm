Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7D25B6B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 21:49:27 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so18781868pad.27
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 18:49:27 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id pb4si224949pdb.225.2014.09.03.18.49.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Sep 2014 18:49:26 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id hz1so18897140pad.34
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 18:49:26 -0700 (PDT)
Date: Wed, 3 Sep 2014 18:47:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 5/6] mm/hugetlb: add migration entry check in
 __unmap_hugepage_range
In-Reply-To: <1409276340-7054-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1409031821220.11485@eggly.anvils>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1409276340-7054-6-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, 28 Aug 2014, Naoya Horiguchi wrote:

> If __unmap_hugepage_range() tries to unmap the address range over which
> hugepage migration is on the way, we get the wrong page because pte_page()
> doesn't work for migration entries. This patch calls pte_to_swp_entry() and
> migration_entry_to_page() to get the right page for migration entries.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org>  # [2.6.36+]

2.6.36+?  But this one doesn't affect hwpoisoned.
I admit I've lost track of how far back hugetlb migration goes:
oh, to 2.6.37+, that fits with what you marked on some commits earlier.
But then 2/6 says 3.12+.  Help!  Please remind me of the sequence of events.

> ---
>  mm/hugetlb.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git mmotm-2014-08-25-16-52.orig/mm/hugetlb.c mmotm-2014-08-25-16-52/mm/hugetlb.c
> index 1ed9df6def54..0a4511115ee0 100644
> --- mmotm-2014-08-25-16-52.orig/mm/hugetlb.c
> +++ mmotm-2014-08-25-16-52/mm/hugetlb.c
> @@ -2652,6 +2652,13 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		if (huge_pte_none(pte))
>  			goto unlock;
>  
> +		if (unlikely(is_hugetlb_entry_migration(pte))) {
> +			swp_entry_t entry = pte_to_swp_entry(pte);
> +
> +			page = migration_entry_to_page(entry);
> +			goto clear;
> +		}
> +

This surprises me: are you sure?  Obviously you know hugetlb migration
much better than I do: is it done in a significantly different way from
order:0 page migration?  In the order:0 case, there is no reference to
the page corresponding to the migration entry placed in a page table,
just the remaining reference held by the task doing the migration.  But
here you are jumping to the code which unmaps and frees a present page.

I can see that a fix is necessary, but I would have expected it to
consist of merely changing the "HWPoisoned" comment below to include
migration entries, and changing its test from
		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
to
		if (unlikely(!pte_present(pte))) {

>  		/*
>  		 * HWPoisoned hugepage is already unmapped and dropped reference
>  		 */
> @@ -2677,7 +2684,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  			 */
>  			set_vma_resv_flags(vma, HPAGE_RESV_UNMAPPED);
>  		}
> -
> +clear:
>  		pte = huge_ptep_get_and_clear(mm, address, ptep);
>  		tlb_remove_tlb_entry(tlb, ptep, address);
>  		if (huge_pte_dirty(pte))
> -- 
> 1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
