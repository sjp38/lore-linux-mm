Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 003686B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 03:46:46 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so228425064pab.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 00:46:46 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id g6si3820092pat.15.2015.11.10.00.46.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 00:46:46 -0800 (PST)
Date: Tue, 10 Nov 2015 11:46:33 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
Message-ID: <20151110084633.GT31308@esperanza>
References: <20151109181604.8231.22983.stgit@firesoul>
 <20151109181703.8231.66384.stgit@firesoul>
 <20151109191335.GM31308@esperanza>
 <20151109212522.6b38988c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151109212522.6b38988c@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Mon, Nov 09, 2015 at 09:25:22PM +0100, Jesper Dangaard Brouer wrote:
> On Mon, 9 Nov 2015 22:13:35 +0300
> Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> 
> > On Mon, Nov 09, 2015 at 07:17:31PM +0100, Jesper Dangaard Brouer wrote:
> > ...
> > > @@ -2556,7 +2563,7 @@ redo:
> > >  	if (unlikely(gfpflags & __GFP_ZERO) && object)
> > >  		memset(object, 0, s->object_size);
> > >  
> > > -	slab_post_alloc_hook(s, gfpflags, object);
> > > +	slab_post_alloc_hook(s, gfpflags, 1, object);
> > 
> > I think it must be &object
> 
> The object is already a void ** type.

Let's forget about types for a second. object contains an address to the
newly allocated object, while slab_post_alloc_hook expects an array of
addresses to objects. Simple test. Suppose an allocation failed. Then
object equals 0. Passing 0 to slab_post_alloc_hook as @p and 1 as @size
will result in NULL ptr dereference.

> 
> > BTW why is object defined as void **? I suspect we can safely drop one
> > star.
> 
> Maybe Christoph can explain this?
> 
> 
> > >  
> > >  	return object;
> > >  }
> > ...
> > > @@ -2953,11 +2958,15 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> > >  			memset(p[j], 0, s->object_size);
> > >  	}
> > >  
> > > +	/* memcg and kmem_cache debug support */
> > > +	slab_post_alloc_hook(s, flags, size, p);
> > > +
> > >  	return true;
> > >  
> > >  error:
> > >  	__kmem_cache_free_bulk(s, i, p);
> > >  	local_irq_enable();
> > > +	memcg_kmem_put_cache(s);
> > 
> > I wouldn't tear memcg_kmem_put_cache from slab_post_alloc_hook. If we
> > add something else to slab_post_alloc_hook (e.g. we might want to call
> > tracing functions from there), we'll have to modify this error path
> > either, which is easy to miss.
> > 
> > What about calling
> > 
> > 	slab_post_alloc_hook(s, flags, 0, NULL);
> > 
> > here?
> 
> Maybe the correct behavior here, to adhere to all the debugging options,
> is to call:
> 
> error:
>  local_irq_enable();
>  slab_post_alloc_hook(s, flags, i, p);
>  __kmem_cache_free_bulk(s, i, p);
>  return false;

Yeah, I think you're right, because __kmem_cache_free_bulk calls
slab_free_hook, which is supposed to undo slab_post_alloc_hook, so we
must call the latter for allocated objects.

Thanks,
Vladimir

> 
>  
> > >  	return false;
> > >  }
> > >  EXPORT_SYMBOL(kmem_cache_alloc_bulk);
> > > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
