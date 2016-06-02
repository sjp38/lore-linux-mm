Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2EC76B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 20:24:37 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id di3so26416774pab.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 17:24:37 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id sn1si14520787pac.215.2016.06.01.17.24.35
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 17:24:36 -0700 (PDT)
Date: Thu, 2 Jun 2016 09:25:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-ID: <20160602002519.GB1736@bbox>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <1464736881-24886-12-git-send-email-minchan@kernel.org>
 <574EEC96.8050805@suse.cz>
MIME-Version: 1.0
In-Reply-To: <574EEC96.8050805@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed, Jun 01, 2016 at 04:09:26PM +0200, Vlastimil Babka wrote:
> On 06/01/2016 01:21 AM, Minchan Kim wrote:
> 
> [...]
> 
> > 
> > Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> I'm not that familiar with zsmalloc, so this is not a full review. I was
> just curious how it's handling the movable migration API, and stumbled
> upon some things pointed out below.
> 
> > @@ -252,16 +276,23 @@ struct zs_pool {
> >   */
> >  #define FULLNESS_BITS	2
> >  #define CLASS_BITS	8
> > +#define ISOLATED_BITS	3
> > +#define MAGIC_VAL_BITS	8
> >  
> >  struct zspage {
> >  	struct {
> >  		unsigned int fullness:FULLNESS_BITS;
> >  		unsigned int class:CLASS_BITS;
> > +		unsigned int isolated:ISOLATED_BITS;
> > +		unsigned int magic:MAGIC_VAL_BITS;
> 
> This magic seems to be only tested via VM_BUG_ON, so it's presence
> should be also guarded by #ifdef DEBUG_VM, no?

Thanks for the point.

Then, I want to change it to BUG_ON because struct zspage corruption
is really risky to work rightly and want to catch on it in real product
which disable CONFIG_DEBUG_VM for a while until make the feature stable.

> 
> > @@ -999,6 +1141,8 @@ static struct zspage *alloc_zspage(struct zs_pool *pool,
> >  		return NULL;
> >  
> >  	memset(zspage, 0, sizeof(struct zspage));
> > +	zspage->magic = ZSPAGE_MAGIC;
> 
> Same here.
> 
> > +int zs_page_migrate(struct address_space *mapping, struct page *newpage,
> > +		struct page *page, enum migrate_mode mode)
> > +{
> > +	struct zs_pool *pool;
> > +	struct size_class *class;
> > +	int class_idx;
> > +	enum fullness_group fullness;
> > +	struct zspage *zspage;
> > +	struct page *dummy;
> > +	void *s_addr, *d_addr, *addr;
> > +	int offset, pos;
> > +	unsigned long handle, head;
> > +	unsigned long old_obj, new_obj;
> > +	unsigned int obj_idx;
> > +	int ret = -EAGAIN;
> > +
> > +	VM_BUG_ON_PAGE(!PageMovable(page), page);
> > +	VM_BUG_ON_PAGE(!PageIsolated(page), page);
> > +
> > +	zspage = get_zspage(page);
> > +
> > +	/* Concurrent compactor cannot migrate any subpage in zspage */
> > +	migrate_write_lock(zspage);
> > +	get_zspage_mapping(zspage, &class_idx, &fullness);
> > +	pool = mapping->private_data;
> > +	class = pool->size_class[class_idx];
> > +	offset = get_first_obj_offset(class, get_first_page(zspage), page);
> > +
> > +	spin_lock(&class->lock);
> > +	if (!get_zspage_inuse(zspage)) {
> > +		ret = -EBUSY;
> > +		goto unlock_class;
> > +	}
> > +
> > +	pos = offset;
> > +	s_addr = kmap_atomic(page);
> > +	while (pos < PAGE_SIZE) {
> > +		head = obj_to_head(page, s_addr + pos);
> > +		if (head & OBJ_ALLOCATED_TAG) {
> > +			handle = head & ~OBJ_ALLOCATED_TAG;
> > +			if (!trypin_tag(handle))
> > +				goto unpin_objects;
> > +		}
> > +		pos += class->size;
> > +	}
> > +
> > +	/*
> > +	 * Here, any user cannot access all objects in the zspage so let's move.
> > +	 */
> > +	d_addr = kmap_atomic(newpage);
> > +	memcpy(d_addr, s_addr, PAGE_SIZE);
> > +	kunmap_atomic(d_addr);
> > +
> > +	for (addr = s_addr + offset; addr < s_addr + pos;
> > +					addr += class->size) {
> > +		head = obj_to_head(page, addr);
> > +		if (head & OBJ_ALLOCATED_TAG) {
> > +			handle = head & ~OBJ_ALLOCATED_TAG;
> > +			if (!testpin_tag(handle))
> > +				BUG();
> > +
> > +			old_obj = handle_to_obj(handle);
> > +			obj_to_location(old_obj, &dummy, &obj_idx);
> > +			new_obj = (unsigned long)location_to_obj(newpage,
> > +								obj_idx);
> > +			new_obj |= BIT(HANDLE_PIN_BIT);
> > +			record_obj(handle, new_obj);
> > +		}
> > +	}
> > +
> > +	replace_sub_page(class, zspage, newpage, page);
> > +	get_page(newpage);
> > +
> > +	dec_zspage_isolation(zspage);
> > +
> > +	/*
> > +	 * Page migration is done so let's putback isolated zspage to
> > +	 * the list if @page is final isolated subpage in the zspage.
> > +	 */
> > +	if (!is_zspage_isolated(zspage))
> > +		putback_zspage(class, zspage);
> > +
> > +	reset_page(page);
> > +	put_page(page);
> > +	page = newpage;
> > +
> > +	ret = 0;
> > +unpin_objects:
> > +	for (addr = s_addr + offset; addr < s_addr + pos;
> > +						addr += class->size) {
> > +		head = obj_to_head(page, addr);
> > +		if (head & OBJ_ALLOCATED_TAG) {
> > +			handle = head & ~OBJ_ALLOCATED_TAG;
> > +			if (!testpin_tag(handle))
> > +				BUG();
> > +			unpin_tag(handle);
> > +		}
> > +	}
> > +	kunmap_atomic(s_addr);
> 
> The above seems suspicious to me. In the success case, page points to
> newpage, but s_addr is still the original one?

s_addr is virtual adress of old page by kmap_atomic so page pointer of
new page doesn't matter.

> 
> Vlastimil
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
