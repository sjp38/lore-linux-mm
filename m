Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C661E6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 05:41:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x83so29445228wma.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 02:41:16 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 128si26053648wmq.81.2016.07.20.02.41.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 02:41:15 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so6164149wme.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 02:41:15 -0700 (PDT)
Date: Wed, 20 Jul 2016 11:41:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: hugetlb: remove incorrect comment
Message-ID: <20160720094113.GG11249@dhcp22.suse.cz>
References: <1468894098-12099-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160719091052.GC9490@dhcp22.suse.cz>
 <20160720092901.GA15995@www9186uo.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160720092901.GA15995@www9186uo.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <nao.horiguchi@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Zhan Chen <zhanc1@andrew.cmu.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 20-07-16 18:29:02, Naoya Horiguchi wrote:
[...]
> >From 7da52ca6920dcd84e3da2df619bd5242f9c3ccec Mon Sep 17 00:00:00 2001
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Wed, 20 Jul 2016 18:21:33 +0900
> Subject: [PATCH v2] mm: hwpoison: remove incorrect comment
> 
> dequeue_hwpoisoned_huge_page() can be called without page lock hold,
> so let's remove incorrect comment.
> 
> The reason why the page lock is not really needed is that
> dequeue_hwpoisoned_huge_page() checks page_huge_active() inside hugetlb_lock,
> which allows us to avoid trying to dequeue a hugepage that are just allocated
> but not linked to active list yet, even without taking page lock.

Thank you for the clarification!

> Reported-by: Zhan Chen <zhanc1@andrew.cmu.edu>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/hugetlb.c        | 1 -
>  mm/memory-failure.c | 2 --
>  2 files changed, 3 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c1f3c0be150a..26f735cc7478 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4401,7 +4401,6 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  
>  /*
>   * This function is called from memory failure code.
> - * Assume the caller holds page lock of the head page.
>   */
>  int dequeue_hwpoisoned_huge_page(struct page *hpage)
>  {
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 2fcca6b0e005..7532c3a8a39c 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -741,8 +741,6 @@ static int me_huge_page(struct page *p, unsigned long pfn)
>  	 * page->lru because it can be used in other hugepage operations,
>  	 * such as __unmap_hugepage_range() and gather_surplus_pages().
>  	 * So instead we use page_mapping() and PageAnon().
> -	 * We assume that this function is called with page lock held,
> -	 * so there is no race between isolation and mapping/unmapping.
>  	 */
>  	if (!(page_mapping(hpage) || PageAnon(hpage))) {
>  		res = dequeue_hwpoisoned_huge_page(hpage);
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
