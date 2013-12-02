Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id AD72B6B0038
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 15:09:42 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z6so9319697yhz.1
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 12:09:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w8si48046138yhd.58.2013.12.02.12.09.41
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 12:09:41 -0800 (PST)
Date: Mon, 02 Dec 2013 15:09:33 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386014973-h0zadm1f-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1385624926-28883-5-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-5-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/9] mm/rmap: make rmap_walk to get the rmap_walk_control
 argument
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, Nov 28, 2013 at 04:48:41PM +0900, Joonsoo Kim wrote:
> In each rmap traverse case, there is some difference so that we need
> function pointers and arguments to them in order to handle these
> difference properly.
> 
> For this purpose, struct rmap_walk_control is introduced in this patch,
> and will be extended in following patch. Introducing and extending are
> separate, because it clarify changes.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

A few comment below ...

> diff --git a/include/linux/ksm.h b/include/linux/ksm.h
> index 45c9b6a..0eef8cb 100644
> --- a/include/linux/ksm.h
> +++ b/include/linux/ksm.h
> @@ -76,8 +76,7 @@ struct page *ksm_might_need_to_copy(struct page *page,
>  int page_referenced_ksm(struct page *page,
>  			struct mem_cgroup *memcg, unsigned long *vm_flags);
>  int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
> -int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
> -		  struct vm_area_struct *, unsigned long, void *), void *arg);
> +int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
>  void ksm_migrate_page(struct page *newpage, struct page *oldpage);
>  
>  #else  /* !CONFIG_KSM */
> @@ -120,8 +119,8 @@ static inline int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
>  	return 0;
>  }
>  
> -static inline int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page*,
> -		struct vm_area_struct *, unsigned long, void *), void *arg)
> +static inline int rmap_walk_ksm(struct page *page,
> +			struct rmap_walk_control *rwc)
>  {
>  	return 0;
>  }
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 6dacb93..0f65686 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -235,11 +235,16 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page);
>  void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
>  int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
>  
> +struct rmap_walk_control {
> +	int (*main)(struct page *, struct vm_area_struct *,
> +					unsigned long, void *);

Maybe you can add parameters' names to make this prototype more readable.

> +	void *arg;	/* argument to main function */
> +};
> +
>  /*
>   * Called by migrate.c to remove migration ptes, but might be used more later.
>   */

This comment also needs update?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
