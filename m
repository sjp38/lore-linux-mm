Date: Fri, 10 Aug 2007 00:40:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB: Fix dynamic dma kmalloc cache creation
Message-Id: <20070810004059.8aa2aadb.akpm@linux-foundation.org>
In-Reply-To: <200708100559.l7A5x3r2019930@hera.kernel.org>
References: <200708100559.l7A5x3r2019930@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Aug 2007 05:59:03 GMT Linux Kernel Mailing List <linux-kernel@vger.kernel.org> wrote:

> Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1ceef40249f21eceabf8633934d94962e7d8e1d7
> Commit:     1ceef40249f21eceabf8633934d94962e7d8e1d7
> Parent:     fcda3d89bf1366f6801447eab2d8a75ac5b9c4ce
> Author:     Christoph Lameter <clameter@sgi.com>
> AuthorDate: Tue Aug 7 15:11:48 2007 -0700
> Committer:  Christoph Lameter <clameter@sgi.com>
> CommitDate: Thu Aug 9 21:57:16 2007 -0700
> 
>     SLUB: Fix dynamic dma kmalloc cache creation
>     
>     The dynamic dma kmalloc creation can run into trouble if a
>     GFP_ATOMIC allocation is the first one performed for a certain size
>     of dma kmalloc slab.
>     
>     - Move the adding of the slab to sysfs into a workqueue
>       (sysfs does GFP_KERNEL allocations)
>     - Do not call kmem_cache_destroy() (uses slub_lock)
>     - Only acquire the slub_lock once and--if we cannot wait--do a trylock.
>     
>       This introduces a slight risk of the first kmalloc(x, GFP_DMA|GFP_ATOMIC)
>       for a range of sizes failing due to another process holding the slub_lock.
>       However, we only need to acquire the spinlock once in order to establish
>       each power of two DMA kmalloc cache. The possible conflict is with the
>       slub_lock taken during slab management actions (create / remove slab cache).
>     
>       It is rather typical that a driver will first fill its buffers using
>       GFP_KERNEL allocations which will wait until the slub_lock can be acquired.
>       Drivers will also create its slab caches first outside of an atomic
>       context before starting to use atomic kmalloc from an interrupt context.
>     
>       If there are any failures then they will occur early after boot or when
>       loading of multiple drivers concurrently. Drivers can already accomodate
>       failures of GFP_ATOMIC for other reasons. Retries will then create the slab.
>     

Well that was fairly foul.  What was wrong wih turning slub_lock into a
spinlock?

>  static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
>  {
>  	struct kmem_cache *s;
> -	struct kmem_cache *x;
>  	char *text;
>  	size_t realsize;
>  
> @@ -2289,22 +2306,36 @@ static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
>  		return s;
>  
>  	/* Dynamically create dma cache */
> -	x = kmalloc(kmem_size, flags & ~SLUB_DMA);
> -	if (!x)
> -		panic("Unable to allocate memory for dma cache\n");
> +	if (flags & __GFP_WAIT)
> +		down_write(&slub_lock);
> +	else {
> +		if (!down_write_trylock(&slub_lock))
> +			goto out;
> +	}
> +
> +	if (kmalloc_caches_dma[index])
> +		goto unlock_out;
>  
>  	realsize = kmalloc_caches[index].objsize;
> -	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
> -			(unsigned int)realsize);
> -	s = create_kmalloc_cache(x, text, realsize, flags);
> -	down_write(&slub_lock);
> -	if (!kmalloc_caches_dma[index]) {
> -		kmalloc_caches_dma[index] = s;
> -		up_write(&slub_lock);
> -		return s;
> +	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d", (unsigned int)realsize),
> +	s = kmalloc(kmem_size, flags & ~SLUB_DMA);
> +
> +	if (!s || !text || !kmem_cache_open(s, flags, text,
> +			realsize, ARCH_KMALLOC_MINALIGN,
> +			SLAB_CACHE_DMA|__SYSFS_ADD_DEFERRED, NULL)) {
> +		kfree(s);
> +		kfree(text);
> +		goto unlock_out;
>  	}
> +
> +	list_add(&s->list, &slab_caches);
> +	kmalloc_caches_dma[index] = s;
> +
> +	schedule_work(&sysfs_add_work);

sysfs_add_work could be already pending, or running.  boom.

> +unlock_out:
>  	up_write(&slub_lock);
> -	kmem_cache_destroy(s);
> +out:
>  	return kmalloc_caches_dma[index];
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
