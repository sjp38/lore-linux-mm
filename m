Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D22FB2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 04:12:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b189so6015994wmb.12
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 01:12:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si9978331wmf.53.2017.06.30.01.12.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 01:12:49 -0700 (PDT)
Date: Fri, 30 Jun 2017 10:12:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmalloc: respect the GFP_NOIO and GFP_NOFS flags
Message-ID: <20170630081245.GA22917@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Andreas Dilger <adilger@dilger.ca>, John Hubbard <jhubbard@nvidia.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

On Thu 29-06-17 22:25:09, Mikulas Patocka wrote:
> The __vmalloc function has a parameter gfp_mask with the allocation flags,
> however it doesn't fully respect the GFP_NOIO and GFP_NOFS flags. The
> pages are allocated with the specified gfp flags, but the pagetables are
> always allocated with GFP_KERNEL. This allocation can cause unexpected
> recursion into the filesystem or I/O subsystem.
> 
> It is not practical to extend page table allocation routines with gfp
> flags because it would require modification of architecture-specific code
> in all architecturs. However, the process can temporarily request that all
> allocations are done with GFP_NOFS or GFP_NOIO with with the functions
> memalloc_nofs_save and memalloc_noio_save.
> 
> This patch makes the vmalloc code use memalloc_nofs_save or
> memalloc_noio_save if the supplied gfp flags do not contain __GFP_FS or
> __GFP_IO. It fixes some possible deadlocks in drivers/mtd/ubi/io.c,
> fs/gfs2/, fs/btrfs/free-space-tree.c, fs/ubifs/,
> fs/nfs/blocklayout/extent_tree.c where __vmalloc is used with the GFP_NOFS
> flag.

