Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id F0BCC6B0265
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 10:09:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 132so10483020lfz.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:09:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gl2si57216565wjd.222.2016.06.01.07.09.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 07:09:28 -0700 (PDT)
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <1464736881-24886-12-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <574EEC96.8050805@suse.cz>
Date: Wed, 1 Jun 2016 16:09:26 +0200
MIME-Version: 1.0
In-Reply-To: <1464736881-24886-12-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On 06/01/2016 01:21 AM, Minchan Kim wrote:

[...]

> 
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

I'm not that familiar with zsmalloc, so this is not a full review. I was
just curious how it's handling the movable migration API, and stumbled
upon some things pointed out below.

> @@ -252,16 +276,23 @@ struct zs_pool {
>   */
>  #define FULLNESS_BITS	2
>  #define CLASS_BITS	8
> +#define ISOLATED_BITS	3
> +#define MAGIC_VAL_BITS	8
>  
>  struct zspage {
>  	struct {
>  		unsigned int fullness:FULLNESS_BITS;
>  		unsigned int class:CLASS_BITS;
> +		unsigned int isolated:ISOLATED_BITS;
> +		unsigned int magic:MAGIC_VAL_BITS;

This magic seems to be only tested via VM_BUG_ON, so it's presence
should be also guarded by #ifdef DEBUG_VM, no?

> @@ -999,6 +1141,8 @@ static struct zspage *alloc_zspage(struct zs_pool *pool,
>  		return NULL;
>  
>  	memset(zspage, 0, sizeof(struct zspage));
> +	zspage->magic = ZSPAGE_MAGIC;

Same here.

> +int zs_page_migrate(struct address_space *mapping, struct page *newpage,
> +		struct page *page, enum migrate_mode mode)
> +{
> +	struct zs_pool *pool;
> +	struct size_class *class;
> +	int class_idx;
> +	enum fullness_group fullness;
> +	struct zspage *zspage;
> +	struct page *dummy;
> +	void *s_addr, *d_addr, *addr;
> +	int offset, pos;
> +	unsigned long handle, head;
> +	unsigned long old_obj, new_obj;
> +	unsigned int obj_idx;
> +	int ret = -EAGAIN;
> +
> +	VM_BUG_ON_PAGE(!PageMovable(page), page);
> +	VM_BUG_ON_PAGE(!PageIsolated(page), page);
> +
> +	zspage = get_zspage(page);
> +
> +	/* Concurrent compactor cannot migrate any subpage in zspage */
> +	migrate_write_lock(zspage);
> +	get_zspage_mapping(zspage, &class_idx, &fullness);
> +	pool = mapping->private_data;
> +	class = pool->size_class[class_idx];
> +	offset = get_first_obj_offset(class, get_first_page(zspage), page);
> +
> +	spin_lock(&class->lock);
> +	if (!get_zspage_inuse(zspage)) {
> +		ret = -EBUSY;
> +		goto unlock_class;
> +	}
> +
> +	pos = offset;
> +	s_addr = kmap_atomic(page);
> +	while (pos < PAGE_SIZE) {
> +		head = obj_to_head(page, s_addr + pos);
> +		if (head & OBJ_ALLOCATED_TAG) {
> +			handle = head & ~OBJ_ALLOCATED_TAG;
> +			if (!trypin_tag(handle))
> +				goto unpin_objects;
> +		}
> +		pos += class->size;
> +	}
> +
> +	/*
> +	 * Here, any user cannot access all objects in the zspage so let's move.
> +	 */
> +	d_addr = kmap_atomic(newpage);
> +	memcpy(d_addr, s_addr, PAGE_SIZE);
> +	kunmap_atomic(d_addr);
> +
> +	for (addr = s_addr + offset; addr < s_addr + pos;
> +					addr += class->size) {
> +		head = obj_to_head(page, addr);
> +		if (head & OBJ_ALLOCATED_TAG) {
> +			handle = head & ~OBJ_ALLOCATED_TAG;
> +			if (!testpin_tag(handle))
> +				BUG();
> +
> +			old_obj = handle_to_obj(handle);
> +			obj_to_location(old_obj, &dummy, &obj_idx);
> +			new_obj = (unsigned long)location_to_obj(newpage,
> +								obj_idx);
> +			new_obj |= BIT(HANDLE_PIN_BIT);
> +			record_obj(handle, new_obj);
> +		}
> +	}
> +
> +	replace_sub_page(class, zspage, newpage, page);
> +	get_page(newpage);
> +
> +	dec_zspage_isolation(zspage);
> +
> +	/*
> +	 * Page migration is done so let's putback isolated zspage to
> +	 * the list if @page is final isolated subpage in the zspage.
> +	 */
> +	if (!is_zspage_isolated(zspage))
> +		putback_zspage(class, zspage);
> +
> +	reset_page(page);
> +	put_page(page);
> +	page = newpage;
> +
> +	ret = 0;
> +unpin_objects:
> +	for (addr = s_addr + offset; addr < s_addr + pos;
> +						addr += class->size) {
> +		head = obj_to_head(page, addr);
> +		if (head & OBJ_ALLOCATED_TAG) {
> +			handle = head & ~OBJ_ALLOCATED_TAG;
> +			if (!testpin_tag(handle))
> +				BUG();
> +			unpin_tag(handle);
> +		}
> +	}
> +	kunmap_atomic(s_addr);

The above seems suspicious to me. In the success case, page points to
newpage, but s_addr is still the original one?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
