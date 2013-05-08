Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 956E76B005C
	for <linux-mm@kvack.org>; Wed,  8 May 2013 15:34:24 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id u10so1477857pdi.19
        for <linux-mm@kvack.org>; Wed, 08 May 2013 12:34:23 -0700 (PDT)
Date: Wed, 8 May 2013 12:34:24 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm: memcg: remove incorrect VM_BUG_ON for swap cache
 pages in uncharge
In-Reply-To: <1368019738-5793-1-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.LNX.2.00.1305081222490.8854@eggly.anvils>
References: <1368019738-5793-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lingzhu Xiang <lxiang@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 8 May 2013, Johannes Weiner wrote:

> 0c59b89 "mm: memcg: push down PageSwapCache check into uncharge entry
> functions" added a VM_BUG_ON() on PageSwapCache in the uncharge path
> after checking that page flag once, assuming that the state is stable
> in all paths, but this is not the case and the condition triggers in
> user environments.  An uncharge after the last page table reference to
> the page goes away can race with reclaim adding the page to swap
> cache.
> 
> Swap cache pages are usually uncharged when they are freed after
> swapout, from a path that also handles swap usage accounting and memcg
> lifetime management.  However, since the last page table reference is
> gone and thus no references to the swap slot left, the swap slot will
> be freed shortly when reclaim attempts to write the page to disk.  The
> whole swap accounting is not even necessary.
> 
> So while the race condition for which this VM_BUG_ON was added is real
> and actually existed all along, there are no negative effects.  Remove
> the VM_BUG_ON again.
> 
> Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Reported-by: Lingzhu Xiang <lxiang@redhat.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Hugh Dickins <hughd@google.com>

Acked-by: Hugh Dickins <hughd@google.com>

> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: stable@vger.kernel.org
> ---
>  mm/memcontrol.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cb1c9de..010d6c1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4108,8 +4108,6 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
>  	if (mem_cgroup_disabled())
>  		return NULL;
>  
> -	VM_BUG_ON(PageSwapCache(page));
> -
>  	if (PageTransHuge(page)) {
>  		nr_pages <<= compound_order(page);
>  		VM_BUG_ON(!PageTransHuge(page));
> @@ -4205,6 +4203,18 @@ void mem_cgroup_uncharge_page(struct page *page)
>  	if (page_mapped(page))
>  		return;
>  	VM_BUG_ON(page->mapping && !PageAnon(page));
> +	/*
> +	 * If the page is in swap cache, uncharge should be deferred
> +	 * to the swap path, which also properly accounts swap usage
> +	 * and handles memcg lifetime.
> +	 *
> +	 * Note that this check is not stable and reclaim may add the
> +	 * page to swap cache at any time after this.  However, if the
> +	 * page is not in swap cache by the time page->mapcount hits
> +	 * 0, there won't be any page table references to the swap
> +	 * slot, and reclaim will free it and not actually write the
> +	 * page to disk.
> +	 */
>  	if (PageSwapCache(page))
>  		return;
>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON, false);
> -- 
> 1.7.11.7
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
