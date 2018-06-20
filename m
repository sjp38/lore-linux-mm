Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B0B786B0007
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 20:49:47 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id p91-v6so752987plb.12
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 17:49:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n59-v6sor348110plb.0.2018.06.19.17.49.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 17:49:46 -0700 (PDT)
Date: Tue, 19 Jun 2018 17:49:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: fix __kmem_cache_empty for !CONFIG_SLUB_DEBUG
In-Reply-To: <20180619213352.71740-1-shakeelb@google.com>
Message-ID: <alpine.DEB.2.21.1806191748040.25812@chino.kir.corp.google.com>
References: <20180619213352.71740-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: "Jason A . Donenfeld" <Jason@zx2c4.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Tue, 19 Jun 2018, Shakeel Butt wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index a3b8467c14af..731c02b371ae 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3673,9 +3673,23 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>  
>  bool __kmem_cache_empty(struct kmem_cache *s)
>  {
> -	int node;
> +	int cpu, node;

Nit: wouldn't cpu be unused if CONFIG_SLUB_DEBUG is disabled?

>  	struct kmem_cache_node *n;
>  
> +	/*
> +	 * slabs_node will always be 0 for !CONFIG_SLUB_DEBUG. So, manually
> +	 * check slabs for all cpus.
> +	 */
> +	if (!IS_ENABLED(CONFIG_SLUB_DEBUG)) {
> +		for_each_online_cpu(cpu) {
> +			struct kmem_cache_cpu *c;
> +
> +			c = per_cpu_ptr(s->cpu_slab, cpu);
> +			if (c->page || slub_percpu_partial(c))
> +				return false;
> +		}
> +	}
> +
>  	for_each_kmem_cache_node(s, node, n)
>  		if (n->nr_partial || slabs_node(s, node))
>  			return false;

Wouldn't it just be better to allow {inc,dec}_slabs_node() to adjust the 
nr_slabs counter instead of doing the per-cpu iteration on every shutdown?
