Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 40E756B0062
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 15:54:21 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so6511903pad.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 12:54:20 -0700 (PDT)
Date: Tue, 2 Oct 2012 12:54:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] slab: Ignore internal flags in cache creation
In-Reply-To: <1349171968-19243-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1210021251330.7383@chino.kir.corp.google.com>
References: <1349171968-19243-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 2 Oct 2012, Glauber Costa wrote:

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 9c21725..79be32e 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -107,6 +107,13 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
>  	if (!kmem_cache_sanity_check(name, size) == 0)
>  		goto out_locked;
>  
> +	/*
> +	 * Some allocators will constraint the set of valid flags to a subset
> +	 * of all flags. We expect them to define CACHE_CREATE_MASK in this

s/CACHE_CREATE_MASK/SLAB_AVAILABLE_FLAGS/

I don't think SLAB_AVAILABLE_FLAGS is the best name we can come up with, I 
think it should be at least something like CACHE_ALLOWED_FLAGS, but I'm 
fine with whatever it turns out to be.

> +	 * case, and we'll just provide them with a sanitized version of the
> +	 * passed flags.
> +	 */
> +	flags &= SLAB_AVAILABLE_FLAGS;
>  
>  	s = __kmem_cache_alias(name, size, align, flags, ctor);
>  	if (s)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
