Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 98C826B0279
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 02:20:45 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u18so105673063pfa.8
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 23:20:45 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 184si5012393pgj.9.2017.06.29.23.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 23:20:44 -0700 (PDT)
Subject: Re: [PATCH] vmalloc: respect the GFP_NOIO and GFP_NOFS flags
References: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2fe798a6-38df-a1f3-adb1-d252e35ec564@nvidia.com>
Date: Thu, 29 Jun 2017 23:20:42 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, Michal Hocko <mhocko@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Andreas Dilger <adilger@dilger.ca>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

On 06/29/2017 07:25 PM, Mikulas Patocka wrote:
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
> 
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

Hi Mikulas,

OK, so given the new behavior in the underlying __vmalloc code, I think it's
appropriate to add this documentation change on top of what you have so far:

 mm/util.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
diff --git a/mm/util.c b/mm/util.c
index cdbc9022c021..39fe94530dd2 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -343,7 +343,8 @@ EXPORT_SYMBOL(vm_mmap);
  * __GFP_RETRY_MAYFAIL is supported, and it should be used only if kmalloc is
  * preferable to the vmalloc fallback, due to visible performance drawbacks.
  *
- * Any use of gfp flags outside of GFP_KERNEL should be consulted with mm people.
+ * Any use of gfp flags other than GFP_KERNEL, GFP_NOIO, or GFP_NOFS should
+ * be done only after consulting with mm people.
  */
 void *kvmalloc_node(size_t size, gfp_t flags, int node)
 {

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

Seems like a nice cleanup, and although I'm not an expert, it looks
correct to me.

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

Pre-existing, and apologies if I missed a conversation about it, but is
__GFP_HIGH necessary and appropriate for kvmalloc()? If so, maybe we
should add it to the list of approved GFP flags in the function's
documentation. But I tentatively think you can just pass in GFP_NOIO
instead, and get the right behavior.

thanks,
john h

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
