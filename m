Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 95E436B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:17:53 -0400 (EDT)
Message-ID: <4FD99D9B.6060000@parallels.com>
Date: Thu, 14 Jun 2012 12:15:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [08/20] Extract common code for kmem_cache_create()
References: <20120613152451.465596612@linux.com> <20120613152519.255119144@linux.com>
In-Reply-To: <20120613152519.255119144@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 06/13/2012 07:24 PM, Christoph Lameter wrote:
> +struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align,
> +		unsigned long flags, void (*ctor)(void *))
> +{
> +	struct kmem_cache *s = NULL;
> +
> +#ifdef CONFIG_DEBUG_VM
> +	if (!name || in_interrupt() || size<  sizeof(void *) ||
> +		size>  KMALLOC_MAX_SIZE) {
> +		printk(KERN_ERR "kmem_cache_create(%s) integrity check"
> +			" failed\n", name);
> +		goto out;
> +	}
> +#endif

Not really a BUG, but label out is not used if !CONFIG_DEBUG_VM. Suggest 
testing for the slab panic flag here, and panicing if we need to.


> +
> +	s = __kmem_cache_create(name, size, align, flags, ctor);
> +
> +out:
> +	if (!s&&  (flags&  SLAB_PANIC))
> +		panic("kmem_cache_create: Failed to create slab '%s'\n", name);
> +
> +	return s;
> +}
> +EXPORT_SYMBOL(kmem_cache_create);
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
