Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A383B6B025F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 11:45:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so30449885pfd.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 08:45:49 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20094.outbound.protection.outlook.com. [40.107.2.94])
        by mx.google.com with ESMTPS id pv7si8994600pac.166.2016.08.09.08.45.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 08:45:48 -0700 (PDT)
Date: Tue, 9 Aug 2016 18:45:39 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2] mm/slub: Run free_partial() outside of the
 kmem_cache_node->list_lock
Message-ID: <20160809154539.GG1983@esperanza>
References: <20160809151743.GF1983@esperanza>
 <1470756466-12493-1-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1470756466-12493-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Dave Gordon <david.s.gordon@intel.com>, linux-mm@kvack.org

On Tue, Aug 09, 2016 at 04:27:46PM +0100, Chris Wilson wrote:
...
> diff --git a/mm/slub.c b/mm/slub.c
> index 825ff45..58f0eb6 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3479,6 +3479,7 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
>   */
>  static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>  {
> +	LIST_HEAD(partial_list);

nit: slabs added to this list are not partially used - they are free, so
let's call it 'free_slabs' or 'discard_list' or just 'discard', please

>  	struct page *page, *h;
>  
>  	BUG_ON(irqs_disabled());
> @@ -3486,13 +3487,16 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>  	list_for_each_entry_safe(page, h, &n->partial, lru) {
>  		if (!page->inuse) {
>  			remove_partial(n, page);
> -			discard_slab(s, page);
> +			list_add(&page->lru, &partial_list);

If there are objects left in the cache on destruction, the cache won't
be destroyed. Instead it will be left on the slab_list and can get
reused later. So we should use list_move() here to always leave
n->partial in a consistent state, even in case of a leak.

>  		} else {
>  			list_slab_objects(s, page,
>  			"Objects remaining in %s on __kmem_cache_shutdown()");
>  		}
>  	}
>  	spin_unlock_irq(&n->list_lock);
> +
> +	list_for_each_entry_safe(page, h, &partial_list, lru)
> +		discard_slab(s, page);
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
