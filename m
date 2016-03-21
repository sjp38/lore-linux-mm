Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D82476B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 09:28:58 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id u190so265726112pfb.3
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 06:28:58 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id lf12si16948323pab.207.2016.03.21.06.28.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 06:28:58 -0700 (PDT)
Subject: Re: [PATCH 45/71] jfs: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458499278-1516-46-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Kleikamp <dave.kleikamp@oracle.com>
Message-ID: <56EFF700.7060406@oracle.com>
Date: Mon, 21 Mar 2016 08:28:32 -0500
MIME-Version: 1.0
In-Reply-To: <1458499278-1516-46-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dave Kleikamp <shaggy@kernel.org>

On 03/20/2016 01:40 PM, Kirill A. Shutemov wrote:
> PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
> with promise that one day it will be possible to implement page cache with
> bigger chunks than PAGE_SIZE.
> 
> This promise never materialized. And unlikely will.
> 
> We have many places where PAGE_CACHE_SIZE assumed to be equal to
> PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
> or PAGE_* constant should be used in a particular case, especially on the
> border between fs and mm.
> 
> Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
> breakage to be doable.
> 
> Let's stop pretending that pages in page cache are special. They are not.
> 
> The changes are pretty straight-forward:
> 
>  - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;
> 
>  - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};
> 
>  - page_cache_get() -> get_page();
> 
>  - page_cache_release() -> put_page();
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Looks good to me. I've also verified the jfs changes in the large patch
you sent out this morning.

Acked-by: Dave Kleikamp <dave.kleikamp@oracle.com>

