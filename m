Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5106B037F
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 19:01:39 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so1670812wmw.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 16:01:39 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id l66si291522wml.44.2016.11.17.16.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 16:01:38 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id m203so768315wma.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 16:01:38 -0800 (PST)
Date: Fri, 18 Nov 2016 03:01:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 11/12] mm: migrate: move_pages() supports thp migration
Message-ID: <20161118000135.GB8891@node>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-12-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478561517-4317-12-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Nov 08, 2016 at 08:31:56AM +0900, Naoya Horiguchi wrote:
> This patch enables thp migration for move_pages(2).
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/migrate.c | 37 ++++++++++++++++++++++++++++---------
>  1 file changed, 28 insertions(+), 9 deletions(-)
> 
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/migrate.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/migrate.c
> index 97ab8d9..6a589b9 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/migrate.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/migrate.c
> @@ -1443,7 +1443,17 @@ static struct page *new_page_node(struct page *p, unsigned long private,
>  	if (PageHuge(p))
>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>  					pm->node);
> -	else
> +	else if (thp_migration_supported() && PageTransHuge(p)) {
> +		struct page *thp;
> +
> +		thp = alloc_pages_node(pm->node,
> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> +			HPAGE_PMD_ORDER);
> +		if (!thp)
> +			return NULL;
> +		prep_transhuge_page(thp);
> +		return thp;
> +	} else
>  		return __alloc_pages_node(pm->node,
>  				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
>  }
> @@ -1470,6 +1480,8 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>  	for (pp = pm; pp->node != MAX_NUMNODES; pp++) {
>  		struct vm_area_struct *vma;
>  		struct page *page;
> +		struct page *head;
> +		unsigned int follflags;
>  
>  		err = -EFAULT;
>  		vma = find_vma(mm, pp->addr);
> @@ -1477,8 +1489,10 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>  			goto set_status;
>  
>  		/* FOLL_DUMP to ignore special (like zero) pages */
> -		page = follow_page(vma, pp->addr,
> -				FOLL_GET | FOLL_SPLIT | FOLL_DUMP);
> +		follflags = FOLL_GET | FOLL_SPLIT | FOLL_DUMP;
> +		if (thp_migration_supported())
> +			follflags &= ~FOLL_SPLIT;

Nit: I would rather filp the condition -- adding flag is easier to read
than clearing.

> +		page = follow_page(vma, pp->addr, follflags);
>  
>  		err = PTR_ERR(page);
>  		if (IS_ERR(page))
> @@ -1488,7 +1502,6 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>  		if (!page)
>  			goto set_status;
>  
> -		pp->page = page;
>  		err = page_to_nid(page);
>  
>  		if (err == pp->node)
> @@ -1503,16 +1516,22 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>  			goto put_and_set;
>  
>  		if (PageHuge(page)) {
> -			if (PageHead(page))
> +			if (PageHead(page)) {
>  				isolate_huge_page(page, &pagelist);
> +				err = 0;
> +				pp->page = page;
> +			}
>  			goto put_and_set;
>  		}
>  
> -		err = isolate_lru_page(page);
> +		pp->page = compound_head(page);
> +		head = compound_head(page);
> +		err = isolate_lru_page(head);
>  		if (!err) {
> -			list_add_tail(&page->lru, &pagelist);
> -			inc_node_page_state(page, NR_ISOLATED_ANON +
> -					    page_is_file_cache(page));
> +			list_add_tail(&head->lru, &pagelist);
> +			mod_node_page_state(page_pgdat(head),
> +				NR_ISOLATED_ANON + page_is_file_cache(head),
> +				hpage_nr_pages(head));
>  		}
>  put_and_set:
>  		/*
> -- 
> 2.7.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
