Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7376B0007
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 04:50:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x18so3401717pfm.18
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 01:50:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si1784528pff.24.2018.04.10.01.50.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 01:50:53 -0700 (PDT)
Date: Tue, 10 Apr 2018 10:50:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410085049.7ysheqavwuykjkvn@quack2.suse.cz>
References: <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
 <20180409144958.GA211679@rodete-laptop-imager.corp.google.com>
 <20180409152032.GB11756@bombadil.infradead.org>
 <20180409230409.GA214542@rodete-desktop-imager.corp.google.com>
 <20180410011211.GA31282@bombadil.infradead.org>
 <20180410023339.GB214542@rodete-desktop-imager.corp.google.com>
 <20180410024152.GC31282@bombadil.infradead.org>
 <20180410025903.GA38000@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410025903.GA38000@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Chao Yu <yuchao0@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Tue 10-04-18 11:59:03, Minchan Kim wrote:
> On Mon, Apr 09, 2018 at 07:41:52PM -0700, Matthew Wilcox wrote:
> > On Tue, Apr 10, 2018 at 11:33:39AM +0900, Minchan Kim wrote:
> > > @@ -522,7 +532,7 @@ EXPORT_SYMBOL(radix_tree_preload);
> > >   */
> > >  int radix_tree_maybe_preload(gfp_t gfp_mask)
> > >  {
> > > -	if (gfpflags_allow_blocking(gfp_mask))
> > > +	if (gfpflags_allow_blocking(gfp_mask) && !(gfp_mask & __GFP_ZERO))
> > >  		return __radix_tree_preload(gfp_mask, RADIX_TREE_PRELOAD_SIZE);
> > >  	/* Preloading doesn't help anything with this gfp mask, skip it */
> > >  	preempt_disable();
> > 
> > No, you've completely misunderstood what's going on in this function.
> 
> Okay, I hope this version clear current concerns.
> 
> From fb37c41b90f7d3ead1798e5cb7baef76709afd94 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Tue, 10 Apr 2018 11:54:57 +0900
> Subject: [PATCH v3] mm: workingset: fix NULL ptr dereference
> 
> It assumes shadow entries of radix tree rely on the init state
> that node->private_list allocated newly is list_empty state
> for the working. Currently, it's initailized in SLAB constructor
> which means node of radix tree would be initialized only when
> *slub allocates new page*, not *slub alloctes new object*.
> 
> If some FS or subsystem pass gfp_mask to __GFP_ZERO, that means
> newly allocated node can have !list_empty(node->private_list)
> by memset of slab allocator. It ends up calling NULL deference
> at workingset_update_node by failing list_empty check.
> 
> This patch fixes it.

The patch looks good. I'd just rephrase the changelog to be more
understandable. Something like:

GFP mask passed to page cache functions (often coming from
mapping->gfp_mask) is used both for allocation of page cache page and for
allocation of radix tree metadata necessary to add the page to the page
cache. When the mask contains __GFP_ZERO (as is the case for some f2fs
metadata mappings), this breaks radix tree code as that code expects
allocated radix tree nodes to be properly initialized by the slab
constructor and not zeroed. In particular node->private_list is failing
list_empty() check and the following list operation in
workingset_update_node() will dereference NULL.

Fix the problem by removing __GFP_ZERO from the mask for radix tree
allocations. Also warn if __GFP_ZERO gets passed to __radix_tree_preload()
to avoid silent breakage in the future for other radix tree users.

With that fixed you can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> 
> Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Jaegeuk Kim <jaegeuk@kernel.org>
> Cc: Chao Yu <yuchao0@huawei.com>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: stable@vger.kernel.org
> Reported-by: Chris Fries <cfries@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  lib/radix-tree.c | 9 +++++++++
>  mm/filemap.c     | 5 +++--
>  2 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index da9e10c827df..7569e637dbaa 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -470,6 +470,15 @@ static __must_check int __radix_tree_preload(gfp_t gfp_mask, unsigned nr)
>  	struct radix_tree_node *node;
>  	int ret = -ENOMEM;
>  
> +	/*
> +	 * New allocate node must have node->private_list as INIT_LIST_HEAD
> +	 * state by workingset shadow memory implementation.
> +	 * If user pass  __GFP_ZERO by mistake, slab allocator will clear
> +	 * node->private_list, which makes a BUG. Rather than going Oops,
> +	 * just fix and warn about it.
> +	 */
> +	if (WARN_ON(gfp_mask & __GFP_ZERO))
> +		gfp_mask &= ~__GFP_ZERO;
>  	/*
>  	 * Nodes preloaded by one cgroup can be be used by another cgroup, so
>  	 * they should never be accounted to any particular memory cgroup.
> diff --git a/mm/filemap.c b/mm/filemap.c
> index ab77e19ab09c..b6de9d691c8a 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -786,7 +786,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  	VM_BUG_ON_PAGE(!PageLocked(new), new);
>  	VM_BUG_ON_PAGE(new->mapping, new);
>  
> -	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> +	error = radix_tree_preload(gfp_mask & ~(__GFP_HIGHMEM | __GFP_ZERO));
>  	if (!error) {
>  		struct address_space *mapping = old->mapping;
>  		void (*freepage)(struct page *);
> @@ -842,7 +842,8 @@ static int __add_to_page_cache_locked(struct page *page,
>  			return error;
>  	}
>  
> -	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
> +	error = radix_tree_maybe_preload(gfp_mask &
> +					~(__GFP_HIGHMEM | __GFP_ZERO));
>  	if (error) {
>  		if (!huge)
>  			mem_cgroup_cancel_charge(page, memcg, false);
> -- 
> 2.17.0.484.g0c8726318c-goog
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
