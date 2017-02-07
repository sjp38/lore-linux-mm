Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4D86B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 07:19:37 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id i10so2730234wrb.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 04:19:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 21si4845835wrx.116.2017.02.07.04.19.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 04:19:36 -0800 (PST)
Date: Tue, 7 Feb 2017 13:19:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
Message-ID: <20170207121934.GN5065@dhcp22.suse.cz>
References: <20170201140530.1325-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170201140530.1325-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 01-02-17 15:05:30, Michal Hocko wrote:
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
> Hi,
> this is based on top of [1]. I believe it was Al who has brought this
> up quite some time ago (or maybe I just misremember). The explicit
> usage of __GFP_HIGHMEM in __vmalloc* seems to be too much to ask from
> users. I believe there is no user which doesn't want vmalloc pages be
> in the highmem but I might be missing something. There is vmalloc_32*
> API but that uses GFP_DMA* explicitly which overrides __GFP_HIGHMEM. So
> all current users _should_ be safe to use __GFP_HIGHMEM unconditionally.
> This patch should simplify things and fix many users which consume
> lowmem for no good reason.
> 
> I am sending this as an RFC to get some feedback, I even haven't compile
> tested it yet.

Any thoughts, objections?

> Any comments are welcome.
> 
> [1] http://lkml.kernel.org/r/20170130094940.13546-1-mhocko@kernel.org
> 
>  arch/parisc/kernel/module.c            |  2 +-
>  arch/x86/kernel/module.c               |  2 +-
>  drivers/block/drbd/drbd_bitmap.c       |  2 +-
>  drivers/gpu/drm/etnaviv/etnaviv_dump.c |  4 ++--
>  drivers/md/dm-bufio.c                  |  2 +-
>  fs/btrfs/free-space-tree.c             |  3 +--
>  fs/file.c                              |  2 +-
>  fs/xfs/kmem.c                          |  2 +-
>  include/drm/drm_mem_util.h             |  3 +--
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
>  20 files changed, 29 insertions(+), 37 deletions(-)
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
>  				PAGE_KERNEL);
>  		if (!new_pages)
>  			return NULL;
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_dump.c b/drivers/gpu/drm/etnaviv/etnaviv_dump.c
> index af65491a78e2..32d2ea18a587 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_dump.c
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_dump.c
> @@ -160,8 +160,8 @@ void etnaviv_core_dump(struct etnaviv_gpu *gpu)
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
> index d36d427a9efb..f183af90f447 100644
> --- a/drivers/md/dm-bufio.c
> +++ b/drivers/md/dm-bufio.c
> @@ -403,7 +403,7 @@ static void *alloc_buffer_data(struct dm_bufio_client *c, gfp_t gfp_mask,
>  	if (gfp_mask & __GFP_NORETRY)
>  		noio_flag = memalloc_noio_save();
>  
> -	ptr = __vmalloc(c->block_size, gfp_mask | __GFP_HIGHMEM, PAGE_KERNEL);
> +	ptr = __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
>  
>  	if (gfp_mask & __GFP_NORETRY)
>  		memalloc_noio_restore(noio_flag);
> diff --git a/fs/btrfs/free-space-tree.c b/fs/btrfs/free-space-tree.c
> index ff0c55337c2e..844473309b37 100644
> --- a/fs/btrfs/free-space-tree.c
> +++ b/fs/btrfs/free-space-tree.c
> @@ -167,8 +167,7 @@ static u8 *alloc_bitmap(u32 bitmap_size)
>  	if (mem)
>  		return mem;
>  
> -	return __vmalloc(bitmap_size, GFP_NOFS | __GFP_HIGHMEM | __GFP_ZERO,
> -			 PAGE_KERNEL);
> +	return __vmalloc(bitmap_size, GFP_NOFS | __GFP_ZERO, PAGE_KERNEL);
>  }
>  
>  int convert_free_space_to_bitmaps(struct btrfs_trans_handle *trans,
> diff --git a/fs/file.c b/fs/file.c
> index 69d6990e3021..5ddf189f3a7e 100644
> --- a/fs/file.c
> +++ b/fs/file.c
> @@ -42,7 +42,7 @@ static void *alloc_fdmem(size_t size)
>  		if (data != NULL)
>  			return data;
>  	}
> -	return __vmalloc(size, GFP_KERNEL_ACCOUNT | __GFP_HIGHMEM, PAGE_KERNEL);
> +	return __vmalloc(size, GFP_KERNEL_ACCOUNT, PAGE_KERNEL);
>  }
>  
>  static void __free_fdtable(struct fdtable *fdt)
> diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> index 339c696bbc01..d3bf13bf30b5 100644
> --- a/fs/xfs/kmem.c
> +++ b/fs/xfs/kmem.c
> @@ -84,7 +84,7 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
>  		noio_flag = memalloc_noio_save();
>  
>  	lflags = kmem_flags_convert(flags);
> -	ptr = __vmalloc(size, lflags | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
> +	ptr = __vmalloc(size, lflags | __GFP_ZERO, PAGE_KERNEL);
>  
>  	if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
>  		memalloc_noio_restore(noio_flag);
> diff --git a/include/drm/drm_mem_util.h b/include/drm/drm_mem_util.h
> index 70d4e221a3ad..9178d9976603 100644
> --- a/include/drm/drm_mem_util.h
> +++ b/include/drm/drm_mem_util.h
> @@ -37,8 +37,7 @@ static __inline__ void *drm_calloc_large(size_t nmemb, size_t size)
>  	if (size * nmemb <= PAGE_SIZE)
>  	    return kcalloc(nmemb, size, GFP_KERNEL);
>  
> -	return __vmalloc(size * nmemb,
> -			 GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
> +	return __vmalloc(size * nmemb, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
>  }
>  
>  /* Modeled after cairo's malloc_ab, it's like calloc but without the zeroing. */
> diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
> index fddd76b1b627..ab2728883239 100644
> --- a/kernel/bpf/core.c
> +++ b/kernel/bpf/core.c
> @@ -73,8 +73,7 @@ void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, uns
>  
>  struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
>  {
> -	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
> -			  gfp_extra_flags;
> +	gfp_t gfp_flags = GFP_KERNEL | __GFP_ZERO | gfp_extra_flags;
>  	struct bpf_prog_aux *aux;
>  	struct bpf_prog *fp;
>  
> @@ -102,8 +101,7 @@ EXPORT_SYMBOL_GPL(bpf_prog_alloc);
>  struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
>  				  gfp_t gfp_extra_flags)
>  {
> -	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
> -			  gfp_extra_flags;
> +	gfp_t gfp_flags = GFP_KERNEL | __GFP_ZERO | gfp_extra_flags;
>  	struct bpf_prog *fp;
>  	u32 pages, delta;
>  	int ret;
> @@ -436,8 +434,7 @@ static int bpf_jit_blind_insn(const struct bpf_insn *from,
>  static struct bpf_prog *bpf_prog_clone_create(struct bpf_prog *fp_other,
>  					      gfp_t gfp_extra_flags)
>  {
> -	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
> -			  gfp_extra_flags;
> +	gfp_t gfp_flags = GFP_KERNEL | __GFP_ZERO | gfp_extra_flags;
>  	struct bpf_prog *fp;
>  
>  	fp = __vmalloc(fp_other->pages * PAGE_SIZE, gfp_flags, PAGE_KERNEL);
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 08a4d287226b..88e749fd6a40 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -67,8 +67,7 @@ void *bpf_map_area_alloc(size_t size)
>  			return area;
>  	}
>  
> -	return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | flags,
> -			 PAGE_KERNEL);
> +	return __vmalloc(size, GFP_KERNEL | flags, PAGE_KERNEL);
>  }
>  
>  void bpf_map_area_free(void *area)
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 1f4bf6d2e45a..fb4e8b2886a1 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -192,7 +192,7 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>  
>  	stack = __vmalloc_node_range(THREAD_SIZE, THREAD_SIZE,
>  				     VMALLOC_START, VMALLOC_END,
> -				     THREADINFO_GFP | __GFP_HIGHMEM,
> +				     THREADINFO_GFP,
>  				     PAGE_KERNEL,
>  				     0, node, __builtin_return_address(0));
>  
> diff --git a/kernel/groups.c b/kernel/groups.c
> index 8dd7a61b7115..d09727692a2a 100644
> --- a/kernel/groups.c
> +++ b/kernel/groups.c
> @@ -18,7 +18,7 @@ struct group_info *groups_alloc(int gidsetsize)
>  	len = sizeof(struct group_info) + sizeof(kgid_t) * gidsetsize;
>  	gi = kmalloc(len, GFP_KERNEL_ACCOUNT|__GFP_NOWARN|__GFP_NORETRY);
>  	if (!gi)
> -		gi = __vmalloc(len, GFP_KERNEL_ACCOUNT|__GFP_HIGHMEM, PAGE_KERNEL);
> +		gi = __vmalloc(len, GFP_KERNEL_ACCOUNT, PAGE_KERNEL);
>  	if (!gi)
>  		return NULL;
>  
> diff --git a/kernel/module.c b/kernel/module.c
> index f4e91dbc2995..6046c8e1d8b9 100644
> --- a/kernel/module.c
> +++ b/kernel/module.c
> @@ -2848,7 +2848,7 @@ static int copy_module_from_user(const void __user *umod, unsigned long len,
>  
>  	/* Suck in entire file: we'll want most of it. */
>  	info->hdr = __vmalloc(info->len,
> -			GFP_KERNEL | __GFP_HIGHMEM | __GFP_NOWARN, PAGE_KERNEL);
> +			GFP_KERNEL | __GFP_NOWARN, PAGE_KERNEL);
>  	if (!info->hdr)
>  		return -ENOMEM;
>  
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 5f6e09c88d25..2ae297009e85 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -679,7 +679,7 @@ int kasan_module_alloc(void *addr, size_t size)
>  
>  	ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
>  			shadow_start + shadow_size,
> -			GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
> +			GFP_KERNEL | __GFP_ZERO,
>  			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
>  			__builtin_return_address(0));
>  
> diff --git a/mm/nommu.c b/mm/nommu.c
> index bee76e6cd4e5..5ee7f8ca7854 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -245,8 +245,7 @@ void *vmalloc_user(unsigned long size)
>  {
>  	void *ret;
>  
> -	ret = __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
> -			PAGE_KERNEL);
> +	ret = __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
>  	if (ret) {
>  		struct vm_area_struct *vma;
>  
> diff --git a/mm/util.c b/mm/util.c
> index f50100ca73ce..695f7a9d645e 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -371,7 +371,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	if (ret || size <= PAGE_SIZE)
>  		return ret;
>  
> -	return __vmalloc_node_flags(size, node, flags | __GFP_HIGHMEM);
> +	return __vmalloc_node_flags(size, node, flags);
>  }
>  EXPORT_SYMBOL(kvmalloc_node);
>  
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 3b90a7f8380c..d811bf99caa6 100644
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
> @@ -1783,7 +1783,7 @@ void *__vmalloc_node_flags(unsigned long size,
>  void *vmalloc(unsigned long size)
>  {
>  	return __vmalloc_node_flags(size, NUMA_NO_NODE,
> -				    GFP_KERNEL | __GFP_HIGHMEM);
> +				    GFP_KERNEL);
>  }
>  EXPORT_SYMBOL(vmalloc);
>  
> @@ -1800,7 +1800,7 @@ EXPORT_SYMBOL(vmalloc);
>  void *vzalloc(unsigned long size)
>  {
>  	return __vmalloc_node_flags(size, NUMA_NO_NODE,
> -				GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
> +				GFP_KERNEL | __GFP_ZERO);
>  }
>  EXPORT_SYMBOL(vzalloc);
>  
> @@ -1817,7 +1817,7 @@ void *vmalloc_user(unsigned long size)
>  	void *ret;
>  
>  	ret = __vmalloc_node(size, SHMLBA,
> -			     GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
> +			     GFP_KERNEL | __GFP_ZERO,
>  			     PAGE_KERNEL, NUMA_NO_NODE,
>  			     __builtin_return_address(0));
>  	if (ret) {
> @@ -1841,7 +1841,7 @@ EXPORT_SYMBOL(vmalloc_user);
>   */
>  void *vmalloc_node(unsigned long size, int node)
>  {
> -	return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL,
> +	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL,
>  					node, __builtin_return_address(0));
>  }
>  EXPORT_SYMBOL(vmalloc_node);
> @@ -1861,7 +1861,7 @@ EXPORT_SYMBOL(vmalloc_node);
>  void *vzalloc_node(unsigned long size, int node)
>  {
>  	return __vmalloc_node_flags(size, node,
> -			 GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
> +			 GFP_KERNEL | __GFP_ZERO);
>  }
>  EXPORT_SYMBOL(vzalloc_node);
>  
> @@ -1883,7 +1883,7 @@ EXPORT_SYMBOL(vzalloc_node);
>  
>  void *vmalloc_exec(unsigned long size)
>  {
> -	return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC,
> +	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
>  			      NUMA_NO_NODE, __builtin_return_address(0));
>  }
>  
> diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
> index 464e88599b9d..73d4739fcbe0 100644
> --- a/net/ceph/ceph_common.c
> +++ b/net/ceph/ceph_common.c
> @@ -187,7 +187,7 @@ void *ceph_kvmalloc(size_t size, gfp_t flags)
>  			return ptr;
>  	}
>  
> -	return __vmalloc(size, flags | __GFP_HIGHMEM, PAGE_KERNEL);
> +	return __vmalloc(size, flags, PAGE_KERNEL);
>  }
>  
>  
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index d529989f5791..e58ecff638b3 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -998,8 +998,7 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
>  	if (sz <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
>  		info = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
>  	if (!info) {
> -		info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN |
> -				     __GFP_NORETRY | __GFP_HIGHMEM,
> +		info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY,
>  				 PAGE_KERNEL);
>  		if (!info)
>  			return NULL;
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