> Cc: Dave Kleikamp <shaggy@kernel.org>
> ---
>  fs/jfs/jfs_metapage.c | 42 +++++++++++++++++++++---------------------
>  fs/jfs/jfs_metapage.h |  4 ++--
>  fs/jfs/super.c        |  2 +-
>  3 files changed, 24 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
> index a3eb316b1ac3..b60e015cc757 100644
> --- a/fs/jfs/jfs_metapage.c
> +++ b/fs/jfs/jfs_metapage.c
> @@ -80,7 +80,7 @@ static inline void lock_metapage(struct metapage *mp)
>  static struct kmem_cache *metapage_cache;
>  static mempool_t *metapage_mempool;
>  
> -#define MPS_PER_PAGE (PAGE_CACHE_SIZE >> L2PSIZE)
> +#define MPS_PER_PAGE (PAGE_SIZE >> L2PSIZE)
>  
>  #if MPS_PER_PAGE > 1
>  
> @@ -316,7 +316,7 @@ static void last_write_complete(struct page *page)
>  	struct metapage *mp;
>  	unsigned int offset;
>  
> -	for (offset = 0; offset < PAGE_CACHE_SIZE; offset += PSIZE) {
> +	for (offset = 0; offset < PAGE_SIZE; offset += PSIZE) {
>  		mp = page_to_mp(page, offset);
>  		if (mp && test_bit(META_io, &mp->flag)) {
>  			if (mp->lsn)
> @@ -366,12 +366,12 @@ static int metapage_writepage(struct page *page, struct writeback_control *wbc)
>  	int bad_blocks = 0;
>  
>  	page_start = (sector_t)page->index <<
> -		     (PAGE_CACHE_SHIFT - inode->i_blkbits);
> +		     (PAGE_SHIFT - inode->i_blkbits);
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(PageWriteback(page));
>  	set_page_writeback(page);
>  
> -	for (offset = 0; offset < PAGE_CACHE_SIZE; offset += PSIZE) {
> +	for (offset = 0; offset < PAGE_SIZE; offset += PSIZE) {
>  		mp = page_to_mp(page, offset);
>  
>  		if (!mp || !test_bit(META_dirty, &mp->flag))
> @@ -416,7 +416,7 @@ static int metapage_writepage(struct page *page, struct writeback_control *wbc)
>  			bio = NULL;
>  		} else
>  			inc_io(page);
> -		xlen = (PAGE_CACHE_SIZE - offset) >> inode->i_blkbits;
> +		xlen = (PAGE_SIZE - offset) >> inode->i_blkbits;
>  		pblock = metapage_get_blocks(inode, lblock, &xlen);
>  		if (!pblock) {
>  			printk(KERN_ERR "JFS: metapage_get_blocks failed\n");
> @@ -485,7 +485,7 @@ static int metapage_readpage(struct file *fp, struct page *page)
>  	struct inode *inode = page->mapping->host;
>  	struct bio *bio = NULL;
>  	int block_offset;
> -	int blocks_per_page = PAGE_CACHE_SIZE >> inode->i_blkbits;
> +	int blocks_per_page = PAGE_SIZE >> inode->i_blkbits;
>  	sector_t page_start;	/* address of page in fs blocks */
>  	sector_t pblock;
>  	int xlen;
> @@ -494,7 +494,7 @@ static int metapage_readpage(struct file *fp, struct page *page)
>  
>  	BUG_ON(!PageLocked(page));
>  	page_start = (sector_t)page->index <<
> -		     (PAGE_CACHE_SHIFT - inode->i_blkbits);
> +		     (PAGE_SHIFT - inode->i_blkbits);
>  
>  	block_offset = 0;
>  	while (block_offset < blocks_per_page) {
> @@ -542,7 +542,7 @@ static int metapage_releasepage(struct page *page, gfp_t gfp_mask)
>  	int ret = 1;
>  	int offset;
>  
> -	for (offset = 0; offset < PAGE_CACHE_SIZE; offset += PSIZE) {
> +	for (offset = 0; offset < PAGE_SIZE; offset += PSIZE) {
>  		mp = page_to_mp(page, offset);
>  
>  		if (!mp)
> @@ -568,7 +568,7 @@ static int metapage_releasepage(struct page *page, gfp_t gfp_mask)
>  static void metapage_invalidatepage(struct page *page, unsigned int offset,
>  				    unsigned int length)
>  {
> -	BUG_ON(offset || length < PAGE_CACHE_SIZE);
> +	BUG_ON(offset || length < PAGE_SIZE);
>  
>  	BUG_ON(PageWriteback(page));
>  
> @@ -599,10 +599,10 @@ struct metapage *__get_metapage(struct inode *inode, unsigned long lblock,
>  		 inode->i_ino, lblock, absolute);
>  
>  	l2bsize = inode->i_blkbits;
> -	l2BlocksPerPage = PAGE_CACHE_SHIFT - l2bsize;
> +	l2BlocksPerPage = PAGE_SHIFT - l2bsize;
>  	page_index = lblock >> l2BlocksPerPage;
>  	page_offset = (lblock - (page_index << l2BlocksPerPage)) << l2bsize;
> -	if ((page_offset + size) > PAGE_CACHE_SIZE) {
> +	if ((page_offset + size) > PAGE_SIZE) {
>  		jfs_err("MetaData crosses page boundary!!");
>  		jfs_err("lblock = %lx, size  = %d", lblock, size);
>  		dump_stack();
> @@ -621,7 +621,7 @@ struct metapage *__get_metapage(struct inode *inode, unsigned long lblock,
>  		mapping = inode->i_mapping;
>  	}
>  
> -	if (new && (PSIZE == PAGE_CACHE_SIZE)) {
> +	if (new && (PSIZE == PAGE_SIZE)) {
>  		page = grab_cache_page(mapping, page_index);
>  		if (!page) {
>  			jfs_err("grab_cache_page failed!");
> @@ -693,7 +693,7 @@ unlock:
>  void grab_metapage(struct metapage * mp)
>  {
>  	jfs_info("grab_metapage: mp = 0x%p", mp);
> -	page_cache_get(mp->page);
> +	get_page(mp->page);
>  	lock_page(mp->page);
>  	mp->count++;
>  	lock_metapage(mp);
> @@ -706,12 +706,12 @@ void force_metapage(struct metapage *mp)
>  	jfs_info("force_metapage: mp = 0x%p", mp);
>  	set_bit(META_forcewrite, &mp->flag);
>  	clear_bit(META_sync, &mp->flag);
> -	page_cache_get(page);
> +	get_page(page);
>  	lock_page(page);
>  	set_page_dirty(page);
>  	write_one_page(page, 1);
>  	clear_bit(META_forcewrite, &mp->flag);
> -	page_cache_release(page);
> +	put_page(page);
>  }
>  
>  void hold_metapage(struct metapage *mp)
> @@ -726,7 +726,7 @@ void put_metapage(struct metapage *mp)
>  		unlock_page(mp->page);
>  		return;
>  	}
> -	page_cache_get(mp->page);
> +	get_page(mp->page);
>  	mp->count++;
>  	lock_metapage(mp);
>  	unlock_page(mp->page);
> @@ -746,7 +746,7 @@ void release_metapage(struct metapage * mp)
>  	assert(mp->count);
>  	if (--mp->count || mp->nohomeok) {
>  		unlock_page(page);
> -		page_cache_release(page);
> +		put_page(page);
>  		return;
>  	}
>  
> @@ -764,13 +764,13 @@ void release_metapage(struct metapage * mp)
>  	drop_metapage(page, mp);
>  
>  	unlock_page(page);
> -	page_cache_release(page);
> +	put_page(page);
>  }
>  
>  void __invalidate_metapages(struct inode *ip, s64 addr, int len)
>  {
>  	sector_t lblock;
> -	int l2BlocksPerPage = PAGE_CACHE_SHIFT - ip->i_blkbits;
> +	int l2BlocksPerPage = PAGE_SHIFT - ip->i_blkbits;
>  	int BlocksPerPage = 1 << l2BlocksPerPage;
>  	/* All callers are interested in block device's mapping */
>  	struct address_space *mapping =
> @@ -788,7 +788,7 @@ void __invalidate_metapages(struct inode *ip, s64 addr, int len)
>  		page = find_lock_page(mapping, lblock >> l2BlocksPerPage);
>  		if (!page)
>  			continue;
> -		for (offset = 0; offset < PAGE_CACHE_SIZE; offset += PSIZE) {
> +		for (offset = 0; offset < PAGE_SIZE; offset += PSIZE) {
>  			mp = page_to_mp(page, offset);
>  			if (!mp)
>  				continue;
> @@ -803,7 +803,7 @@ void __invalidate_metapages(struct inode *ip, s64 addr, int len)
>  				remove_from_logsync(mp);
>  		}
>  		unlock_page(page);
> -		page_cache_release(page);
> +		put_page(page);
>  	}
>  }
>  
> diff --git a/fs/jfs/jfs_metapage.h b/fs/jfs/jfs_metapage.h
> index 337e9e51ac06..a869fb4a20d6 100644
> --- a/fs/jfs/jfs_metapage.h
> +++ b/fs/jfs/jfs_metapage.h
> @@ -106,7 +106,7 @@ static inline void metapage_nohomeok(struct metapage *mp)
>  	lock_page(page);
>  	if (!mp->nohomeok++) {
>  		mark_metapage_dirty(mp);
> -		page_cache_get(page);
> +		get_page(page);
>  		wait_on_page_writeback(page);
>  	}
>  	unlock_page(page);
> @@ -128,7 +128,7 @@ static inline void metapage_wait_for_io(struct metapage *mp)
>  static inline void _metapage_homeok(struct metapage *mp)
>  {
>  	if (!--mp->nohomeok)
> -		page_cache_release(mp->page);
> +		put_page(mp->page);
>  }
>  
>  static inline void metapage_homeok(struct metapage *mp)
> diff --git a/fs/jfs/super.c b/fs/jfs/super.c
> index 4f5d85ba8e23..78d599198bf5 100644
> --- a/fs/jfs/super.c
> +++ b/fs/jfs/super.c
> @@ -596,7 +596,7 @@ static int jfs_fill_super(struct super_block *sb, void *data, int silent)
>  	 * Page cache is indexed by long.
>  	 * I would use MAX_LFS_FILESIZE, but it's only half as big
>  	 */
> -	sb->s_maxbytes = min(((u64) PAGE_CACHE_SIZE << 32) - 1,
> +	sb->s_maxbytes = min(((u64) PAGE_SIZE << 32) - 1,
>  			     (u64)sb->s_maxbytes);
>  #endif
>  	sb->s_time_gran = 1;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
