Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 614B46B0037
	for <linux-mm@kvack.org>; Wed, 14 May 2014 12:16:40 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so3145541qcy.17
        for <linux-mm@kvack.org>; Wed, 14 May 2014 09:16:40 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id o3si1097632qcc.5.2014.05.14.09.16.39
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 09:16:39 -0700 (PDT)
Date: Wed, 14 May 2014 11:16:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 1/3] slub: keep full slabs on list for per memcg
 caches
In-Reply-To: <bc70b480221f7765926c8b4d63c55fb42e85baaf.1399982635.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1405141114040.16512@gentwo.org>
References: <cover.1399982635.git.vdavydov@parallels.com> <bc70b480221f7765926c8b4d63c55fb42e85baaf.1399982635.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 May 2014, Vladimir Davydov wrote:

> Currently full slabs are only kept on per-node lists for debugging, but
> we need this feature to reparent per memcg caches, so let's enable it
> for them too.

That will significantly impact the fastpaths for alloc and free.

Also a pretty significant change the logic of the fastpaths since they
were not designed to handle the full lists. In debug mode all operations
were only performed by the slow paths and only the slow paths so far
supported tracking full slabs.

> @@ -2587,6 +2610,9 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>
>  			} else { /* Needs to be taken off a list */
>
> +				if (kmem_cache_has_cpu_partial(s) && !prior)
> +					new.frozen = 1;
> +
>  	                        n = get_node(s, page_to_nid(page));

Make this code conditional?

>  				/*
>  				 * Speculatively acquire the list_lock.
> @@ -2606,6 +2632,12 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>  		object, new.counters,
>  		"__slab_free"));
>
> +	if (unlikely(n) && new.frozen && !was_frozen) {
> +		remove_full(s, n, page);
> +		spin_unlock_irqrestore(&n->list_lock, flags);
> +		n = NULL;
> +	}
> +
>  	if (likely(!n)) {

Here too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
