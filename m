Date: Tue, 12 Oct 2004 07:35:00 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <20041012103500.GA3168@logos.cnet>
References: <20041008100010.GB16028@logos.cnet> <20041008.212319.19886370.taka@valinux.co.jp> <20041008124149.GI16028@logos.cnet> <20041009.015239.74741436.taka@valinux.co.jp> <20041008153646.GJ16028@logos.cnet> <20041012105657.D1D0670463@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041012105657.D1D0670463@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 12, 2004 at 07:56:57PM +0900, IWAMOTO Toshihiro wrote:
> At Fri, 8 Oct 2004 12:36:46 -0300,
> Marcelo Tosatti wrote:
> > 
> > On Sat, Oct 09, 2004 at 01:52:39AM +0900, Hirokazu Takahashi wrote:
> > > Hi, Marcelo.
> > > 
> > > > > > > > That is, if we can't migrate the page, try to write it out?
> > > > > > 
> > > > > > I just didnt understand the logic very well, maybe I should just 
> > > > > > go reread the code.
> > > > > > 
> > > > > > Thanks!
> > > > 
> > > > I'm thinking about how to implement a nonblocking version of generic_migrate_page().
> > > > 
> > > > For this purpose its really bad to allocate swap space to anonymous pages, well
> > > > need to figure out someother way of blocking the users via pagetablefault.
> > > > 
> > > > Like a "virtual" swap space but without allocating swap map space. 
> > > 
> > > I've also ever thought to implement such a device.
> > > It would be nice if you can design it simple.
> > > 
> > > Mr.Iwamoto thought otherwise and posted another opinion on the lhms
> > > list, though. I felt it also has a point.
> > > 
> > > iwamoto> I don't think requiring swap is a big deal.  If you don't have a
> > > iwamoto> dedicated swap device, which case I think unusual, you can swapon a
> > > iwamoto> regular file.
> > 
> > Sure its not a big deal, but nicer if it doesnt require swap.
> 
> > For memory defragmentation it is a big deal.
> 
> Why?  IMO, it isn't very rewarding to tune memory
> migration/defragmentation performance as they involve memory copy
> anyway.

Hi Iwamoto,

Oh yes, they already involve memory copy, but then if they use swap
its worse!

> Or, do you want memory defragmentation everywhere, including embedded
> systems?

Yes I want defragmentation everywhere!

The thing is grabbing swap pages for memory migration is 
not a very optimal operation.

First, we interfere with swap allocation patterns (if true
swap is going on at the moment, we screw up is performance). 

We are probably also not going to use that swap space, 
there is no point in allocating it.

And finally if we run out of swap space, we are dead. 

Sure, it works fine with all this restrictions, but it would
be an advantage if we didnt had such swap usage overhead for memory
migration.

I'm writting a "migration cache" - its basically a swapcache without
backing store, instead we use idr (lib/idr.c) to allocate the offsets.

It will be much faster and not interfere with swap space.

I'll use one bit of "swap type" to identify such "migration pte's".

I'll test it with memory migration operation first then with 
memory defragmentation.

Hope it works fine.


struct idr migration_idr;
struct address_space migration_space = {
        .page_tree      = RADIX_TREE_INIT(GFP_ATOMIC),
        .tree_lock      = RW_LOCK_UNLOCKED,
        .a_ops          = NULL,
        .flags          = GFP_HIGHUSER,
        .i_mmap_nonlinear = LIST_HEAD_INIT(migration_space.i_mmap_nonlinear),
        .backing_dev_info = NULL,
};

int init_migration_cache(void) 
{
	idr_init(&migration_idr);

	printk(KERN_INFO "Initializating migration cache!\n");

}

__initcall(init_migration_cache);

struct page *lookup_migration_cache(int id) { 
	return find_get_page(&migration_space, id);
}

int remove_from_migration_cache(struct page *page, int id)
{
	write_lock_irq(&migration_space.tree_lock);
        idr_remove(&migration_idr, id);
	radix_tree_delete(&migration_space.page_tree, id);
	write_unlock_irq(&migration_space.tree_lock);
}

int add_to_migration_cache(struct page *page) 
{
	int error, offset;
	int gfp_mask = GFP_KERNEL;

	BUG_ON(PageSwapCache(page));
	BUG_ON(PagePrivate(page));

        if (idr_pre_get(&migration_idr, GFP_ATOMIC) == 0)
                return -ENOMEM;

	error = radix_tree_preload(gfp_mask);

	if (!error) {
		write_lock_irq(&migration_space.tree_lock);
	        error = idr_get_new(&migration_idr, NULL, &offset);

		error = radix_tree_insert(&migration_space.page_tree, offset,
							page);

		if (!error) {
			page_cache_get(page);
			SetPageLocked(page);
			page->private = offset;
			page->mapping = &migration_space;
		}
		write_unlock_irq(&migration_cache.tree_lock);
                radix_tree_preload_end();

	}

	return error;
}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
