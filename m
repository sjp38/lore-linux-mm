Date: Mon, 30 Apr 2007 11:48:07 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Antifrag patches may benefit from clean up of GFP allocation
 flags
In-Reply-To: <Pine.LNX.4.64.0704292157200.1863@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0704301037420.32439@skynet.skynet.ie>
References: <Pine.LNX.4.64.0704292157200.1863@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 29 Apr 2007, Christoph Lameter wrote:

> I looked some more into how the flags are used with the antifrag patches

That's good.

> and I am a bit concerned.

That's not so good :) . That said, much of the feedback deals with the 
logical progression of the patches rather than critical flaws in the 
concept.

> This is rather complicated and may confuse
> people like it did me. In particular the use of __GFP_RECLAIMABLE for
> short term allocs etc. We need to have some clear definitions of
> allocation categories.
>

Ok.

> Could we have some easier to understand categories? Maybe some more.

More means that there are more migrate types, a bigger bitmap and so on. 
However, lets look through anyway. It seems that some of the flags would 
act as documentation artifacts without needing to be treated as special 
groupings.

> They
> can be assigned via #define to the antifrag categories supported. Define
> some new GFP_xxx types?
>
> F.e.
>
> GFP_PERSISTENT		Long term allocation
>

I don't think this one is needed. It's currently covered by specifying no 
mobility flag at all so GFP_KERNEL == GFP_PERSISTENT for example. Pages 
allocated for modules loading would fall into the same category.

The flag could be defined but act as documentation only.

> GFP_TEMPORARY		Short term allocation that is going to be
> 			removed by the subsystem performing the alloc
> 			on its own.
>

I have mixed feelings on this.

Temporary allocations are obviously short-lived. That means that areas 
reserved for them will tend to be sparse and because of that will be used 
by other allocation types and "stolen" when memory is low. The temporary 
allocations will then start falling back elsewhere because their reserved 
blocks were full. HIGHALLOC had this problem and even when dealt with, it 
was a bit of a mess.

What I can do to start with is define __GFP_TEMPORARY but give it the same 
value as __GFP_RECLAIMABLE. This would be for documentation purposes and 
later I'll group them separetly and see do they behave like HIGHALLOC 
blocks or not.

> GFP_RECLAIMABLE		Allocation that requires a reclaim function
> 			to be called in the subsystem that performed
> 			the allocation. Many slab allocations fall
> 			into that category.
>

Many of the current users of __GFP_RECLAIMABLE cannot be collapsed into a 
single flag like this which is why it was never defined. However, with 
SLAB_RECLAIM_ACCOUNT, it will make sense.

> GFP_MOVABLE		Allocation of a page that can be moved/reclaimed
> 			in a targeted way by just performing operations
> 			on the page itself.
>

Nice description of MOVABLE.

Currently there would only be one user of this and it's bdget(). It's on 
the TODO list to determine if this is even doing the right thing or not so 
I'll hold off on GFP_MOVABLE for the moment. GFP_HIGH_MOVABLE is the 
current flag of interest here. From what you say later, GFP_HIGH_MOVABLE 
should be renamed to GFP_HIGHUSER_MOVABLE because GFP_HIGH could be 
misinterpreted.

> Maybe then have corresponding slab flags that make the slab
> allocations pass the corresponding flag to the page allocator? The meaning
> may be slightly different.
>
> SLAB_PERSISTENT		Objects are allocated for good. The slab allocator
> 			can then make sure that these objects are allocated
> 	 		with maximum density even sacrificing some alloc
> 			performance.
>

As they will currently be treated as UNMOVABLE, I think we're ok here but 
I've added it to the TODO list to check out later. What I'm missing here 
is if SLUB would benefit by having all these persistent slabs together. I 
vagely recall that SLUB does something special with packing (for lock 
reduction maybe?). Care to comment?

> SLAB_TEMPORARY		Objects are temporary and will be gone soon.
> 			This is true for networking packets etc.
> 			The slab can then waste more memory on allocation
> 			structures to make sure that no contention occurs.
> 			Larger sets of free objects may be kept around.
>

Like __GFP_RECLAIMABLE vs __GFP_TEMPORARY, I'll define it as a 
documentation thing and then split them out later to see what it looks 
like at runtime.

