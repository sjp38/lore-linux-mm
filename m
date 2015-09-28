Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C71316B0254
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 10:53:18 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so79753751pab.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 07:53:18 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ud7si29039781pab.185.2015.09.28.07.53.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 07:53:18 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so180426435pac.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 07:53:17 -0700 (PDT)
Subject: Re: [PATCH 7/7] slub: do prefetching in kmem_cache_alloc_bulk()
References: <20150928122444.15409.10498.stgit@canyon>
 <20150928122639.15409.21583.stgit@canyon>
From: Alexander Duyck <alexander.duyck@gmail.com>
Message-ID: <5609545C.4010807@gmail.com>
Date: Mon, 28 Sep 2015 07:53:16 -0700
MIME-Version: 1.0
In-Reply-To: <20150928122639.15409.21583.stgit@canyon>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 09/28/2015 05:26 AM, Jesper Dangaard Brouer wrote:
> For practical use-cases it is beneficial to prefetch the next freelist
> object in bulk allocation loop.
>
> Micro benchmarking show approx 1 cycle change:
>
> bulk -  prev-patch     -  this patch
>     1 -  49 cycles(tsc) - 49 cycles(tsc) - increase in cycles:0
>     2 -  30 cycles(tsc) - 31 cycles(tsc) - increase in cycles:1
>     3 -  23 cycles(tsc) - 25 cycles(tsc) - increase in cycles:2
>     4 -  20 cycles(tsc) - 22 cycles(tsc) - increase in cycles:2
>     8 -  18 cycles(tsc) - 19 cycles(tsc) - increase in cycles:1
>    16 -  17 cycles(tsc) - 18 cycles(tsc) - increase in cycles:1
>    30 -  18 cycles(tsc) - 17 cycles(tsc) - increase in cycles:-1
>    32 -  18 cycles(tsc) - 19 cycles(tsc) - increase in cycles:1
>    34 -  23 cycles(tsc) - 24 cycles(tsc) - increase in cycles:1
>    48 -  21 cycles(tsc) - 22 cycles(tsc) - increase in cycles:1
>    64 -  20 cycles(tsc) - 21 cycles(tsc) - increase in cycles:1
>   128 -  27 cycles(tsc) - 27 cycles(tsc) - increase in cycles:0
>   158 -  30 cycles(tsc) - 30 cycles(tsc) - increase in cycles:0
>   250 -  37 cycles(tsc) - 37 cycles(tsc) - increase in cycles:0
>
> Note, benchmark done with slab_nomerge to keep it stable enough
> for accurate comparison.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>   mm/slub.c |    2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index c25717ab3b5a..5af75a618b91 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2951,6 +2951,7 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
>   				goto error;
>   
>   			c = this_cpu_ptr(s->cpu_slab);
> +			prefetch_freepointer(s, c->freelist);
>   			continue; /* goto for-loop */
>   		}
>   
> @@ -2960,6 +2961,7 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
>   			goto error;
>   
>   		c->freelist = get_freepointer(s, object);
> +		prefetch_freepointer(s, c->freelist);
>   		p[i] = object;
>   
>   		/* kmem_cache debug support */
>

I can see the prefetch in the last item case being possibly useful since 
you have time between when you call the prefetch and when you are 
accessing the next object.  However, is there any actual benefit to 
prefetching inside the loop itself?  Based on your data above it doesn't 
seem like that is the case since you are now adding one additional cycle 
to the allocation and I am not seeing any actual gain reported here.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
