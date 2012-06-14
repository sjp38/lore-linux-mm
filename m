Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id AFA226B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 22:07:54 -0400 (EDT)
Message-ID: <4FD94779.3030108@kernel.org>
Date: Thu, 14 Jun 2012 11:07:53 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add gfp_mask parameter to vm_map_ram()
References: <20120612012134.GA7706@localhost> <20120613123932.GA1445@localhost> <20120614012026.GL3019@devil.redhat.com> <20120614014902.GB7289@localhost>
In-Reply-To: <20120614014902.GB7289@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com

Hi Fengguang,

On 06/14/2012 10:49 AM, Fengguang Wu wrote:

> On Thu, Jun 14, 2012 at 11:20:26AM +1000, Dave Chinner wrote:
>> On Wed, Jun 13, 2012 at 08:39:32PM +0800, Fengguang Wu wrote:
>>> Hi Christoph, Dave,
>>>
>>> I got this lockdep warning on XFS when running the xfs tests:
>>>
>>> [  704.832019] =================================
>>> [  704.832019] [ INFO: inconsistent lock state ]
>>> [  704.832019] 3.5.0-rc1+ #8 Tainted: G        W   
>>> [  704.832019] ---------------------------------
>>> [  704.832019] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
>>> [  704.832019] fsstress/11619 [HC0[0]:SC0[0]:HE1:SE1] takes:
>>> [  704.832019]  (&(&ip->i_lock)->mr_lock){++++?.}, at: [<ffffffff8143953d>] xfs_ilock_nowait+0xd7/0x1d0
>>> [  704.832019] {IN-RECLAIM_FS-W} state was registered at:
>>> [  704.832019]   [<ffffffff810e30a2>] mark_irqflags+0x12d/0x13e
>>> [  704.832019]   [<ffffffff810e32f6>] __lock_acquire+0x243/0x3f9
>>> [  704.832019]   [<ffffffff810e3a1c>] lock_acquire+0x112/0x13d
>>> [  704.832019]   [<ffffffff810b8931>] down_write_nested+0x54/0x8b
>>> [  704.832019]   [<ffffffff81438fab>] xfs_ilock+0xd8/0x17d
>>> [  704.832019]   [<ffffffff814431b8>] xfs_reclaim_inode+0x4a/0x2cb
>>> [  704.832019]   [<ffffffff814435ee>] xfs_reclaim_inodes_ag+0x1b5/0x28e
>>> [  704.832019]   [<ffffffff814437d7>] xfs_reclaim_inodes_nr+0x33/0x3a
>>> [  704.832019]   [<ffffffff8144050e>] xfs_fs_free_cached_objects+0x15/0x17
>>> [  704.832019]   [<ffffffff81196076>] prune_super+0x103/0x154
>>> [  704.832019]   [<ffffffff81152fa7>] shrink_slab+0x1ec/0x316
>>> [  704.832019]   [<ffffffff8115574f>] balance_pgdat+0x308/0x618
>>> [  704.832019]   [<ffffffff81155c22>] kswapd+0x1c3/0x1dc
>>> [  704.832019]   [<ffffffff810b3f77>] kthread+0xaf/0xb7
>>> [  704.832019]   [<ffffffff82f480b4>] kernel_thread_helper+0x4/0x10
>>
>> ......
>>> [  704.832019] stack backtrace:
>>> [  704.832019] Pid: 11619, comm: fsstress Tainted: G        W    3.5.0-rc1+ #8
>>> [  704.832019] Call Trace:
>>> [  704.832019]  [<ffffffff82e92243>] print_usage_bug+0x1f5/0x206
>>> [  704.832019]  [<ffffffff810e2220>] ? check_usage_forwards+0xa6/0xa6
>>> [  704.832019]  [<ffffffff82e922c3>] mark_lock_irq+0x6f/0x120
>>> [  704.832019]  [<ffffffff810e2f02>] mark_lock+0xaf/0x122
>>> [  704.832019]  [<ffffffff810e3d4e>] mark_held_locks+0x6d/0x95
>>> [  704.832019]  [<ffffffff810c5cd1>] ? local_clock+0x36/0x4d
>>> [  704.832019]  [<ffffffff810e3de3>] __lockdep_trace_alloc+0x6d/0x6f
>>> [  704.832019]  [<ffffffff810e42e7>] lockdep_trace_alloc+0x3d/0x57
>>> [  704.832019]  [<ffffffff811837c8>] kmem_cache_alloc_node_trace+0x47/0x1b4
>>> [  704.832019]  [<ffffffff810e377d>] ? lock_release_nested+0x9f/0xa6
>>> [  704.832019]  [<ffffffff81431650>] ? _xfs_buf_find+0xaa/0x302
>>> [  704.832019]  [<ffffffff811710a2>] ? new_vmap_block.constprop.18+0x3a/0x1de
>>> [  704.832019]  [<ffffffff811710a2>] new_vmap_block.constprop.18+0x3a/0x1de
>>> [  704.832019]  [<ffffffff8117144a>] vb_alloc.constprop.16+0x204/0x225
>>> [  704.832019]  [<ffffffff8117149d>] vm_map_ram+0x32/0xaa
>>> [  704.832019]  [<ffffffff81430c95>] _xfs_buf_map_pages+0xb3/0xf5
>>> [  704.832019]  [<ffffffff81431a6a>] xfs_buf_get+0xd3/0x1ac
>>> [  704.832019]  [<ffffffff81492dd9>] xfs_trans_get_buf+0x180/0x244
>>> [  704.832019]  [<ffffffff8146947a>] xfs_da_do_buf+0x2a0/0x5cc
>>> [  704.832019]  [<ffffffff81469826>] xfs_da_get_buf+0x21/0x23
>>> [  704.832019]  [<ffffffff8146f894>] xfs_dir2_data_init+0x44/0xf9
>>> [  704.832019]  [<ffffffff8146e94f>] xfs_dir2_sf_to_block+0x1ef/0x5d8
>>
>> Bug in vm_map_ram - it does an unconditional GFP_KERNEL allocation
>> here, and we are in a GFP_NOFS context. We can't pass a gfp_mask to
>> vm_map_ram(), so until vm_map_ram() grows that we can't fix it...
> 
> This trivial patch should fix it.
> 
> The only behavior change is the XFS part:
> 
> @@ -406,7 +406,7 @@ _xfs_buf_map_pages(
>  
>                 do {
>                         bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
> -                                               -1, PAGE_KERNEL);
> +                                               -1, GFP_NOFS, PAGE_KERNEL);
>                         if (bp->b_addr)
>                                 break;
>                         vm_unmap_aliases();
> 
> Does that look fine to you?

