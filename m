Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D465B6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 07:51:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so326613640pfd.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 04:51:17 -0700 (PDT)
Received: from mail-pa0-f66.google.com (mail-pa0-f66.google.com. [209.85.220.66])
        by mx.google.com with ESMTPS id a73si2820026pfc.20.2016.08.02.04.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 04:51:16 -0700 (PDT)
Received: by mail-pa0-f66.google.com with SMTP id q2so11849652pap.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 04:51:15 -0700 (PDT)
Date: Tue, 2 Aug 2016 13:51:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] radix-tree: account nodes to memcg only if explicitly
 requested
Message-ID: <20160802115111.GG12403@dhcp22.suse.cz>
References: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 01-08-16 16:13:08, Vladimir Davydov wrote:
> Radix trees may be used not only for storing page cache pages, so
> unconditionally accounting radix tree nodes to the current memory cgroup
> is bad: if a radix tree node is used for storing data shared among
> different cgroups we risk pinning dead memory cgroups forever. So let's
> only account radix tree nodes if it was explicitly requested by passing
> __GFP_ACCOUNT to INIT_RADIX_TREE. Currently, we only want to account
> page cache entries, so mark mapping->page_tree so.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

OK, the patch makes sense to me. Such a false sharing would be really
tedious to debug

Do we want to mark it for stable 4.6 to prevent from some pathological
issues. The patch is simple enough.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  fs/inode.c       |  2 +-
>  lib/radix-tree.c | 14 ++++++++++----
>  2 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index 559a9da25237..1d04dab5211c 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -345,7 +345,7 @@ EXPORT_SYMBOL(inc_nlink);
>  void address_space_init_once(struct address_space *mapping)
>  {
>  	memset(mapping, 0, sizeof(*mapping));
> -	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
> +	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC | __GFP_ACCOUNT);
>  	spin_lock_init(&mapping->tree_lock);
>  	init_rwsem(&mapping->i_mmap_rwsem);
>  	INIT_LIST_HEAD(&mapping->private_list);
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 61b8fb529cef..1b7bf7314141 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -277,10 +277,11 @@ radix_tree_node_alloc(struct radix_tree_root *root)
>  
>  		/*
>  		 * Even if the caller has preloaded, try to allocate from the
> -		 * cache first for the new node to get accounted.
> +		 * cache first for the new node to get accounted to the memory
> +		 * cgroup.
>  		 */
>  		ret = kmem_cache_alloc(radix_tree_node_cachep,
> -				       gfp_mask | __GFP_ACCOUNT | __GFP_NOWARN);
> +				       gfp_mask | __GFP_NOWARN);
>  		if (ret)
>  			goto out;
>  
> @@ -303,8 +304,7 @@ radix_tree_node_alloc(struct radix_tree_root *root)
>  		kmemleak_update_trace(ret);
>  		goto out;
>  	}
> -	ret = kmem_cache_alloc(radix_tree_node_cachep,
> -			       gfp_mask | __GFP_ACCOUNT);
> +	ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
>  out:
>  	BUG_ON(radix_tree_is_internal_node(ret));
>  	return ret;
> @@ -351,6 +351,12 @@ static int __radix_tree_preload(gfp_t gfp_mask, int nr)
>  	struct radix_tree_node *node;
>  	int ret = -ENOMEM;
>  
> +	/*
> +	 * Nodes preloaded by one cgroup can be be used by another cgroup, so
> +	 * they should never be accounted to any particular memory cgroup.
> +	 */
> +	gfp_mask &= ~__GFP_ACCOUNT;
> +
>  	preempt_disable();
>  	rtp = this_cpu_ptr(&radix_tree_preloads);
>  	while (rtp->nr < nr) {
> -- 
> 2.1.4
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
