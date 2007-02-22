Subject: Re: SLUB: The unqueued Slab allocator
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 22 Feb 2007 09:34:34 +0100
Message-Id: <1172133274.6374.12.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-02-21 at 23:00 -0800, Christoph Lameter wrote:

> +/*
> + * Lock order:
> + *   1. slab_lock(page)
> + *   2. slab->list_lock
> + *

That seems to contradict this:

> +/*
> + * Lock page and remove it from the partial list
> + *
> + * Must hold list_lock
> + */
> +static __always_inline int lock_and_del_slab(struct kmem_cache *s,
> +						struct page *page)
> +{
> +	if (slab_trylock(page)) {
> +		list_del(&page->lru);
> +		s->nr_partial--;
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * Get a partial page, lock it and return it.
> + */
> +#ifdef CONFIG_NUMA
> +static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
> +{
> +	struct page *page;
> +	int searchnode = (node == -1) ? numa_node_id() : node;
> +
> +	if (!s->nr_partial)
> +		return NULL;
> +
> +	spin_lock(&s->list_lock);
> +	/*
> +	 * Search for slab on the right node
> +	 */
> +	list_for_each_entry(page, &s->partial, lru)
> +		if (likely(page_to_nid(page) == searchnode) &&
> +			lock_and_del_slab(s, page))
> +				goto out;
> +
> +	if (likely(!(flags & __GFP_THISNODE))) {
> +		/*
> +		 * We can fall back to any other node in order to
> +		 * reduce the size of the partial list.
> +		 */
> +		list_for_each_entry(page, &s->partial, lru)
> +			if (likely(lock_and_del_slab(s, page)))
> +				goto out;
> +	}
> +
> +	/* Nothing found */
> +	page = NULL;
> +out:
> +	spin_unlock(&s->list_lock);
> +	return page;
> +}
> +#else
> +static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
> +{
> +	struct page *page;
> +
> +	/*
> +	 * Racy check. If we mistakenly see no partial slabs then we
> +	 * just allocate an empty slab.
> +	 */
> +	if (!s->nr_partial)
> +		return NULL;
> +
> +	spin_lock(&s->list_lock);
> +	list_for_each_entry(page, &s->partial, lru)
> +		if (likely(lock_and_del_slab(s, page)))
> +			goto out;
> +
> +	/* No slab or all slabs busy */
> +	page = NULL;
> +out:
> +	spin_unlock(&s->list_lock);
> +	return page;
> +}
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
