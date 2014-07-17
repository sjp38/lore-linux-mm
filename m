Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id BB4FB6B0069
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 10:30:29 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id x48so3167598wes.19
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 07:30:28 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id dz2si8234442wib.44.2014.07.17.07.30.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 07:30:24 -0700 (PDT)
Received: by mail-wg0-f42.google.com with SMTP id l18so2123337wgh.25
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 07:30:24 -0700 (PDT)
Date: Thu, 17 Jul 2014 16:30:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: rewrite charge API fix - hugetlb charging
Message-ID: <20140717143021.GE8011@dhcp22.suse.cz>
References: <1405528080-2975-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405528080-2975-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 16-07-14 12:28:00, Johannes Weiner wrote:
> Naoya-san reports that hugetlb pages now get charged as file cache,
> which wreaks all kinds of havoc during migration, uncharge etc.
> 
> The file-specific charge path used to filter PageCompound(), but it
> wasn't commented and so it got lost when unifying the charge paths.
> 
> We can't add PageCompound() back into a unified charge path because of
> THP, so filter huge pages directly in add_to_page_cache().

This looks a bit fragile to me but I understand your motivation to not
punish all the code paths with PageHuge check.

> Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/filemap.c | 20 ++++++++++++++------
>  1 file changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 114cd89c1cc2..c088ac01e856 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -31,6 +31,7 @@
>  #include <linux/security.h>
>  #include <linux/cpuset.h>
>  #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
> +#include <linux/hugetlb.h>
>  #include <linux/memcontrol.h>
>  #include <linux/cleancache.h>
>  #include <linux/rmap.h>
> @@ -560,19 +561,24 @@ static int __add_to_page_cache_locked(struct page *page,
>  				      pgoff_t offset, gfp_t gfp_mask,
>  				      void **shadowp)
>  {
> +	int huge = PageHuge(page);
>  	struct mem_cgroup *memcg;
>  	int error;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
>  
> -	error = mem_cgroup_try_charge(page, current->mm, gfp_mask, &memcg);
> -	if (error)
> -		return error;
> +	if (!huge) {
> +		error = mem_cgroup_try_charge(page, current->mm,
> +					      gfp_mask, &memcg);
> +		if (error)
> +			return error;
> +	}
>  
>  	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
>  	if (error) {
> -		mem_cgroup_cancel_charge(page, memcg);
> +		if (!huge)
> +			mem_cgroup_cancel_charge(page, memcg);
>  		return error;
>  	}
>  
> @@ -587,14 +593,16 @@ static int __add_to_page_cache_locked(struct page *page,
>  		goto err_insert;
>  	__inc_zone_page_state(page, NR_FILE_PAGES);
>  	spin_unlock_irq(&mapping->tree_lock);
> -	mem_cgroup_commit_charge(page, memcg, false);
> +	if (!huge)
> +		mem_cgroup_commit_charge(page, memcg, false);
>  	trace_mm_filemap_add_to_page_cache(page);
>  	return 0;
>  err_insert:
>  	page->mapping = NULL;
>  	/* Leave page->index set: truncation relies upon it */
>  	spin_unlock_irq(&mapping->tree_lock);
> -	mem_cgroup_cancel_charge(page, memcg);
> +	if (!huge)
> +		mem_cgroup_cancel_charge(page, memcg);
>  	page_cache_release(page);
>  	return error;
>  }
> -- 
> 2.0.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
