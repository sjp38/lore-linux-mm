Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1336B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 23:48:31 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id p6so962708qcv.9
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 20:48:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j8si21259507qan.55.2015.02.10.20.48.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 20:48:30 -0800 (PST)
Date: Wed, 11 Feb 2015 17:48:17 +1300
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/3] slub: Support for array operations
Message-ID: <20150211174817.44cc5562@redhat.com>
In-Reply-To: <20150210194811.902155759@linux.com>
References: <20150210194804.288708936@linux.com>
	<20150210194811.902155759@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, brouer@redhat.com


On Tue, 10 Feb 2015 13:48:06 -0600 Christoph Lameter <cl@linux.com> wrote:

> The major portions are there but there is no support yet for
> directly allocating per cpu objects. There could also be more
> sophisticated code to exploit the batch freeing.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
[...]
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
[...]
> @@ -2516,8 +2521,78 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trac
>  #endif
>  #endif
>  
> +int slab_array_alloc_from_partial(struct kmem_cache *s,
> +			size_t nr, void **p)
> +{
> +	void **end = p + nr;
> +	struct kmem_cache_node *n = get_node(s, numa_mem_id());
> +	int allocated = 0;
> +	unsigned long flags;
> +	struct page *page, *page2;
> +
> +	if (!n->nr_partial)
> +		return 0;
> +
> +
> +	spin_lock_irqsave(&n->list_lock, flags);

This is quite an expensive lock with irqsave.


> +	list_for_each_entry_safe(page, page2, &n->partial, lru) {
> +		void *freelist;
> +
> +		if (page->objects - page->inuse > end - p)
> +			/* More objects free in page than we want */
> +			break;
> +		list_del(&page->lru);
> +		slab_lock(page);

Yet another lock cost.

> +		freelist = page->freelist;
> +		page->inuse = page->objects;
> +		page->freelist = NULL;
> +		slab_unlock(page);
> +		/* Grab all available objects */
> +		while (freelist) {
> +			*p++ = freelist;
> +			freelist = get_freepointer(s, freelist);
> +			allocated++;
> +		}
> +	}
> +	spin_unlock_irqrestore(&n->list_lock, flags);
> +	return allocated;

I estimate (on my CPU) the locking cost itself is more than 32ns, plus
the irqsave (which I've also found quite expensive, alone 14ns).  Thus,
estimated 46ns.  Single elem slub fast path cost is 18-19ns. Thus 3-4
elem bulking should be enough to amortized the cost, guess we are still
good :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
