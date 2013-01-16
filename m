Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id C2DE56B005A
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 10:20:58 -0500 (EST)
Date: Wed, 16 Jan 2013 15:20:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH V2] mm/slab: add a leak decoder callback
In-Reply-To: <1358305393-3507-1-git-send-email-bo.li.liu@oracle.com>
Message-ID: <0000013c43f2e550-649fcc34-13c2-4e4b-81be-96d68e63cf60-000000@email.amazonses.com>
References: <1358305393-3507-1-git-send-email-bo.li.liu@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Bo <bo.li.liu@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, zab@zabbo.net, penberg@kernel.org

On Wed, 16 Jan 2013, Liu Bo wrote:

> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -93,6 +93,7 @@ struct kmem_cache {
>  	gfp_t allocflags;	/* gfp flags to use on each alloc */
>  	int refcount;		/* Refcount for slab cache destroy */
>  	void (*ctor)(void *);
> +	void (*decoder)(void *);

The field needs to be moved away from the first hot cachelines in
kmem_cache.


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

Not necessary since s is filled with zeros on allocation.

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

Now that is a bit weird since __kmem_cache_destroy now sets a field in
kmem_cache?

If a kmem_cache has a decoder field set then it is no longer mergeable.

It looks like the decoder field would have to be set on cache creation.

If we do that then the functionality could be more generic. I always
wanted to have a function that checks the object integrity as well.

The cache validation could then go through all objects and in addition to
checking the slab meta data integrity could also have the subsystem
confirm the integrity of the object.

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

Hmmm... The function is currently only used on kmem_cache_destroy but that
may change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
