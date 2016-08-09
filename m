Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A81226B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 11:17:53 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n69so36262074ion.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 08:17:53 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0095.outbound.protection.outlook.com. [104.47.0.95])
        by mx.google.com with ESMTPS id f34si1607178otd.290.2016.08.09.08.17.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 08:17:52 -0700 (PDT)
Date: Tue, 9 Aug 2016 18:17:43 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm/slub: Run free_partial() outside of the
 kmem_cache_node->list_lock
Message-ID: <20160809151743.GF1983@esperanza>
References: <1470753992-8114-1-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1470753992-8114-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Dave Gordon <david.s.gordon@intel.com>, linux-mm@kvack.org

On Tue, Aug 09, 2016 at 03:46:32PM +0100, Chris Wilson wrote:
...
> diff --git a/mm/slub.c b/mm/slub.c
> index 850737bdfbd8..22b2c1f3db0e 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3629,11 +3629,15 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
>   */
>  static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>  {
> +	LIST_HEAD(partial_list);
>  	struct page *page, *h;
>  
>  	BUG_ON(irqs_disabled());
>  	spin_lock_irq(&n->list_lock);
> -	list_for_each_entry_safe(page, h, &n->partial, lru) {
> +	list_splice_init(&n->partial, &partial_list);
> +	spin_unlock_irq(&n->list_lock);
> +
> +	list_for_each_entry_safe(page, h, &partial_list, lru) {
>  		if (!page->inuse) {
>  			remove_partial(n, page);

remove_partial() must be called with n->list_lock held - it even has
lockdep_assert_held(). What you actually need to do is to move
discard_slab() out of the critical section, like __kmem_cache_shrink()
does.

>  			discard_slab(s, page);
> @@ -3642,7 +3646,6 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>  			"Objects remaining in %s on __kmem_cache_shutdown()");
>  		}
>  	}
> -	spin_unlock_irq(&n->list_lock);
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
