Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id D81826B008C
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 18:18:30 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id l13so40434iga.13
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:18:30 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id i11si168801igf.37.2014.07.24.15.18.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 15:18:30 -0700 (PDT)
Received: by mail-ig0-f180.google.com with SMTP id l13so45385iga.1
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:18:29 -0700 (PDT)
Date: Thu, 24 Jul 2014 15:18:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, slub: fix false-positive lockdep warning in
 free_partial()
In-Reply-To: <20140724122143.GI1725@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1407241517440.19906@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407221550500.9885@chino.kir.corp.google.com> <alpine.DEB.2.02.1407221556330.9885@chino.kir.corp.google.com> <20140724122143.GI1725@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Dan Carpenter <dan.carpenter@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Jul 2014, Johannes Weiner wrote:

> > diff --git a/mm/slub.c b/mm/slub.c
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3195,12 +3195,13 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
> >  /*
> >   * Attempt to free all partial slabs on a node.
> >   * This is called from kmem_cache_close(). We must be the last thread
> > - * using the cache and therefore we do not need to lock anymore.
> > + * using the cache, but we still have to lock for lockdep's sake.
> >   */
> >  static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
> >  {
> >  	struct page *page, *h;
> >  
> > +	spin_lock_irq(&n->list_lock);
> >  	list_for_each_entry_safe(page, h, &n->partial, lru) {
> >  		if (!page->inuse) {
> >  			__remove_partial(n, page);
> 
> This already uses __remove_partial(), which does not have the lockdep
> assertion.  You even acked the patch that made this change, why add
> the spinlock now?
> 

Yup, thanks.  This was sitting in Pekka's slab/next branch but isn't 
actually needed after commit 1e4dd9461fab ("slub: do not assert not 
having lock in removing freed partial").  Good catch!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
