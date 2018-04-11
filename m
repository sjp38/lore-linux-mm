Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97A336B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 02:35:59 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x81so253873pgx.21
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 23:35:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t11si327881pgv.123.2018.04.10.23.35.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 23:35:58 -0700 (PDT)
Date: Wed, 11 Apr 2018 08:35:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
Message-ID: <20180411063554.GB30893@dhcp22.suse.cz>
References: <20180411060320.14458-1-willy@infradead.org>
 <20180411060320.14458-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180411060320.14458-3-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Tue 10-04-18 23:03:20, Matthew Wilcox wrote:
> diff --git a/mm/slab.c b/mm/slab.c
> index 58c8cecc26ab..9ad85fd9fca8 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2661,6 +2661,7 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
>  				invalid_mask, &invalid_mask, flags, &flags);
>  		dump_stack();
>  	}
> +	BUG_ON(cachep->ctor && (flags & __GFP_ZERO));

NAK. We really do not want to blow the whole kernel just because
somebody is doing something stupid. Make it WARN_ON_ONCE and fix up the
flag.

> +static inline bool slab_no_ctor(struct kmem_cache *s)
> +{
> +	if (IS_ENABLED(CONFIG_DEBUG_VM))
> +		return !WARN_ON_ONCE(s->ctor);
> +	return true;
> +}

I do realize that you want to keep the hotpath without additional checks
but if for nothing else this is a really bad misnomer.
debug_slab_no_ctor()? I can clearly see how somebody uses this blindly
for a different purpose.
[...]
> diff --git a/mm/slub.c b/mm/slub.c
> index a28488643603..9f8f38a552e5 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1576,6 +1576,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  
>  	if (gfpflags_allow_blocking(flags))
>  		local_irq_enable();
> +	BUG_ON(s->ctor && (flags & __GFP_ZERO));

No no on this as well.

Othe than that. Once those are fixed, feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs
