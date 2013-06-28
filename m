Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51CD5649.8040408@cn.fujitsu.com>
Date: Fri, 28 Jun 2013 17:24:25 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [WiP]: aio support for migrating pages (Re: [PATCH V2 1/2] mm:
 hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable())
References: <20130513091902.GP11497@suse.de> <5191B5B3.7080406@cn.fujitsu.com> <20130515132453.GB11497@suse.de> <5194748A.5070700@cn.fujitsu.com> <20130517002349.GI1008@kvack.org> <5195A3F4.70803@cn.fujitsu.com> <20130517143718.GK1008@kvack.org> <519AD6F8.2070504@cn.fujitsu.com> <20130521022733.GT1008@kvack.org> <51B6F107.80501@cn.fujitsu.com> <20130611144525.GB14404@kvack.org>
In-Reply-To: <20130611144525.GB14404@kvack.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On 06/11/2013 10:45 PM, Benjamin LaHaise wrote:

> Hi Tang,
> 
> On Tue, Jun 11, 2013 at 05:42:31PM +0800, Tang Chen wrote:
>> Hi Benjamin,
>>
>> Are you still working on this problem ?
>>
>> Thanks. :)
> 
> Below is a copy of the most recent version of this patch I have worked 
> on.  This version works and stands up to my testing using move_pages() to 
> force the migration of the aio ring buffer.  A test program is available 
> at http://www.kvack.org/~bcrl/aio/aio-numa-test.c .  Please note that 
> this version is not suitable for mainline as the modifactions to the 

> anon inode code are undesirable, so that part needs reworking.

Hi Ben,
Are you still working on this patch?
As you know, using the current anon inode will lead to more than one instance of
aio can not work. Have you found a way to fix this issue? Or can we use some
other ones to replace the anon inode?

Thanks,
Gu