I strongly believe this is a step in the _wrong_ direction. Why? Because
the memalloc_no{io,fs}_save API is for the scope allocation context. We
want users of the scope to define it and document why it is needed.
GFP_NOFS (I haven't checked GFP_NOIO users) is overused a _lot_ mostly
based on the filesystem should rather use it to prevent deadlock cargo
cult. This should change longterm because heavy fs workloads can cause
troubles to the memory reclaim. So we really want to encourage those
users to define nofs scopes (e.g. on journal locked contexts etc.)
rather than have them use the GFP_NOFS explicitly and very often
mindlessly.

I am not going to nack this patch because it not incorrect but I would
really like to discourage you from it because while it saves 24 lines of
code it (ab)uses the scope allocation context at a wrong layer.

> The patch also simplifies code in dm-bufio.c, dm-ioctl.c and fs/xfs/kmem.c
> by removing explicit calls to memalloc_nofs_save and memalloc_noio_save
> before the call to __vmalloc.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> 
> ---
>  drivers/md/dm-bufio.c |   24 +-----------------------
>  drivers/md/dm-ioctl.c |    6 +-----
>  fs/xfs/kmem.c         |   14 --------------
>  mm/util.c             |    6 +++---
>  mm/vmalloc.c          |   18 +++++++++++++++++-
>  5 files changed, 22 insertions(+), 46 deletions(-)
> 
> Index: linux-2.6/mm/vmalloc.c
> ===================================================================
> --- linux-2.6.orig/mm/vmalloc.c
> +++ linux-2.6/mm/vmalloc.c
> @@ -31,6 +31,7 @@
>  #include <linux/compiler.h>
>  #include <linux/llist.h>
>  #include <linux/bitops.h>
> +#include <linux/sched/mm.h>
>  
>  #include <linux/uaccess.h>
>  #include <asm/tlbflush.h>
> @@ -1670,6 +1671,8 @@ static void *__vmalloc_area_node(struct
>  	unsigned int nr_pages, array_size, i;
>  	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
>  	const gfp_t alloc_mask = gfp_mask | __GFP_HIGHMEM | __GFP_NOWARN;
> +	unsigned noio_flag;
> +	int r;
>  
>  	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
>  	array_size = (nr_pages * sizeof(struct page *));
> @@ -1712,8 +1715,21 @@ static void *__vmalloc_area_node(struct
>  			cond_resched();
>  	}
>  
> -	if (map_vm_area(area, prot, pages))
> +	if (unlikely(!(gfp_mask & __GFP_IO)))
> +		noio_flag = memalloc_noio_save();
> +	else if (unlikely(!(gfp_mask & __GFP_FS)))
> +		noio_flag = memalloc_nofs_save();
> +
> +	r = map_vm_area(area, prot, pages);
> +
> +	if (unlikely(!(gfp_mask & __GFP_IO)))
> +		memalloc_noio_restore(noio_flag);
> +	else if (unlikely(!(gfp_mask & __GFP_FS)))
> +		memalloc_nofs_restore(noio_flag);
> +
> +	if (unlikely(r))
>  		goto fail;
> +
>  	return area->addr;
>  
>  fail:
> Index: linux-2.6/mm/util.c
> ===================================================================
> --- linux-2.6.orig/mm/util.c
> +++ linux-2.6/mm/util.c
> @@ -351,10 +351,10 @@ void *kvmalloc_node(size_t size, gfp_t f
>  	void *ret;
>  
>  	/*
> -	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
> -	 * so the given set of flags has to be compatible.
> +	 * vmalloc uses blocking allocations for some internal allocations
> +	 * (e.g page tables) so the given set of flags has to be compatible.
>  	 */
> -	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
> +	WARN_ON_ONCE(!gfpflags_allow_blocking(flags));
>  
>  	/*
>  	 * We want to attempt a large physically contiguous block first because
> Index: linux-2.6/drivers/md/dm-bufio.c
> ===================================================================
> --- linux-2.6.orig/drivers/md/dm-bufio.c
> +++ linux-2.6/drivers/md/dm-bufio.c
> @@ -386,9 +386,6 @@ static void __cache_size_refresh(void)
>  static void *alloc_buffer_data(struct dm_bufio_client *c, gfp_t gfp_mask,
>  			       enum data_mode *data_mode)
>  {
> -	unsigned noio_flag;
> -	void *ptr;
> -
>  	if (c->block_size <= DM_BUFIO_BLOCK_SIZE_SLAB_LIMIT) {
>  		*data_mode = DATA_MODE_SLAB;
>  		return kmem_cache_alloc(DM_BUFIO_CACHE(c), gfp_mask);
> @@ -402,26 +399,7 @@ static void *alloc_buffer_data(struct dm
>  	}
>  
>  	*data_mode = DATA_MODE_VMALLOC;
> -
> -	/*
> -	 * __vmalloc allocates the data pages and auxiliary structures with
> -	 * gfp_flags that were specified, but pagetables are always allocated
> -	 * with GFP_KERNEL, no matter what was specified as gfp_mask.
> -	 *
> -	 * Consequently, we must set per-process flag PF_MEMALLOC_NOIO so that
> -	 * all allocations done by this process (including pagetables) are done
> -	 * as if GFP_NOIO was specified.
> -	 */
> -
> -	if (gfp_mask & __GFP_NORETRY)
> -		noio_flag = memalloc_noio_save();
> -
> -	ptr = __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
> -
> -	if (gfp_mask & __GFP_NORETRY)
> -		memalloc_noio_restore(noio_flag);
> -
> -	return ptr;
> +	return __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
>  }
>  
>  /*
> Index: linux-2.6/drivers/md/dm-ioctl.c
> ===================================================================
> --- linux-2.6.orig/drivers/md/dm-ioctl.c
> +++ linux-2.6/drivers/md/dm-ioctl.c
> @@ -1691,7 +1691,6 @@ static int copy_params(struct dm_ioctl _
>  	struct dm_ioctl *dmi;
>  	int secure_data;
>  	const size_t minimum_data_size = offsetof(struct dm_ioctl, data);
> -	unsigned noio_flag;
>  
>  	if (copy_from_user(param_kernel, user, minimum_data_size))
>  		return -EFAULT;
> @@ -1714,10 +1713,7 @@ static int copy_params(struct dm_ioctl _
>  	 * suspended and the ioctl is needed to resume it.
>  	 * Use kmalloc() rather than vmalloc() when we can.
>  	 */
> -	dmi = NULL;
> -	noio_flag = memalloc_noio_save();
> -	dmi = kvmalloc(param_kernel->data_size, GFP_KERNEL | __GFP_HIGH);
> -	memalloc_noio_restore(noio_flag);
> +	dmi = kvmalloc(param_kernel->data_size, GFP_NOIO | __GFP_HIGH);
>  
>  	if (!dmi) {
>  		if (secure_data && clear_user(user, param_kernel->data_size))
> Index: linux-2.6/fs/xfs/kmem.c
> ===================================================================
> --- linux-2.6.orig/fs/xfs/kmem.c
> +++ linux-2.6/fs/xfs/kmem.c
> @@ -48,7 +48,6 @@ kmem_alloc(size_t size, xfs_km_flags_t f
>  void *
>  kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
>  {
> -	unsigned nofs_flag = 0;
>  	void	*ptr;
>  	gfp_t	lflags;
>  
> @@ -56,22 +55,9 @@ kmem_zalloc_large(size_t size, xfs_km_fl
>  	if (ptr)
>  		return ptr;
>  
> -	/*
> -	 * __vmalloc() will allocate data pages and auxillary structures (e.g.
> -	 * pagetables) with GFP_KERNEL, yet we may be under GFP_NOFS context
> -	 * here. Hence we need to tell memory reclaim that we are in such a
> -	 * context via PF_MEMALLOC_NOFS to prevent memory reclaim re-entering
> -	 * the filesystem here and potentially deadlocking.
> -	 */
> -	if (flags & KM_NOFS)
> -		nofs_flag = memalloc_nofs_save();
> -
>  	lflags = kmem_flags_convert(flags);
>  	ptr = __vmalloc(size, lflags | __GFP_ZERO, PAGE_KERNEL);
>  
> -	if (flags & KM_NOFS)
> -		memalloc_nofs_restore(nofs_flag);
> -
>  	return ptr;
>  }
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