> 
> Thanks,

> Fengguang
> ---
> 
> From 7301975d3211da2ce07723c294cf3260229fe84b Mon Sep 17 00:00:00 2001
> From: Fengguang Wu <fengguang.wu@intel.com>
> Date: Thu, 14 Jun 2012 09:38:33 +0800
> Subject: [PATCH] mm: add @gfp_mask parameter to vm_map_ram()
> 
> XFS needs GFP_NOFS allocation.
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  drivers/firewire/ohci.c                 |    2 +-
>  drivers/media/video/videobuf2-dma-sg.c  |    1 +
>  drivers/media/video/videobuf2-vmalloc.c |    2 +-
>  fs/xfs/xfs_buf.c                        |    2 +-
>  include/linux/vmalloc.h                 |    2 +-
>  mm/nommu.c                              |    3 ++-
>  mm/vmalloc.c                            |    7 ++++---
>  7 files changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/firewire/ohci.c b/drivers/firewire/ohci.c
> index c1af05e..b53f5a9 100644
> --- a/drivers/firewire/ohci.c
> +++ b/drivers/firewire/ohci.c
> @@ -1000,7 +1000,7 @@ static int ar_context_init(struct ar_context *ctx, struct fw_ohci *ohci,
>  	for (i = 0; i < AR_WRAPAROUND_PAGES; i++)
>  		pages[AR_BUFFERS + i] = ctx->pages[i];
>  	ctx->buffer = vm_map_ram(pages, AR_BUFFERS + AR_WRAPAROUND_PAGES,
> -				 -1, PAGE_KERNEL);
> +				 -1, GFP_KERNEL, PAGE_KERNEL);
>  	if (!ctx->buffer)
>  		goto out_of_memory;
>  
> diff --git a/drivers/media/video/videobuf2-dma-sg.c b/drivers/media/video/videobuf2-dma-sg.c
> index 25c3b36..d087f52 100644
> --- a/drivers/media/video/videobuf2-dma-sg.c
> +++ b/drivers/media/video/videobuf2-dma-sg.c
> @@ -209,6 +209,7 @@ static void *vb2_dma_sg_vaddr(void *buf_priv)
>  		buf->vaddr = vm_map_ram(buf->pages,
>  					buf->sg_desc.num_pages,
>  					-1,
> +					GFP_KERNEL,
>  					PAGE_KERNEL);
>  
>  	/* add offset in case userptr is not page-aligned */
> diff --git a/drivers/media/video/videobuf2-vmalloc.c b/drivers/media/video/videobuf2-vmalloc.c
> index 6b5ca6c..548ebda 100644
> --- a/drivers/media/video/videobuf2-vmalloc.c
> +++ b/drivers/media/video/videobuf2-vmalloc.c
> @@ -111,7 +111,7 @@ static void *vb2_vmalloc_get_userptr(void *alloc_ctx, unsigned long vaddr,
>  			goto fail_get_user_pages;
>  
>  		buf->vaddr = vm_map_ram(buf->pages, buf->n_pages, -1,
> -					PAGE_KERNEL);
> +					GFP_KERNEL, PAGE_KERNEL);
>  		if (!buf->vaddr)
>  			goto fail_get_user_pages;
>  	}
> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index 172d3cc..b3e7289 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -406,7 +406,7 @@ _xfs_buf_map_pages(
>  
>  		do {
>  			bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
> -						-1, PAGE_KERNEL);
> +						-1, GFP_NOFS, PAGE_KERNEL);
>  			if (bp->b_addr)
>  				break;
>  			vm_unmap_aliases();
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index dcdfc2b..c811763 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -40,7 +40,7 @@ struct vm_struct {
>   */
>  extern void vm_unmap_ram(const void *mem, unsigned int count);
>  extern void *vm_map_ram(struct page **pages, unsigned int count,
> -				int node, pgprot_t prot);
> +				int node, gfp_t gfp_mask, pgprot_t prot);
>  extern void vm_unmap_aliases(void);
>  
>  #ifdef CONFIG_MMU
> diff --git a/mm/nommu.c b/mm/nommu.c
> index d4b0c10..2fb4ec1 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -416,7 +416,8 @@ void vunmap(const void *addr)
>  }
>  EXPORT_SYMBOL(vunmap);
>  
> -void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
> +void *vm_map_ram(struct page **pages, unsigned int count,
> +		 int node, gfp_t gfp_mask, pgprot_t prot)
>  {
>  	BUG();
>  	return NULL;
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 2aad499..3f736d1 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1088,21 +1088,22 @@ EXPORT_SYMBOL(vm_unmap_ram);
>   *
>   * Returns: a pointer to the address that has been mapped, or %NULL on failure
>   */
> -void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
> +void *vm_map_ram(struct page **pages, unsigned int count,
> +		 int node, gfp_t gfp_mask, pgprot_t prot)
>  {
>  	unsigned long size = count << PAGE_SHIFT;
>  	unsigned long addr;
>  	void *mem;
>  
>  	if (likely(count <= VMAP_MAX_ALLOC)) {
> -		mem = vb_alloc(size, GFP_KERNEL);
> +		mem = vb_alloc(size, gfp_mask);
>  		if (IS_ERR(mem))
>  			return NULL;
>  		addr = (unsigned long)mem;
>  	} else {
>  		struct vmap_area *va;
>  		va = alloc_vmap_area(size, PAGE_SIZE,
> -				VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
> +				VMALLOC_START, VMALLOC_END, node, gfp_mask);
>  		if (IS_ERR(va))
>  			return NULL;
>  


It shouldn't work because vmap_page_range still can allocate GFP_KERNEL by pud_alloc in vmap_pud_range.
For it, I tried [1] but other mm guys want to add WARNING [2] so let's avoiding gfp context passing.

[1] https://lkml.org/lkml/2012/4/23/77
[2] https://lkml.org/lkml/2012/5/2/340

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
