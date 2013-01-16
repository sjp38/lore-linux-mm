Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 1B4646B0062
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 00:34:06 -0500 (EST)
Message-ID: <50F63BEE.8040506@cn.fujitsu.com>
Date: Wed, 16 Jan 2013 13:34:38 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH V2] mm/slab: add a leak decoder callback
References: <1358305393-3507-1-git-send-email-bo.li.liu@oracle.com>
In-Reply-To: <1358305393-3507-1-git-send-email-bo.li.liu@oracle.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Bo <bo.li.liu@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, zab@zabbo.net, cl@linux.com, penberg@kernel.org

On wed, 16 Jan 2013 11:03:13 +0800, Liu Bo wrote:
> This adds a leak decoder callback so that slab destruction
> can use to generate debugging output for the allocated objects.
> 
> Callers like btrfs are using their own leak tracking which will
> manage allocated objects in a list(or something else), this does
> indeed the same thing as what slab does.  So adding a callback
> for leak tracking can avoid this as well as runtime overhead.

If the slab is merged with the other one, this patch can work well?

Thanks
Miao

> (The idea is from Zach Brown <zab@zabbo.net>.)
> 
> Signed-off-by: Liu Bo <bo.li.liu@oracle.com>
> ---
> v2: add a wrapper API for slab destruction to make decoder only
> work in particular path.
> 
>  fs/btrfs/extent_io.c     |   26 ++++++++++++++++++++++++--
>  fs/btrfs/extent_map.c    |   13 ++++++++++++-
>  include/linux/slab.h     |    2 ++
>  include/linux/slab_def.h |    1 +
>  include/linux/slub_def.h |    1 +
>  mm/slab_common.c         |   17 ++++++++++++++++-
>  mm/slub.c                |    2 ++
>  7 files changed, 58 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
> index bcc8dff..355c7fc 100644
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -63,6 +63,26 @@ tree_fs_info(struct extent_io_tree *tree)
>  	return btrfs_sb(tree->mapping->host->i_sb);
>  }
>  
> +static void extent_state_leak_decoder(void *object)
> +{
> +	struct extent_state *state = object;
> +
> +	printk(KERN_ERR "btrfs state leak: start %llu end %llu "
> +	       "state %lu in tree %p refs %d\n",
> +	       (unsigned long long)state->start,
> +	       (unsigned long long)state->end,
> +	       state->state, state->tree, atomic_read(&state->refs));
> +}
> +
> +static void extent_buffer_leak_decoder(void *object)
> +{
> +	struct extent_buffer *eb = object;
> +
> +	printk(KERN_ERR "btrfs buffer leak start %llu len %lu "
> +	       "refs %d\n", (unsigned long long)eb->start,
> +	       eb->len, atomic_read(&eb->refs));
> +}
> +
>  int __init extent_io_init(void)
>  {
>  	extent_state_cache = kmem_cache_create("btrfs_extent_state",
> @@ -115,9 +135,11 @@ void extent_io_exit(void)
>  	 */
>  	rcu_barrier();
>  	if (extent_state_cache)
> -		kmem_cache_destroy(extent_state_cache);
> +		kmem_cache_destroy_decoder(extent_state_cache,
> +					   extent_state_leak_decoder);
>  	if (extent_buffer_cache)
> -		kmem_cache_destroy(extent_buffer_cache);
> +		kmem_cache_destroy_decoder(extent_buffer_cache,
> +					   extent_buffer_leak_decoder);
>  }
>  
>  void extent_io_tree_init(struct extent_io_tree *tree,
> diff --git a/fs/btrfs/extent_map.c b/fs/btrfs/extent_map.c
> index f359e4c..bccba3d 100644
> --- a/fs/btrfs/extent_map.c
> +++ b/fs/btrfs/extent_map.c
> @@ -16,6 +16,16 @@ static LIST_HEAD(emaps);
>  static DEFINE_SPINLOCK(map_leak_lock);
>  #endif
>  
> +static void extent_map_leak_decoder(void *object)
> +{
> +	struct extent_map *em = object;
> +
> +	printk(KERN_ERR "btrfs ext map leak: start %llu len %llu block %llu "
> +	       "flags %lu refs %d in tree %d compress %d\n",
> +	       em->start, em->len, em->block_start, em->flags,
> +	       atomic_read(&em->refs), em->in_tree, (int)em->compress_type);
> +}
> +
>  int __init extent_map_init(void)
>  {
>  	extent_map_cache = kmem_cache_create("btrfs_extent_map",
> @@ -39,7 +49,8 @@ void extent_map_exit(void)
>  	}
>  
>  	if (extent_map_cache)
> -		kmem_cache_destroy(extent_map_cache);
> +		kmem_cache_destroy_decoder(extent_map_cache,
> +					   extent_map_leak_decoder);
>  }
>  
>  /**
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 5d168d7..5c6a8d8 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -114,6 +114,7 @@ struct kmem_cache {
>  	const char *name;	/* Slab name for sysfs */
>  	int refcount;		/* Use counter */
>  	void (*ctor)(void *);	/* Called on object slot creation */
> +	void (*decoder)(void *);/* Called on object slot leak detection */
>  	struct list_head list;	/* List of all slab caches on the system */
>  };
>  #endif
> @@ -132,6 +133,7 @@ struct kmem_cache *
>  kmem_cache_create_memcg(struct mem_cgroup *, const char *, size_t, size_t,
>  			unsigned long, void (*)(void *), struct kmem_cache *);
>  void kmem_cache_destroy(struct kmem_cache *);
> +void kmem_cache_destroy_decoder(struct kmem_cache *, void (*)(void *));
>  int kmem_cache_shrink(struct kmem_cache *);
>  void kmem_cache_free(struct kmem_cache *, void *);
>  
> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> index 8bb6e0e..7ca8309 100644
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -48,6 +48,7 @@ struct kmem_cache {
>  
>  	/* constructor func */
>  	void (*ctor)(void *obj);
> +	void (*decoder)(void *obj);
>  
>  /* 4) cache creation/removal */
>  	const char *name;
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 9db4825..fc18af7 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -93,6 +93,7 @@ struct kmem_cache {
>  	gfp_t allocflags;	/* gfp flags to use on each alloc */
>  	int refcount;		/* Refcount for slab cache destroy */
>  	void (*ctor)(void *);
> +	void (*decoder)(void *);
>  	int inuse;		/* Offset to metadata */
>  	int align;		/* Alignment */
>  	int reserved;		/* Reserved bytes at the end of slabs */
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 3f3cd97..8c19bfd 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -193,6 +193,7 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
>  		s->object_size = s->size = size;
>  		s->align = calculate_alignment(flags, align, size);
>  		s->ctor = ctor;
> +		s->decoder = NULL;
>  
>  		if (memcg_register_cache(memcg, s, parent_cache)) {
>  			kmem_cache_free(kmem_cache, s);
> @@ -248,7 +249,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
>  }
>  EXPORT_SYMBOL(kmem_cache_create);
>  
> -void kmem_cache_destroy(struct kmem_cache *s)
> +static void __kmem_cache_destroy(struct kmem_cache *s, void (*decoder)(void *))
>  {
>  	/* Destroy all the children caches if we aren't a memcg cache */
>  	kmem_cache_destroy_memcg_children(s);
> @@ -259,6 +260,9 @@ void kmem_cache_destroy(struct kmem_cache *s)
>  	if (!s->refcount) {
>  		list_del(&s->list);
>  
> +		if (unlikely(decoder))
> +			s->decoder = decoder;
> +
>  		if (!__kmem_cache_shutdown(s)) {
>  			mutex_unlock(&slab_mutex);
>  			if (s->flags & SLAB_DESTROY_BY_RCU)
> @@ -279,8 +283,19 @@ void kmem_cache_destroy(struct kmem_cache *s)
>  	}
>  	put_online_cpus();
>  }
> +
> +void kmem_cache_destroy(struct kmem_cache *s)
> +{
> +	return __kmem_cache_destroy(s, NULL);
> +}
>  EXPORT_SYMBOL(kmem_cache_destroy);
>  
> +void kmem_cache_destroy_decoder(struct kmem_cache *s, void (*decoder)(void *))
> +{
> +	return __kmem_cache_destroy(s, decoder);
> +}
> +EXPORT_SYMBOL(kmem_cache_destroy_decoder);
> +
>  int slab_is_available(void)
>  {
>  	return slab_state >= UP;
> diff --git a/mm/slub.c b/mm/slub.c
> index ba2ca53..34b3b75 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3098,6 +3098,8 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
>  	for_each_object(p, s, addr, page->objects) {
>  
>  		if (!test_bit(slab_index(p, s, addr), map)) {
> +			if (unlikely(s->decoder))
> +				s->decoder(p);
>  			printk(KERN_ERR "INFO: Object 0x%p @offset=%tu\n",
>  							p, p - addr);
>  			print_tracking(s, p);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
