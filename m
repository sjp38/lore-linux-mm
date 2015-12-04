Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7EA6B025C
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 12:17:04 -0500 (EST)
Received: by ioir85 with SMTP id r85so122728804ioi.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 09:17:04 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id c196si21544541ioe.212.2015.12.04.09.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 04 Dec 2015 09:17:04 -0800 (PST)
Date: Fri, 4 Dec 2015 11:17:02 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151203155736.3589.67424.stgit@firesoul>
Message-ID: <alpine.DEB.2.20.1512041111180.21819@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul> <20151203155736.3589.67424.stgit@firesoul>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 3 Dec 2015, Jesper Dangaard Brouer wrote:

> +void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)

orig_s? Thats strange

> +{
> +	struct kmem_cache *s;

s?

> +	size_t i;
> +
> +	local_irq_disable();
> +	for (i = 0; i < size; i++) {
> +		void *objp = p[i];
> +
> +		s = cache_from_obj(orig_s, objp);

Does this support freeing objects from a set of different caches?

Otherwise there needs to be a check in here that the objects come from the
same cache.

> +
> +		debug_check_no_locks_freed(objp, s->object_size);
> +		if (!(s->flags & SLAB_DEBUG_OBJECTS))
> +			debug_check_no_obj_freed(objp, s->object_size);
> +
> +		__cache_free(s, objp, _RET_IP_);

The function could be further optimized if you take the code from
__cache_free() and move stuff outside of the loop. The alien cache check
f.e. and the Pfmemalloc checking may be moved out. The call to
virt_to_head page may also be avoided if the objects are on the same
page  as the last. So you may be able to function calls for the
fastpath in the inner loop which may accelerate frees significantly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
