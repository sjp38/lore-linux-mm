Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id DCF716B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 13:27:13 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id o15so19001013qap.30
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:27:13 -0800 (PST)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id r61si1166139qga.89.2014.02.14.10.27.13
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 10:27:13 -0800 (PST)
Date: Fri, 14 Feb 2014 12:27:10 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/9] slab: makes clear_obj_pfmemalloc() just return store
 masked value
In-Reply-To: <1392361043-22420-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1402141225460.12887@nuc>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> clear_obj_pfmemalloc() takes the pointer to the object pointer as argument
> to store masked value back into this address.
> But this is useless, since we don't use this stored value anymore.
> All we need is just masked value. So makes clear_obj_pfmemalloc()
> just return masked value.

Could this be a bit more compact?

> @@ -215,9 +215,9 @@ static inline void set_obj_pfmemalloc(void **objp)
>  	return;
>  }
>
> -static inline void clear_obj_pfmemalloc(void **objp)
> +static inline void *clear_obj_pfmemalloc(void *objp)
>  {
> -	*objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
> +	return (void *)((unsigned long)objp & ~SLAB_OBJ_PFMEMALLOC);
>  }

I dont think you need the (void *) cast here.

>  /*
> @@ -810,7 +810,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
>  		struct kmem_cache_node *n;
>
>  		if (gfp_pfmemalloc_allowed(flags)) {
> -			clear_obj_pfmemalloc(&objp);
> +			objp = clear_obj_pfmemalloc(objp);
>  			return objp;
>  		}

No need for objp. Just "return clear_obj_....


> @@ -833,7 +833,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
>  		if (!list_empty(&n->slabs_free) && force_refill) {
>  			struct page *page = virt_to_head_page(objp);
>  			ClearPageSlabPfmemalloc(page);
> -			clear_obj_pfmemalloc(&objp);
> +			objp = clear_obj_pfmemalloc(objp);
>  			recheck_pfmemalloc_active(cachep, ac);
>  			return objp;

Same here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