> 
> 		-ben
> 
> 
>  fs/aio.c                |  113 ++++++++++++++++++++++++++++++++++++++++++++----
>  fs/anon_inodes.c        |   14 ++++-
>  include/linux/migrate.h |    3 +
>  mm/migrate.c            |    2 
>  mm/swap.c               |    1 
>  5 files changed, 121 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/aio.c b/fs/aio.c
> index c5b1a8c..a951690 100644
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
> @@ -108,6 +111,7 @@ struct kioctx {
>  	} ____cacheline_aligned_in_smp;
>  
>  	struct page		*internal_pages[AIO_RING_PAGES];
> +	struct file		*ctx_file;
>  };
>  
>  /*------ sysctl variables----*/
> @@ -136,18 +140,80 @@ __initcall(aio_setup);
>  
>  static void aio_free_ring(struct kioctx *ctx)
>  {
> -	long i;
> -
> -	for (i = 0; i < ctx->nr_pages; i++)
> -		put_page(ctx->ring_pages[i]);
> +	int i;
>  
>  	if (ctx->mmap_size)
>  		vm_munmap(ctx->mmap_base, ctx->mmap_size);
>  
> +	if (ctx->ctx_file)
> +		truncate_setsize(ctx->ctx_file->f_inode, 0);
> +
> +	for (i = 0; i < ctx->nr_pages; i++) {
> +		pr_debug("pid(%d) [%d] page->count=%d\n", current->pid, i,
> +			 page_count(ctx->ring_pages[i]));
> +		put_page(ctx->ring_pages[i]);
> +	}
> +
>  	if (ctx->ring_pages && ctx->ring_pages != ctx->internal_pages)
>  		kfree(ctx->ring_pages);
> +
> +	if (ctx->ctx_file) {
> +		truncate_setsize(ctx->ctx_file->f_inode, 0);
> +		pr_debug("pid(%d) i_nlink=%u d_count=%d, d_unhashed=%d i_count=%d\n",
> +			 current->pid, ctx->ctx_file->f_inode->i_nlink,
> +			 ctx->ctx_file->f_path.dentry->d_count,
> +			 d_unhashed(ctx->ctx_file->f_path.dentry),
> +			 atomic_read(&ctx->ctx_file->f_path.dentry->d_inode->i_count));
> +		fput(ctx->ctx_file);
> +		ctx->ctx_file = NULL;
> +	}
> +}
> +
> +static int aio_ctx_mmap(struct file *file, struct vm_area_struct *vma)
> +{
> +	vma->vm_ops = &generic_file_vm_ops;
> +	return 0;
> +}
> +
> +static const struct file_operations aio_ctx_fops = {
> +	.mmap	= aio_ctx_mmap,
> +};
> +
> +static int aio_set_page_dirty(struct page *page)
> +{
> +	return 0;
> +}
> +
> +static int aio_migratepage(struct address_space *mapping, struct page *new,
> +			   struct page *old, enum migrate_mode mode)
> +{
> +	struct kioctx *ctx = mapping->private_data;
> +	unsigned long flags;
> +	unsigned idx = old->index;
> +	int rc;
> +
> +	BUG_ON(PageWriteback(old));    /* Writeback must be complete */
> +	put_page(old);
> +	rc = migrate_page_move_mapping(mapping, new, old, NULL, mode);
> +	if (rc != MIGRATEPAGE_SUCCESS) {
> +		get_page(old);
> +		return rc;
> +	}
> +	get_page(new);
> +
> +	spin_lock_irqsave(&ctx->completion_lock, flags);
> +	migrate_page_copy(new, old);
> +	ctx->ring_pages[idx] = new;
> +	spin_unlock_irqrestore(&ctx->completion_lock, flags);
> +
> +	return MIGRATEPAGE_SUCCESS;
>  }
>  
> +static const struct address_space_operations aio_ctx_aops = {
> +	.set_page_dirty = aio_set_page_dirty,
> +	.migratepage	= aio_migratepage,
> +};
> +
>  static int aio_setup_ring(struct kioctx *ctx)
>  {
>  	struct aio_ring *ring;
> @@ -155,6 +221,7 @@ static int aio_setup_ring(struct kioctx *ctx)
>  	struct mm_struct *mm = current->mm;
>  	unsigned long size, populate;
>  	int nr_pages;
> +	int i;
>  
>  	/* Compensate for the ring buffer's head/tail overlap entry */
>  	nr_events += 2;	/* 1 is required, 2 for good luck */
> @@ -166,6 +233,28 @@ static int aio_setup_ring(struct kioctx *ctx)
>  	if (nr_pages < 0)
>  		return -EINVAL;
>  
> +	ctx->ctx_file = anon_inode_getfile("[aio]", &aio_ctx_fops, ctx, O_RDWR);
> +	if (IS_ERR(ctx->ctx_file)) {
> +		ctx->ctx_file = NULL;
> +		return -EAGAIN;
> +	}
> +	ctx->ctx_file->f_inode->i_mapping->a_ops = &aio_ctx_aops;
> +	ctx->ctx_file->f_inode->i_mapping->private_data = ctx;
> +	ctx->ctx_file->f_inode->i_size = PAGE_SIZE * (loff_t)nr_pages;
> +
> +	for (i=0; i<nr_pages; i++) {
> +		struct page *page;
> +		page = find_or_create_page(ctx->ctx_file->f_inode->i_mapping,
> +					   i, GFP_HIGHUSER | __GFP_ZERO);
> +		if (!page)
> +			break;
> +		pr_debug("pid(%d) page[%d]->count=%d\n",
> +			 current->pid, i, page_count(page));
> +		SetPageUptodate(page);
> +		SetPageDirty(page);
> +		unlock_page(page);
> +	}
> +
>  	nr_events = (PAGE_SIZE * nr_pages - sizeof(struct aio_ring)) / sizeof(struct io_event);
>  
>  	ctx->nr_events = 0;
> @@ -180,20 +269,25 @@ static int aio_setup_ring(struct kioctx *ctx)
>  	ctx->mmap_size = nr_pages * PAGE_SIZE;
>  	pr_debug("attempting mmap of %lu bytes\n", ctx->mmap_size);
>  	down_write(&mm->mmap_sem);
> -	ctx->mmap_base = do_mmap_pgoff(NULL, 0, ctx->mmap_size,
> -				       PROT_READ|PROT_WRITE,
> -				       MAP_ANONYMOUS|MAP_PRIVATE, 0, &populate);
> +	ctx->mmap_base = do_mmap_pgoff(ctx->ctx_file, 0, ctx->mmap_size,
> +				       PROT_READ | PROT_WRITE,
> +				       MAP_SHARED | MAP_POPULATE, 0,
> +				       &populate);
>  	if (IS_ERR((void *)ctx->mmap_base)) {
>  		up_write(&mm->mmap_sem);
>  		ctx->mmap_size = 0;
>  		aio_free_ring(ctx);
>  		return -EAGAIN;
>  	}
> +	up_write(&mm->mmap_sem);
> +	mm_populate(ctx->mmap_base, populate);
>  
>  	pr_debug("mmap address: 0x%08lx\n", ctx->mmap_base);
>  	ctx->nr_pages = get_user_pages(current, mm, ctx->mmap_base, nr_pages,
>  				       1, 0, ctx->ring_pages, NULL);
> -	up_write(&mm->mmap_sem);
> +	for (i=0; i<ctx->nr_pages; i++) {
> +		put_page(ctx->ring_pages[i]);
> +	}
>  
>  	if (unlikely(ctx->nr_pages != nr_pages)) {
>  		aio_free_ring(ctx);
> @@ -403,6 +497,8 @@ out_cleanup:
>  	err = -EAGAIN;
>  	aio_free_ring(ctx);
>  out_freectx:
> +	if (ctx->ctx_file)
> +		fput(ctx->ctx_file);
>  	kmem_cache_free(kioctx_cachep, ctx);
>  	pr_debug("error allocating ioctx %d\n", err);
>  	return ERR_PTR(err);
> @@ -852,6 +948,7 @@ SYSCALL_DEFINE2(io_setup, unsigned, nr_events, aio_context_t __user *, ctxp)
>  	ioctx = ioctx_alloc(nr_events);
>  	ret = PTR_ERR(ioctx);
>  	if (!IS_ERR(ioctx)) {
> +		ctx = ioctx->user_id;
>  		ret = put_user(ioctx->user_id, ctxp);
>  		if (ret)
>  			kill_ioctx(ioctx);
> diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
> index 47a65df..376d289 100644
> --- a/fs/anon_inodes.c
> +++ b/fs/anon_inodes.c
> @@ -131,6 +131,7 @@ struct file *anon_inode_getfile(const char *name,
>  	struct qstr this;
>  	struct path path;
>  	struct file *file;
> +	struct inode *inode;
>  
>  	if (IS_ERR(anon_inode_inode))
>  		return ERR_PTR(-ENODEV);
> @@ -138,6 +139,12 @@ struct file *anon_inode_getfile(const char *name,
>  	if (fops->owner && !try_module_get(fops->owner))
>  		return ERR_PTR(-ENOENT);
>  
> +	inode = anon_inode_mkinode(anon_inode_inode->i_sb);
> +	if (IS_ERR(inode)) {
> +		file = ERR_PTR(-ENOMEM);
> +		goto err_module;
> +	}
> +
>  	/*
>  	 * Link the inode to a directory entry by creating a unique name
>  	 * using the inode sequence number.
> @@ -155,17 +162,18 @@ struct file *anon_inode_getfile(const char *name,
>  	 * We know the anon_inode inode count is always greater than zero,
>  	 * so ihold() is safe.
>  	 */
> -	ihold(anon_inode_inode);
> +	//ihold(inode);
>  
> -	d_instantiate(path.dentry, anon_inode_inode);
> +	d_instantiate(path.dentry, inode);
>  
>  	file = alloc_file(&path, OPEN_FMODE(flags), fops);
>  	if (IS_ERR(file))
>  		goto err_dput;
> -	file->f_mapping = anon_inode_inode->i_mapping;
> +	file->f_mapping = inode->i_mapping;
>  
>  	file->f_flags = flags & (O_ACCMODE | O_NONBLOCK);
>  	file->private_data = priv;
> +	drop_nlink(inode);
>  
>  	return file;
>  
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index a405d3dc..b6f3289 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -55,6 +55,9 @@ extern int migrate_vmas(struct mm_struct *mm,
>  extern void migrate_page_copy(struct page *newpage, struct page *page);
>  extern int migrate_huge_page_move_mapping(struct address_space *mapping,
>  				  struct page *newpage, struct page *page);
> +extern int migrate_page_move_mapping(struct address_space *mapping,
> +                struct page *newpage, struct page *page,
> +                struct buffer_head *head, enum migrate_mode mode);
>  #else
>  
>  static inline void putback_lru_pages(struct list_head *l) {}
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 27ed225..ac9c3a9 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -294,7 +294,7 @@ static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
>   * 2 for pages with a mapping
>   * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
>   */
> -static int migrate_page_move_mapping(struct address_space *mapping,
> +int migrate_page_move_mapping(struct address_space *mapping,
>  		struct page *newpage, struct page *page,
>  		struct buffer_head *head, enum migrate_mode mode)
>  {
> diff --git a/mm/swap.c b/mm/swap.c
> index dfd7d71..bbfba0a 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -160,6 +160,7 @@ skip_lock_tail:
>  
>  void put_page(struct page *page)
>  {
> +	BUG_ON(page_count(page) <= 0);
>  	if (unlikely(PageCompound(page)))
>  		put_compound_page(page);
>  	else if (put_page_testzero(page))
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
