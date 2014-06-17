Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7275B6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 17:17:16 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so6125154pac.33
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 14:17:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id oh1si15704539pbc.149.2014.06.17.14.17.15
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 14:17:15 -0700 (PDT)
Date: Tue, 17 Jun 2014 14:17:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] slab common: Add functions for kmem_cache_node
 access
Message-Id: <20140617141713.08e290145d24ca95c487c330@linux-foundation.org>
In-Reply-To: <20140611191518.964245135@linux.com>
References: <20140611191510.082006044@linux.com>
	<20140611191518.964245135@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 11 Jun 2014 14:15:11 -0500 Christoph Lameter <cl@linux.com> wrote:

> These functions allow to eliminate repeatedly used code in both
> SLAB and SLUB and also allow for the insertion of debugging code
> that may be needed in the development process.
> 
> ...
>
> --- linux.orig/mm/slab.h	2014-06-10 14:18:11.506956436 -0500
> +++ linux/mm/slab.h	2014-06-10 14:21:51.279893231 -0500
> @@ -294,5 +294,18 @@ struct kmem_cache_node {
>  
>  };
>  
> +static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
> +{
> +	return s->node[node];
> +}
> +
> +/*
> + * Iterator over all nodes. The body will be executed for each node that has
> + * a kmem_cache_node structure allocated (which is true for all online nodes)
> + */
> +#define for_each_kmem_cache_node(__s, __node, __n) \
> +	for (__node = 0; __n = get_node(__s, __node), __node < nr_node_ids; __node++) \
> +		 if (__n)

Clueless newbs would be aided if this comment were to describe the
iterator's locking requirements.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
