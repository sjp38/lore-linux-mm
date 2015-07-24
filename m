Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 07D426B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:08:27 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so18240080pdb.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:08:26 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id a14si23115381pdk.37.2015.07.24.13.08.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 13:08:24 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so18228261pdb.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:08:23 -0700 (PDT)
Date: Fri, 24 Jul 2015 13:08:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v2 1/4] mm: make alloc_pages_exact_node pass
 __GFP_THISNODE
In-Reply-To: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1507241301400.5215@chino.kir.corp.google.com>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, 24 Jul 2015, Vlastimil Babka wrote:

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 15928f0..c50848e 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -300,6 +300,22 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
>  	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
>  }
>  
> +/*
> + * An optimized version of alloc_pages_node(), to be only used in places where
> + * the overhead of the check for nid == -1 could matter.

We don't actually check for nid == -1, or nid == NUMA_NO_NODE, in any of 
the functions.  I would just state that nid must be valid and possible to 
allocate from when passed to this function.

> + */
> +static inline struct page *
> +__alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
> +{
> +	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
> +
> +	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
> +}
> +
> +/*
> + * Allocate pages, preferring the node given as nid. When nid equals -1,
> + * prefer the current CPU's node.
> + */

We've done quite a bit of work to refer only to NUMA_NO_NODE, so we'd like 
to avoid hardcoded -1 anywhere we can.

>  static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
> @@ -310,11 +326,18 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }
>  
> +/*
> + * Allocate pages, restricting the allocation to the node given as nid. The
> + * node must be valid and online. This is achieved by adding __GFP_THISNODE
> + * to gfp_mask.

Not sure we need to point out that __GPF_THISNODE does this, it stands out 
pretty well in the function already :)

> + */
>  static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
>  	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
>  
> +	gfp_mask |= __GFP_THISNODE;
> +
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }
>  
[snip]

I assume you looked at the collapse_huge_page() case and decided that it 
needs no modification since the gfp mask is used later for other calls?

> diff --git a/mm/migrate.c b/mm/migrate.c
> index f53838f..d139222 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1554,10 +1554,8 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
>  	struct page *newpage;
>  
>  	newpage = alloc_pages_exact_node(nid,
> -					 (GFP_HIGHUSER_MOVABLE |
> -					  __GFP_THISNODE | __GFP_NOMEMALLOC |
> -					  __GFP_NORETRY | __GFP_NOWARN) &
> -					 ~GFP_IOFS, 0);
> +				(GFP_HIGHUSER_MOVABLE | __GFP_NOMEMALLOC |
> +				 __GFP_NORETRY | __GFP_NOWARN) & ~GFP_IOFS, 0);
>  
>  	return newpage;
>  }
[snip]

What about the alloc_pages_exact_node() in new_page_node()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
