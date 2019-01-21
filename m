Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E69D8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:37:52 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t2so15566416pfj.15
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 01:37:52 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t77si9103289pgb.51.2019.01.21.01.37.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 01:37:50 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0L9YVPL025683
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:37:50 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q58e782cu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:37:49 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 09:37:47 -0000
Date: Mon, 21 Jan 2019 11:37:40 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] Add kv_to_page()
References: <20190121003944.GA26866@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121003944.GA26866@bombadil.infradead.org>
Message-Id: <20190121093739.GA19725@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 20, 2019 at 04:39:44PM -0800, Matthew Wilcox wrote:
> 
> We currently have 12 places in the kernel which call either
> vmalloc_to_page() or virt_to_page() or even kmap_to_page() depending on
> the type of memory passed to them.  This is clearly useful functionality
> we should provide in the kernel core so add kv_to_page() and convert
> these users.
> 
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> 
> ---
>  drivers/fpga/fpga-mgr.c                  |    5 +----
>  drivers/gpu/drm/ttm/ttm_page_alloc_dma.c |    5 +----
>  drivers/md/bcache/util.c                 |    5 +----
>  drivers/md/dm-writecache.c               |   17 ++---------------
>  drivers/misc/mic/scif/scif_rma.c         |   26 ++++----------------------
>  drivers/spi/spi.c                        |    5 +----
>  drivers/uio/uio.c                        |    5 +----
>  drivers/virt/vboxguest/vboxguest_utils.c |   10 +---------
>  fs/xfs/xfs_buf.c                         |   13 +------------
>  include/linux/mm.h                       |    2 ++
>  mm/util.c                                |   12 ++++++++++++
>  net/9p/trans_virtio.c                    |    5 +----
>  net/ceph/crypto.c                        |    6 +-----
>  net/packet/af_packet.c                   |   31 ++++++++++++-------------------
>  14 files changed, 41 insertions(+), 106 deletions(-)
> 
> diff --git a/drivers/fpga/fpga-mgr.c b/drivers/fpga/fpga-mgr.c
> index c3866816456a..a39b2461a3d1 100644
> --- a/drivers/fpga/fpga-mgr.c
> +++ b/drivers/fpga/fpga-mgr.c
> @@ -275,10 +275,7 @@ static int fpga_mgr_buf_load(struct fpga_manager *mgr,
> 
>  	p = buf - offset_in_page(buf);
>  	for (index = 0; index < nr_pages; index++) {
> -		if (is_vmalloc_addr(p))
> -			pages[index] = vmalloc_to_page(p);
> -		else
> -			pages[index] = kmap_to_page((void *)p);
> +		pages[index] = kv_to_page(p);
>  		if (!pages[index]) {
>  			kfree(pages);
>  			return -EFAULT;
> diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> index d594f7520b7b..46326de4d9fe 100644
> --- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> +++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> @@ -308,10 +308,7 @@ static struct dma_page *__ttm_dma_alloc_page(struct dma_pool *pool)
>  	vaddr = dma_alloc_attrs(pool->dev, pool->size, &d_page->dma,
>  				pool->gfp_flags, attrs);
>  	if (vaddr) {
> -		if (is_vmalloc_addr(vaddr))
> -			d_page->p = vmalloc_to_page(vaddr);
> -		else
> -			d_page->p = virt_to_page(vaddr);
> +		d_page->p = kv_to_page(vaddr);
>  		d_page->vaddr = (unsigned long)vaddr;
>  		if (pool->type & IS_HUGE)
>  			d_page->vaddr |= VADDR_FLAG_HUGE_POOL;
> diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
> index 20eddeac1531..2609ba9f27b6 100644
> --- a/drivers/md/bcache/util.c
> +++ b/drivers/md/bcache/util.c
> @@ -244,10 +244,7 @@ void bch_bio_map(struct bio *bio, void *base)
>  start:		bv->bv_len	= min_t(size_t, PAGE_SIZE - bv->bv_offset,
>  					size);
>  		if (base) {
> -			bv->bv_page = is_vmalloc_addr(base)
> -				? vmalloc_to_page(base)
> -				: virt_to_page(base);
> -
> +			bv->bv_page = kv_to_page(base);
>  			base += bv->bv_len;
>  		}
> 
> diff --git a/drivers/md/dm-writecache.c b/drivers/md/dm-writecache.c
> index 2b8cee35e4d5..50ae919d66b9 100644
> --- a/drivers/md/dm-writecache.c
> +++ b/drivers/md/dm-writecache.c
> @@ -318,19 +318,6 @@ static void persistent_memory_release(struct dm_writecache *wc)
>  		vunmap(wc->memory_map - ((size_t)wc->start_sector << SECTOR_SHIFT));
>  }
> 
> -static struct page *persistent_memory_page(void *addr)
> -{
> -	if (is_vmalloc_addr(addr))
> -		return vmalloc_to_page(addr);
> -	else
> -		return virt_to_page(addr);
> -}
> -
> -static unsigned persistent_memory_page_offset(void *addr)
> -{
> -	return (unsigned long)addr & (PAGE_SIZE - 1);
> -}
> -
>  static void persistent_memory_flush_cache(void *ptr, size_t size)
>  {
>  	if (is_vmalloc_addr(ptr))
> @@ -1439,8 +1426,8 @@ static bool wc_add_block(struct writeback_struct *wb, struct wc_entry *e, gfp_t
>  	void *address = memory_data(wc, e);
> 
>  	persistent_memory_flush_cache(address, block_size);
> -	return bio_add_page(&wb->bio, persistent_memory_page(address),
> -			    block_size, persistent_memory_page_offset(address)) != 0;
> +	return bio_add_page(&wb->bio, kv_to_page(address), block_size,
> +			offset_in_page(address)) != 0;

This would be less eye hurting with 

	struct page *page = kv_to_page(address);
	unsigned offset = offset_in_page(address);

defined.

>  }
> 
>  struct writeback_list {
> diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
> index 749321eb91ae..ee38b346985c 100644
> --- a/drivers/misc/mic/scif/scif_rma.c
> +++ b/drivers/misc/mic/scif/scif_rma.c
> @@ -370,7 +370,6 @@ static int scif_create_remote_lookup(struct scif_dev *remote_dev,
>  {
>  	int i, j, err = 0;
>  	int nr_pages = window->nr_pages;
> -	bool vmalloc_dma_phys, vmalloc_num_pages;
> 
>  	might_sleep();
>  	/* Map window */
> @@ -403,23 +402,14 @@ static int scif_create_remote_lookup(struct scif_dev *remote_dev,
>  		goto error_window;
>  	}
> 
> -	vmalloc_dma_phys = is_vmalloc_addr(&window->dma_addr[0]);
> -	vmalloc_num_pages = is_vmalloc_addr(&window->num_pages[0]);
> -
>  	/* Now map each of the pages containing physical addresses */
>  	for (i = 0, j = 0; i < nr_pages; i += SCIF_NR_ADDR_IN_PAGE, j++) {
>  		err = scif_map_page(&window->dma_addr_lookup.lookup[j],
> -				    vmalloc_dma_phys ?
> -				    vmalloc_to_page(&window->dma_addr[i]) :
> -				    virt_to_page(&window->dma_addr[i]),
> -				    remote_dev);
> +				kv_to_page(&window->dma_addr[i]), remote_dev);
>  		if (err)
>  			goto error_window;
>  		err = scif_map_page(&window->num_pages_lookup.lookup[j],
> -				    vmalloc_num_pages ?
> -				    vmalloc_to_page(&window->num_pages[i]) :
> -				    virt_to_page(&window->num_pages[i]),
> -				    remote_dev);
> +				kv_to_page(&window->num_pages[i]), remote_dev);

I'd add a temporary variable here.

>  		if (err)
>  			goto error_window;
>  	}
> @@ -1327,7 +1317,6 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
>  {
>  	struct scif_pinned_pages *pinned_pages;
>  	int nr_pages, err = 0, i;
> -	bool vmalloc_addr = false;
>  	bool try_upgrade = false;
>  	int prot = *out_prot;
>  	int ulimit = 0;
> @@ -1358,16 +1347,9 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
>  		return -ENOMEM;
> 
>  	if (map_flags & SCIF_MAP_KERNEL) {
> -		if (is_vmalloc_addr(addr))
> -			vmalloc_addr = true;
> -
>  		for (i = 0; i < nr_pages; i++) {
> -			if (vmalloc_addr)
> -				pinned_pages->pages[i] =
> -					vmalloc_to_page(addr + (i * PAGE_SIZE));
> -			else
> -				pinned_pages->pages[i] =
> -					virt_to_page(addr + (i * PAGE_SIZE));
> +			pinned_pages->pages[i] =
> +				kv_to_page(addr + (i * PAGE_SIZE));
>  		}
>  		pinned_pages->nr_pages = nr_pages;
>  		pinned_pages->map_flags = SCIF_MAP_KERNEL;
> diff --git a/drivers/spi/spi.c b/drivers/spi/spi.c
> index 9a7def7c3237..1382cc18e7db 100644
> --- a/drivers/spi/spi.c
> +++ b/drivers/spi/spi.c
> @@ -833,10 +833,7 @@ int spi_map_buf(struct spi_controller *ctlr, struct device *dev,
>  			min = min_t(size_t, desc_len,
>  				    min_t(size_t, len,
>  					  PAGE_SIZE - offset_in_page(buf)));
> -			if (vmalloced_buf)
> -				vm_page = vmalloc_to_page(buf);
> -			else
> -				vm_page = kmap_to_page(buf);
> +			vm_page = kv_to_page(buf);
>  			if (!vm_page) {
>  				sg_free_table(sgt);
>  				return -ENOMEM;
> diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
> index 131342280b46..6de5ffa506c0 100644
> --- a/drivers/uio/uio.c
> +++ b/drivers/uio/uio.c
> @@ -692,10 +692,7 @@ static vm_fault_t uio_vma_fault(struct vm_fault *vmf)
>  	offset = (vmf->pgoff - mi) << PAGE_SHIFT;
> 
>  	addr = (void *)(unsigned long)idev->info->mem[mi].addr + offset;
> -	if (idev->info->mem[mi].memtype == UIO_MEM_LOGICAL)
> -		page = virt_to_page(addr);
> -	else
> -		page = vmalloc_to_page(addr);
> +	page = kv_to_page(addr);
>  	get_page(page);
>  	vmf->page = page;
> 
> diff --git a/drivers/virt/vboxguest/vboxguest_utils.c b/drivers/virt/vboxguest/vboxguest_utils.c
> index bf4474214b4d..4999b17210c9 100644
> --- a/drivers/virt/vboxguest/vboxguest_utils.c
> +++ b/drivers/virt/vboxguest/vboxguest_utils.c
> @@ -326,8 +326,6 @@ static void hgcm_call_init_linaddr(struct vmmdev_hgcm_call *call,
>  	enum vmmdev_hgcm_function_parameter_type type, u32 *off_extra)
>  {
>  	struct vmmdev_hgcm_pagelist *dst_pg_lst;
> -	struct page *page;
> -	bool is_vmalloc;
>  	u32 i, page_count;
> 
>  	dst_parm->type = type;
> @@ -340,7 +338,6 @@ static void hgcm_call_init_linaddr(struct vmmdev_hgcm_call *call,
> 
>  	dst_pg_lst = (void *)call + *off_extra;
>  	page_count = hgcm_call_buf_size_in_pages(buf, len);
> -	is_vmalloc = is_vmalloc_addr(buf);
> 
>  	dst_parm->type = VMMDEV_HGCM_PARM_TYPE_PAGELIST;
>  	dst_parm->u.page_list.size = len;
> @@ -350,12 +347,7 @@ static void hgcm_call_init_linaddr(struct vmmdev_hgcm_call *call,
>  	dst_pg_lst->page_count = page_count;
> 
>  	for (i = 0; i < page_count; i++) {
> -		if (is_vmalloc)
> -			page = vmalloc_to_page(buf);
> -		else
> -			page = virt_to_page(buf);
> -
> -		dst_pg_lst->pages[i] = page_to_phys(page);
> +		dst_pg_lst->pages[i] = page_to_phys(kv_to_page(buf));
>  		buf += PAGE_SIZE;
>  	}
> 
> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index b21ea2ba768d..b84ecd2a012d 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -922,17 +922,6 @@ xfs_buf_set_empty(
>  	bp->b_maps[0].bm_len = bp->b_length;
>  }
> 
> -static inline struct page *
> -mem_to_page(
> -	void			*addr)
> -{
> -	if ((!is_vmalloc_addr(addr))) {
> -		return virt_to_page(addr);
> -	} else {
> -		return vmalloc_to_page(addr);
> -	}
> -}
> -
>  int
>  xfs_buf_associate_memory(
>  	xfs_buf_t		*bp,
> @@ -965,7 +954,7 @@ xfs_buf_associate_memory(
>  	bp->b_offset = offset;
> 
>  	for (i = 0; i < bp->b_page_count; i++) {
> -		bp->b_pages[i] = mem_to_page((void *)pageaddr);
> +		bp->b_pages[i] = kv_to_page((void *)pageaddr);
>  		pageaddr += PAGE_SIZE;
>  	}
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c6a5aabc7f85..5056fe66f259 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -691,6 +691,8 @@ static inline struct page *virt_to_head_page(const void *x)
>  	return compound_head(page);
>  }
> 
> +struct page *kv_to_page(const void *addr);
> +
>  void __put_page(struct page *page);
> 
>  void put_pages_list(struct list_head *pages);
> diff --git a/mm/util.c b/mm/util.c
> index 4df23d64aac7..a7ddfbe04a15 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -446,6 +446,18 @@ void kvfree(const void *addr)
>  }
>  EXPORT_SYMBOL(kvfree);
> 
> +/**
> + * kv_to_page() - Return the struct page for a virtual address
> + * @addr: Virtual address

I know adding 'Return:' here is redundant, but without it there will be
warning in 'make V=1 htmldocs'.

> + */
> +struct page *kv_to_page(const void *addr)
> +{
> +	if (is_vmalloc_addr(addr))
> +		return vmalloc_to_page(addr);
> +	return kmap_to_page((void *)addr);
> +}
> +EXPORT_SYMBOL(kv_to_page);
> +
>  static inline void *__page_rmapping(struct page *page)
>  {
>  	unsigned long mapping;
> diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
> index b1d39cabf125..2afdf6f3418b 100644
> --- a/net/9p/trans_virtio.c
> +++ b/net/9p/trans_virtio.c
> @@ -377,10 +377,7 @@ static int p9_get_mapped_pages(struct virtio_chan *chan,
>  		*need_drop = 0;
>  		p -= (*offs = offset_in_page(p));
>  		for (index = 0; index < nr_pages; index++) {
> -			if (is_vmalloc_addr(p))
> -				(*pages)[index] = vmalloc_to_page(p);
> -			else
> -				(*pages)[index] = kmap_to_page(p);
> +			(*pages)[index] = kv_to_page(p);
>  			p += PAGE_SIZE;
>  		}
>  		return len;
> diff --git a/net/ceph/crypto.c b/net/ceph/crypto.c
> index 5d6724cee38f..4e13e88dd38c 100644
> --- a/net/ceph/crypto.c
> +++ b/net/ceph/crypto.c
> @@ -191,11 +191,7 @@ static int setup_sgtable(struct sg_table *sgt, struct scatterlist *prealloc_sg,
>  		struct page *page;
>  		unsigned int len = min(chunk_len - off, buf_len);
> 
> -		if (is_vmalloc)
> -			page = vmalloc_to_page(buf);
> -		else
> -			page = virt_to_page(buf);
> -
> +		page = kv_to_page(buf);
>  		sg_set_page(sg, page, len, off);
> 
>  		off = 0;
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index a74650e98f42..c87ea1c09882 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -359,13 +359,6 @@ static void unregister_prot_hook(struct sock *sk, bool sync)
>  		__unregister_prot_hook(sk, sync);
>  }
> 
> -static inline struct page * __pure pgv_to_page(void *addr)
> -{
> -	if (is_vmalloc_addr(addr))
> -		return vmalloc_to_page(addr);
> -	return virt_to_page(addr);
> -}
> -
>  static void __packet_set_status(struct packet_sock *po, void *frame, int status)
>  {
>  	union tpacket_uhdr h;
> @@ -374,15 +367,15 @@ static void __packet_set_status(struct packet_sock *po, void *frame, int status)
>  	switch (po->tp_version) {
>  	case TPACKET_V1:
>  		h.h1->tp_status = status;
> -		flush_dcache_page(pgv_to_page(&h.h1->tp_status));
> +		flush_dcache_page(kv_to_page(&h.h1->tp_status));
>  		break;
>  	case TPACKET_V2:
>  		h.h2->tp_status = status;
> -		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
> +		flush_dcache_page(kv_to_page(&h.h2->tp_status));
>  		break;
>  	case TPACKET_V3:
>  		h.h3->tp_status = status;
> -		flush_dcache_page(pgv_to_page(&h.h3->tp_status));
> +		flush_dcache_page(kv_to_page(&h.h3->tp_status));
>  		break;
>  	default:
>  		WARN(1, "TPACKET version not supported.\n");
> @@ -401,13 +394,13 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
>  	h.raw = frame;
>  	switch (po->tp_version) {
>  	case TPACKET_V1:
> -		flush_dcache_page(pgv_to_page(&h.h1->tp_status));
> +		flush_dcache_page(kv_to_page(&h.h1->tp_status));
>  		return h.h1->tp_status;
>  	case TPACKET_V2:
> -		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
> +		flush_dcache_page(kv_to_page(&h.h2->tp_status));
>  		return h.h2->tp_status;
>  	case TPACKET_V3:
> -		flush_dcache_page(pgv_to_page(&h.h3->tp_status));
> +		flush_dcache_page(kv_to_page(&h.h3->tp_status));
>  		return h.h3->tp_status;
>  	default:
>  		WARN(1, "TPACKET version not supported.\n");
> @@ -462,7 +455,7 @@ static __u32 __packet_set_timestamp(struct packet_sock *po, void *frame,
>  	}
> 
>  	/* one flush is safe, as both fields always lie on the same cacheline */
> -	flush_dcache_page(pgv_to_page(&h.h1->tp_sec));
> +	flush_dcache_page(kv_to_page(&h.h1->tp_sec));
>  	smp_wmb();
> 
>  	return ts_status;
> @@ -728,7 +721,7 @@ static void prb_flush_block(struct tpacket_kbdq_core *pkc1,
> 
>  	end = (u8 *)PAGE_ALIGN((unsigned long)pkc1->pkblk_end);
>  	for (; start < end; start += PAGE_SIZE)
> -		flush_dcache_page(pgv_to_page(start));
> +		flush_dcache_page(kv_to_page(start));
> 
>  	smp_wmb();
>  #endif
> @@ -741,7 +734,7 @@ static void prb_flush_block(struct tpacket_kbdq_core *pkc1,
> 
>  #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
>  	start = (u8 *)pbd1;
> -	flush_dcache_page(pgv_to_page(start));
> +	flush_dcache_page(kv_to_page(start));
> 
>  	smp_wmb();
>  #endif
> @@ -2352,7 +2345,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>  					macoff + snaplen);
> 
>  		for (start = h.raw; start < end; start += PAGE_SIZE)
> -			flush_dcache_page(pgv_to_page(start));
> +			flush_dcache_page(kv_to_page(start));
>  	}
>  	smp_wmb();
>  #endif
> @@ -2508,7 +2501,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>  			return -EFAULT;
>  		}
> 
> -		page = pgv_to_page(data);
> +		page = kv_to_page(data);
>  		data += len;
>  		flush_dcache_page(page);
>  		get_page(page);
> @@ -4423,7 +4416,7 @@ static int packet_mmap(struct file *file, struct socket *sock,
>  			int pg_num;
> 
>  			for (pg_num = 0; pg_num < rb->pg_vec_pages; pg_num++) {
> -				page = pgv_to_page(kaddr);
> +				page = kv_to_page(kaddr);
>  				err = vm_insert_page(vma, start, page);
>  				if (unlikely(err))
>  					goto out;
> 

-- 
Sincerely yours,
Mike.
