Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id EB95A6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 15:53:53 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so761156pbb.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 12:53:53 -0700 (PDT)
Date: Tue, 25 Sep 2012 12:53:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch slab/next] mm, slob: fix build breakage in
 __kmalloc_node_track_caller
In-Reply-To: <1347137279-17568-4-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1209251250520.31518@chino.kir.corp.google.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com> <1347137279-17568-4-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 8 Sep 2012, Ezequiel Garcia wrote:

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
> +	return __do_kmalloc_node(size, gfp, NUMA_NO_NODE, caller);
> +}
> +
> +#ifdef CONFIG_NUMA
> +void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
> +					int node, unsigned long caller)
> +{
> +	return __do_kmalloc_node(size, gfp, node, caller);
> +}
> +#endif

This breaks Pekka's slab/next tree with this:

mm/slob.c: In function '__kmalloc_node_track_caller':
mm/slob.c:488: error: 'gfp' undeclared (first use in this function)
mm/slob.c:488: error: (Each undeclared identifier is reported only once
mm/slob.c:488: error: for each function it appears in.)


mm, slob: fix build breakage in __kmalloc_node_track_caller

"mm, slob: Add support for kmalloc_track_caller()" breaks the build 
because gfp is undeclared.  Fix it.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slob.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -482,7 +482,7 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfp, unsigned long caller)
 }
 
 #ifdef CONFIG_NUMA
-void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
+void *__kmalloc_node_track_caller(size_t size, gfp_t gfp,
 					int node, unsigned long caller)
 {
 	return __do_kmalloc_node(size, gfp, node, caller);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
