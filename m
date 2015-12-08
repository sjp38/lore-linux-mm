Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 281966B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 09:12:33 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so11749895lbb.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 06:12:32 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id d190si1779437lfb.135.2015.12.08.06.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 06:12:31 -0800 (PST)
Date: Tue, 8 Dec 2015 17:12:11 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
Message-ID: <20151208141211.GH11488@esperanza>
References: <20151203155600.3589.86568.stgit@firesoul>
 <20151203155736.3589.67424.stgit@firesoul>
 <alpine.DEB.2.20.1512041111180.21819@east.gentwo.org>
 <20151207122549.109e82db@redhat.com>
 <alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 07, 2015 at 08:59:25AM -0600, Christoph Lameter wrote:
> On Mon, 7 Dec 2015, Jesper Dangaard Brouer wrote:
> 
> > > s?
> >
> > The "s" comes from the slub.c code uses "struct kmem_cache *s" everywhere.
> 
> Ok then use it. Why is there an orig_s here.
> 
> > > > +
> > > > +	local_irq_disable();
> > > > +	for (i = 0; i < size; i++) {
> > > > +		void *objp = p[i];
> > > > +
> > > > +		s = cache_from_obj(orig_s, objp);
> > >
> > > Does this support freeing objects from a set of different caches?
> >
> > This is for supporting memcg (CONFIG_MEMCG_KMEM).
> >
> > Quoting from commit 033745189b1b ("slub: add missing kmem cgroup
> > support to kmem_cache_free_bulk"):
> >
> >    Incoming bulk free objects can belong to different kmem cgroups, and
> >    object free call can happen at a later point outside memcg context.  Thus,
> >    we need to keep the orig kmem_cache, to correctly verify if a memcg object
> >    match against its "root_cache" (s->memcg_params.root_cache).
> 
> Where is that verification? This looks like SLAB would support freeing
> objects from different caches.

As Jesper explained to me in the thread regarding the SLUB version of
this API (see http://www.spinics.net/lists/linux-mm/msg96728.html),
objects allocated by kmem_cache_alloc_bulk() will not necessarily be
freed by kmem_cache_free_bulk() and vice-versa. For instance, it is
possible that a bunch of objects allocated using kmem_cache_alloc() will
be freed with a single kmem_cache_free_bulk() call. As a result, we
can't prevent users of the API from doing something like this:

 1. Multiple producers allocate objects of the same kind using
    kmem_cache_alloc() and pass them to the consumer
 2. The consumer processes the objects and frees as many as possible
    using kmem_cache_bulk()

If producers are represented by different processes, they can belong to
different memory cgroups, so that objects passed to the consumer will
come from different kmem caches (per memcg caches), although they are
all of the same kind. This means, we must call cache_from_obj() on each
object passed to kmem_cache_free_bulk() in order to free each object to
the cache it was allocated from.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
