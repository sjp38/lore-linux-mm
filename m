Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id AC02B82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 00:06:19 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so51233858pac.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 21:06:19 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id py15si5088152pab.12.2015.11.04.21.06.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 21:06:18 -0800 (PST)
Date: Thu, 5 Nov 2015 14:06:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
Message-ID: <20151105050621.GC20374@js1304-P5Q-DELUXE>
References: <20151029130531.15158.58018.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151029130531.15158.58018.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Thu, Oct 29, 2015 at 02:05:31PM +0100, Jesper Dangaard Brouer wrote:
> Initial implementation missed support for kmem cgroup support
> in kmem_cache_free_bulk() call, add this.
> 
> If CONFIG_MEMCG_KMEM is not enabled, the compiler should
> be smart enough to not add any asm code.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  mm/slub.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 9be12ffae9fc..9875864ad7b8 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2845,6 +2845,9 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
>  	if (!object)
>  		return 0;
>  
> +	/* Support for kmemcg */
> +	s = cache_from_obj(s, object);
> +
>  	/* Start new detached freelist */
>  	set_freepointer(s, object, NULL);
>  	df->page = virt_to_head_page(object);

Hello,

It'd better to add this 's = cache_from_obj()' on kmem_cache_free_bulk().
Not only build_detached_freelist() but also slab_free() need proper
cache.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
