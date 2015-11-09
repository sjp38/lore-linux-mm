Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id F03FA6B0257
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 15:25:28 -0500 (EST)
Received: by ioc74 with SMTP id 74so132430921ioc.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 12:25:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r64si470809ioi.49.2015.11.09.12.25.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 12:25:28 -0800 (PST)
Date: Mon, 9 Nov 2015 21:25:22 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in
 kmem_cache_alloc_bulk
Message-ID: <20151109212522.6b38988c@redhat.com>
In-Reply-To: <20151109191335.GM31308@esperanza>
References: <20151109181604.8231.22983.stgit@firesoul>
	<20151109181703.8231.66384.stgit@firesoul>
	<20151109191335.GM31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, brouer@redhat.com

On Mon, 9 Nov 2015 22:13:35 +0300
Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> On Mon, Nov 09, 2015 at 07:17:31PM +0100, Jesper Dangaard Brouer wrote:
> ...
> > @@ -2556,7 +2563,7 @@ redo:
> >  	if (unlikely(gfpflags & __GFP_ZERO) && object)
> >  		memset(object, 0, s->object_size);
> >  
> > -	slab_post_alloc_hook(s, gfpflags, object);
> > +	slab_post_alloc_hook(s, gfpflags, 1, object);
> 
> I think it must be &object

The object is already a void ** type.

> BTW why is object defined as void **? I suspect we can safely drop one
> star.

Maybe Christoph can explain this?


> >  
> >  	return object;
> >  }
> ...
> > @@ -2953,11 +2958,15 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> >  			memset(p[j], 0, s->object_size);
> >  	}
> >  
> > +	/* memcg and kmem_cache debug support */
> > +	slab_post_alloc_hook(s, flags, size, p);
> > +
> >  	return true;
> >  
> >  error:
> >  	__kmem_cache_free_bulk(s, i, p);
> >  	local_irq_enable();
> > +	memcg_kmem_put_cache(s);
> 
> I wouldn't tear memcg_kmem_put_cache from slab_post_alloc_hook. If we
> add something else to slab_post_alloc_hook (e.g. we might want to call
> tracing functions from there), we'll have to modify this error path
> either, which is easy to miss.
> 
> What about calling
> 
> 	slab_post_alloc_hook(s, flags, 0, NULL);
> 
> here?

Maybe the correct behavior here, to adhere to all the debugging options,
is to call:

error:
 local_irq_enable();
 slab_post_alloc_hook(s, flags, i, p);
 __kmem_cache_free_bulk(s, i, p);
 return false;

 
> >  	return false;
> >  }
> >  EXPORT_SYMBOL(kmem_cache_alloc_bulk);
> > 


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
