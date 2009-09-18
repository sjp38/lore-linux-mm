Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 087846B00FB
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:05:19 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so531790fga.8
        for <linux-mm@kvack.org>; Fri, 18 Sep 2009 14:05:19 -0700 (PDT)
Message-ID: <4AB3F60D.2030808@gmail.com>
Date: Fri, 18 Sep 2009 23:05:17 +0200
From: Marcin Slusarz <marcin.slusarz@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] xvmalloc memory allocator
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org> <1253227412-24342-2-git-send-email-ngupta@vflare.org>
In-Reply-To: <1253227412-24342-2-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

Nitin Gupta wrote:
> (...)
> +
> +/*
> + * Allocate a memory page. Called when a pool needs to grow.
> + */
> +static struct page *xv_alloc_page(gfp_t flags)
> +{
> +	struct page *page;
> +
> +	page = alloc_page(flags);
> +	if (unlikely(!page))
> +		return 0;
> +
> +	return page;
> +}

When alloc_page returns 0 it returns 0, when not - it returns page.
Why not call alloc_page directly?

> (...)
> +/*
> + * Remove block from freelist. Index 'slindex' identifies the freelist.
> + */
> +static void remove_block(struct xv_pool *pool, struct page *page, u32 offset,
> +			struct block_header *block, u32 slindex)
> +{
> +	u32 flindex;
> +	struct block_header *tmpblock;
> +
> +	if (pool->freelist[slindex].page == page
> +	   && pool->freelist[slindex].offset == offset) {
> +		remove_block_head(pool, block, slindex);
> +		return;
> +	}
> +
> +	flindex = slindex / BITS_PER_LONG;
> +
> +	if (block->link.prev_page) {
> +		tmpblock = get_ptr_atomic(block->link.prev_page,
> +				block->link.prev_offset, KM_USER1);
> +		tmpblock->link.next_page = block->link.next_page;
> +		tmpblock->link.next_offset = block->link.next_offset;
> +		put_ptr_atomic(tmpblock, KM_USER1);
> +	}
> +
> +	if (block->link.next_page) {
> +		tmpblock = get_ptr_atomic(block->link.next_page,
> +				block->link.next_offset, KM_USER1);
> +		tmpblock->link.prev_page = block->link.prev_page;
> +		tmpblock->link.prev_offset = block->link.prev_offset;
> +		put_ptr_atomic(tmpblock, KM_USER1);
> +	}
> +
> +	return;
> +}

needless return

