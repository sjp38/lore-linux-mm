Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 845A86B0254
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 15:21:52 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l68so1949829wml.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 12:21:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id il10si299271wjb.245.2016.03.09.12.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 12:21:51 -0800 (PST)
Date: Wed, 9 Mar 2016 12:21:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 7/7] mm: kasan: Initial memory quarantine
 implementation
Message-Id: <20160309122148.1250854b862349399591dabf@linux-foundation.org>
In-Reply-To: <bdd59cc00ee49b7849ad60a11c6a4704c3e4856b.1457519440.git.glider@google.com>
References: <cover.1457519440.git.glider@google.com>
	<bdd59cc00ee49b7849ad60a11c6a4704c3e4856b.1457519440.git.glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed,  9 Mar 2016 12:05:48 +0100 Alexander Potapenko <glider@google.com> wrote:

> Quarantine isolates freed objects in a separate queue. The objects are
> returned to the allocator later, which helps to detect use-after-free
> errors.

I'd like to see some more details on precisely *how* the parking of
objects in the qlists helps "detect use-after-free"?

> Freed objects are first added to per-cpu quarantine queues.
> When a cache is destroyed or memory shrinking is requested, the objects
> are moved into the global quarantine queue. Whenever a kmalloc call
> allows memory reclaiming, the oldest objects are popped out of the
> global queue until the total size of objects in quarantine is less than
> 3/4 of the maximum quarantine size (which is a fraction of installed
> physical memory).
> 
> Right now quarantine support is only enabled in SLAB allocator.
> Unification of KASAN features in SLAB and SLUB will be done later.
> 
> This patch is based on the "mm: kasan: quarantine" patch originally
> prepared by Dmitry Chernenkov.
> 

qlists look awfully like list_heads.  Some explanation of why a new
container mechanism was needed would be good to see - wht are existing
ones unsuitable?

>
> ...
>
> +void kasan_cache_shrink(struct kmem_cache *cache)
> +{
> +#ifdef CONFIG_SLAB
> +	quarantine_remove_cache(cache);
> +#endif
> +}
> +
> +void kasan_cache_destroy(struct kmem_cache *cache)
> +{
> +#ifdef CONFIG_SLAB
> +	quarantine_remove_cache(cache);
> +#endif
> +}

We could avoid th4ese ifdefs in the usual way: an empty version of
quarantine_remove_cache() if CONFIG_SLAB=n.

>
> ...
>
> @@ -493,6 +532,11 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>  	unsigned long redzone_start;
>  	unsigned long redzone_end;
>  
> +#ifdef CONFIG_SLAB
> +	if (flags & __GFP_RECLAIM)
> +		quarantine_reduce();
> +#endif

Here also.

>  	if (unlikely(object == NULL))
>  		return;
>  
> --- /dev/null
> +++ b/mm/kasan/quarantine.c
> @@ -0,0 +1,306 @@
> +/*
> + * KASAN quarantine.
> + *
> + * Author: Alexander Potapenko <glider@google.com>
> + * Copyright (C) 2016 Google, Inc.
> + *
> + * Based on code by Dmitry Chernenkov.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + *
> + */
> +
> +#include <linux/gfp.h>
> +#include <linux/hash.h>
> +#include <linux/kernel.h>
> +#include <linux/mm.h>
> +#include <linux/percpu.h>
> +#include <linux/printk.h>
> +#include <linux/shrinker.h>
> +#include <linux/slab.h>
> +#include <linux/string.h>
> +#include <linux/types.h>
> +
> +#include "../slab.h"
> +#include "kasan.h"
> +
> +/* Data structure and operations for quarantine queues. */
> +
> +/* Each queue is a signled-linked list, which also stores the total size of

tpyo

> + * objects inside of it.
> + */
> +struct qlist {
> +	void **head;
> +	void **tail;
> +	size_t bytes;
> +};
> +
> +#define QLIST_INIT { NULL, NULL, 0 }
> +
> +static inline bool empty_qlist(struct qlist *q)
> +{
> +	return !q->head;
> +}

Should be "qlist_empty()".

> +static inline void init_qlist(struct qlist *q)
> +{
> +	q->head = q->tail = NULL;
> +	q->bytes = 0;
> +}

"qlist_init()"

> +static inline void qlist_put(struct qlist *q, void **qlink, size_t size)
> +{
> +	if (unlikely(empty_qlist(q)))
> +		q->head = qlink;
> +	else
> +		*q->tail = qlink;
> +	q->tail = qlink;
> +	*qlink = NULL;
> +	q->bytes += size;
> +}
> +
> +static inline void **qlist_remove(struct qlist *q, void ***prev,
> +				 size_t size)
> +{
> +	void **qlink = *prev;
> +
> +	*prev = *qlink;
> +	if (q->tail == qlink) {
> +		if (q->head == qlink)
> +			q->tail = NULL;
> +		else
> +			q->tail = (void **)prev;
> +	}
> +	q->bytes -= size;
> +
> +	return qlink;
> +}
> +
> +static inline void qlist_move_all(struct qlist *from, struct qlist *to)
> +{
> +	if (unlikely(empty_qlist(from)))
> +		return;
> +
> +	if (empty_qlist(to)) {
> +		*to = *from;
> +		init_qlist(from);
> +		return;
> +	}
> +
> +	*to->tail = from->head;
> +	to->tail = from->tail;
> +	to->bytes += from->bytes;
> +
> +	init_qlist(from);
> +}
> +
> +static inline void qlist_move(struct qlist *from, void **last, struct qlist *to,
> +			  size_t size)
> +{
> +	if (unlikely(last == from->tail)) {
> +		qlist_move_all(from, to);
> +		return;
> +	}
> +	if (empty_qlist(to))
> +		to->head = from->head;
> +	else
> +		*to->tail = from->head;
> +	to->tail = last;
> +	from->head = *last;
> +	*last = NULL;
> +	from->bytes -= size;
> +	to->bytes += size;
> +}

The above code is a candidate for hoisting out into a generic library
facility, so let's impement it that way (ie: get the naming right).

All the inlining looks excessive, and the compiler will defeat it
anyway if it thinks that is best.

>
> ...
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
