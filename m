Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id EBB284403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 03:58:14 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id 5so9773034igt.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 00:58:14 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id j33si26032497ioo.30.2016.02.05.00.58.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 00:58:14 -0800 (PST)
Date: Fri, 5 Feb 2016 02:58:13 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: support left red zone
In-Reply-To: <1454566550-28288-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1602050251020.13917@east.gentwo.org>
References: <1454566550-28288-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 4 Feb 2016, Joonsoo Kim wrote:
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -77,6 +77,7 @@ struct kmem_cache {
>  	int refcount;		/* Refcount for slab cache destroy */
>  	void (*ctor)(void *);
>  	int inuse;		/* Offset to metadata */
> +	int red_left_pad;	/* Left redzone padding size */
>  	int align;		/* Alignment */
>  	int reserved;		/* Reserved bytes at the end of slabs */

This is debugging related so its not a priority field.Please add the field
after the non debugging fields.

>
>  #include "internal.h"
>
> +#ifdef CONFIG_KASAN
> +#include "kasan/kasan.h"
> +#endif
> +
>  /*

??

> @@ -4270,9 +4337,12 @@ static void process_slab(struct loc_track *t, struct kmem_cache *s,
>  	bitmap_zero(map, page->objects);
>  	get_map(s, page, map);
>
> -	for_each_object(p, s, addr, page->objects)
> +	for_each_object(p, s, addr, page->objects) {
> +		void *object = fixup_red_left(s, p);
> +

Change for_each_object instead  to give us the right pointer?


>  		if (!test_bit(slab_index(p, s, addr), map))
> -			add_location(t, s, get_track(s, p, alloc));
> +			add_location(t, s, get_track(s, object, alloc));
> +	}
>  }
>
>  static int list_locations(struct kmem_cache *s, char *buf,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
