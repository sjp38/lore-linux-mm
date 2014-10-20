Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 537196B006E
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 15:13:00 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id k14so6178093wgh.19
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 12:12:59 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id df1si9546850wib.37.2014.10.20.12.12.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 12:12:59 -0700 (PDT)
Received: by mail-wg0-f43.google.com with SMTP id m15so6225920wgh.14
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 12:12:58 -0700 (PDT)
Date: Mon, 20 Oct 2014 21:12:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: update mem_cgroup_page_lruvec()
 documentation
Message-ID: <20141020191256.GD505@dhcp22.suse.cz>
References: <1413732616-15962-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413732616-15962-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun 19-10-14 11:30:16, Johannes Weiner wrote:
> 7512102cf64d ("memcg: fix GPF when cgroup removal races with last
> exit") added a pc->mem_cgroup reset into mem_cgroup_page_lruvec() to
> prevent a crash where an anon page gets uncharged on unmap, the memcg
> is released, and then the final LRU isolation on free dereferences the
> stale pc->mem_cgroup pointer.
> 
> But since 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API"), pages
> are only uncharged AFTER that final LRU isolation, which guarantees
> the memcg's lifetime until then.  pc->mem_cgroup now only needs to be
> reset for swapcache readahead pages.

Do we want VM_BUG_ON_PAGE(!PageSwapCache, page) into the fixup path?

> Update the comment and callsite requirements accordingly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3a203c7ec6c7..fc1d7ca96b9d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1262,9 +1262,13 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>  }
>  
>  /**
> - * mem_cgroup_page_lruvec - return lruvec for adding an lru page
> + * mem_cgroup_page_lruvec - return lruvec for isolating/putting an LRU page
>   * @page: the page
>   * @zone: zone of the page
> + *
> + * This function is only safe when following the LRU page isolation
> + * and putback protocol: the LRU lock must be held, and the page must
> + * either be PageLRU() or the caller must have isolated/allocated it.
>   */
>  struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>  {
> @@ -1282,13 +1286,9 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>  	memcg = pc->mem_cgroup;
>  
>  	/*
> -	 * Surreptitiously switch any uncharged offlist page to root:
> -	 * an uncharged page off lru does nothing to secure
> -	 * its former mem_cgroup from sudden removal.
> -	 *
> -	 * Our caller holds lru_lock, and PageCgroupUsed is updated
> -	 * under page_cgroup lock: between them, they make all uses
> -	 * of pc->mem_cgroup safe.
> +	 * Swapcache readahead pages are added to the LRU - and
> +	 * possibly migrated - before they are charged.  Ensure
> +	 * pc->mem_cgroup is sane.
>  	 */
>  	if (!PageLRU(page) && !PageCgroupUsed(pc) && memcg != root_mem_cgroup)
>  		pc->mem_cgroup = memcg = root_mem_cgroup;
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
