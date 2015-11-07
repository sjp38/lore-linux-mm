Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7D66682F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 11:40:50 -0500 (EST)
Received: by oiad129 with SMTP id d129so81042299oia.0
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 08:40:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u7si2755548oej.90.2015.11.07.08.40.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 08:40:49 -0800 (PST)
Date: Sat, 7 Nov 2015 17:40:43 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH V2 1/2] slub: fix kmem cgroup bug in
 kmem_cache_alloc_bulk
Message-ID: <20151107174043.6484d5bb@redhat.com>
In-Reply-To: <20151105161805.GH29259@esperanza>
References: <20151105153704.1115.10475.stgit@firesoul>
	<20151105153744.1115.38620.stgit@firesoul>
	<20151105161805.GH29259@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, brouer@redhat.com

On Thu, 5 Nov 2015 19:18:05 +0300
Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> On Thu, Nov 05, 2015 at 04:37:51PM +0100, Jesper Dangaard Brouer wrote:
> ...
> > @@ -1298,7 +1298,6 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s,
> >  	flags &= gfp_allowed_mask;
> >  	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
> >  	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
> > -	memcg_kmem_put_cache(s);
> >  	kasan_slab_alloc(s, object);
> >  }
> >  
> > @@ -2557,6 +2556,7 @@ redo:
> >  		memset(object, 0, s->object_size);
> >  
> >  	slab_post_alloc_hook(s, gfpflags, object);
> > +	memcg_kmem_put_cache(s);
> 
> Asymmetric - not good IMO. What about passing array of allocated objects
> to slab_post_alloc_hook? Then we could leave memcg_kmem_put_cache where
> it is now. I.e here we'd have
> 
> 	slab_post_alloc_hook(s, gfpflags, &object, 1);
> 
> while in kmem_cache_alloc_bulk it'd look like
> 
> 	slab_post_alloc_hook(s, flags, p, size);
> 
> right before return.

In theory a good idea, but we just have to make sure that the compiler
can "see" that it can remove the loop if the CONFIG feature is turned
off, and that const propagation works for the "1" element case.

I'll verify this tomorrow or Monday (busy at a conf yesterday goo.gl/rRTdNL)

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
