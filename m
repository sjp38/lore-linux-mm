Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 320F26B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 08:04:25 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id t20so14335381wju.5
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 05:04:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kv9si96455815wjb.50.2017.01.09.05.04.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 05:04:23 -0800 (PST)
Subject: Re: [PATCH 3/8] mm: introduce memalloc_nofs_{save,restore} API
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-4-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <86dbce74-a532-2f98-6a63-4dbad77b2aa1@suse.cz>
Date: Mon, 9 Jan 2017 14:04:21 +0100
MIME-Version: 1.0
In-Reply-To: <20170106141107.23953-4-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 01/06/2017 03:11 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> GFP_NOFS context is used for the following 5 reasons currently
> 	- to prevent from deadlocks when the lock held by the allocation
> 	  context would be needed during the memory reclaim
> 	- to prevent from stack overflows during the reclaim because
> 	  the allocation is performed from a deep context already
> 	- to prevent lockups when the allocation context depends on
> 	  other reclaimers to make a forward progress indirectly
> 	- just in case because this would be safe from the fs POV
> 	- silence lockdep false positives
> 
> Unfortunately overuse of this allocation context brings some problems
> to the MM. Memory reclaim is much weaker (especially during heavy FS
> metadata workloads), OOM killer cannot be invoked because the MM layer
> doesn't have enough information about how much memory is freeable by the
> FS layer.
> 
> In many cases it is far from clear why the weaker context is even used
> and so it might be used unnecessarily. We would like to get rid of
> those as much as possible. One way to do that is to use the flag in
> scopes rather than isolated cases. Such a scope is declared when really
> necessary, tracked per task and all the allocation requests from within
> the context will simply inherit the GFP_NOFS semantic.
> 
> Not only this is easier to understand and maintain because there are
> much less problematic contexts than specific allocation requests, this
> also helps code paths where FS layer interacts with other layers (e.g.
> crypto, security modules, MM etc...) and there is no easy way to convey
> the allocation context between the layers.
> 
> Introduce memalloc_nofs_{save,restore} API to control the scope
> of GFP_NOFS allocation context. This is basically copying
> memalloc_noio_{save,restore} API we have for other restricted allocation
> context GFP_NOIO. The PF_MEMALLOC_NOFS flag already exists and it is
> just an alias for PF_FSTRANS which has been xfs specific until recently.
> There are no more PF_FSTRANS users anymore so let's just drop it.
> 
> PF_MEMALLOC_NOFS is now checked in the MM layer and drops __GFP_FS
> implicitly same as PF_MEMALLOC_NOIO drops __GFP_IO. memalloc_noio_flags
> is renamed to current_gfp_context because it now cares about both
> PF_MEMALLOC_NOFS and PF_MEMALLOC_NOIO contexts. Xfs code paths preserve
> their semantic. kmem_flags_convert() doesn't need to evaluate the flag
> anymore.
> 
> This patch shouldn't introduce any functional changes.
> 
> Let's hope that filesystems will drop direct GFP_NOFS (resp. ~__GFP_FS)
> usage as much as possible and only use a properly documented
> memalloc_nofs_{save,restore} checkpoints where they are appropriate.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>


[...]

> +static inline unsigned int memalloc_nofs_save(void)
> +{
> +	unsigned int flags = current->flags & PF_MEMALLOC_NOFS;
> +	current->flags |= PF_MEMALLOC_NOFS;

So this is not new, as same goes for memalloc_noio_save, but I've
noticed that e.g. exit_signal() does tsk->flags |= PF_EXITING;
So is it possible that there's a r-m-w hazard here?

> +	return flags;
> +}
> +
> +static inline void memalloc_nofs_restore(unsigned int flags)
> +{
> +	current->flags = (current->flags & ~PF_MEMALLOC_NOFS) | flags;
> +}
> +
>  /* Per-process atomic flags. */
>  #define PFA_NO_NEW_PRIVS 0	/* May not gain new privileges. */
>  #define PFA_SPREAD_PAGE  1      /* Spread page cache over cpuset */

[...]

> @@ -3029,7 +3029,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  	int nid;
>  	struct scan_control sc = {
>  		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
> -		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> +		.gfp_mask = (current_gfp_context(gfp_mask) & GFP_RECLAIM_MASK) |

So this function didn't do memalloc_noio_flags() before? Is it a bug
that should be fixed separately or at least mentioned? Because that
looks like a functional change...

Thanks!

>  				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
>  		.reclaim_idx = MAX_NR_ZONES - 1,
>  		.target_mem_cgroup = memcg,
> @@ -3723,7 +3723,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  	int classzone_idx = gfp_zone(gfp_mask);
>  	struct scan_control sc = {
>  		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
> -		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
> +		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
>  		.order = order,
>  		.priority = NODE_RECLAIM_PRIORITY,
>  		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
