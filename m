Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id E12B56B0068
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:36:46 -0400 (EDT)
Message-ID: <5044CDD0.4040403@parallels.com>
Date: Mon, 3 Sep 2012 19:33:36 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [13/14] Shrink __kmem_cache_create() parameter lists
References: <20120824160903.168122683@linux.com> <00000139596cab81-8759391f-4d20-494a-9c7c-a759363e2b87-000000@email.amazonses.com>
In-Reply-To: <00000139596cab81-8759391f-4d20-494a-9c7c-a759363e2b87-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:17 PM, Christoph Lameter wrote:
> -__kmem_cache_create (struct kmem_cache *cachep, const char *name, size_t size, size_t align,
> -	unsigned long flags, void (*ctor)(void *))
> +__kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>  {
>  	size_t left_over, slab_size, ralign;
>  	gfp_t gfp;
> @@ -2385,9 +2383,9 @@ __kmem_cache_create (struct kmem_cache *
>  	 * unaligned accesses for some archs when redzoning is used, and makes
>  	 * sure any on-slab bufctl's are also correctly aligned.
>  	 */
> -	if (size & (BYTES_PER_WORD - 1)) {
> -		size += (BYTES_PER_WORD - 1);
> -		size &= ~(BYTES_PER_WORD - 1);
> +	if (cachep->size & (BYTES_PER_WORD - 1)) {
> +		cachep->size += (BYTES_PER_WORD - 1);
> +		cachep->size &= ~(BYTES_PER_WORD - 1);
>  	}

There are still one reference to "size" inside this function that will
break the build. This reference is enclosed inside CONFIG_DEBUG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
