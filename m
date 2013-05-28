Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id EA95F6B007B
	for <linux-mm@kvack.org>; Tue, 28 May 2013 17:59:20 -0400 (EDT)
Date: Tue, 28 May 2013 14:59:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv12 3/4] zswap: add to mm/
Message-Id: <20130528145918.acbd84df00313e527cf04d1b@linux-foundation.org>
In-Reply-To: <1369067168-12291-4-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1369067168-12291-4-git-send-email-sjenning@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, 20 May 2013 11:26:07 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:

> zswap is a thin backend for frontswap that takes pages that are in the process
> of being swapped out and attempts to compress them and store them in a
> RAM-based memory pool.  This can result in a significant I/O reduction on the
> swap device and, in the case where decompressing from RAM is faster than
> reading from the swap device, can also improve workload performance.
> 
> It also has support for evicting swap pages that are currently compressed in
> zswap to the swap device on an LRU(ish) basis. This functionality makes zswap a
> true cache in that, once the cache is full, the oldest pages can be moved out
> of zswap to the swap device so newer pages can be compressed and stored in
> zswap.
> 
> This patch adds the zswap driver to mm/
> 
> ...

Some random doodlings:

> +/*********************************
> +* zswap entry functions
> +**********************************/
> +#define ZSWAP_KMEM_CACHE_NAME "zswap_entry_cache"

I don't think this macro needs to exist - it is only used once.

> +static struct kmem_cache *zswap_entry_cache;
> +
> +static inline int zswap_entry_cache_create(void)
> +{
> +	zswap_entry_cache =
> +		kmem_cache_create(ZSWAP_KMEM_CACHE_NAME,
> +			sizeof(struct zswap_entry), 0, 0, NULL);

Could use the KMEM_CACHE() helper here?

> +	return (zswap_entry_cache == NULL);
> +}
> +
> +static inline void zswap_entry_cache_destory(void)
> +{
> +	kmem_cache_destroy(zswap_entry_cache);
> +}
> +
> +static inline struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
> +{
> +	struct zswap_entry *entry;
> +	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
> +	if (!entry)
> +		return NULL;
> +	entry->refcount = 1;
> +	return entry;
> +}
> +
> +static inline void zswap_entry_cache_free(struct zswap_entry *entry)
> +{
> +	kmem_cache_free(zswap_entry_cache, entry);
> +}
> +
> +/* caller must hold the tree lock */
> +static inline void zswap_entry_get(struct zswap_entry *entry)
> +{
> +	entry->refcount++;
> +}
> +
> +/* caller must hold the tree lock */
> +static inline int zswap_entry_put(struct zswap_entry *entry)
> +{
> +	entry->refcount--;
> +	return entry->refcount;
> +}

Don't bother with the explicit "inline".  The compiler will ignore it
and will generally DTRT anyway.

> +/*********************************
> +* rbtree functions
> +**********************************/
> +static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
> +{
> +	struct rb_node *node = root->rb_node;
> +	struct zswap_entry *entry;
> +
> +	while (node) {
> +		entry = rb_entry(node, struct zswap_entry, rbnode);
> +		if (entry->offset > offset)
> +			node = node->rb_left;
> +		else if (entry->offset < offset)
> +			node = node->rb_right;
> +		else
> +			return entry;
> +	}
> +	return NULL;
> +}
> +
> +/*
> + * In the case that a entry with the same offset is found, it a pointer to
> + * the existing entry is stored in dupentry and the function returns -EEXIST

"it a pointer"?

> +*/

Missing leading space.

> +static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *entry,
> +			struct zswap_entry **dupentry)
> +{
> +	struct rb_node **link = &root->rb_node, *parent = NULL;
> +	struct zswap_entry *myentry;
> +
> +	while (*link) {
> +		parent = *link;
> +		myentry = rb_entry(parent, struct zswap_entry, rbnode);
> +		if (myentry->offset > entry->offset)
> +			link = &(*link)->rb_left;
> +		else if (myentry->offset < entry->offset)
> +			link = &(*link)->rb_right;
> +		else {
> +			*dupentry = myentry;
> +			return -EEXIST;
> +		}
> +	}
> +	rb_link_node(&entry->rbnode, parent, link);
> +	rb_insert_color(&entry->rbnode, root);
> +	return 0;
> +}
> +
>
> ...
>
> +/*********************************
> +* helpers
> +**********************************/
> +static inline bool zswap_is_full(void)
> +{
> +	return (totalram_pages * zswap_max_pool_percent / 100 <
> +		zswap_pool_pages);
> +}

