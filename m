Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFC616B0069
	for <linux-mm@kvack.org>; Sat, 30 Dec 2017 01:42:49 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 33so26070845pll.9
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 22:42:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s76si7838826pgc.768.2017.12.29.22.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Dec 2017 22:42:48 -0800 (PST)
Date: Fri, 29 Dec 2017 22:42:46 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 3/8] slub: Add isolate() and migrate() methods
Message-ID: <20171230064246.GC27959@bombadil.infradead.org>
References: <20171227220636.361857279@linux.com>
 <20171227220652.402842142@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227220652.402842142@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Wed, Dec 27, 2017 at 04:06:39PM -0600, Christoph Lameter wrote:
> @@ -98,6 +98,9 @@ struct kmem_cache {
>  	gfp_t allocflags;	/* gfp flags to use on each alloc */
>  	int refcount;		/* Refcount for slab cache destroy */
>  	void (*ctor)(void *);
> +	kmem_isolate_func *isolate;
> +	kmem_migrate_func *migrate;
> +
>  	int inuse;		/* Offset to metadata */
>  	int align;		/* Alignment */
>  	int reserved;		/* Reserved bytes at the end of slabs */
[...]
> +/*
> + * kmem_cache_setup_mobility() is used to setup callbacks for a slab cache.
> + */
> +#ifdef CONFIG_SLUB
> +void kmem_cache_setup_mobility(struct kmem_cache *, kmem_isolate_func,
> +						kmem_migrate_func);
> +#else
> +static inline void kmem_cache_setup_mobility(struct kmem_cache *s,
> +	kmem_isolate_func isolate, kmem_migrate_func migrate) {}
> +#endif

Is this the right approach?  I could imagine there being more ops in
the future.  I suspect we should bite the bullet now and do:

struct kmem_cache_operations {
	void (*ctor)(void *);
	void *(*isolate)(struct kmem_cache *, void **objs, int nr);
	void (*migrate)(struct kmem_cache *, void **objs, int nr, int node,
			void *private);
};

Not sure how best to convert the existing constructor users to this scheme.
Perhaps cheat ...

- 	void (*ctor)(void *);
+	union {
+	 	void (*ctor)(void *);
+		const struct kmem_cache_operations *ops;
+	};

and use a slab flag to tell you which to use.		

> @@ -4969,6 +4987,20 @@ static ssize_t ops_show(struct kmem_cach
>  
>  	if (s->ctor)
>  		x += sprintf(buf + x, "ctor : %pS\n", s->ctor);
> +
> +	if (s->isolate) {
> +		x += sprintf(buf + x, "isolate : ");
> +		x += sprint_symbol(buf + x,
> +				(unsigned long)s->isolate);
> +		x += sprintf(buf + x, "\n");
> +	}

Here you could print the symbol of the ops vector instead of the function
pointer ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