> SLAB_RECLAIMABLE	Slab reclaim functions can be run that will
> 			free up batches of slabs. This is the traditional
> 			slab shrinking.
>

Right, this makes sense.

> SLAB_MOVABLE		The slabcache has a callback function that allows
> 			targeted object moving or removal. The antifrag
> 			functionality can selectively kick out such a
> 			page in the same way as a page allocated via
> 			GFP_MOVABLE.
>

Are there any slabs that can be treated like this today?

> I looked through the kernel sources and also saw that the flags are not
> consistently changed. In many locations temporary allocs are not flagged.
>

I didn't do a full audit for these type of allocations. I only caught the 
ones that I knew were occuring on my test machines but I'll use your patch 
to improve the situation. This is something I see improving over time.

> Following is a patch that gives some idea how this might be done.
> Note that the difference between GFP_USER and GFP_KERNEL is only in how
> the cpuset boundaries are handled. That is irrelevant for a temporary
> allocation. It may even be considered safe to not fail on cpuset limit
> violation for a temporary kernel alloc. It will be gone soon and it is
> better not to fail.
>

Ok, the patch looks pretty clear. I'll use it as a starting point for the 
GFP_TEMPORARY work. Thanks a lot.

> It may be best to first perform an audit of the GFP flags.
> There are certain confusions that should be cleaned up first. F.e.
>
> GFP_HIGH and GFP_HIGHUSER
>
> are not related as one would expect. GFP_HIGHUSER implies a HIGHMEM
> allocation whereas GFP_HIGH is a HIGH priority alloc that can tap into
> reserves.
>

Added to the (rapidly growing) TODO list.

> Also I wish there would be some /proc file system where one would be able
> to see the categories of memory in use. The availability of that data
> may help to guide the antifrag/defrag activities of the page allocator.
>

I actually use external kernel modules to gather this sort of information. 
For a while I was also using PAGE_OWNER to export additional information 
so I knew where everything was coming from. They modules are totally 
unsuitable in the kernel though. I'll take a closer look at how the 
/proc/pid/pagemap interface is implemented and see can I do something 
similar.

It might also be doable as a systemtap script if the kernel code to do the 
job looks insane.

> Information that I would expect to be in such a proc file are:
>
> 1. Number of pages in all the categories mentioned above. This should
>   include the pages available and the pages allocated in that category.
>

Ok, that is doable and I've used patches along those lines in the past but 
never submitted them because "no one will care". Should they always be 
available or only when DEBUG_VM is set? Counting them may be expensive you 
see because it would affect the per-cpu allocator paths but it'll be easy 
to detect.

> 2. The number of pages allocated would need to track the various orders
>   of pages available in a certain category. This includes higher order
>   pages allocated via GFP_COMP. Having both the number of used pages
>   of a page order and the number of free pages of the same page order
>   will help the allocator to decide when a shortness of pages of a
>   certain order is occurring.
>

Ok, makes sense.

> 3. Display for each order how many pages can still be allocated.
>

That is much harder because it all depends on how many pages in an area 
can be freed. It may be possible to figure it out by scanning memory 
similar to what lumpy reclaim does. It'll be expensive but I guess it 
would be very rarely used.

My TODO list based on this feedback looks like;

1. Deprecate alloc_zeroed_user_highpage()

2. Use SLAB_ACCOUNT_RECLAIMBLE to set __GFP_RECLAIMABLE instead of setting
    flags individually

3. Add a GFP_TEMPORARY and SLAB_TEMPORARY for short-lived allocations. For
    the moment, alias it to *_RECLAIMABLE.

4. Group based on blocks smaller than MAX_ORDER_NR_PAGES. Test on IA64 with
    64K hugepages

5. Export stats on anti-frag to userspace. See Christophs mail for a list
    of what is needed.

7. Audit GFP Flag usage ofr confused usage - e.g. GFP_HIGH and GFP_HIGHUSER.
    Consider renaming GFP_HIGH_MOVABLE to GFP_HIGHUSER_MOVABLE

8. Check that bdget() is really doing the right thing with respect to
    __GFP_RECLAIMABLE. If mapped by user they are reclaimable. If mapped
    by filesystem for metadata, they aren't.

