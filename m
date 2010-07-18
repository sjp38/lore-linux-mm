Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AD7FE6007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 04:14:48 -0400 (EDT)
Message-ID: <4C42B7EA.4020409@cs.helsinki.fi>
Date: Sun, 18 Jul 2010 11:14:34 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] Basic zcache functionality
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org> <1279283870-18549-3-git-send-email-ngupta@vflare.org>
In-Reply-To: <1279283870-18549-3-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nitin Gupta wrote:
> +/*
> + * Individual percpu values can go negative but the sum across all CPUs
> + * must always be positive (we store various counts). So, return sum as
> + * unsigned value.
> + */
> +static u64 zcache_get_stat(struct zcache_pool *zpool,
> +		enum zcache_pool_stats_index idx)
> +{
> +	int cpu;
> +	s64 val = 0;
> +
> +	for_each_possible_cpu(cpu) {
> +		unsigned int start;
> +		struct zcache_pool_stats_cpu *stats;
> +
> +		stats = per_cpu_ptr(zpool->stats, cpu);
> +		do {
> +			start = u64_stats_fetch_begin(&stats->syncp);
> +			val += stats->count[idx];
> +		} while (u64_stats_fetch_retry(&stats->syncp, start));

Can we use 'struct percpu_counter' for this? OTOH, the warning on top of 
include/linux/percpu_counter.h makes me think not.

> +	}
> +
> +	BUG_ON(val < 0);

BUG_ON() seems overly aggressive. How about

   if (WARN_ON(val < 0))
           return 0;

> +	return val;
> +}
> +
> +static void zcache_add_stat(struct zcache_pool *zpool,
> +		enum zcache_pool_stats_index idx, s64 val)
> +{
> +	struct zcache_pool_stats_cpu *stats;
> +
> +	preempt_disable();
> +	stats = __this_cpu_ptr(zpool->stats);
> +	u64_stats_update_begin(&stats->syncp);
> +	stats->count[idx] += val;
> +	u64_stats_update_end(&stats->syncp);
> +	preempt_enable();

What is the preempt_disable/preempt_enable trying to do here?

> +static void zcache_destroy_pool(struct zcache_pool *zpool)
> +{
> +	int i;
> +
> +	if (!zpool)
> +		return;
> +
> +	spin_lock(&zcache->pool_lock);
> +	zcache->num_pools--;
> +	for (i = 0; i < MAX_ZCACHE_POOLS; i++)
> +		if (zcache->pools[i] == zpool)
> +			break;
> +	zcache->pools[i] = NULL;
> +	spin_unlock(&zcache->pool_lock);
> +
> +	if (!RB_EMPTY_ROOT(&zpool->inode_tree)) {

Use WARN_ON here to get a stack trace?

> +		pr_warn("Memory leak detected. Freeing non-empty pool!\n");
> +		zcache_dump_stats(zpool);
> +	}
> +
> +	free_percpu(zpool->stats);
> +	kfree(zpool);
> +}
> +
> +/*
> + * Allocate a new zcache pool and set default memlimit.
> + *
> + * Returns pool_id on success, negative error code otherwise.
> + */
> +int zcache_create_pool(void)
> +{
> +	int ret;
> +	u64 memlimit;
> +	struct zcache_pool *zpool = NULL;
> +
> +	spin_lock(&zcache->pool_lock);
> +	if (zcache->num_pools == MAX_ZCACHE_POOLS) {
> +		spin_unlock(&zcache->pool_lock);
> +		pr_info("Cannot create new pool (limit: %u)\n",
> +					MAX_ZCACHE_POOLS);
> +		ret = -EPERM;
> +		goto out;
> +	}
> +	zcache->num_pools++;
> +	spin_unlock(&zcache->pool_lock);
> +
> +	zpool = kzalloc(sizeof(*zpool), GFP_KERNEL);
> +	if (!zpool) {
> +		spin_lock(&zcache->pool_lock);
> +		zcache->num_pools--;
> +		spin_unlock(&zcache->pool_lock);
> +		ret = -ENOMEM;
> +		goto out;
> +	}

Why not kmalloc() an new struct zcache_pool object first and then take 
zcache->pool_lock() and check for MAX_ZCACHE_POOLS? That should make the 
locking little less confusing here.

> +
> +	zpool->stats = alloc_percpu(struct zcache_pool_stats_cpu);
> +	if (!zpool->stats) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	rwlock_init(&zpool->tree_lock);
> +	seqlock_init(&zpool->memlimit_lock);
> +	zpool->inode_tree = RB_ROOT;
> +
> +	memlimit = zcache_pool_default_memlimit_perc_ram *
> +				((totalram_pages << PAGE_SHIFT) / 100);
> +	memlimit &= PAGE_MASK;
> +	zcache_set_memlimit(zpool, memlimit);
> +
> +	/* Add to pool list */
> +	spin_lock(&zcache->pool_lock);
> +	for (ret = 0; ret < MAX_ZCACHE_POOLS; ret++)
> +		if (!zcache->pools[ret])
> +			break;
> +	zcache->pools[ret] = zpool;
> +	spin_unlock(&zcache->pool_lock);
> +
> +out:
> +	if (ret < 0)
> +		zcache_destroy_pool(zpool);
> +
> +	return ret;
> +}

> +/*
> + * Allocate memory for storing the given page and insert
> + * it in the given node's page tree at location 'index'.
> + *
> + * Returns 0 on success, negative error code on failure.
> + */
> +static int zcache_store_page(struct zcache_inode_rb *znode,
> +			pgoff_t index, struct page *page)
> +{
> +	int ret;
> +	unsigned long flags;
> +	struct page *zpage;
> +	void *src_data, *dest_data;
> +
> +	zpage = alloc_page(GFP_NOWAIT);
> +	if (!zpage) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +	zpage->index = index;
> +
> +	src_data = kmap_atomic(page, KM_USER0);
> +	dest_data = kmap_atomic(zpage, KM_USER1);
> +	memcpy(dest_data, src_data, PAGE_SIZE);
> +	kunmap_atomic(src_data, KM_USER0);
> +	kunmap_atomic(dest_data, KM_USER1);

copy_highpage()

> +
> +	spin_lock_irqsave(&znode->tree_lock, flags);
> +	ret = radix_tree_insert(&znode->page_tree, index, zpage);
> +	spin_unlock_irqrestore(&znode->tree_lock, flags);
> +	if (unlikely(ret))
> +		__free_page(zpage);
> +
> +out:
> +	return ret;
> +}

> +/*
> + * cleancache_ops.get_page
> + *
> + * Locates stored zcache page using <pool_id, inode_no, index>.
> + * If found, copies it to the given output page 'page' and frees
> + * zcache copy of the same.
> + *
> + * Returns 0 if requested page found, -1 otherwise.
> + */
> +static int zcache_get_page(int pool_id, ino_t inode_no,
> +			pgoff_t index, struct page *page)
> +{
> +	int ret = -1;
> +	unsigned long flags;
> +	struct page *src_page;
> +	void *src_data, *dest_data;
> +	struct zcache_inode_rb *znode;
> +	struct zcache_pool *zpool = zcache->pools[pool_id];
> +
> +	znode = zcache_find_inode(zpool, inode_no);
> +	if (!znode)
> +		goto out;
> +
> +	BUG_ON(znode->inode_no != inode_no);

Maybe use WARN_ON here and return -1?

> +
> +	spin_lock_irqsave(&znode->tree_lock, flags);
> +	src_page = radix_tree_delete(&znode->page_tree, index);
> +	if (zcache_inode_is_empty(znode))
> +		zcache_inode_isolate(znode);
> +	spin_unlock_irqrestore(&znode->tree_lock, flags);
> +
> +	kref_put(&znode->refcount, zcache_inode_release);
> +
> +	if (!src_page)
> +		goto out;
> +
> +	src_data = kmap_atomic(src_page, KM_USER0);
> +	dest_data = kmap_atomic(page, KM_USER1);
> +	memcpy(dest_data, src_data, PAGE_SIZE);
> +	kunmap_atomic(src_data, KM_USER0);
> +	kunmap_atomic(dest_data, KM_USER1);

The above sequence can be replaced with copy_highpage().

> +
> +	flush_dcache_page(page);
> +
> +	__free_page(src_page);
> +
> +	zcache_dec_stat(zpool, ZPOOL_STAT_PAGES_STORED);
> +	ret = 0; /* success */
> +
> +out:
> +	return ret;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
