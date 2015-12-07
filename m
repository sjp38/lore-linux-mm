Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1B12D6B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 09:59:27 -0500 (EST)
Received: by ioc74 with SMTP id 74so183093494ioc.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 06:59:26 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id i80si5524137ioi.14.2015.12.07.06.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 07 Dec 2015 06:59:26 -0800 (PST)
Date: Mon, 7 Dec 2015 08:59:25 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151207122549.109e82db@redhat.com>
Message-ID: <alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul> <20151203155736.3589.67424.stgit@firesoul> <alpine.DEB.2.20.1512041111180.21819@east.gentwo.org> <20151207122549.109e82db@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 7 Dec 2015, Jesper Dangaard Brouer wrote:

> > s?
>
> The "s" comes from the slub.c code uses "struct kmem_cache *s" everywhere.

Ok then use it. Why is there an orig_s here.

> > > +
> > > +	local_irq_disable();
> > > +	for (i = 0; i < size; i++) {
> > > +		void *objp = p[i];
> > > +
> > > +		s = cache_from_obj(orig_s, objp);
> >
> > Does this support freeing objects from a set of different caches?
>
> This is for supporting memcg (CONFIG_MEMCG_KMEM).
>
> Quoting from commit 033745189b1b ("slub: add missing kmem cgroup
> support to kmem_cache_free_bulk"):
>
>    Incoming bulk free objects can belong to different kmem cgroups, and
>    object free call can happen at a later point outside memcg context.  Thus,
>    we need to keep the orig kmem_cache, to correctly verify if a memcg object
>    match against its "root_cache" (s->memcg_params.root_cache).

Where is that verification? This looks like SLAB would support freeing
objects from different caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