> +
> +/*
> + * Allocate a page and add it freelist of given pool.
> + */
> +static int grow_pool(struct xv_pool *pool, gfp_t flags)
> +{
> +	struct page *page;
> +	struct block_header *block;
> +
> +	page = xv_alloc_page(flags);
> +	if (unlikely(!page))
> +		return -ENOMEM;
> +
> +	stat_inc(&pool->total_pages);
> +
> +	spin_lock(&pool->lock);
> +	block = get_ptr_atomic(page, 0, KM_USER0);
> +
> +	block->size = PAGE_SIZE - XV_ALIGN;
> +	set_flag(block, BLOCK_FREE);
> +	clear_flag(block, PREV_FREE);
> +	set_blockprev(block, 0);
> +
> +	insert_block(pool, page, 0, block);
> +
> +	put_ptr_atomic(block, KM_USER0);
> +	spin_unlock(&pool->lock);
> +
> +	return 0;
> +}
> +
> (...)
> +/**
> + * xv_malloc - Allocate block of given size from pool.
> + * @pool: pool to allocate from
> + * @size: size of block to allocate
> + * @page: page no. that holds the object
> + * @offset: location of object within page
> + *
> + * On success, <page, offset> identifies block allocated
> + * and 0 is returned. On failure, <page, offset> is set to
> + * 0 and -ENOMEM is returned.
> + *
> + * Allocation requests with size > XV_MAX_ALLOC_SIZE will fail.
> + */
> +int xv_malloc(struct xv_pool *pool, u32 size, struct page **page,
> +		u32 *offset, gfp_t flags)
> +{
> +	int error;
> +	u32 index, tmpsize, origsize, tmpoffset;
> +	struct block_header *block, *tmpblock;
> +
> +	*page = NULL;
> +	*offset = 0;
> +	origsize = size;
> +
> +	if (unlikely(!size || size > XV_MAX_ALLOC_SIZE))
> +		return -ENOMEM;
> +
> +	size = ALIGN(size, XV_ALIGN);
> +
> +	spin_lock(&pool->lock);
> +
> +	index = find_block(pool, size, page, offset);
> +
> +	if (!*page) {
> +		spin_unlock(&pool->lock);
> +		if (flags & GFP_NOWAIT)
> +			return -ENOMEM;
> +		error = grow_pool(pool, flags);
> +		if (unlikely(error))
> +			return -ENOMEM;

shouldn't it return error? (grow_pool returns 0 or -ENOMEM for now but...)

> +
> +		spin_lock(&pool->lock);
> +		index = find_block(pool, size, page, offset);
> +	}
> +
> +	if (!*page) {
> +		spin_unlock(&pool->lock);
> +		return -ENOMEM;
> +	}
> +
> +	block = get_ptr_atomic(*page, *offset, KM_USER0);
> +
> +	remove_block_head(pool, block, index);
> +
> +	/* Split the block if required */
> +	tmpoffset = *offset + size + XV_ALIGN;
> +	tmpsize = block->size - size;
> +	tmpblock = (struct block_header *)((char *)block + size + XV_ALIGN);
> +	if (tmpsize) {
> +		tmpblock->size = tmpsize - XV_ALIGN;
> +		set_flag(tmpblock, BLOCK_FREE);
> +		clear_flag(tmpblock, PREV_FREE);
> +
> +		set_blockprev(tmpblock, *offset);
> +		if (tmpblock->size >= XV_MIN_ALLOC_SIZE)
> +			insert_block(pool, *page, tmpoffset, tmpblock);
> +
> +		if (tmpoffset + XV_ALIGN + tmpblock->size != PAGE_SIZE) {
> +			tmpblock = BLOCK_NEXT(tmpblock);
> +			set_blockprev(tmpblock, tmpoffset);
> +		}
> +	} else {
> +		/* This block is exact fit */
> +		if (tmpoffset != PAGE_SIZE)
> +			clear_flag(tmpblock, PREV_FREE);
> +	}
> +
> +	block->size = origsize;
> +	clear_flag(block, BLOCK_FREE);
> +
> +	put_ptr_atomic(block, KM_USER0);
> +	spin_unlock(&pool->lock);
> +
> +	*offset += XV_ALIGN;
> +
> +	return 0;
> +}
> +
> +/*
> + * Free block identified with <page, offset>
> + */
> +void xv_free(struct xv_pool *pool, struct page *page, u32 offset)
> +{
> +	void *page_start;
> +	struct block_header *block, *tmpblock;
> +
> +	offset -= XV_ALIGN;
> +
> +	spin_lock(&pool->lock);
> +
> +	page_start = get_ptr_atomic(page, 0, KM_USER0);
> +	block = (struct block_header *)((char *)page_start + offset);
> +
> +	/* Catch double free bugs */
> +	BUG_ON(test_flag(block, BLOCK_FREE));
> +
> +	block->size = ALIGN(block->size, XV_ALIGN);
> +
> +	tmpblock = BLOCK_NEXT(block);
> +	if (offset + block->size + XV_ALIGN == PAGE_SIZE)
> +		tmpblock = NULL;
> +
> +	/* Merge next block if its free */
> +	if (tmpblock && test_flag(tmpblock, BLOCK_FREE)) {
> +		/*
> +		 * Blocks smaller than XV_MIN_ALLOC_SIZE
> +		 * are not inserted in any free list.
> +		 */
> +		if (tmpblock->size >= XV_MIN_ALLOC_SIZE) {
> +			remove_block(pool, page,
> +				    offset + block->size + XV_ALIGN, tmpblock,
> +				    get_index_for_insert(tmpblock->size));
> +		}
> +		block->size += tmpblock->size + XV_ALIGN;
> +	}
> +
> +	/* Merge previous block if its free */
> +	if (test_flag(block, PREV_FREE)) {
> +		tmpblock = (struct block_header *)((char *)(page_start) +
> +						get_blockprev(block));
> +		offset = offset - tmpblock->size - XV_ALIGN;
> +
> +		if (tmpblock->size >= XV_MIN_ALLOC_SIZE)
> +			remove_block(pool, page, offset, tmpblock,
> +				    get_index_for_insert(tmpblock->size));
> +
> +		tmpblock->size += block->size + XV_ALIGN;
> +		block = tmpblock;
> +	}
> +
> +	/* No used objects in this page. Free it. */
> +	if (block->size == PAGE_SIZE - XV_ALIGN) {
> +		put_ptr_atomic(page_start, KM_USER0);
> +		spin_unlock(&pool->lock);
> +
> +		xv_free_page(page);
> +		stat_dec(&pool->total_pages);
> +		return;
> +	}
> +
> +	set_flag(block, BLOCK_FREE);
> +	if (block->size >= XV_MIN_ALLOC_SIZE)
> +		insert_block(pool, page, offset, block);
> +
> +	if (offset + block->size + XV_ALIGN != PAGE_SIZE) {
> +		tmpblock = BLOCK_NEXT(block);
> +		set_flag(tmpblock, PREV_FREE);
> +		set_blockprev(tmpblock, offset);
> +	}
> +
> +	put_ptr_atomic(page_start, KM_USER0);
> +	spin_unlock(&pool->lock);
> +
> +	return;
> +}

needless return


Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
