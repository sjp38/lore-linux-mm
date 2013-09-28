Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id BAA316B0032
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 13:26:11 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so4093546pab.3
        for <linux-mm@kvack.org>; Sat, 28 Sep 2013 10:26:11 -0700 (PDT)
Date: Sat, 28 Sep 2013 19:26:02 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 4/9] migrate: add hugepage migration code to move_pages()
Message-ID: <20130928172602.GA6191@pd.tnic>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-5-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1376025702-14818-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 09, 2013 at 01:21:37AM -0400, Naoya Horiguchi wrote:
> This patch extends move_pages() to handle vma with VM_HUGETLB set.
> We will be able to migrate hugepage with move_pages(2) after
> applying the enablement patch which comes later in this series.
> 
> We avoid getting refcount on tail pages of hugepage, because unlike thp,
> hugepage is not split and we need not care about races with splitting.
> 
> And migration of larger (1GB for x86_64) hugepage are not enabled.
> 
> ChangeLog v4:
>  - use get_page instead of get_page_foll
>  - add comment in follow_page_mask
> 
> ChangeLog v3:
>  - revert introducing migrate_movable_pages
>  - follow_page_mask(FOLL_GET) returns NULL for tail pages
>  - use isolate_huge_page
> 
> ChangeLog v2:
>  - updated description and renamed patch title
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/memory.c  | 17 +++++++++++++++--
>  mm/migrate.c | 13 +++++++++++--
>  2 files changed, 26 insertions(+), 4 deletions(-)

...

> diff --git v3.11-rc3.orig/mm/migrate.c v3.11-rc3/mm/migrate.c
> index 3ec47d3..d313737 100644
> --- v3.11-rc3.orig/mm/migrate.c
> +++ v3.11-rc3/mm/migrate.c
> @@ -1092,7 +1092,11 @@ static struct page *new_page_node(struct page *p, unsigned long private,
>  
>  	*result = &pm->status;
>  
> -	return alloc_pages_exact_node(pm->node,
> +	if (PageHuge(p))
> +		return alloc_huge_page_node(page_hstate(compound_head(p)),
> +					pm->node);
> +	else
> +		return alloc_pages_exact_node(pm->node,
>  				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
>  }
>  
> @@ -1152,6 +1156,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>  				!migrate_all)
>  			goto put_and_set;
>  
> +		if (PageHuge(page)) {
> +			isolate_huge_page(page, &pagelist);
> +			goto put_and_set;
> +		}

This gives

In file included from mm/migrate.c:35:0:
mm/migrate.c: In function a??do_move_page_to_node_arraya??:
include/linux/hugetlb.h:140:33: warning: statement with no effect [-Wunused-value]
 #define isolate_huge_page(p, l) false
                                 ^
mm/migrate.c:1170:4: note: in expansion of macro a??isolate_huge_pagea??
    isolate_huge_page(page, &pagelist);

on a

# CONFIG_HUGETLBFS is not set

.config.

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
