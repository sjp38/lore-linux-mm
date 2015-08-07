Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 163076B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 11:05:05 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so65110965wic.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 08:05:04 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id dj6si11545302wib.22.2015.08.07.08.05.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 08:05:03 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so69613335wib.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 08:05:03 -0700 (PDT)
Date: Fri, 7 Aug 2015 17:05:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/slub: don't wait for high-order page allocation
Message-ID: <20150807150501.GJ30785@dhcp22.suse.cz>
References: <1438913403-3682-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438913403-3682-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Shaohua Li <shli@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Eric Dumazet <edumazet@google.com>

On Fri 07-08-15 11:10:03, Joonsoo Kim wrote:
[...]
> diff --git a/mm/slub.c b/mm/slub.c
> index 257283f..52b9025 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1364,6 +1364,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	 * so we fall-back to the minimum order allocation.
>  	 */
>  	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
> +	if ((alloc_gfp & __GFP_WAIT) && oo_order(oo) > oo_order(s->min))
> +		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~__GFP_WAIT;

Wouldn't it be preferable to "fix" the __GFP_WAIT behavior than spilling
__GFP_NOMEMALLOC around the kernel? GFP flags are getting harder and
harder to use right and that is a signal we should thing about it and
unclutter the current state.

>  
>  	page = alloc_slab_page(s, alloc_gfp, node, oo);
>  	if (unlikely(!page)) {
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
