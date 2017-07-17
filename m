Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2886B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 01:40:06 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u123so160812361itu.5
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 22:40:06 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f202si9089752itb.123.2017.07.16.22.40.02
        for <linux-mm@kvack.org>;
        Sun, 16 Jul 2017 22:40:03 -0700 (PDT)
Date: Mon, 17 Jul 2017 14:39:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: zs_page_migrate: not check inuse if
 migrate_mode is not MIGRATE_ASYNC
Message-ID: <20170717053941.GA29581@bbox>
References: <1500018667-30175-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500018667-30175-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com

Hello Hui,

On Fri, Jul 14, 2017 at 03:51:07PM +0800, Hui Zhu wrote:
> Got some -EBUSY from zs_page_migrate that will make migration
> slow (retry) or fail (zs_page_putback will schedule_work free_work,
> but it cannot ensure the success).

I think EAGAIN(migration retrial) is better than EBUSY(bailout) because
expectation is that zsmalloc will release the empty zs_page soon so
at next retrial, it will be succeeded.
About schedule_work, as you said, we don't make sure when it happens but
I believe it will happen in a migration iteration most of case.
How often do you see that case?

> 
> And I didn't find anything that make zs_page_migrate cannot work with
> a ZS_EMPTY zspage.
> So make the patch to not check inuse if migrate_mode is not
> MIGRATE_ASYNC.

At a first glance, I think it work but the question is that it a same problem
ith schedule_work of zs_page_putback. IOW, Until the work is done, compaction
cannot succeed. Do you have any number before and after?

Thanks.

> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> ---
>  mm/zsmalloc.c | 66 +++++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 37 insertions(+), 29 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index d41edd2..c298e5c 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1982,6 +1982,7 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>  	unsigned long old_obj, new_obj;
>  	unsigned int obj_idx;
>  	int ret = -EAGAIN;
> +	int inuse;
>  
>  	VM_BUG_ON_PAGE(!PageMovable(page), page);
>  	VM_BUG_ON_PAGE(!PageIsolated(page), page);
> @@ -1996,21 +1997,24 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>  	offset = get_first_obj_offset(page);
>  
>  	spin_lock(&class->lock);
> -	if (!get_zspage_inuse(zspage)) {
> +	inuse = get_zspage_inuse(zspage);
> +	if (mode == MIGRATE_ASYNC && !inuse) {
>  		ret = -EBUSY;
>  		goto unlock_class;
>  	}
>  
>  	pos = offset;
>  	s_addr = kmap_atomic(page);
> -	while (pos < PAGE_SIZE) {
> -		head = obj_to_head(page, s_addr + pos);
> -		if (head & OBJ_ALLOCATED_TAG) {
> -			handle = head & ~OBJ_ALLOCATED_TAG;
> -			if (!trypin_tag(handle))
> -				goto unpin_objects;
> +	if (inuse) {
> +		while (pos < PAGE_SIZE) {
> +			head = obj_to_head(page, s_addr + pos);
> +			if (head & OBJ_ALLOCATED_TAG) {
> +				handle = head & ~OBJ_ALLOCATED_TAG;
> +				if (!trypin_tag(handle))
> +					goto unpin_objects;
> +			}
> +			pos += class->size;
>  		}
> -		pos += class->size;
>  	}
>  
>  	/*
> @@ -2020,20 +2024,22 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>  	memcpy(d_addr, s_addr, PAGE_SIZE);
>  	kunmap_atomic(d_addr);
>  
> -	for (addr = s_addr + offset; addr < s_addr + pos;
> -					addr += class->size) {
> -		head = obj_to_head(page, addr);
> -		if (head & OBJ_ALLOCATED_TAG) {
> -			handle = head & ~OBJ_ALLOCATED_TAG;
> -			if (!testpin_tag(handle))
> -				BUG();
> -
> -			old_obj = handle_to_obj(handle);
> -			obj_to_location(old_obj, &dummy, &obj_idx);
> -			new_obj = (unsigned long)location_to_obj(newpage,
> -								obj_idx);
> -			new_obj |= BIT(HANDLE_PIN_BIT);
> -			record_obj(handle, new_obj);
> +	if (inuse) {
> +		for (addr = s_addr + offset; addr < s_addr + pos;
> +						addr += class->size) {
> +			head = obj_to_head(page, addr);
> +			if (head & OBJ_ALLOCATED_TAG) {
> +				handle = head & ~OBJ_ALLOCATED_TAG;
> +				if (!testpin_tag(handle))
> +					BUG();
> +
> +				old_obj = handle_to_obj(handle);
> +				obj_to_location(old_obj, &dummy, &obj_idx);
> +				new_obj = (unsigned long)
> +					location_to_obj(newpage, obj_idx);
> +				new_obj |= BIT(HANDLE_PIN_BIT);
> +				record_obj(handle, new_obj);
> +			}
>  		}
>  	}
>  
> @@ -2055,14 +2061,16 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>  
>  	ret = MIGRATEPAGE_SUCCESS;
>  unpin_objects:
> -	for (addr = s_addr + offset; addr < s_addr + pos;
> +	if (inuse) {
> +		for (addr = s_addr + offset; addr < s_addr + pos;
>  						addr += class->size) {
> -		head = obj_to_head(page, addr);
> -		if (head & OBJ_ALLOCATED_TAG) {
> -			handle = head & ~OBJ_ALLOCATED_TAG;
> -			if (!testpin_tag(handle))
> -				BUG();
> -			unpin_tag(handle);
> +			head = obj_to_head(page, addr);
> +			if (head & OBJ_ALLOCATED_TAG) {
> +				handle = head & ~OBJ_ALLOCATED_TAG;
> +				if (!testpin_tag(handle))
> +					BUG();
> +				unpin_tag(handle);
> +			}
>  		}
>  	}
>  	kunmap_atomic(s_addr);
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
