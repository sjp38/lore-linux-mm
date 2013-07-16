Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 16 Jul 2013 09:34:50 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH RESEND 2/2] fs/aio: Add support to aio ring pages migration
Message-ID: <20130716133450.GD5403@kvack.org>
References: <51E518C0.2020908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E518C0.2020908@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, tangchen <tangchen@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Tue, Jul 16, 2013 at 05:56:16PM +0800, Gu Zheng wrote:
> As the aio job will pin the ring pages, that will lead to mem migrated
> failed. In order to fix this problem we use an anon inode to manage the aio ring
> pages, and  setup the migratepage callback in the anon inode's address space, so
> that when mem migrating the aio ring pages will be moved to other mem node safely.

There are a few minor issues that needed to be fixed -- see below.  I've 
made these changes and added them to git://git.kvack.org/~bcrl/aio-next.git ,
and will ask for that tree to be included in linux-next.

mm folks: can someone familiar with page migration / hot plug memory please 
review the migration changes?

> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Again, I had not provided my Signed-off-by on this patch previously, so 
don't add it for me.

> ---
>  fs/aio.c                |  120 ++++++++++++++++++++++++++++++++++++++++++----
>  include/linux/migrate.h |    3 +
>  mm/migrate.c            |    2 +-
>  3 files changed, 113 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/aio.c b/fs/aio.c
> index 9b5ca11..d10f956 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -35,6 +35,9 @@
>  #include <linux/eventfd.h>
>  #include <linux/blkdev.h>
>  #include <linux/compat.h>
> +#include <linux/anon_inodes.h>
> +#include <linux/migrate.h>
> +#include <linux/ramfs.h>
>  
>  #include <asm/kmap_types.h>
>  #include <asm/uaccess.h>
> @@ -110,6 +113,7 @@ struct kioctx {
>  	} ____cacheline_aligned_in_smp;
>  
>  	struct page		*internal_pages[AIO_RING_PAGES];
> +	struct file		*aio_ring_file;
>  };
>  
>  /*------ sysctl variables----*/
> @@ -138,15 +142,78 @@ __initcall(aio_setup);
>  
>  static void aio_free_ring(struct kioctx *ctx)
>  {
> -	long i;
> +	int i;
> +	struct file *aio_ring_file = ctx->aio_ring_file;
>  
> -	for (i = 0; i < ctx->nr_pages; i++)
> +	for (i = 0; i < ctx->nr_pages; i++) {
> +		pr_debug("pid(%d) [%d] page->count=%d\n", current->pid, i,
> +				page_count(ctx->ring_pages[i]));
>  		put_page(ctx->ring_pages[i]);
> +	}
>  
>  	if (ctx->ring_pages && ctx->ring_pages != ctx->internal_pages)
>  		kfree(ctx->ring_pages);
> +
> +	if (aio_ring_file) {
> +		truncate_setsize(aio_ring_file->f_inode, 0);
> +		pr_debug("pid(%d) i_nlink=%u d_count=%d d_unhashed=%d i_count=%d\n",
> +			current->pid, aio_ring_file->f_inode->i_nlink,
> +			aio_ring_file->f_path.dentry->d_count,
> +			d_unhashed(aio_ring_file->f_path.dentry),
> +			atomic_read(&aio_ring_file->f_inode->i_count));
> +		fput(aio_ring_file);
> +		ctx->aio_ring_file = NULL;
> +	}
> +}
> +
> +static int aio_ring_mmap(struct file *file, struct vm_area_struct *vma)
> +{
> +	vma->vm_ops = &generic_file_vm_ops;
> +	return 0;
> +}
> +
> +static const struct file_operations aio_ring_fops = {
> +	.mmap = aio_ring_mmap,
> +};
> +
> +static int aio_set_page_dirty(struct page *page)
> +{
> +	return 0;
>  }
>  
> +static int aio_migratepage(struct address_space *mapping, struct page *new,
> +			struct page *old, enum migrate_mode mode)
> +{
> +	struct kioctx *ctx = mapping->private_data;
> +	unsigned long flags;
> +	unsigned idx = old->index;
> +	int rc;
> +
> +	/*Writeback must be complete*/

Missing spaces before/after beginning and end of comment.

> +	BUG_ON(PageWriteback(old));
> +	put_page(old);
> +
> +	rc = migrate_page_move_mapping(mapping, new, old, NULL, mode);
> +	if (rc != MIGRATEPAGE_SUCCESS) {
> +		get_page(old);
> +		return rc;
> +	}
> +
> +	get_page(new);
> +
> +	spin_lock_irqsave(&ctx->completion_lock, flags);
> +	migrate_page_copy(new, old);
> +	ctx->ring_pages[idx] = new;
> +	spin_unlock_irqrestore(&ctx->completion_lock, flags);
> +
> +	return rc;
> +}
> +
> +static const struct address_space_operations aio_ctx_aops = {
> +	.set_page_dirty = aio_set_page_dirty,
> +	.migratepage	= aio_migratepage,
> +};
> +
>  static int aio_setup_ring(struct kioctx *ctx)
>  {
>  	struct aio_ring *ring;
> @@ -154,20 +221,45 @@ static int aio_setup_ring(struct kioctx *ctx)
>  	struct mm_struct *mm = current->mm;
>  	unsigned long size, populate;
>  	int nr_pages;
> +	int i;
> +	struct file *file;
>  
>  	/* Compensate for the ring buffer's head/tail overlap entry */
>  	nr_events += 2;	/* 1 is required, 2 for good luck */
>  
>  	size = sizeof(struct aio_ring);
>  	size += sizeof(struct io_event) * nr_events;
> -	nr_pages = (size + PAGE_SIZE-1) >> PAGE_SHIFT;
>  
> +	nr_pages = (size + PAGE_SIZE-1) >> PAGE_SHIFT;

Hrm, this should probably be replaced by PFN_UP(size) rather than the old 
open coding of same.

>  	if (nr_pages < 0)
>  		return -EINVAL;
>  
> -	nr_events = (PAGE_SIZE * nr_pages - sizeof(struct aio_ring)) / sizeof(struct io_event);
> +	file = anon_inode_getfile_private("[aio]", &aio_ring_fops, ctx, O_RDWR);
> +	if (IS_ERR(file)) {
> +		ctx->aio_ring_file = NULL;
> +		return -EAGAIN;
> +	}
> +
> +	file->f_inode->i_mapping->a_ops = &aio_ctx_aops;
> +	file->f_inode->i_mapping->private_data = ctx;
> +	file->f_inode->i_size = PAGE_SIZE * (loff_t)nr_pages;
> +
> +	for (i = 0; i < nr_pages; i++) {
> +		struct page *page;
> +		page = find_or_create_page(file->f_inode->i_mapping,
> +					   i, GFP_HIGHUSER | __GFP_ZERO);
> +		if (!page)
> +			break;
> +		pr_debug("pid(%d) page[%d]->count=%d\n",
> +			 current->pid, i, page_count(page));
> +		SetPageUptodate(page);
> +		SetPageDirty(page);
> +		unlock_page(page);
> +	}
> +	ctx->aio_ring_file = file;
> +	nr_events = (PAGE_SIZE * nr_pages - sizeof(struct aio_ring))
> +			/ sizeof(struct io_event);
>  
> -	ctx->nr_events = 0;
>  	ctx->ring_pages = ctx->internal_pages;
>  	if (nr_pages > AIO_RING_PAGES) {
>  		ctx->ring_pages = kcalloc(nr_pages, sizeof(struct page *),
> @@ -178,28 +270,31 @@ static int aio_setup_ring(struct kioctx *ctx)
>  
>  	ctx->mmap_size = nr_pages * PAGE_SIZE;
>  	pr_debug("attempting mmap of %lu bytes\n", ctx->mmap_size);
> +
>  	down_write(&mm->mmap_sem);
> -	ctx->mmap_base = do_mmap_pgoff(NULL, 0, ctx->mmap_size,
> -				       PROT_READ|PROT_WRITE,
> -				       MAP_ANONYMOUS|MAP_PRIVATE, 0, &populate);
> +	ctx->mmap_base = do_mmap_pgoff(ctx->aio_ring_file, 0, ctx->mmap_size,
> +				       PROT_READ | PROT_WRITE,
> +				       MAP_SHARED | MAP_POPULATE, 0, &populate);
>  	if (IS_ERR((void *)ctx->mmap_base)) {
>  		up_write(&mm->mmap_sem);
>  		ctx->mmap_size = 0;
>  		aio_free_ring(ctx);
>  		return -EAGAIN;
>  	}
> +	up_write(&mm->mmap_sem);
> +
> +	mm_populate(ctx->mmap_base, populate);
>  
>  	pr_debug("mmap address: 0x%08lx\n", ctx->mmap_base);
>  	ctx->nr_pages = get_user_pages(current, mm, ctx->mmap_base, nr_pages,
>  				       1, 0, ctx->ring_pages, NULL);
> -	up_write(&mm->mmap_sem);
> +	for (i = 0; i < ctx->nr_pages; i++)
> +		put_page(ctx->ring_pages[i]);
>  
>  	if (unlikely(ctx->nr_pages != nr_pages)) {
>  		aio_free_ring(ctx);
>  		return -EAGAIN;
>  	}
> -	if (populate)
> -		mm_populate(ctx->mmap_base, populate);
>  
>  	ctx->user_id = ctx->mmap_base;
>  	ctx->nr_events = nr_events; /* trusted copy */
> @@ -399,6 +494,8 @@ out_cleanup:
>  	err = -EAGAIN;
>  	aio_free_ring(ctx);
>  out_freectx:
> +	if (ctx->aio_ring_file)
> +		fput(ctx->aio_ring_file);
>  	kmem_cache_free(kioctx_cachep, ctx);
>  	pr_debug("error allocating ioctx %d\n", err);
>  	return ERR_PTR(err);
> @@ -852,6 +949,7 @@ SYSCALL_DEFINE2(io_setup, unsigned, nr_events, aio_context_t __user *, ctxp)
>  	ioctx = ioctx_alloc(nr_events);
>  	ret = PTR_ERR(ioctx);
>  	if (!IS_ERR(ioctx)) {
> +		ctx = ioctx->user_id;
>  		ret = put_user(ioctx->user_id, ctxp);
>  		if (ret)
>  			kill_ioctx(ioctx);

This hunk doesn't do anything and needs to be removed.  That should cover 
things.

		-ben

> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index a405d3dc..c407d88 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -55,6 +55,9 @@ extern int migrate_vmas(struct mm_struct *mm,
>  extern void migrate_page_copy(struct page *newpage, struct page *page);
>  extern int migrate_huge_page_move_mapping(struct address_space *mapping,
>  				  struct page *newpage, struct page *page);
> +extern int migrate_page_move_mapping(struct address_space *mapping,
> +		struct page *newpage, struct page *page,
> +		struct buffer_head *head, enum migrate_mode mode);
>  #else
>  
>  static inline void putback_lru_pages(struct list_head *l) {}
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 6f0c244..1da0092 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -307,7 +307,7 @@ static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
>   * 2 for pages with a mapping
>   * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
>   */
> -static int migrate_page_move_mapping(struct address_space *mapping,
> +int migrate_page_move_mapping(struct address_space *mapping,
>  		struct page *newpage, struct page *page,
>  		struct buffer_head *head, enum migrate_mode mode)
>  {
> -- 
> 1.7.7
> 

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
