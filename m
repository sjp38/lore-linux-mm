Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 474516B0003
	for <linux-mm@kvack.org>; Sun,  8 Apr 2018 23:09:38 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 91-v6so6009375pla.18
        for <linux-mm@kvack.org>; Sun, 08 Apr 2018 20:09:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i20sor3792995pfj.126.2018.04.08.20.09.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Apr 2018 20:09:37 -0700 (PDT)
Date: Mon, 9 Apr 2018 12:09:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409024925.GA21889@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>

On Sun, Apr 08, 2018 at 07:49:25PM -0700, Matthew Wilcox wrote:
> On Mon, Apr 09, 2018 at 10:58:15AM +0900, Minchan Kim wrote:
> > It assumes shadow entry of radix tree relies on the init state
> > that node->private_list allocated should be list_empty state.
> > Currently, it's initailized in SLAB constructor which means
> > node of radix tree would be initialized only when *slub allocates
> > new page*, not *new object*. So, if some FS or subsystem pass
> > gfp_mask to __GFP_ZERO, slub allocator will do memset blindly.
> 
> Wait, what?  Who's declaring their radix tree with GFP_ZERO flags?
> I don't see anyone using INIT_RADIX_TREE or RADIX_TREE or RADIX_TREE_INIT
> with GFP_ZERO.

Look at fs/f2fs/inode.c
mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);

__add_to_page_cache_locked
  radix_tree_maybe_preload

add_to_page_cache_lru

What's the wrong with setting __GFP_ZERO with mapping->gfp_mask?

> 
> Although, even if nobody's doing that intentionally, if somebody has
> a bitflip with the __GFP_ZERO bit, it's going to propagate widely.
> I think something like this might be appropriate:
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 9e1100f9298f..0f55f0a0dcaa 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2714,8 +2714,10 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
>  		stat(s, ALLOC_FASTPATH);
>  	}
>  
> -	if (unlikely(gfpflags & __GFP_ZERO) && object)
> -		memset(object, 0, s->object_size);
> +	if (unlikely(gfpflags & __GFP_ZERO) && object) {
> +		if (!WARN_ON_ONCE(s->ctor))
> +			memset(object, 0, s->object_size);
> +	}


>  
>  	slab_post_alloc_hook(s, gfpflags, 1, &object);
>  
> 
> Something you could try is checking that the list is empty when the node
> is inserted into the radix tree.
> 
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 8e00138d593f..580f52d0c072 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -428,6 +428,7 @@ radix_tree_node_alloc(gfp_t gfp_mask, struct radix_tree_node *parent,
>  		ret->exceptional = exceptional;
>  		ret->parent = parent;
>  		ret->root = root;
> +		BUG_ON(!list_empty(&ret->private_list));
>  	}
>  	return ret;
>  }
