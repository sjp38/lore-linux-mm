Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 3E1D56B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:23:26 -0400 (EDT)
Message-ID: <4FD9F347.2020409@parallels.com>
Date: Thu, 14 Jun 2012 18:20:55 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [08/20] Extract common code for kmem_cache_create()
References: <20120613152451.465596612@linux.com> <20120613152519.255119144@linux.com> <4FD99D9B.6060000@parallels.com> <alpine.DEB.2.00.1206140912250.32075@router.home>
In-Reply-To: <alpine.DEB.2.00.1206140912250.32075@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 06/14/2012 06:18 PM, Christoph Lameter wrote:
> On Thu, 14 Jun 2012, Glauber Costa wrote:
>
>> On 06/13/2012 07:24 PM, Christoph Lameter wrote:
>>> +struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t
>>> align,
>>> +		unsigned long flags, void (*ctor)(void *))
>>> +{
>>> +	struct kmem_cache *s = NULL;
>>> +
>>> +#ifdef CONFIG_DEBUG_VM
>>> +	if (!name || in_interrupt() || size<   sizeof(void *) ||
>>> +		size>   KMALLOC_MAX_SIZE) {
>>> +		printk(KERN_ERR "kmem_cache_create(%s) integrity check"
>>> +			" failed\n", name);
>>> +		goto out;
>>> +	}
>>> +#endif
>>
>> Not really a BUG, but label out is not used if !CONFIG_DEBUG_VM. Suggest
>> testing for the slab panic flag here, and panicing if we need to.
>
> Hmmm.. That is quite sensitive. A change here will cause later patches in
> the series to have issues. Maybe its best to put an #ifdef around the
> label until a later patch that makes use of out: from code that is not
> #ifdefed.
>
>
> Subject: Add #ifdef to avoid warning about unused label
>
> out: is only used if CONFIG_DEBUG_VM is enabled.
>
> Signed-off-by: Christoph Lameter<cl@linux.com>
>
> Index: linux-2.6/mm/slab_common.c
> ===================================================================
> --- linux-2.6.orig/mm/slab_common.c	2012-06-14 03:16:06.778702087 -0500
> +++ linux-2.6/mm/slab_common.c	2012-06-14 03:16:01.054702201 -0500
> @@ -57,7 +57,9 @@ struct kmem_cache *kmem_cache_create(con
>
>   	s = __kmem_cache_create(name, size, align, flags, ctor);
>
> +#ifdef CONFIG_DEBUG_VM
>   out:
> +#endif
>   	if (!s&&  (flags&  SLAB_PANIC))
>   		panic("kmem_cache_create: Failed to create slab '%s'\n", name);
>

That's how my code reads:

#ifdef CONFIG_DEBUG_VM
if (!name || in_interrupt() || size < sizeof(void *) ||
     size    KMALLOC_MAX_SIZE) {

     if ((flags & SLAB_PANIC))
         panic("kmem_cache_create(%s) integrity check failed\n", name);
     printk(KERN_ERR "kmem_cache_create(%s) integrity check failed\n",
            name);
     return NULL;
}
#endif

How can it put any patch later than this in trouble ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
