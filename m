Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5616B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 12:10:07 -0500 (EST)
Received: by ioc74 with SMTP id 74so122244750ioc.2
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 09:10:07 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id m8si7218283igx.42.2015.12.04.09.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 04 Dec 2015 09:10:06 -0800 (PST)
Date: Fri, 4 Dec 2015 11:10:05 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 1/2] slab: implement bulk alloc in SLAB allocator
In-Reply-To: <20151203155637.3589.62609.stgit@firesoul>
Message-ID: <alpine.DEB.2.20.1512041106410.21819@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul> <20151203155637.3589.62609.stgit@firesoul>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 3 Dec 2015, Jesper Dangaard Brouer wrote:

> +	size_t i;
> +
> +	flags &= gfp_allowed_mask;
> +	lockdep_trace_alloc(flags);
> +
> +	if (slab_should_failslab(s, flags))
> +		return 0;

Ok here is an overlap with slub;'s pre_alloc_hook() and that stuff is
really not allocator specific. Could make it generic and move the hook
calls into slab_common.c/slab.h? That also gives you the opportunity to
get the array option in there.

> +	s = memcg_kmem_get_cache(s, flags);
> +
> +	cache_alloc_debugcheck_before(s, flags);
> +
> +	local_irq_disable();
> +	for (i = 0; i < size; i++) {
> +		void *objp = __do_cache_alloc(s, flags);
> +
> +		// this call could be done outside IRQ disabled section
> +		objp = cache_alloc_debugcheck_after(s, flags, objp, _RET_IP_);
> +
> +		if (unlikely(!objp))
> +			goto error;
> +
> +		prefetchw(objp);

Is the prefetch really useful here? Only if these objects are immediately
used I would think.

> +		p[i] = objp;
> +	}
> +	local_irq_enable();
> +
> +	/* Kmemleak and kmemcheck outside IRQ disabled section */
> +	for (i = 0; i < size; i++) {
> +		void *x = p[i];
> +
> +		kmemleak_alloc_recursive(x, s->object_size, 1, s->flags, flags);
> +		kmemcheck_slab_alloc(s, flags, x, s->object_size);
> +	}
> +
> +	/* Clear memory outside IRQ disabled section */
> +	if (unlikely(flags & __GFP_ZERO))
> +		for (i = 0; i < size; i++)
> +			memset(p[i], 0, s->object_size);

Maybe make this one loop instead of two?


> +// FIXME: Trace call missing... should we create a bulk variant?
> +/*  Like:
> +	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size, s->size, flags);
> +*/

That trace call could be created when you do the genericization of the
hooks() which also involve debugging stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
