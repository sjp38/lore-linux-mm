Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 55C2E82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:25:34 -0500 (EST)
Received: by lbbes7 with SMTP id es7so39183354lbb.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:25:33 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q1si4852427lfd.98.2015.11.05.08.25.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 08:25:32 -0800 (PST)
Date: Thu, 5 Nov 2015 19:25:14 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V2 2/2] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
Message-ID: <20151105162514.GI29259@esperanza>
References: <20151105153704.1115.10475.stgit@firesoul>
 <20151105153756.1115.41409.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151105153756.1115.41409.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Thu, Nov 05, 2015 at 04:38:06PM +0100, Jesper Dangaard Brouer wrote:
> Initial implementation missed support for kmem cgroup support
> in kmem_cache_free_bulk() call, add this.
> 
> If CONFIG_MEMCG_KMEM is not enabled, the compiler should
> be smart enough to not add any asm code.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> ---
> V2: Fixes according to input from:
>  Vladimir Davydov <vdavydov@virtuozzo.com>
>  and Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
>  mm/slub.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 8e9e9b2ee6f3..bc64514ad1bb 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2890,6 +2890,9 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
>  	do {
>  		struct detached_freelist df;
>  
> +		/* Support for memcg */
> +		s = cache_from_obj(s, p[size - 1]);
> +

AFAIU all objects in the array should come from the same cache (should
they?), so it should be enough to call this only once:

diff --git a/mm/slub.c b/mm/slub.c
index 438ebf8bbab1..a6c3c058ce7c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2887,6 +2887,7 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 	if (WARN_ON(!size))
 		return;
 
+	s = cache_from_obj(s, *p);
 	do {
 		struct detached_freelist df;

Thanks,
Vladimir

>  		size = build_detached_freelist(s, size, p, &df);
>  		if (unlikely(!df.page))
>  			continue;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
