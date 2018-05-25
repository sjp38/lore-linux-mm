Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA2066B0005
	for <linux-mm@kvack.org>; Fri, 25 May 2018 13:17:11 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k136-v6so3009071oih.4
        for <linux-mm@kvack.org>; Fri, 25 May 2018 10:17:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y196-v6si8271126oia.163.2018.05.25.10.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 10:17:05 -0700 (PDT)
Date: Fri, 25 May 2018 13:17:02 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 1/2] iomap: add support for sub-pagesize buffered I/O
 without buffer heads
Message-ID: <20180525171701.GA92502@bfoster.bfoster>
References: <20180523144646.19159-1-hch@lst.de>
 <20180523144646.19159-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144646.19159-2-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:46:45PM +0200, Christoph Hellwig wrote:
> After already supporting a simple implementation of buffered writes for
> the blocksize == PAGE_SIZE case in the last commit this adds full support
> even for smaller block sizes.   There are three bits of per-block
> information in the buffer_head structure that really matter for the iomap
> read and write path:
> 
>  - uptodate status (BH_uptodate)
>  - marked as currently under read I/O (BH_Async_Read)
>  - marked as currently under write I/O (BH_Async_Write)
> 
> Instead of having new per-block structures this now adds a per-page
> structure called struct iomap_page to track this information in a slightly
> different form:
> 
>  - a bitmap for the per-block uptodate status.  For worst case of a 64k
>    page size system this bitmap needs to contain 128 bits.  For the
>    typical 4k page size case it only needs 8 bits, although we still
>    need a full unsigned long due to the way the atomic bitmap API works.
>  - two atomic_t counters are used to track the outstanding read and write
>    counts
> 
> There is quite a bit of boilerplate code as the buffered I/O path uses
> various helper methods, but the actual code is very straight forward.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/iomap.c            | 247 +++++++++++++++++++++++++++++++++++++++---
>  include/linux/iomap.h |  31 ++++++
>  2 files changed, 260 insertions(+), 18 deletions(-)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index debb859a8a14..ea746e0287f9 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
...
> @@ -104,6 +105,107 @@ iomap_sector(struct iomap *iomap, loff_t pos)
>  	return (iomap->addr + pos - iomap->offset) >> SECTOR_SHIFT;
>  }
>  
> +static struct iomap_page *
> +iomap_page_create(struct inode *inode, struct page *page)
> +{
> +	struct iomap_page *iop = to_iomap_page(page);
> +
> +	if (iop || i_blocksize(inode) == PAGE_SIZE)
> +		return iop;
> +
> +	iop = kmalloc(sizeof(*iop), GFP_NOFS | __GFP_NOFAIL);
> +	atomic_set(&iop->read_count, 0);
> +	atomic_set(&iop->write_count, 0);
> +	bitmap_zero(iop->uptodate, PAGE_SIZE / SECTOR_SIZE);
> +	set_page_private(page, (unsigned long)iop);
> +	SetPagePrivate(page);

The buffer head implementation does a get/put page when the private
state is set. I'm not quite sure why that is tbh, but do you know
whether we need that here or not?

> +	return iop;
> +}
> +
...
> @@ -142,18 +244,19 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  {
>  	struct iomap_readpage_ctx *ctx = data;
>  	struct page *page = ctx->cur_page;
> -	unsigned poff = pos & (PAGE_SIZE - 1);
> -	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, length);
> +	struct iomap_page *iop = iomap_page_create(inode, page);
>  	bool is_contig = false;
> +	loff_t orig_pos = pos;
> +	unsigned poff, plen;
>  	sector_t sector;
>  
> -	/* we don't support blocksize < PAGE_SIZE quite yet: */
> -	WARN_ON_ONCE(pos != page_offset(page));
> -	WARN_ON_ONCE(plen != PAGE_SIZE);
> +	iomap_adjust_read_range(inode, iop, &pos, length, &poff, &plen);
> +	if (plen == 0)
> +		goto done;
>  
>  	if (iomap->type != IOMAP_MAPPED || pos >= i_size_read(inode)) {
>  		zero_user(page, poff, plen);
> -		SetPageUptodate(page);
> +		iomap_set_range_uptodate(page, poff, plen);
>  		goto done;
>  	}
>  
> @@ -169,6 +272,14 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  		is_contig = true;
>  	}
>  
> +	/*
> +	 * If we start a new segment we need to increase the read count, and we
> +	 * need to do so before submitting any previous full bio to make sure
> +	 * that we don't prematurely unlock the page.
> +	 */
> +	if (iop)
> +		atomic_inc(&iop->read_count);
> +
>  	if (!ctx->bio || !is_contig || bio_full(ctx->bio)) {
>  		if (ctx->bio)
>  			submit_bio(ctx->bio);
> @@ -177,7 +288,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  
>  	__bio_add_page(ctx->bio, page, plen, poff);
>  done:
> -	return plen;
> +	return pos - orig_pos + plen;

A brief comment here (or above the adjust_read_range() call) to explain
the final length calculation would be helpful. E.g., it looks like
leading uptodate blocks are part of the read while trailing uptodate
blocks can be truncated by the above call.

>  }
>  
>  int
> @@ -188,8 +299,6 @@ iomap_readpage(struct page *page, const struct iomap_ops *ops)
>  	unsigned poff;
>  	loff_t ret;
>  
> -	WARN_ON_ONCE(page_has_buffers(page));
> -
>  	for (poff = 0; poff < PAGE_SIZE; poff += ret) {
>  		ret = iomap_apply(inode, page_offset(page) + poff,
>  				PAGE_SIZE - poff, 0, ops, &ctx,
> @@ -295,6 +404,92 @@ iomap_readpages(struct address_space *mapping, struct list_head *pages,
>  }
>  EXPORT_SYMBOL_GPL(iomap_readpages);
>  
> +int
> +iomap_is_partially_uptodate(struct page *page, unsigned long from,
> +		unsigned long count)
> +{
> +	struct iomap_page *iop = to_iomap_page(page);
> +	struct inode *inode = page->mapping->host;
> +	unsigned first = from >> inode->i_blkbits;
> +	unsigned last = (from + count - 1) >> inode->i_blkbits;
> +	unsigned i;
> +

block_is_partially_uptodate() has this check:

        if (from < blocksize && to > PAGE_SIZE - blocksize)
                return 0;

... which looks like it checks that the range is actually partial wrt to
block size. The only callers check the page first, but I'm still not
sure why it returns 0 in that case. Any idea?

> +	if (iop) {
> +		for (i = first; i <= last; i++)
> +			if (!test_bit(i, iop->uptodate))
> +				return 0;
> +		return 1;
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(iomap_is_partially_uptodate);
> +
...
> +
> +void
> +iomap_invalidatepage(struct page *page, unsigned int offset, unsigned int len)
> +{
> +	/*
> +	 * If we are invalidating the entire page, clear the dirty state from it
> +	 * and release it to avoid unnecessary buildup of the LRU.
> +	 */
> +	if (offset == 0 && len == PAGE_SIZE) {
> +		cancel_dirty_page(page);
> +		iomap_releasepage(page, GFP_NOIO);

Seems like this should probably be calling ->releasepage().

> +	}
> +}
> +EXPORT_SYMBOL_GPL(iomap_invalidatepage);
> +
...
> @@ -333,6 +529,7 @@ static int
>  __iomap_write_begin(struct inode *inode, loff_t pos, unsigned len,
>  		struct page *page, struct iomap *iomap)
>  {
> +	struct iomap_page *iop = iomap_page_create(inode, page);
>  	loff_t block_size = i_blocksize(inode);
>  	loff_t block_start = pos & ~(block_size - 1);
>  	loff_t block_end = (pos + len + block_size - 1) & ~(block_size - 1);
> @@ -340,15 +537,29 @@ __iomap_write_begin(struct inode *inode, loff_t pos, unsigned len,
>  	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, block_end - block_start);

poff/plen are now initialized here and in iomap_adjust_read_range().
Perhaps drop this one so the semantic of these being set by the latter
is a bit more clear?

>  	unsigned from = pos & (PAGE_SIZE - 1);
>  	unsigned to = from + len;
> -
> -	WARN_ON_ONCE(i_blocksize(inode) < PAGE_SIZE);
> +	int status;
>  
>  	if (PageUptodate(page))
>  		return 0;
> -	if (from <= poff && to >= poff + plen)
> -		return 0;
> -	return iomap_read_page_sync(inode, block_start, page,
> -			poff, plen, from, to, iomap);
> +
> +	do {
> +		iomap_adjust_read_range(inode, iop, &block_start,
> +				block_end - block_start, &poff, &plen);
> +		if (plen == 0)
> +			break;
> +
> +		if ((from > poff && from < poff + plen) ||
> +		    (to > poff && to < poff + plen)) {
> +			status = iomap_read_page_sync(inode, block_start, page,
> +					poff, plen, from, to, iomap);
> +			if (status)
> +				return status;
> +		}
> +
> +		block_start += plen;
> +	} while (poff + plen < PAGE_SIZE);

Something like while (block_start < block_end) would seem a bit more
clear here as well.

Brian

> +
> +	return 0;
>  }
>  
>  static int
> @@ -429,7 +640,7 @@ __iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  	if (unlikely(copied < len && !PageUptodate(page))) {
>  		copied = 0;
>  	} else {
> -		SetPageUptodate(page);
> +		iomap_set_range_uptodate(page, pos & (PAGE_SIZE - 1), len);
>  		iomap_set_page_dirty(page);
>  	}
>  	return __generic_write_end(inode, pos, copied, page);
> @@ -741,7 +952,7 @@ iomap_page_mkwrite_actor(struct inode *inode, loff_t pos, loff_t length,
>  		block_commit_write(page, 0, length);
>  	} else {
>  		WARN_ON_ONCE(!PageUptodate(page));
> -		WARN_ON_ONCE(i_blocksize(inode) < PAGE_SIZE);
> +		iomap_page_create(inode, page);
>  	}
>  
>  	return length;
> diff --git a/include/linux/iomap.h b/include/linux/iomap.h
> index 4d3d9d0cd69f..7f8787a1bbce 100644
> --- a/include/linux/iomap.h
> +++ b/include/linux/iomap.h
> @@ -2,6 +2,9 @@
>  #ifndef LINUX_IOMAP_H
>  #define LINUX_IOMAP_H 1
>  
> +#include <linux/atomic.h>
> +#include <linux/bitmap.h>
> +#include <linux/mm.h>
>  #include <linux/types.h>
>  
>  struct address_space;
> @@ -88,12 +91,40 @@ struct iomap_ops {
>  			ssize_t written, unsigned flags, struct iomap *iomap);
>  };
>  
> +/*
> + * Structure allocate for each page when block size < PAGE_SIZE to track
> + * sub-page uptodate status and I/O completions.
> + */
> +struct iomap_page {
> +	atomic_t		read_count;
> +	atomic_t		write_count;
> +	DECLARE_BITMAP(uptodate, PAGE_SIZE / 512);
> +};
> +
> +static inline struct iomap_page *to_iomap_page(struct page *page)
> +{
> +	if (page_has_private(page))
> +		return (struct iomap_page *)page_private(page);
> +	return NULL;
> +}
> +
>  ssize_t iomap_file_buffered_write(struct kiocb *iocb, struct iov_iter *from,
>  		const struct iomap_ops *ops);
>  int iomap_readpage(struct page *page, const struct iomap_ops *ops);
>  int iomap_readpages(struct address_space *mapping, struct list_head *pages,
>  		unsigned nr_pages, const struct iomap_ops *ops);
>  int iomap_set_page_dirty(struct page *page);
> +int iomap_is_partially_uptodate(struct page *page, unsigned long from,
> +		unsigned long count);
> +int iomap_releasepage(struct page *page, gfp_t gfp_mask);
> +void iomap_invalidatepage(struct page *page, unsigned int offset,
> +		unsigned int len);
> +#ifdef CONFIG_MIGRATION
> +int iomap_migrate_page(struct address_space *mapping, struct page *newpage,
> +		struct page *page, enum migrate_mode mode);
> +#else
> +#define iomap_migrate_page NULL
> +#endif
>  int iomap_file_dirty(struct inode *inode, loff_t pos, loff_t len,
>  		const struct iomap_ops *ops);
>  int iomap_zero_range(struct inode *inode, loff_t pos, loff_t len,
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
