Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEDCE6B03AC
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:32:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id s63so7460443wms.7
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 23:32:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d3si6379518wjm.90.2016.11.17.23.32.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 23:32:35 -0800 (PST)
Date: Fri, 18 Nov 2016 08:32:34 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/9] mm: workingset: turn shadow node shrinker bugs into
 warnings
Message-ID: <20161118073234.GC18676@quack2.suse.cz>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
 <20161117191138.22769-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117191138.22769-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 17-11-16 14:11:32, Johannes Weiner wrote:
> When the shadow page shrinker tries to reclaim a radix tree node but
> finds it in an unexpected state - it should contain no pages, and
> non-zero shadow entries - there is no need to kill the executing task
> or even the entire system. Warn about the invalid state, then leave
> that tree node be. Simply don't put it back on the shadow LRU for
> future reclaim and move on.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/workingset.c | 20 ++++++++++++--------
>  1 file changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 617475f529f4..3cfc61d84a52 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -418,23 +418,27 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
>  	 * no pages, so we expect to be able to remove them all and
>  	 * delete and free the empty node afterwards.
>  	 */
> -	BUG_ON(!workingset_node_shadows(node));
> -	BUG_ON(workingset_node_pages(node));
> -
> +	if (WARN_ON_ONCE(!workingset_node_shadows(node)))
> +		goto out_invalid;
> +	if (WARN_ON_ONCE(workingset_node_pages(node)))
> +		goto out_invalid;
>  	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
>  		if (node->slots[i]) {
> -			BUG_ON(!radix_tree_exceptional_entry(node->slots[i]));
> +			if (WARN_ON_ONCE(!radix_tree_exceptional_entry(node->slots[i])))
> +				goto out_invalid;
> +			if (WARN_ON_ONCE(!mapping->nrexceptional))
> +				goto out_invalid;
>  			node->slots[i] = NULL;
>  			workingset_node_shadows_dec(node);
> -			BUG_ON(!mapping->nrexceptional);
>  			mapping->nrexceptional--;
>  		}
>  	}
> -	BUG_ON(workingset_node_shadows(node));
> +	if (WARN_ON_ONCE(workingset_node_shadows(node)))
> +		goto out_invalid;
>  	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
> -	if (!__radix_tree_delete_node(&mapping->page_tree, node))
> -		BUG();
> +	__radix_tree_delete_node(&mapping->page_tree, node);
>  
> +out_invalid:
>  	spin_unlock(&mapping->tree_lock);
>  	ret = LRU_REMOVED_RETRY;
>  out:
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
