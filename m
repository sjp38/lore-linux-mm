Date: Wed, 13 Oct 2004 02:55:23 +0900 (JST)
Message-Id: <20041013.025523.74732789.taka@valinux.co.jp>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041012103500.GA3168@logos.cnet>
References: <20041008153646.GJ16028@logos.cnet>
	<20041012105657.D1D0670463@sv1.valinux.co.jp>
	<20041012103500.GA3168@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: iwamoto@valinux.co.jp, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> It will be much faster and not interfere with swap space.
> 
> I'll use one bit of "swap type" to identify such "migration pte's".
>
> I'll test it with memory migration operation first then with 
> memory defragmentation.
> 
> Hope it works fine.

IMHO, if one "swap type" is reserved for it, a target page can be
inserted in swapper_space directly. I guess it may be possible to
reuse the swapper_space and some of the existing codes, which should
be moved out of #ifdef CONFIG_SWAP though.

> struct idr migration_idr;
> struct address_space migration_space = {
>         .page_tree      = RADIX_TREE_INIT(GFP_ATOMIC),
>         .tree_lock      = RW_LOCK_UNLOCKED,
>         .a_ops          = NULL,
>         .flags          = GFP_HIGHUSER,
>         .i_mmap_nonlinear = LIST_HEAD_INIT(migration_space.i_mmap_nonlinear),
>         .backing_dev_info = NULL,
> };
> 
> int init_migration_cache(void) 
> {
> 	idr_init(&migration_idr);
> 
> 	printk(KERN_INFO "Initializating migration cache!\n");
> 
> }
> 
> __initcall(init_migration_cache);
> 
> struct page *lookup_migration_cache(int id) { 
> 	return find_get_page(&migration_space, id);
> }
> 
> int remove_from_migration_cache(struct page *page, int id)
> {
> 	write_lock_irq(&migration_space.tree_lock);
>         idr_remove(&migration_idr, id);
> 	radix_tree_delete(&migration_space.page_tree, id);
> 	write_unlock_irq(&migration_space.tree_lock);
> }
> 
> int add_to_migration_cache(struct page *page) 
> {
> 	int error, offset;
> 	int gfp_mask = GFP_KERNEL;
> 
> 	BUG_ON(PageSwapCache(page));
> 	BUG_ON(PagePrivate(page));
> 
>         if (idr_pre_get(&migration_idr, GFP_ATOMIC) == 0)
>                 return -ENOMEM;

I guess GFP_KERNEL is enough.

> 	error = radix_tree_preload(gfp_mask);
> 
> 	if (!error) {
> 		write_lock_irq(&migration_space.tree_lock);
> 	        error = idr_get_new(&migration_idr, NULL, &offset);
> 
> 		error = radix_tree_insert(&migration_space.page_tree, offset,
> 							page);
> 
> 		if (!error) {
> 			page_cache_get(page);
> 			SetPageLocked(page);
> 			page->private = offset;
> 			page->mapping = &migration_space;
> 		}
> 		write_unlock_irq(&migration_cache.tree_lock);
>                 radix_tree_preload_end();
> 
> 	}
> 
> 	return error;
> }
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