We have had issues in the past where percentage-based tunables were too
coarse on very large machines.  For example, a terabyte machine where 0
bytes is too small and 10GB is too large.

>
> ...
>
> +/*
> + * Attempts to free and entry by adding a page to the swap cache,

a/and/an/

> + * decompressing the entry data into the page, and issuing a
> + * bio write to write the page back to the swap device.
> + *
> + * This can be thought of as a "resumed writeback" of the page
> + * to the swap device.  We are basically resuming the same swap
> + * writeback path that was intercepted with the frontswap_store()
> + * in the first place.  After the page has been decompressed into
> + * the swap cache, the compressed version stored by zswap can be
> + * freed.
> + */
>
> ...
>
> +static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> +				struct page *page)
> +{
> +	struct zswap_tree *tree = zswap_trees[type];
> +	struct zswap_entry *entry;
> +	u8 *src, *dst;
> +	unsigned int dlen;
> +	int refcount, ret;
> +
> +	/* find */
> +	spin_lock(&tree->lock);
> +	entry = zswap_rb_search(&tree->rbroot, offset);
> +	if (!entry) {
> +		/* entry was written back */
> +		spin_unlock(&tree->lock);
> +		return -1;
> +	}
> +	zswap_entry_get(entry);
> +	spin_unlock(&tree->lock);
> +
> +	/* decompress */
> +	dlen = PAGE_SIZE;
> +	src = (u8 *)zbud_map(tree->pool, entry->handle) +
> +			sizeof(struct zswap_header);
> +	dst = kmap_atomic(page);
> +	ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
> +		dst, &dlen);

In all these places where the CPU alters the kmapped page: do we have
(or need) the appropriate cache flushing primitives? 
flush_dcache_page() and similar.

> +	kunmap_atomic(dst);
> +	zbud_unmap(tree->pool, entry->handle);
> +	BUG_ON(ret);
> +
> +	spin_lock(&tree->lock);
> +	refcount = zswap_entry_put(entry);
> +	if (likely(refcount)) {
> +		spin_unlock(&tree->lock);
> +		return 0;
> +	}
> +	spin_unlock(&tree->lock);
> +
> +	/*
> +	 * We don't have to unlink from the rbtree because
> +	 * zswap_writeback_entry() or zswap_frontswap_invalidate page()
> +	 * has already done this for us if we are the last reference.
> +	 */
> +	/* free */
> +
> +	zswap_free_entry(tree, entry);
> +
> +	return 0;
> +}
> +
> +/* invalidates a single page */

"invalidate" is a very vague term in Linux.  More specificity about
what actually happens to this page would be useful.

>
> ...
>
> +static struct zbud_ops zswap_zbud_ops = {
> +	.evict = zswap_writeback_entry
> +};
> +
> +/* NOTE: this is called in atomic context from swapon and must not sleep */

Actually from frontswap, and calling a subsystem's ->init handler in
atomic context is quite lame - *of course* that handler will want to
allocate memory!

Whereabouts is the offending calling code and how do we fix it?

> +static void zswap_frontswap_init(unsigned type)
> +{
> +	struct zswap_tree *tree;
> +
> +	tree = kzalloc(sizeof(struct zswap_tree), GFP_ATOMIC);
> +	if (!tree)
> +		goto err;
> +	tree->pool = zbud_create_pool(GFP_NOWAIT, &zswap_zbud_ops);
> +	if (!tree->pool)
> +		goto freetree;
> +	tree->rbroot = RB_ROOT;
> +	spin_lock_init(&tree->lock);
> +	zswap_trees[type] = tree;
> +	return;
> +
> +freetree:
> +	kfree(tree);
> +err:
> +	pr_err("alloc failed, zswap disabled for swap type %d\n", type);
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
