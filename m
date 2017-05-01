Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5B46B02EE
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 22:41:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t7so39519065pgt.6
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 19:41:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g15si13172882pln.293.2017.04.30.19.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 19:41:08 -0700 (PDT)
Date: Sun, 30 Apr 2017 19:41:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/3] mm/slub: wrap cpu_slab->partial in
 CONFIG_SLUB_CPU_PARTIAL
Message-ID: <20170501024103.GI27790@bombadil.infradead.org>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
 <20170430113152.6590-3-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170430113152.6590-3-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Apr 30, 2017 at 07:31:51PM +0800, Wei Yang wrote:
> @@ -2302,7 +2302,11 @@ static bool has_cpu_slab(int cpu, void *info)
>  	struct kmem_cache *s = info;
>  	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
>  
> -	return c->page || c->partial;
> +	return c->page
> +#ifdef CONFIG_SLUB_CPU_PARTIAL
> +		|| c->partial
> +#endif
> +		;
>  }

No.  No way.  This is disgusting.

The right way to do this is to create an accessor like this:

#ifdef CONFIG_SLUB_CPU_PARTIAL
#define slub_cpu_partial(c)	((c)->partial)
#else
#define slub_cpu_partial(c)	0
#endif

And then the above becomes:

-	return c->page || c->partial;
+	return c->page || slub_cpu_partial(c);

All the other ifdefs go away, apart from these two:

> @@ -4980,6 +4990,7 @@ static ssize_t objects_partial_show(struct kmem_cache *s, char *buf)
>  }
>  SLAB_ATTR_RO(objects_partial);
>  
> +#ifdef CONFIG_SLUB_CPU_PARTIAL
>  static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
>  {
>  	int objects = 0;
> @@ -5010,6 +5021,7 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
>  	return len + sprintf(buf + len, "\n");
>  }
>  SLAB_ATTR_RO(slabs_cpu_partial);
> +#endif
>  
>  static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
>  {
> @@ -5364,7 +5376,9 @@ static struct attribute *slab_attrs[] = {
>  	&destroy_by_rcu_attr.attr,
>  	&shrink_attr.attr,
>  	&reserved_attr.attr,
> +#ifdef CONFIG_SLUB_CPU_PARTIAL
>  	&slabs_cpu_partial_attr.attr,
> +#endif
>  #ifdef CONFIG_SLUB_DEBUG
>  	&total_objects_attr.attr,
>  	&slabs_attr.attr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
