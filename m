Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 80E9F600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:03:19 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o38J3GtY007537
	for <linux-mm@kvack.org>; Thu, 8 Apr 2010 12:03:16 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz5.hot.corp.google.com with ESMTP id o38J2GOX031825
	for <linux-mm@kvack.org>; Thu, 8 Apr 2010 12:03:15 -0700
Received: by pzk9 with SMTP id 9so2113103pzk.19
        for <linux-mm@kvack.org>; Thu, 08 Apr 2010 12:03:13 -0700 (PDT)
Date: Thu, 8 Apr 2010 12:03:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: __kmalloc_node_track_caller should trace
 kmalloc_large_node case
In-Reply-To: <1270718804-27268-1-git-send-email-dfeng@redhat.com>
Message-ID: <alpine.DEB.2.00.1004081202570.21040@chino.kir.corp.google.com>
References: <1270718804-27268-1-git-send-email-dfeng@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Xiaotian Feng <dfeng@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Ingo Molnar <mingo@elte.hu>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010, Xiaotian Feng wrote:

> commit 94b528d (kmemtrace: SLUB hooks for caller-tracking functions)
> missed tracing kmalloc_large_node in __kmalloc_node_track_caller. We
> should trace it same as __kmalloc_node.
> 
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Vegard Nossum <vegard.nossum@gmail.com>
> ---
>  mm/slub.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index b364844..a3a5a18 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3335,8 +3335,15 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
>  	struct kmem_cache *s;
>  	void *ret;
>  
> -	if (unlikely(size > SLUB_MAX_SIZE))
> -		return kmalloc_large_node(size, gfpflags, node);
> +	if (unlikely(size > SLUB_MAX_SIZE)) {
> +		ret = kmalloc_large_node(size, gfpflags, node);
> +
> +		trace_kmalloc_node(caller, ret,
> +				   size, PAGE_SIZE << get_order(size),
> +				   gfpflags, node);
> +
> +		return ret;
> +	}
>  
>  	s = get_slab(size, gfpflags);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
