Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 160786B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 04:04:07 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id e128so117349827pfe.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 01:04:07 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id u6si40059787pfa.186.2016.04.04.01.04.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 01:04:05 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0O530146WNQSFZA0@mailout1.samsung.com> for linux-mm@kvack.org;
 Mon, 04 Apr 2016 17:04:04 +0900 (KST)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: quoted-printable
Subject: Re: [PATCH v3 12/16] zsmalloc: zs_compact refactoring
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-13-git-send-email-minchan@kernel.org>
From: Chulmin Kim <cmlaika.kim@samsung.com>
Message-id: <57022000.9030705@samsung.com>
Date: Mon, 04 Apr 2016 17:04:16 +0900
In-reply-to: <1459321935-3655-13-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2016=EB=85=84 03=EC=9B=94 30=EC=9D=BC 16:12, Minchan Kim wrote:
> Currently, we rely on class->lock to prevent zspage destruction.
> It was okay until now because the critical section is short but
> with run-time migration, it could be long so class->lock is not
> a good apporach any more.
>
> So, this patch introduces [un]freeze_zspage functions which
> freeze allocated objects in the zspage with pinning tag so
> user cannot free using object. With those functions, this patch
> redesign compaction.
>
> Those functions will be used for implementing zspage runtime
> migrations, too.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   mm/zsmalloc.c | 393 ++++++++++++++++++++++++++++++++++++++--------------------
>   1 file changed, 257 insertions(+), 136 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index b11dcd718502..ac8ca7b10720 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -922,6 +922,13 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
>   		return *(unsigned long *)obj;
>   }
>
> +static inline int testpin_tag(unsigned long handle)
> +{
> +	unsigned long *ptr =3D (unsigned long *)handle;
> +
> +	return test_bit(HANDLE_PIN_BIT, ptr);
> +}
> +
>   static inline int trypin_tag(unsigned long handle)
>   {
>   	unsigned long *ptr =3D (unsigned long *)handle;
> @@ -949,8 +956,7 @@ static void reset_page(struct page *page)
>   	page->freelist =3D NULL;
>   }
>
> -static void free_zspage(struct zs_pool *pool, struct size_class *class,
> -			struct page *first_page)
> +static void free_zspage(struct zs_pool *pool, struct page *first_page)
>   {
>   	struct page *nextp, *tmp, *head_extra;
>
> @@ -973,11 +979,6 @@ static void free_zspage(struct zs_pool *pool, struct size_class *class,
>   	}
>   	reset_page(head_extra);
>   	__free_page(head_extra);
> -
> -	zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
> -			class->size, class->pages_per_zspage));
> -	atomic_long_sub(class->pages_per_zspage,
> -				&pool->pages_allocated);
>   }
>
>   /* Initialize a newly allocated zspage */
> @@ -1325,6 +1326,11 @@ static bool zspage_full(struct size_class *class, struct page *first_page)
>   	return get_zspage_inuse(first_page) =3D=3D class->objs_per_zspage;
>   }
>
> +static bool zspage_empty(struct size_class *class, struct page *first_page)
> +{
> +	return get_zspage_inuse(first_page) =3D=3D 0;
> +}
> +
>   unsigned long zs_get_total_pages(struct zs_pool *pool)
>   {
>   	return atomic_long_read(&pool->pages_allocated);
> @@ -1455,7 +1461,6 @@ static unsigned long obj_malloc(struct size_class *class,
>   		set_page_private(first_page, handle | OBJ_ALLOCATED_TAG);
>   	kunmap_atomic(vaddr);
>   	mod_zspage_inuse(first_page, 1);
> -	zs_stat_inc(class, OBJ_USED, 1);
>
>   	obj =3D location_to_obj(m_page, obj);
>
> @@ -1510,6 +1515,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>   	}
>
>   	obj =3D obj_malloc(class, first_page, handle);
> +	zs_stat_inc(class, OBJ_USED, 1);
>   	/* Now move the zspage to another fullness group, if required */
>   	fix_fullness_group(class, first_page);
>   	record_obj(handle, obj);
> @@ -1540,7 +1546,6 @@ static void obj_free(struct size_class *class, unsigned long obj)
>   	kunmap_atomic(vaddr);
>   	set_freeobj(first_page, f_objidx);
>   	mod_zspage_inuse(first_page, -1);
> -	zs_stat_dec(class, OBJ_USED, 1);
>   }
>
>   void zs_free(struct zs_pool *pool, unsigned long handle)
> @@ -1564,10 +1569,19 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
>
>   	spin_lock(&class->lock);
>   	obj_free(class, obj);
> +	zs_stat_dec(class, OBJ_USED, 1);
>   	fullness =3D fix_fullness_group(class, first_page);
> -	if (fullness =3D=3D ZS_EMPTY)
> -		free_zspage(pool, class, first_page);
> +	if (fullness =3D=3D ZS_EMPTY) {
> +		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
> +				class->size, class->pages_per_zspage));
> +		spin_unlock(&class->lock);
> +		atomic_long_sub(class->pages_per_zspage,
> +					&pool->pages_allocated);
> +		free_zspage(pool, first_page);
> +		goto out;
> +	}
>   	spin_unlock(&class->lock);
> +out:
>   	unpin_tag(handle);
>
>   	free_handle(pool, handle);
> @@ -1637,127 +1651,66 @@ static void zs_object_copy(struct size_class *class, unsigned long dst,
>   	kunmap_atomic(s_addr);
>   }
>
> -/*
> - * Find alloced object in zspage from index object and
> - * return handle.
> - */
> -static unsigned long find_alloced_obj(struct size_class *class,
> -					struct page *page, int index)
> +static unsigned long handle_from_obj(struct size_class *class,
> +				struct page *first_page, int obj_idx)
>   {
> -	unsigned long head;
> -	int offset =3D 0;
> -	unsigned long handle =3D 0;
> -	void *addr =3D kmap_atomic(page);
> -
> -	if (!is_first_page(page))
> -		offset =3D page->index;
> -	offset +=3D class->size * index;
> -
> -	while (offset < PAGE_SIZE) {
> -		head =3D obj_to_head(class, page, addr + offset);
> -		if (head & OBJ_ALLOCATED_TAG) {
> -			handle =3D head & ~OBJ_ALLOCATED_TAG;
> -			if (trypin_tag(handle))
> -				break;
> -			handle =3D 0;
> -		}
> +	struct page *page;
> +	unsigned long offset_in_page;
> +	void *addr;
> +	unsigned long head, handle =3D 0;
>
> -		offset +=3D class->size;
> -		index++;
> -	}
> +	objidx_to_page_and_offset(class, first_page, obj_idx,
> +			&page, &offset_in_page);
>
> +	addr =3D kmap_atomic(page);
> +	head =3D obj_to_head(class, page, addr + offset_in_page);
> +	if (head & OBJ_ALLOCATED_TAG)
> +		handle =3D head & ~OBJ_ALLOCATED_TAG;
>   	kunmap_atomic(addr);
> +
>   	return handle;
>   }
>
> -struct zs_compact_control {
> -	/* Source page for migration which could be a subpage of zspage. */
> -	struct page *s_page;
> -	/* Destination page for migration which should be a first page
> -	 * of zspage. */
> -	struct page *d_page;
> -	 /* Starting object index within @s_page which used for live object
> -	  * in the subpage. */
> -	int index;
> -};
> -
> -static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
> -				struct zs_compact_control *cc)
> +static int migrate_zspage(struct size_class *class, struct page *dst_page,
> +				struct page *src_page)
>   {
> -	unsigned long used_obj, free_obj;
>   	unsigned long handle;
> -	struct page *s_page =3D cc->s_page;
> -	struct page *d_page =3D cc->d_page;
> -	unsigned long index =3D cc->index;
> -	int ret =3D 0;
> +	unsigned long old_obj, new_obj;
> +	int i;
> +	int nr_migrated =3D 0;
>
> -	while (1) {
> -		handle =3D find_alloced_obj(class, s_page, index);
> -		if (!handle) {
> -			s_page =3D get_next_page(s_page);
> -			if (!s_page)
> -				break;
> -			index =3D 0;
> +	for (i =3D 0; i < class->objs_per_zspage; i++) {
> +		handle =3D handle_from_obj(class, src_page, i);
> +		if (!handle)
>   			continue;
> -		}
> -
> -		/* Stop if there is no more space */
> -		if (zspage_full(class, d_page)) {
> -			unpin_tag(handle);
> -			ret =3D -ENOMEM;
> +		if (zspage_full(class, dst_page))
>   			break;
> -		}
> -
> -		used_obj =3D handle_to_obj(handle);
> -		free_obj =3D obj_malloc(class, d_page, handle);
> -		zs_object_copy(class, free_obj, used_obj);
> -		index++;
> +		old_obj =3D handle_to_obj(handle);
> +		new_obj =3D obj_malloc(class, dst_page, handle);
> +		zs_object_copy(class, new_obj, old_obj);
> +		nr_migrated++;
>   		/*
>   		 * record_obj updates handle's value to free_obj and it will
>   		 * invalidate lock bit(ie, HANDLE_PIN_BIT) of handle, which
>   		 * breaks synchronization using pin_tag(e,g, zs_free) so
>   		 * let's keep the lock bit.
>   		 */
> -		free_obj |=3D BIT(HANDLE_PIN_BIT);
> -		record_obj(handle, free_obj);
> -		unpin_tag(handle);
> -		obj_free(class, used_obj);
> +		new_obj |=3D BIT(HANDLE_PIN_BIT);
> +		record_obj(handle, new_obj);
> +		obj_free(class, old_obj);
>   	}
> -
> -	/* Remember last position in this iteration */
> -	cc->s_page =3D s_page;
> -	cc->index =3D index;
> -
> -	return ret;
> -}
> -
> -static struct page *isolate_target_page(struct size_class *class)
> -{
> -	int i;
> -	struct page *page;
> -
> -	for (i =3D 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
> -		page =3D class->fullness_list[i];
> -		if (page) {
> -			remove_zspage(class, i, page);
> -			break;
> -		}
> -	}
> -
> -	return page;
> +	return nr_migrated;
>   }
>
>   /*
>    * putback_zspage - add @first_page into right class's fullness list
> - * @pool: target pool
>    * @class: destination class
>    * @first_page: target page
>    *
>    * Return @first_page's updated fullness_group
>    */
> -static enum fullness_group putback_zspage(struct zs_pool *pool,
> -			struct size_class *class,
> -			struct page *first_page)
> +static enum fullness_group putback_zspage(struct size_class *class,
> +					struct page *first_page)
>   {
>   	enum fullness_group fullness;
>
> @@ -1768,17 +1721,155 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
>   	return fullness;
>   }
>
> +/*
> + * freeze_zspage - freeze all objects in a zspage
> + * @class: size class of the page
> + * @first_page: first page of zspage
> + *
> + * Freeze all allocated objects in a zspage so objects couldn't be
> + * freed until unfreeze objects. It should be called under class->lock.
> + *
> + * RETURNS:
> + * the number of pinned objects
> + */
> +static int freeze_zspage(struct size_class *class, struct page *first_page)
> +{
> +	unsigned long obj_idx;
> +	struct page *obj_page;
> +	unsigned long offset;
> +	void *addr;
> +	int nr_freeze =3D 0;
> +
> +	for (obj_idx =3D 0; obj_idx < class->objs_per_zspage; obj_idx++) {
> +		unsigned long head;
> +
> +		objidx_to_page_and_offset(class, first_page, obj_idx,
> +					&obj_page, &offset);
> +		addr =3D kmap_atomic(obj_page);
> +		head =3D obj_to_head(class, obj_page, addr + offset);
> +		if (head & OBJ_ALLOCATED_TAG) {
> +			unsigned long handle =3D head & ~OBJ_ALLOCATED_TAG;
> +
> +			if (!trypin_tag(handle)) {
> +				kunmap_atomic(addr);
> +				break;
> +			}
> +			nr_freeze++;
> +		}
> +		kunmap_atomic(addr);
> +	}
> +
> +	return nr_freeze;
> +}
> +
> +/*
> + * unfreeze_page - unfreeze objects freezed by freeze_zspage in a zspage
> + * @class: size class of the page
> + * @first_page: freezed zspage to unfreeze
> + * @nr_obj: the number of objects to unfreeze
> + *
> + * unfreeze objects in a zspage.
> + */
> +static void unfreeze_zspage(struct size_class *class, struct page *first_page,
> +			int nr_obj)
> +{
> +	unsigned long obj_idx;
> +	struct page *obj_page;
> +	unsigned long offset;
> +	void *addr;
> +	int nr_unfreeze =3D 0;
> +
> +	for (obj_idx =3D 0; obj_idx < class->objs_per_zspage &&
> +			nr_unfreeze < nr_obj; obj_idx++) {
> +		unsigned long head;
> +
> +		objidx_to_page_and_offset(class, first_page, obj_idx,
> +					&obj_page, &offset);
> +		addr =3D kmap_atomic(obj_page);
> +		head =3D obj_to_head(class, obj_page, addr + offset);
> +		if (head & OBJ_ALLOCATED_TAG) {
> +			unsigned long handle =3D head & ~OBJ_ALLOCATED_TAG;
> +
> +			VM_BUG_ON(!testpin_tag(handle));
> +			unpin_tag(handle);
> +			nr_unfreeze++;
> +		}
> +		kunmap_atomic(addr);
> +	}
> +}
> +
> +/*
> + * isolate_source_page - isolate a zspage for migration source
> + * @class: size class of zspage for isolation
> + *
> + * Returns a zspage which are isolated from list so anyone can
> + * allocate a object from that page. As well, freeze all objects
> + * allocated in the zspage so anyone cannot access that objects
> + * (e.g., zs_map_object, zs_free).
> + */
>   static struct page *isolate_source_page(struct size_class *class)
>   {
>   	int i;
>   	struct page *page =3D NULL;
>
>   	for (i =3D ZS_ALMOST_EMPTY; i >=3D ZS_ALMOST_FULL; i--) {
> +		int inuse, freezed;
> +
>   		page =3D class->fullness_list[i];
>   		if (!page)
>   			continue;
>
>   		remove_zspage(class, i, page);
> +
> +		inuse =3D get_zspage_inuse(page);
> +		freezed =3D freeze_zspage(class, page);
> +
> +		if (inuse !=3D freezed) {
> +			unfreeze_zspage(class, page, freezed);
> +			putback_zspage(class, page);
> +			page =3D NULL;
> +			continue;
> +		}
> +
> +		break;
> +	}
> +
> +	return page;
> +}
> +
> +/*
> + * isolate_target_page - isolate a zspage for migration target
> + * @class: size class of zspage for isolation
> + *
> + * Returns a zspage which are isolated from list so anyone can
> + * allocate a object from that page. As well, freeze all objects
> + * allocated in the zspage so anyone cannot access that objects
> + * (e.g., zs_map_object, zs_free).
> + */
> +static struct page *isolate_target_page(struct size_class *class)
> +{
> +	int i;
> +	struct page *page;
> +
> +	for (i =3D 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
> +		int inuse, freezed;
> +
> +		page =3D class->fullness_list[i];
> +		if (!page)
> +			continue;
> +
> +		remove_zspage(class, i, page);
> +
> +		inuse =3D get_zspage_inuse(page);
> +		freezed =3D freeze_zspage(class, page);
> +
> +		if (inuse !=3D freezed) {
> +			unfreeze_zspage(class, page, freezed);
> +			putback_zspage(class, page);
> +			page =3D NULL;
> +			continue;
> +		}
> +
>   		break;
>   	}
>
> @@ -1793,9 +1884,11 @@ static struct page *isolate_source_page(struct size_class *class)
>   static unsigned long zs_can_compact(struct size_class *class)
>   {
>   	unsigned long obj_wasted;
> +	unsigned long obj_allocated, obj_used;
>
> -	obj_wasted =3D zs_stat_get(class, OBJ_ALLOCATED) -
> -		zs_stat_get(class, OBJ_USED);
> +	obj_allocated =3D zs_stat_get(class, OBJ_ALLOCATED);
> +	obj_used =3D zs_stat_get(class, OBJ_USED);
> +	obj_wasted =3D obj_allocated - obj_used;
>
>   	obj_wasted /=3D get_maxobj_per_zspage(class->size,
>   			class->pages_per_zspage);
> @@ -1805,53 +1898,81 @@ static unsigned long zs_can_compact(struct size_class *class)
>
>   static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>   {
> -	struct zs_compact_control cc;
> -	struct page *src_page;
> +	struct page *src_page =3D NULL;
>   	struct page *dst_page =3D NULL;
>
> -	spin_lock(&class->lock);
> -	while ((src_page =3D isolate_source_page(class))) {
> +	while (1) {
> +		int nr_migrated;
>
> -		if (!zs_can_compact(class))
> +		spin_lock(&class->lock);
> +		if (!zs_can_compact(class)) {
> +			spin_unlock(&class->lock);
>   			break;
> +		}
>
> -		cc.index =3D 0;
> -		cc.s_page =3D src_page;
> +		/*
> +		 * Isolate source page and freeze all objects in a zspage
> +		 * to prevent zspage destroying.
> +		 */
> +		if (!src_page) {
> +			src_page =3D isolate_source_page(class);
> +			if (!src_page) {
> +				spin_unlock(&class->lock);
> +				break;
> +			}
> +		}
>
> -		while ((dst_page =3D isolate_target_page(class))) {
> -			cc.d_page =3D dst_page;
> -			/*
> -			 * If there is no more space in dst_page, resched
> -			 * and see if anyone had allocated another zspage.
> -			 */
> -			if (!migrate_zspage(pool, class, &cc))
> +		/* Isolate target page and freeze all objects in the zspage */
> +		if (!dst_page) {
> +			dst_page =3D isolate_target_page(class);
> +			if (!dst_page) {
> +				spin_unlock(&class->lock);
>   				break;
> +			}
> +		}
> +		spin_unlock(&class->lock);

(Sorry to delete individual recipients due to my compliance issues.)

Hello, Minchan.


Is it safe to unlock=3F


(I assume that the system has 2 cores
and a swap device is using zsmalloc pool.)
If a zs compact context scheduled out after this "spin_unlock" line,


    CPU A (Swap In)                CPU B (zs_free by process killed)
---------------------           -------------------------
                                 ...
                                 spin_lock(&si->lock)
                                 ...
                                # assume it is pinned by zs_compact context.
                                 pin_tag(handle) --> block

...
spin_lock(&si->lock) --> block


I think CPU A and CPU B may not be released forever.
Am I missing something=3F

Thanks.
Chulmin


> +
> +		nr_migrated =3D migrate_zspage(class, dst_page, src_page);
>
> -			VM_BUG_ON_PAGE(putback_zspage(pool, class,
> -				dst_page) =3D=3D ZS_EMPTY, dst_page);
> +		if (zspage_full(class, dst_page)) {
> +			spin_lock(&class->lock);
> +			putback_zspage(class, dst_page);
> +			unfreeze_zspage(class, dst_page,
> +				class->objs_per_zspage);
> +			spin_unlock(&class->lock);
> +			dst_page =3D NULL;
>   		}
>
> -		/* Stop if we couldn't find slot */
> -		if (dst_page =3D=3D NULL)
> -			break;
> +		if (zspage_empty(class, src_page)) {
> +			free_zspage(pool, src_page);
> +			spin_lock(&class->lock);
> +			zs_stat_dec(class, OBJ_ALLOCATED,
> +				get_maxobj_per_zspage(
> +				class->size, class->pages_per_zspage));
> +			atomic_long_sub(class->pages_per_zspage,
> +					&pool->pages_allocated);
>
> -		VM_BUG_ON_PAGE(putback_zspage(pool, class,
> -				dst_page) =3D=3D ZS_EMPTY, dst_page);
> -		if (putback_zspage(pool, class, src_page) =3D=3D ZS_EMPTY) {
>   			pool->stats.pages_compacted +=3D class->pages_per_zspage;
>   			spin_unlock(&class->lock);
> -			free_zspage(pool, class, src_page);
> -		} else {
> -			spin_unlock(&class->lock);
> +			src_page =3D NULL;
>   		}
> +	}
>
> -		cond_resched();
> -		spin_lock(&class->lock);
> +	if (!src_page && !dst_page)
> +		return;
> +
> +	spin_lock(&class->lock);
> +	if (src_page) {
> +		putback_zspage(class, src_page);
> +		unfreeze_zspage(class, src_page,
> +				class->objs_per_zspage);
>   	}
>
> -	if (src_page)
> -		VM_BUG_ON_PAGE(putback_zspage(pool, class,
> -				src_page) =3D=3D ZS_EMPTY, src_page);
> +	if (dst_page) {
> +		putback_zspage(class, dst_page);
> +		unfreeze_zspage(class, dst_page,
> +				class->objs_per_zspage);
> +	}
>
>   	spin_unlock(&class->lock);
>   }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
