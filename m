Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 51D956B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 11:06:15 -0500 (EST)
Received: by iofh3 with SMTP id h3so50405994iof.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 08:06:15 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id m25si6389557ioi.189.2015.12.02.08.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 08:06:14 -0800 (PST)
Date: Wed, 2 Dec 2015 10:06:13 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm/slab: use list_{empty_careful,last_entry} in
 drain_freelist
In-Reply-To: <670c0018e0e4f44d6e788423b35e2c32ccf6c1e2.1449070964.git.geliangtang@163.com>
Message-ID: <alpine.DEB.2.20.1512021005120.28955@east.gentwo.org>
References: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com> <670c0018e0e4f44d6e788423b35e2c32ccf6c1e2.1449070964.git.geliangtang@163.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2 Dec 2015, Geliang Tang wrote:

> diff --git a/mm/slab.c b/mm/slab.c
> index 5d5aa3b..1a7d91c 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2362,21 +2362,14 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
>  static int drain_freelist(struct kmem_cache *cache,
>  			struct kmem_cache_node *n, int tofree)
>  {
> -	struct list_head *p;
>  	int nr_freed;
>  	struct page *page;
>
>  	nr_freed = 0;
> -	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
> +	while (nr_freed < tofree && !list_empty_careful(&n->slabs_free)) {
>
>  		spin_lock_irq(&n->list_lock);
> -		p = n->slabs_free.prev;
> -		if (p == &n->slabs_free) {
> -			spin_unlock_irq(&n->list_lock);
> -			goto out;
> -		}
> -
> -		page = list_entry(p, struct page, lru);
> +		page = list_last_entry(&n->slabs_free, struct page, lru);

This is safe? Process could be rescheduled and lots of things could happen
before disabling irqs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
