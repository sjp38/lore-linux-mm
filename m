Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 728566B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 06:37:37 -0400 (EDT)
Message-ID: <501A57C2.2060702@parallels.com>
Date: Thu, 2 Aug 2012 14:34:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [15/16] Shrink __kmem_cache_create() parameter lists
References: <20120801211130.025389154@linux.com> <20120801211204.342096542@linux.com>
In-Reply-To: <20120801211204.342096542@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 01:11 AM, Christoph Lameter wrote:
>  
>  	if (s) {
> -		int r = __kmem_cache_create(s, n, size, align, flags, ctor);
> +		int r;
>  
> -		if (!r)
> +		s->object_size = s->size = size;
> +		s->align = align;
> +		s->ctor = ctor;
> +		s->name = kstrdup(name, GFP_KERNEL);
> +		if (!s->name) {
> +			kmem_cache_free(kmem_cache, s);
> +			s = NULL;
> +			goto oops;
> +		}
> +
> +		r = __kmem_cache_create(s, flags);
> +
> +		if (!r) {
> +			s->refcount = 1;
>  			list_add(&s->list, &slab_caches);
> -		else {
> -			kfree(n);
> +		} else {
> +			kfree(s->name);
>  			kmem_cache_free(kmem_cache, s);
>  			s = NULL;
>  		}
>  	} else
> -		kfree(n);
> +		kfree(s->name);

This last statement is a NULL pointer dereference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
