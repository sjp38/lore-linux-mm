Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0C3D6B03BC
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:34:01 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g8so8561213wmg.7
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:34:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g14si3179696wrg.275.2017.03.07.23.33.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 23:34:00 -0800 (PST)
Subject: Re: [PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
References: <20170307141020.29107-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a984cf7d-221d-6106-e91d-6258b4e1d03c@suse.cz>
Date: Wed, 8 Mar 2017 08:33:58 +0100
MIME-Version: 1.0
In-Reply-To: <20170307141020.29107-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 03/07/2017 03:10 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __vmalloc* allows users to provide gfp flags for the underlying
> allocation. This API is quite popular
> $ git grep "=[[:space:]]__vmalloc\|return[[:space:]]*__vmalloc" | wc -l
> 77
> 
> the only problem is that many people are not aware that they really want
> to give __GFP_HIGHMEM along with other flags because there is really no
> reason to consume precious lowmemory on CONFIG_HIGHMEM systems for pages
> which are mapped to the kernel vmalloc space. About half of users don't
> use this flag, though. This signals that we make the API unnecessarily
> too complex.
> 
> This patch simply uses __GFP_HIGHMEM implicitly when allocating pages to
> be mapped to the vmalloc space. Current users which add __GFP_HIGHMEM
> are simplified and drop the flag.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> this has been posted [1] as an RFC before and nobody really screamed
> about this. Well, there was only little feedback, to be honest. I still
> believe this is an improvement and the implicit __GFP_HIGHMEM will make
> the __vmalloc* usage less error prone.
> 
> [1] http://lkml.kernel.org/r/20170201140530.1325-1-mhocko@kernel.org
> 
>  arch/parisc/kernel/module.c            |  2 +-
>  arch/x86/kernel/module.c               |  2 +-
>  drivers/block/drbd/drbd_bitmap.c       |  2 +-
>  drivers/gpu/drm/etnaviv/etnaviv_dump.c |  4 ++--
>  drivers/md/dm-bufio.c                  |  2 +-
>  fs/btrfs/free-space-tree.c             |  3 +--
>  fs/file.c                              |  2 +-
>  fs/xfs/kmem.c                          |  2 +-
>  include/drm/drm_mem_util.h             |  9 +++------
>  kernel/bpf/core.c                      |  9 +++------
>  kernel/bpf/syscall.c                   |  3 +--
>  kernel/fork.c                          |  2 +-
>  kernel/groups.c                        |  2 +-
>  kernel/module.c                        |  2 +-
>  mm/kasan/kasan.c                       |  2 +-
>  mm/nommu.c                             |  3 +--
>  mm/util.c                              |  2 +-
>  mm/vmalloc.c                           | 14 +++++++-------
>  net/ceph/ceph_common.c                 |  2 +-
>  net/netfilter/x_tables.c               |  3 +--
>  20 files changed, 31 insertions(+), 41 deletions(-)
> 
> diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
> index a0ecdb4abcc8..3d4f5660a2e0 100644
> --- a/arch/parisc/kernel/module.c
> +++ b/arch/parisc/kernel/module.c
> @@ -218,7 +218,7 @@ void *module_alloc(unsigned long size)
>  	 * easier than trying to map the text, data, init_text and
>  	 * init_data correctly */
>  	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
> -				    GFP_KERNEL | __GFP_HIGHMEM,
> +				    GFP_KERNEL,
>  				    PAGE_KERNEL_RWX, 0, NUMA_NO_NODE,
>  				    __builtin_return_address(0));
>  }
> diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
> index 477ae806c2fa..f67bd3205df7 100644
> --- a/arch/x86/kernel/module.c
> +++ b/arch/x86/kernel/module.c
> @@ -85,7 +85,7 @@ void *module_alloc(unsigned long size)
>  
>  	p = __vmalloc_node_range(size, MODULE_ALIGN,
>  				    MODULES_VADDR + get_module_load_offset(),
> -				    MODULES_END, GFP_KERNEL | __GFP_HIGHMEM,
> +				    MODULES_END, GFP_KERNEL,
>  				    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
>  				    __builtin_return_address(0));
>  	if (p && (kasan_module_alloc(p, size) < 0)) {
> diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
> index dece26f119d4..a804a4107fbc 100644
> --- a/drivers/block/drbd/drbd_bitmap.c
> +++ b/drivers/block/drbd/drbd_bitmap.c
> @@ -409,7 +409,7 @@ static struct page **bm_realloc_pages(struct drbd_bitmap *b, unsigned long want)
>  	new_pages = kzalloc(bytes, GFP_NOIO | __GFP_NOWARN);
>  	if (!new_pages) {
>  		new_pages = __vmalloc(bytes,
> -				GFP_NOIO | __GFP_HIGHMEM | __GFP_ZERO,
> +				GFP_NOIO | __GFP_ZERO,

This should be converted to memalloc_noio_save(), right? And then
kvmalloc? Unless that happens in your other series :)

>  				PAGE_KERNEL);
>  		if (!new_pages)
>  			return NULL;
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_dump.c b/drivers/gpu/drm/etnaviv/etnaviv_dump.c
> index d019b5e311cc..2d955d7d7b6d 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_dump.c
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_dump.c
> @@ -161,8 +161,8 @@ void etnaviv_core_dump(struct etnaviv_gpu *gpu)
>  	file_size += sizeof(*iter.hdr) * n_obj;
>  
>  	/* Allocate the file in vmalloc memory, it's likely to be big */
> -	iter.start = __vmalloc(file_size, GFP_KERNEL | __GFP_HIGHMEM |
> -			       __GFP_NOWARN | __GFP_NORETRY, PAGE_KERNEL);
> +	iter.start = __vmalloc(file_size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY,
> +			       PAGE_KERNEL);
>  	if (!iter.start) {
>  		dev_warn(gpu->dev, "failed to allocate devcoredump file\n");
>  		return;
> diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
> index df4859f6ac6a..c058ae86f51b 100644
> --- a/drivers/md/dm-bufio.c
> +++ b/drivers/md/dm-bufio.c
> @@ -404,7 +404,7 @@ static void *alloc_buffer_data(struct dm_bufio_client *c, gfp_t gfp_mask,
>  	if (gfp_mask & __GFP_NORETRY)
>  		noio_flag = memalloc_noio_save();
>  
> -	ptr = __vmalloc(c->block_size, gfp_mask | __GFP_HIGHMEM, PAGE_KERNEL);
> +	ptr = __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
>  
>  	if (gfp_mask & __GFP_NORETRY)
>  		memalloc_noio_restore(noio_flag);
> diff --git a/fs/btrfs/free-space-tree.c b/fs/btrfs/free-space-tree.c
> index dd7fb22a955a..fc0bd8406758 100644
> --- a/fs/btrfs/free-space-tree.c
> +++ b/fs/btrfs/free-space-tree.c
> @@ -167,8 +167,7 @@ static u8 *alloc_bitmap(u32 bitmap_size)
>  	if (mem)
>  		return mem;
>  
> -	return __vmalloc(bitmap_size, GFP_NOFS | __GFP_HIGHMEM | __GFP_ZERO,
> -			 PAGE_KERNEL);
> +	return __vmalloc(bitmap_size, GFP_NOFS | __GFP_ZERO, PAGE_KERNEL);

memalloc_nofs_save() and plain vzalloc()?

>  }
>  
>  int convert_free_space_to_bitmaps(struct btrfs_trans_handle *trans,

[...]

> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -693,7 +693,7 @@ int kasan_module_alloc(void *addr, size_t size)
>  
>  	ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
>  			shadow_start + shadow_size,
> -			GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
> +			GFP_KERNEL | __GFP_ZERO,
>  			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
>  			__builtin_return_address(0));
>  
> diff --git a/mm/nommu.c b/mm/nommu.c
> index a80411d258fc..fc184f597d59 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -246,8 +246,7 @@ void *vmalloc_user(unsigned long size)
>  {
>  	void *ret;
>  
> -	ret = __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
> -			PAGE_KERNEL);
> +	ret = __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);

vzalloc()?

>  	if (ret) {
>  		struct vm_area_struct *vma;
>  
> diff --git a/mm/util.c b/mm/util.c
> index 6ed3e49bf1e5..e5b0623df89d 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -382,7 +382,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	if (ret || size <= PAGE_SIZE)
>  		return ret;
>  
> -	return __vmalloc_node_flags(size, node, flags | __GFP_HIGHMEM);
> +	return __vmalloc_node_flags(size, node, flags);
>  }
>  EXPORT_SYMBOL(kvmalloc_node);
>  
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 32979d945766..9fa9274d8f6d 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1619,7 +1619,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	struct page **pages;
>  	unsigned int nr_pages, array_size, i;
>  	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
> -	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
> +	const gfp_t alloc_mask = gfp_mask | __GFP_HIGHMEM | __GFP_NOWARN;
>  
>  	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
>  	array_size = (nr_pages * sizeof(struct page *));
> @@ -1788,7 +1788,7 @@ void *__vmalloc_node_flags(unsigned long size,
>  void *vmalloc(unsigned long size)
>  {
>  	return __vmalloc_node_flags(size, NUMA_NO_NODE,
> -				    GFP_KERNEL | __GFP_HIGHMEM);
> +				    GFP_KERNEL);

Nit: this could now fit on single line.

>  }
>  EXPORT_SYMBOL(vmalloc);
>  
> @@ -1805,7 +1805,7 @@ EXPORT_SYMBOL(vmalloc);
>  void *vzalloc(unsigned long size)
>  {
>  	return __vmalloc_node_flags(size, NUMA_NO_NODE,
> -				GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
> +				GFP_KERNEL | __GFP_ZERO);
>  }
>  EXPORT_SYMBOL(vzalloc);
>  
> @@ -1822,7 +1822,7 @@ void *vmalloc_user(unsigned long size)
>  	void *ret;
>  
>  	ret = __vmalloc_node(size, SHMLBA,
> -			     GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
> +			     GFP_KERNEL | __GFP_ZERO,
>  			     PAGE_KERNEL, NUMA_NO_NODE,
>  			     __builtin_return_address(0));
>  	if (ret) {
> @@ -1846,7 +1846,7 @@ EXPORT_SYMBOL(vmalloc_user);
>   */
>  void *vmalloc_node(unsigned long size, int node)
>  {
> -	return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL,
> +	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL,
>  					node, __builtin_return_address(0));
>  }
>  EXPORT_SYMBOL(vmalloc_node);
> @@ -1866,7 +1866,7 @@ EXPORT_SYMBOL(vmalloc_node);
>  void *vzalloc_node(unsigned long size, int node)
>  {
>  	return __vmalloc_node_flags(size, node,
> -			 GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
> +			 GFP_KERNEL | __GFP_ZERO);

This too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
