Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 84D656B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:48:04 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id n4so7226075qaq.12
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:48:04 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id h45si13579733qgd.59.2015.01.26.07.48.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 07:48:03 -0800 (PST)
Date: Mon, 26 Jan 2015 09:48:00 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 1/3] slub: don't fail kmem_cache_shrink if slab
 placement optimization fails
In-Reply-To: <3804a429071f939e6b4f654b6c6426c1fdd95f7e.1422275084.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1501260944550.15849@gentwo.org>
References: <cover.1422275084.git.vdavydov@parallels.com> <3804a429071f939e6b4f654b6c6426c1fdd95f7e.1422275084.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015, Vladimir Davydov wrote:

> SLUB's kmem_cache_shrink not only removes empty slabs from the cache,
> but also sorts slabs by the number of objects in-use to cope with
> fragmentation. To achieve that, it tries to allocate a temporary array.
> If it fails, it will abort the whole procedure.

I do not think its worth optimizing this. If we cannot allocate even a
small object then the system is in an extremely bad state anyways.

> @@ -3400,7 +3407,9 @@ int __kmem_cache_shrink(struct kmem_cache *s)
>  		 * list_lock. page->inuse here is the upper limit.
>  		 */
>  		list_for_each_entry_safe(page, t, &n->partial, lru) {
> -			list_move(&page->lru, slabs_by_inuse + page->inuse);
> +			if (page->inuse < objects)
> +				list_move(&page->lru,
> +					  slabs_by_inuse + page->inuse);
>  			if (!page->inuse)
>  				n->nr_partial--;
>  		}

The condition is always true. A page that has page->inuse == objects
would not be on the partial list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
