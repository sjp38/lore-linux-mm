Received: by nproxy.gmail.com with SMTP id l35so56662nfa
        for <linux-mm@kvack.org>; Thu, 26 Jan 2006 00:11:22 -0800 (PST)
Message-ID: <84144f020601260011p1e2f883fp8058eb0e2edee99f@mail.gmail.com>
Date: Thu, 26 Jan 2006 10:11:21 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 9/9] slab - Implement single mempool backing for slab allocator
In-Reply-To: <1138218024.2092.9.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060125161321.647368000@localhost.localdomain>
	 <1138218024.2092.9.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 1/25/06, Matthew Dobson <colpatch@us.ibm.com> wrote:
> -static void *kmem_getpages(kmem_cache_t *cachep, gfp_t flags, int nodeid)
> +static void *kmem_getpages(kmem_cache_t *cachep, gfp_t flags, int nodeid,
> +                          mempool_t *pool)
>  {
>         struct page *page;
>         void *addr;
>         int i;
>
>         flags |= cachep->gfpflags;
> -       page = alloc_pages_node(nodeid, flags, cachep->gfporder);
> +       /*
> +        * If this allocation request isn't backed by a memory pool, or if that
> +        * memory pool's gfporder is not the same as the cache's gfporder, fall
> +        * back to alloc_pages_node().
> +        */
> +       if (!pool || cachep->gfporder != (int)pool->pool_data)
> +               page = alloc_pages_node(nodeid, flags, cachep->gfporder);
> +       else
> +               page = mempool_alloc_node(pool, flags, nodeid);

You're not returning any pages to the pool, so the it will run out
pages at some point, no? Also, there's no guarantee the slab allocator
will give back the critical page any time soon either because it will
use it for non-critical allocations as well as soon as it becomes part
of the object cache slab lists.

                                     Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
