Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDB176B025E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:07:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e9so6861040pfn.16
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 06:07:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12si1799697pgq.533.2018.04.10.06.07.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 06:07:48 -0700 (PDT)
Date: Tue, 10 Apr 2018 15:07:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a constructor
Message-ID: <20180410130742.GM21835@dhcp22.suse.cz>
References: <20180410125351.15837-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410125351.15837-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue 10-04-18 05:53:50, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> __GFP_ZERO requests that the object be initialised to all-zeroes,
> while the purpose of a constructor is to initialise an object to a
> particular pattern.  We cannot do both.  Add a warning to catch any
> users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> a constructor.
> 
> Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: stable@vger.kernel.org
> ---
>  mm/slab.c | 6 ++++--
>  mm/slob.c | 4 +++-
>  mm/slub.c | 6 ++++--
>  3 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 38d3f4fd17d7..8b2cb7db85db 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3313,8 +3313,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
>  	local_irq_restore(save_flags);
>  	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
>  
> -	if (unlikely(flags & __GFP_ZERO) && ptr)
> -		memset(ptr, 0, cachep->object_size);
> +	if (unlikely(flags & __GFP_ZERO) && ptr) {
> +		if (!WARN_ON_ONCE(cachep->ctor))
> +			memset(ptr, 0, cachep->object_size);
> +	}
>  
>  	slab_post_alloc_hook(cachep, flags, 1, &ptr);
>  	return ptr;

Why don't we need to cover this in slab_alloc and kmem_cache_alloc_bulk as well?

Other than that this patch makes sense to me.
-- 
Michal Hocko
SUSE Labs
