Date: Tue, 26 Jun 2007 01:18:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 21/26] Slab defragmentation: support dentry
 defragmentation
Message-Id: <20070626011845.bfd4efe0.akpm@linux-foundation.org>
In-Reply-To: <20070618095918.404020641@sgi.com>
References: <20070618095838.238615343@sgi.com>
	<20070618095918.404020641@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007 02:58:59 -0700 clameter@sgi.com wrote:

> get() uses the dcache lock and then works with dget_locked to obtain a
> reference to the dentry. An additional complication is that the dentry
> may be in process of being freed or it may just have been allocated.
> We add an additional flag to d_flags to be able to determined the
> status of an object.
> 
> kick() is called after get() has been used and after the slab has dropped
> all of its own locks. The dentry pruning for unused entries works in a
> straighforward way.
> 
> ...
>
> +/*
> + * Slab has dropped all the locks. Get rid of the
> + * refcount we obtained earlier and also rid of the
> + * object.
> + */
> +static void kick_dentries(struct kmem_cache *s, int nr, void **v, void *private)
> +{
> +	struct dentry *dentry;
> +	int abort = 0;
> +	int i;
> +
> +	/*
> +	 * First invalidate the dentries without holding the dcache lock
> +	 */
> +	for (i = 0; i < nr; i++) {
> +		dentry = v[i];
> +
> +		if (dentry)
> +			d_invalidate(dentry);
> +	}
> +
> +	/*
> +	 * If we are the last one holding a reference then the dentries can
> +	 * be freed. We  need the dcache_lock.
> +	 */
> +	spin_lock(&dcache_lock);
> +	for (i = 0; i < nr; i++) {
> +		dentry = v[i];
> +		if (!dentry)
> +			continue;
> +
> +		if (abort)
> +			goto put_dentry;
> +
> +		spin_lock(&dentry->d_lock);
> +		if (atomic_read(&dentry->d_count) > 1) {
> +			/*
> +			 * Reference count was increased.
> +			 * We need to abandon the freeing of
> +			 * objects.
> +			 */
> +			abort = 1;

It's unobvious why the entire shrink effort is abandoned if one busy dentry
is encountered.  Please flesh the comment out explaining this.

> +			spin_unlock(&dentry->d_lock);
> +put_dentry:
> +			spin_unlock(&dcache_lock);
> +			dput(dentry);
> +			spin_lock(&dcache_lock);
> +			continue;
> +		}
> +
> +		/* Remove from LRU */
> +		if (!list_empty(&dentry->d_lru)) {
> +			dentry_stat.nr_unused--;
> +			list_del_init(&dentry->d_lru);
> +		}
> +		/* Drop the entry */
> +		prune_one_dentry(dentry, 1);
> +	}
> +	spin_unlock(&dcache_lock);
> +
> +	/*
> +	 * dentries are freed using RCU so we need to wait until RCU
> +	 * operations arei complete
> +	 */
> +	if (!abort)
> +		synchronize_rcu();
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
