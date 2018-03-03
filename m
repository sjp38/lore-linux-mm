Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B90EB6B0003
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 07:44:40 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e1so6802582pfi.10
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 04:44:40 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f71si662950pfe.158.2018.03.03.04.44.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Mar 2018 04:44:39 -0800 (PST)
Message-ID: <1520081076.4280.18.camel@kernel.org>
Subject: Re: [PATCH v7 02/61] radix tree: Use bottom four bits of gfp_t for
 flags
From: Jeff Layton <jlayton@kernel.org>
Date: Sat, 03 Mar 2018 07:44:36 -0500
In-Reply-To: <20180219194556.6575-3-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
	 <20180219194556.6575-3-willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 2018-02-19 at 11:44 -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> None of these four bits may be used for slab allocations, so we can
> use them for flags as long as we mask them off before passing them
> to the slab allocator.  Move the IDR flag from the top bits to the
> bottom bits.
>
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/idr.h                  | 3 ++-
>  include/linux/radix-tree.h           | 7 ++++---
>  lib/radix-tree.c                     | 3 ++-
>  tools/testing/radix-tree/linux/gfp.h | 1 +
>  4 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/idr.h b/include/linux/idr.h
> index 7d6a6313f0ab..913c335054f0 100644
> --- a/include/linux/idr.h
> +++ b/include/linux/idr.h
> @@ -29,7 +29,8 @@ struct idr {
>  #define IDR_FREE	0
>  
>  /* Set the IDR flag and the IDR_FREE tag */
> -#define IDR_RT_MARKER		((__force gfp_t)(3 << __GFP_BITS_SHIFT))
> +#define IDR_RT_MARKER	(ROOT_IS_IDR | (__force gfp_t)			\
> +					(1 << (ROOT_TAG_SHIFT + IDR_FREE)))
>  
>  #define IDR_INIT_BASE(base) {						\
>  	.idr_rt = RADIX_TREE_INIT(IDR_RT_MARKER),			\
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index fc55ff31eca7..6c4e2e716dac 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -104,9 +104,10 @@ struct radix_tree_node {
>  	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
>  };
>  
> -/* The top bits of gfp_mask are used to store the root tags and the IDR flag */
> -#define ROOT_IS_IDR	((__force gfp_t)(1 << __GFP_BITS_SHIFT))
> -#define ROOT_TAG_SHIFT	(__GFP_BITS_SHIFT + 1)
> +/* The IDR tag is stored in the low bits of the GFP flags */
> +#define ROOT_IS_IDR	((__force gfp_t)4)
> +/* The top bits of gfp_mask are used to store the root tags */
> +#define ROOT_TAG_SHIFT	(__GFP_BITS_SHIFT)
>  
>  struct radix_tree_root {
>  	gfp_t			gfp_mask;
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 0a7ae3288a24..66732e2f9606 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -146,7 +146,7 @@ static unsigned int radix_tree_descend(const struct radix_tree_node *parent,
>  
>  static inline gfp_t root_gfp_mask(const struct radix_tree_root *root)
>  {
> -	return root->gfp_mask & __GFP_BITS_MASK;
> +	return root->gfp_mask & ((__GFP_BITS_MASK >> 4) << 4);

Maybe phrase this in terms of a constant like GFP_ZONEMASK here? Would
this be more appropriate?

    root->gfp_mask & (__GFP_BITS_MASK & ~GFP_ZONEMASK);

>  }      
>  static inline void tag_set(struct radix_tree_node *node, unsigned int tag,
> @@ -2285,6 +2285,7 @@ void __init radix_tree_init(void)
>  	int ret;
>  
>  	BUILD_BUG_ON(RADIX_TREE_MAX_TAGS + __GFP_BITS_SHIFT > 32);
> +	BUILD_BUG_ON(GFP_ZONEMASK != (__force gfp_t)15);
>  	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
>  			sizeof(struct radix_tree_node), 0,
>  			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
> diff --git a/tools/testing/radix-tree/linux/gfp.h b/tools/testing/radix-tree/linux/gfp.h
> index e9fff59dfd8a..a72007d9818b 100644
> --- a/tools/testing/radix-tree/linux/gfp.h
> +++ b/tools/testing/radix-tree/linux/gfp.h
> @@ -18,6 +18,7 @@
>  
>  #define __GFP_RECLAIM	(__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM)
>  
> +#define GFP_ZONEMASK	0x0fu
>  #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
>  #define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
>  #define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)

-- 
Jeff Layton <jlayton@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