9. Treat __GFP_TEMPORARY as a separate type. Determine if tends to bounce
   around because the temporary blocks get stolen by other types

10. Are radix trees indirectly reclaimable?

11. Check if SLAB_PERSISTENT would be useful

12. Try sizing ZONE_MOVABLE at runtime.

Thanks

>
> Index: linux-2.6.21-rc7-mm2/fs/proc/base.c
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/fs/proc/base.c	2007-04-29 16:12:16.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/fs/proc/base.c	2007-04-29 16:26:00.000000000 -0700
> @@ -388,7 +388,7 @@ static int __mounts_open(struct inode *i
> 		p = kmalloc(sizeof(struct proc_mounts), GFP_KERNEL);
> 		if (p) {
> 			file->private_data = &p->m;
> -			p->page = (void *)__get_free_page(GFP_KERNEL);
> +			p->page = (void *)__get_free_page(GFP_TEMPORARY);
> 			if (p->page)
> 				ret = seq_open(file, seq_ops);
> 			if (!ret) {
> @@ -479,7 +479,7 @@ static ssize_t proc_info_read(struct fil
> 		count = PROC_BLOCK_SIZE;
>
> 	length = -ENOMEM;
> -	if (!(page = __get_free_page(GFP_KERNEL|__GFP_RECLAIMABLE)))
> +	if (!(page = __get_free_page(GFP_TEMPORARY)))
> 		goto out;
>
> 	length = PROC_I(inode)->op.proc_read(task, (char*)page);
> @@ -519,7 +519,7 @@ static ssize_t mem_read(struct file * fi
> 		goto out;
>
> 	ret = -ENOMEM;
> -	page = (char *)__get_free_page(GFP_USER);
> +	page = (char *)__get_free_page(GFP_TEMPORARY);
> 	if (!page)
> 		goto out;
>
> @@ -589,7 +589,7 @@ static ssize_t mem_write(struct file * f
> 		goto out;
>
> 	copied = -ENOMEM;
> -	page = (char *)__get_free_page(GFP_USER|__GFP_RECLAIMABLE);
> +	page = (char *)__get_free_page(GFP_TEMPORARY);
> 	if (!page)
> 		goto out;
>
> @@ -746,7 +746,7 @@ static ssize_t proc_loginuid_write(struc
> 		/* No partial writes. */
> 		return -EINVAL;
> 	}
> -	page = (char*)__get_free_page(GFP_USER|__GFP_RECLAIMABLE);
> +	page = (char*)__get_free_page(GFP_TEMPORARY);
> 	if (!page)
> 		return -ENOMEM;
> 	length = -EFAULT;
> @@ -928,7 +928,7 @@ static int do_proc_readlink(struct dentr
> 			    char __user *buffer, int buflen)
> {
> 	struct inode * inode;
> -	char *tmp = (char*)__get_free_page(GFP_KERNEL|__GFP_RECLAIMABLE);
> +	char *tmp = (char*)__get_free_page(GFP_TEMPORARY);
> 	char *path;
> 	int len;
>
> @@ -1701,7 +1701,7 @@ static ssize_t proc_pid_attr_write(struc
> 		goto out;
>
> 	length = -ENOMEM;
> -	page = (char*)__get_free_page(GFP_USER|__GFP_RECLAIMABLE);
> +	page = (char*)__get_free_page(GFP_TEMPORARY);
> 	if (!page)
> 		goto out;
>
> Index: linux-2.6.21-rc7-mm2/include/linux/gfp.h
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/include/linux/gfp.h	2007-04-29 15:53:43.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/include/linux/gfp.h	2007-04-29 16:07:19.000000000 -0700
> @@ -85,6 +85,10 @@ struct vm_area_struct;
> #define GFP_THISNODE	((__force gfp_t)0)
> #endif
>
> +#define GFP_PERSISTENT	(GFP_KERNEL)
> +#define GFP_TEMPORARY	(GFP_KERNEL | __GFP_RECLAIMABLE)
> +#define GFP_RECLAIMABLE	(GFP_KERNEL | __GFP_RECLAIMABLE)
> +#define GFP_MOVABLE	(GFP_KERNEL | __GFP_MOVABLE)
>
> /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
>    platforms, used as appropriate on others */
> Index: linux-2.6.21-rc7-mm2/include/linux/slab.h
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/include/linux/slab.h	2007-04-29 15:55:05.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/include/linux/slab.h	2007-04-29 16:06:40.000000000 -0700
> @@ -26,12 +26,18 @@ typedef struct kmem_cache kmem_cache_t _
> #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
> #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
> #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
> -#define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
> #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
> #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
> #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
> #define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
>
> +#define SLAB_PERSISTENT		0x00001000UL	/* Very long lived object */
> +#define SLAB_TEMPORARY		0x00008000UL	/* Objects are short lived */
> +#define SLAB_RECLAIMABLE	0x00020000UL	/* Objects are reclaimable */
> +#define SLAB_MOVABLE		0x00000200UL	/* Callback exists to remove / move objects */
> +
> +#define SLAB_RECLAIM_ACCOUNT	SLAB_RECLAIM
> +
> /* Flags passed to a constructor functions */
> #define SLAB_CTOR_CONSTRUCTOR	0x001UL		/* If not set, then deconstructor */
>
> Index: linux-2.6.21-rc7-mm2/drivers/block/acsi_slm.c
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/drivers/block/acsi_slm.c	2007-04-29 16:19:55.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/drivers/block/acsi_slm.c	2007-04-29 16:20:21.000000000 -0700
> @@ -367,7 +367,7 @@ static ssize_t slm_read( struct file *fi
> 	int length;
> 	int end;
>
> -	if (!(page = __get_free_page( GFP_KERNEL )))
> +	if (!(page = __get_free_page(GFP_TEMPORARY)))
> 		return( -ENOMEM );
>
> 	length = slm_getstats( (char *)page, iminor(node) );
> Index: linux-2.6.21-rc7-mm2/mm/slub.c
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/mm/slub.c	2007-04-29 16:20:37.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/mm/slub.c	2007-04-29 16:21:34.000000000 -0700
> @@ -2688,7 +2688,7 @@ static int alloc_loc_track(struct loc_tr
>
> 	order = get_order(sizeof(struct location) * max);
>
> -	l = (void *)__get_free_pages(GFP_KERNEL, order);
> +	l = (void *)__get_free_pages(GFP_TEMPORARY, order);
>
> 	if (!l)
> 		return 0;
> Index: linux-2.6.21-rc7-mm2/fs/proc/generic.c
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/fs/proc/generic.c	2007-04-29 16:26:50.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/fs/proc/generic.c	2007-04-29 16:27:09.000000000 -0700
> @@ -74,7 +74,7 @@ proc_file_read(struct file *file, char _
> 		nbytes = MAX_NON_LFS - pos;
>
> 	dp = PDE(inode);
> -	if (!(page = (char*) __get_free_page(GFP_KERNEL|__GFP_RECLAIMABLE)))
> +	if (!(page = (char*) __get_free_page(GFP_TEMPORARY)))
> 		return -ENOMEM;
>
> 	while ((nbytes > 0) && !eof) {
> Index: linux-2.6.21-rc7-mm2/fs/proc/proc_misc.c
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/fs/proc/proc_misc.c	2007-04-29 16:27:45.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/fs/proc/proc_misc.c	2007-04-29 16:28:35.000000000 -0700
> @@ -678,7 +678,7 @@ static ssize_t kpagemap_read(struct file
> 	if (src & KPMMASK || count & KPMMASK)
> 		return -EIO;
>
> -	page = (unsigned long *)__get_free_page(GFP_USER);
> +	page = (unsigned long *)__get_free_page(GFP_TEMPORARY);
> 	if (!page)
> 		return -ENOMEM;
>
> Index: linux-2.6.21-rc7-mm2/kernel/cpuset.c
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/kernel/cpuset.c	2007-04-29 16:28:39.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/kernel/cpuset.c	2007-04-29 16:28:53.000000000 -0700
> @@ -1361,7 +1361,7 @@ static ssize_t cpuset_common_file_read(s
> 	ssize_t retval = 0;
> 	char *s;
>
> -	if (!(page = (char *)__get_free_page(GFP_KERNEL)))
> +	if (!(page = (char *)__get_free_page(GFP_TEMPORARY)))
> 		return -ENOMEM;
>
> 	s = page;
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
