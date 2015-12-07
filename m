Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 149E86B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 06:25:56 -0500 (EST)
Received: by qkfb125 with SMTP id b125so1207108qkf.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 03:25:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g189si26876305qhd.50.2015.12.07.03.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 03:25:55 -0800 (PST)
Date: Mon, 7 Dec 2015 12:25:49 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
Message-ID: <20151207122549.109e82db@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1512041111180.21819@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul>
	<20151203155736.3589.67424.stgit@firesoul>
	<alpine.DEB.2.20.1512041111180.21819@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com

On Fri, 4 Dec 2015 11:17:02 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 3 Dec 2015, Jesper Dangaard Brouer wrote:
> 
> > +void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
> 
> orig_s? Thats strange
> 
> > +{
> > +	struct kmem_cache *s;
> 
> s?

The "s" comes from the slub.c code uses "struct kmem_cache *s" everywhere.

> > +	size_t i;
> > +
> > +	local_irq_disable();
> > +	for (i = 0; i < size; i++) {
> > +		void *objp = p[i];
> > +
> > +		s = cache_from_obj(orig_s, objp);
> 
> Does this support freeing objects from a set of different caches?

This is for supporting memcg (CONFIG_MEMCG_KMEM).

Quoting from commit 033745189b1b ("slub: add missing kmem cgroup
support to kmem_cache_free_bulk"):

   Incoming bulk free objects can belong to different kmem cgroups, and
   object free call can happen at a later point outside memcg context.  Thus,
   we need to keep the orig kmem_cache, to correctly verify if a memcg object
   match against its "root_cache" (s->memcg_params.root_cache).
 

> > +
> > +		debug_check_no_locks_freed(objp, s->object_size);
> > +		if (!(s->flags & SLAB_DEBUG_OBJECTS))
> > +			debug_check_no_obj_freed(objp, s->object_size);
> > +
> > +		__cache_free(s, objp, _RET_IP_);
> 
> The function could be further optimized if you take the code from
> __cache_free() and move stuff outside of the loop. The alien cache check
> f.e. and the Pfmemalloc checking may be moved out. The call to
> virt_to_head page may also be avoided if the objects are on the same
> page  as the last. So you may be able to function calls for the
> fastpath in the inner loop which may accelerate frees significantly.

Interesting! Maybe we can do a followup patch to pullout last
optimization's.  Right now I'm mostly interested in correctness and
clean code.  And we are already looking at a 80% speedup with these
patches ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
