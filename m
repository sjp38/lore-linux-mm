Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 7D38D6B0099
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 20:57:07 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so1952995pbb.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 17:57:06 -0700 (PDT)
Date: Wed, 5 Sep 2012 17:57:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] mm, slob: Add support for kmalloc_track_caller()
In-Reply-To: <1346885323-15689-2-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1209051756270.7625@chino.kir.corp.google.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com> <1346885323-15689-2-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Wed, 5 Sep 2012, Ezequiel Garcia wrote:

> @@ -454,15 +455,35 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
>  			gfp |= __GFP_COMP;
>  		ret = slob_new_pages(gfp, order, node);
>  
> -		trace_kmalloc_node(_RET_IP_, ret,
> +		trace_kmalloc_node(caller, ret,
>  				   size, PAGE_SIZE << order, gfp, node);
>  	}
>  
>  	kmemleak_alloc(ret, size, 1, gfp);
>  	return ret;
>  }
> +
> +void *__kmalloc_node(size_t size, gfp_t gfp, int node)
> +{
> +	return __do_kmalloc_node(size, gfp, node, _RET_IP_);
> +}
>  EXPORT_SYMBOL(__kmalloc_node);
>  
> +#ifdef CONFIG_TRACING
> +void *__kmalloc_track_caller(size_t size, gfp_t gfp, unsigned long caller)
> +{
> +	return __do_kmalloc_node(size, gfp, -1, caller);

NUMA_NO_NODE.

> +}
> +
> +#ifdef CONFIG_NUMA
> +void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
> +					int node, unsigned long caller)
> +{
> +	return __do_kmalloc_node(size, gfp, node, caller);
> +}
> +#endif
> +#endif
> +
>  void kfree(const void *block)
>  {
>  	struct page *sp;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
