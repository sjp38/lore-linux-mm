Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id CAFA76B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 01:31:09 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id r129so76764244wmr.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 22:31:09 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id kd3si35410707wjb.84.2016.03.21.22.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 22:31:08 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id u125so859805wmg.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 22:31:08 -0700 (PDT)
Message-ID: <56F0D899.4040609@electrozaur.com>
Date: Tue, 22 Mar 2016 07:31:05 +0200
From: Boaz Harrosh <ooo@electrozaur.com>
MIME-Version: 1.0
Subject: Re: [PATCH 31/71] exofs: get rid of PAGE_CACHE_* and page_cache_{get,release}
 macros
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com> <1458499278-1516-32-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-32-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>

On 03/20/2016 08:40 PM, Kirill A. Shutemov wrote:
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
> Cc: Boaz Harrosh <ooo@electrozaur.com>

ACK-by: Boaz Harrosh <ooo@electrozaur.com>

Could you please push this through some other maintainer perhaps
the vfs tree?

Thank you Kirill
Boaz

> Cc: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/exofs/dir.c   | 30 +++++++++++++++---------------
>  fs/exofs/inode.c | 34 +++++++++++++++++-----------------
>  fs/exofs/namei.c |  4 ++--
>  3 files changed, 34 insertions(+), 34 deletions(-)
> 
> diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
> index e5bb2abf77f9..547b93cbea63 100644
> --- a/fs/exofs/dir.c
> +++ b/fs/exofs/dir.c
> @@ -41,16 +41,16 @@ static inline unsigned exofs_chunk_size(struct inode *inode)
>  static inline void exofs_put_page(struct page *page)
>  {
>  	kunmap(page);
> -	page_cache_release(page);
> +	put_page(page);
>  }
>  
>  static unsigned exofs_last_byte(struct inode *inode, unsigned long page_nr)
>  {
>  	loff_t last_byte = inode->i_size;
>  
> -	last_byte -= page_nr << PAGE_CACHE_SHIFT;
> -	if (last_byte > PAGE_CACHE_SIZE)
> -		last_byte = PAGE_CACHE_SIZE;
> +	last_byte -= page_nr << PAGE_SHIFT;
> +	if (last_byte > PAGE_SIZE)
> +		last_byte = PAGE_SIZE;
>  	return last_byte;
>  }
>  
> @@ -85,13 +85,13 @@ static void exofs_check_page(struct page *page)
>  	unsigned chunk_size = exofs_chunk_size(dir);
>  	char *kaddr = page_address(page);
>  	unsigned offs, rec_len;
> -	unsigned limit = PAGE_CACHE_SIZE;
> +	unsigned limit = PAGE_SIZE;
>  	struct exofs_dir_entry *p;
>  	char *error;
>  
>  	/* if the page is the last one in the directory */
> -	if ((dir->i_size >> PAGE_CACHE_SHIFT) == page->index) {
> -		limit = dir->i_size & ~PAGE_CACHE_MASK;
> +	if ((dir->i_size >> PAGE_SHIFT) == page->index) {
> +		limit = dir->i_size & ~PAGE_MASK;
>  		if (limit & (chunk_size - 1))
>  			goto Ebadsize;
>  		if (!limit)
> @@ -138,7 +138,7 @@ bad_entry:
>  	EXOFS_ERR(
>  		"ERROR [exofs_check_page]: bad entry in directory(0x%lx): %s - "
>  		"offset=%lu, inode=0x%llu, rec_len=%d, name_len=%d\n",
> -		dir->i_ino, error, (page->index<<PAGE_CACHE_SHIFT)+offs,
> +		dir->i_ino, error, (page->index<<PAGE_SHIFT)+offs,
>  		_LLU(le64_to_cpu(p->inode_no)),
>  		rec_len, p->name_len);
>  	goto fail;
> @@ -147,7 +147,7 @@ Eend:
>  	EXOFS_ERR("ERROR [exofs_check_page]: "
>  		"entry in directory(0x%lx) spans the page boundary"
>  		"offset=%lu, inode=0x%llx\n",
> -		dir->i_ino, (page->index<<PAGE_CACHE_SHIFT)+offs,
> +		dir->i_ino, (page->index<<PAGE_SHIFT)+offs,
>  		_LLU(le64_to_cpu(p->inode_no)));
>  fail:
>  	SetPageChecked(page);
> @@ -237,8 +237,8 @@ exofs_readdir(struct file *file, struct dir_context *ctx)
>  {
>  	loff_t pos = ctx->pos;
>  	struct inode *inode = file_inode(file);
> -	unsigned int offset = pos & ~PAGE_CACHE_MASK;
> -	unsigned long n = pos >> PAGE_CACHE_SHIFT;
> +	unsigned int offset = pos & ~PAGE_MASK;
> +	unsigned long n = pos >> PAGE_SHIFT;
>  	unsigned long npages = dir_pages(inode);
>  	unsigned chunk_mask = ~(exofs_chunk_size(inode)-1);
>  	int need_revalidate = (file->f_version != inode->i_version);
> @@ -254,7 +254,7 @@ exofs_readdir(struct file *file, struct dir_context *ctx)
>  		if (IS_ERR(page)) {
>  			EXOFS_ERR("ERROR: bad page in directory(0x%lx)\n",
>  				  inode->i_ino);
> -			ctx->pos += PAGE_CACHE_SIZE - offset;
> +			ctx->pos += PAGE_SIZE - offset;
>  			return PTR_ERR(page);
>  		}
>  		kaddr = page_address(page);
> @@ -262,7 +262,7 @@ exofs_readdir(struct file *file, struct dir_context *ctx)
>  			if (offset) {
>  				offset = exofs_validate_entry(kaddr, offset,
>  								chunk_mask);
> -				ctx->pos = (n<<PAGE_CACHE_SHIFT) + offset;
> +				ctx->pos = (n<<PAGE_SHIFT) + offset;
>  			}
>  			file->f_version = inode->i_version;
>  			need_revalidate = 0;
> @@ -449,7 +449,7 @@ int exofs_add_link(struct dentry *dentry, struct inode *inode)
>  		kaddr = page_address(page);
>  		dir_end = kaddr + exofs_last_byte(dir, n);
>  		de = (struct exofs_dir_entry *)kaddr;
> -		kaddr += PAGE_CACHE_SIZE - reclen;
> +		kaddr += PAGE_SIZE - reclen;
>  		while ((char *)de <= kaddr) {
>  			if ((char *)de == dir_end) {
>  				name_len = 0;
> @@ -602,7 +602,7 @@ int exofs_make_empty(struct inode *inode, struct inode *parent)
>  	kunmap_atomic(kaddr);
>  	err = exofs_commit_chunk(page, 0, chunk_size);
>  fail:
> -	page_cache_release(page);
> +	put_page(page);
>  	return err;
>  }
>  
> diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
> index 9eaf595aeaf8..49e1bd00b4ec 100644
> --- a/fs/exofs/inode.c
> +++ b/fs/exofs/inode.c
> @@ -317,7 +317,7 @@ static int read_exec(struct page_collect *pcol)
>  
>  	if (!pcol->ios) {
>  		int ret = ore_get_rw_state(&pcol->sbi->layout, &oi->oc, true,
> -					     pcol->pg_first << PAGE_CACHE_SHIFT,
> +					     pcol->pg_first << PAGE_SHIFT,
>  					     pcol->length, &pcol->ios);
>  
>  		if (ret)
> @@ -383,7 +383,7 @@ static int readpage_strip(void *data, struct page *page)
>  	struct inode *inode = pcol->inode;
>  	struct exofs_i_info *oi = exofs_i(inode);
>  	loff_t i_size = i_size_read(inode);
> -	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
> +	pgoff_t end_index = i_size >> PAGE_SHIFT;
>  	size_t len;
>  	int ret;
>  
> @@ -397,9 +397,9 @@ static int readpage_strip(void *data, struct page *page)
>  	pcol->that_locked_page = page;
>  
>  	if (page->index < end_index)
> -		len = PAGE_CACHE_SIZE;
> +		len = PAGE_SIZE;
>  	else if (page->index == end_index)
> -		len = i_size & ~PAGE_CACHE_MASK;
> +		len = i_size & ~PAGE_MASK;
>  	else
>  		len = 0;
>  
> @@ -442,8 +442,8 @@ try_again:
>  			goto fail;
>  	}
>  
> -	if (len != PAGE_CACHE_SIZE)
> -		zero_user(page, len, PAGE_CACHE_SIZE - len);
> +	if (len != PAGE_SIZE)
> +		zero_user(page, len, PAGE_SIZE - len);
>  
>  	EXOFS_DBGMSG2("    readpage_strip(0x%lx, 0x%lx) len=0x%zx\n",
>  		     inode->i_ino, page->index, len);
> @@ -609,7 +609,7 @@ static void __r4w_put_page(void *priv, struct page *page)
>  
>  	if ((pcol->that_locked_page != page) && (ZERO_PAGE(0) != page)) {
>  		EXOFS_DBGMSG2("index=0x%lx\n", page->index);
> -		page_cache_release(page);
> +		put_page(page);
>  		return;
>  	}
>  	EXOFS_DBGMSG2("that_locked_page index=0x%lx\n",
> @@ -633,7 +633,7 @@ static int write_exec(struct page_collect *pcol)
>  
>  	BUG_ON(pcol->ios);
>  	ret = ore_get_rw_state(&pcol->sbi->layout, &oi->oc, false,
> -				 pcol->pg_first << PAGE_CACHE_SHIFT,
> +				 pcol->pg_first << PAGE_SHIFT,
>  				 pcol->length, &pcol->ios);
>  	if (unlikely(ret))
>  		goto err;
> @@ -696,7 +696,7 @@ static int writepage_strip(struct page *page,
>  	struct inode *inode = pcol->inode;
>  	struct exofs_i_info *oi = exofs_i(inode);
>  	loff_t i_size = i_size_read(inode);
> -	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
> +	pgoff_t end_index = i_size >> PAGE_SHIFT;
>  	size_t len;
>  	int ret;
>  
> @@ -708,9 +708,9 @@ static int writepage_strip(struct page *page,
>  
>  	if (page->index < end_index)
>  		/* in this case, the page is within the limits of the file */
> -		len = PAGE_CACHE_SIZE;
> +		len = PAGE_SIZE;
>  	else {
> -		len = i_size & ~PAGE_CACHE_MASK;
> +		len = i_size & ~PAGE_MASK;
>  
>  		if (page->index > end_index || !len) {
>  			/* in this case, the page is outside the limits
> @@ -790,10 +790,10 @@ static int exofs_writepages(struct address_space *mapping,
>  	long start, end, expected_pages;
>  	int ret;
>  
> -	start = wbc->range_start >> PAGE_CACHE_SHIFT;
> +	start = wbc->range_start >> PAGE_SHIFT;
>  	end = (wbc->range_end == LLONG_MAX) ?
>  			start + mapping->nrpages :
> -			wbc->range_end >> PAGE_CACHE_SHIFT;
> +			wbc->range_end >> PAGE_SHIFT;
>  
>  	if (start || end)
>  		expected_pages = end - start + 1;
> @@ -881,15 +881,15 @@ int exofs_write_begin(struct file *file, struct address_space *mapping,
>  	}
>  
>  	 /* read modify write */
> -	if (!PageUptodate(page) && (len != PAGE_CACHE_SIZE)) {
> +	if (!PageUptodate(page) && (len != PAGE_SIZE)) {
>  		loff_t i_size = i_size_read(mapping->host);
> -		pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
> +		pgoff_t end_index = i_size >> PAGE_SHIFT;
>  		size_t rlen;
>  
>  		if (page->index < end_index)
> -			rlen = PAGE_CACHE_SIZE;
> +			rlen = PAGE_SIZE;
>  		else if (page->index == end_index)
> -			rlen = i_size & ~PAGE_CACHE_MASK;
> +			rlen = i_size & ~PAGE_MASK;
>  		else
>  			rlen = 0;
>  
> diff --git a/fs/exofs/namei.c b/fs/exofs/namei.c
> index c20d77df2679..622a686bb08b 100644
> --- a/fs/exofs/namei.c
> +++ b/fs/exofs/namei.c
> @@ -292,11 +292,11 @@ static int exofs_rename(struct inode *old_dir, struct dentry *old_dentry,
>  out_dir:
>  	if (dir_de) {
>  		kunmap(dir_page);
> -		page_cache_release(dir_page);
> +		put_page(dir_page);
>  	}
>  out_old:
>  	kunmap(old_page);
> -	page_cache_release(old_page);
> +	put_page(old_page);
>  out:
>  	return err;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
