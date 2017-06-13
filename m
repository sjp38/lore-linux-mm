Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA766B0279
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 13:56:35 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v20so57303598qtg.3
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 10:56:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h8si647795qtc.332.2017.06.13.10.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 10:56:33 -0700 (PDT)
Date: Tue, 13 Jun 2017 20:56:23 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 3/6] virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
Message-ID: <20170613200049-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-4-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497004901-30593-4-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, Matthew Wilcox <willy@infradead.org>

On Fri, Jun 09, 2017 at 06:41:38PM +0800, Wei Wang wrote:
> Add a new feature, VIRTIO_BALLOON_F_PAGE_CHUNKS, which enables
> the transfer of the ballooned (i.e. inflated/deflated) pages in
> chunks to the host.

so now these chunks are just s/g list entry.
So let's rename this VIRTIO_BALLOON_F_SG with a comment:
* Use standard virtio s/g instead of PFN lists *

> The implementation of the previous virtio-balloon is not very
> efficient, because the ballooned pages are transferred to the
> host one by one. Here is the breakdown of the time in percentage
> spent on each step of the balloon inflating process (inflating
> 7GB of an 8GB idle guest).
> 
> 1) allocating pages (6.5%)
> 2) sending PFNs to host (68.3%)
> 3) address translation (6.1%)
> 4) madvise (19%)
> 
> It takes about 4126ms for the inflating process to complete.
> The above profiling shows that the bottlenecks are stage 2)
> and stage 4).
> 
> This patch optimizes step 2) by transferring pages to the host in
> chunks. A chunk consists of guest physically continuous pages.
> When the pages are packed into a chunk, they are converted into
> balloon page size (4KB) pages. A chunk is offered to the host
> via a base address (i.e. the start guest physical address of those
> physically continuous pages) and the size (i.e. the total number
> of the 4KB balloon size pages). A chunk is described via a
> vring_desc struct in the implementation.
> 
> By doing so, step 4) can also be optimized by doing address
> translation and madvise() in chunks rather than page by page.
> 
> With this new feature, the above ballooning process takes ~590ms
> resulting in an improvement of ~85%.
> 
> TODO: optimize stage 1) by allocating/freeing a chunk of pages
> instead of a single page each time.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/virtio/virtio_balloon.c     | 418 +++++++++++++++++++++++++++++++++---
>  drivers/virtio/virtio_ring.c        | 120 ++++++++++-
>  include/linux/virtio.h              |   7 +
>  include/uapi/linux/virtio_balloon.h |   1 +
>  include/uapi/linux/virtio_ring.h    |   3 +
>  5 files changed, 517 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index ecb64e9..0cf945c 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -51,6 +51,36 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>  static struct vfsmount *balloon_mnt;
>  #endif
>  
> +/* The size of one page_bmap used to record inflated/deflated pages. */
> +#define VIRTIO_BALLOON_PAGE_BMAP_SIZE	(8 * PAGE_SIZE)

At this size, you probably want alloc_pages to avoid kmalloc
overhead.

> +/*
> + * Callulates how many pfns can a page_bmap record. A bit corresponds to a
> + * page of PAGE_SIZE.
> + */
> +#define VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP \
> +	(VIRTIO_BALLOON_PAGE_BMAP_SIZE * BITS_PER_BYTE)
> +
> +/* The number of page_bmap to allocate by default. */
> +#define VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM	1

It's not by default, it's at probe time, right?

> +/* The maximum number of page_bmap that can be allocated. */

Not really, this is the size of the array we use to keep them.

> +#define VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM	32
> +

So you still have a home-grown bitmap. I'd like to know why
isn't xbitmap suggested for this purpose by Matthew Wilcox
appropriate. Please add a comment explaining the requirements
from the data structure.

> +/*
> + * QEMU virtio implementation requires the desc table size less than
> + * VIRTQUEUE_MAX_SIZE, so minus 1 here.

I think it doesn't, the issue is probably that you add a header
as a separate s/g. In any case see below.

> + */
> +#define VIRTIO_BALLOON_MAX_PAGE_CHUNKS (VIRTQUEUE_MAX_SIZE - 1)

This is wrong, virtio spec says s/g size should not exceed VQ size.
If you want to support huge VQ sizes, you can add a fallback to
smaller sizes until it fits in 1 page.

> +
> +/* The struct to manage ballooned pages in chunks */
> +struct virtio_balloon_page_chunk {
> +	/* Indirect desc table to hold chunks of balloon pages */
> +	struct vring_desc *desc_table;
> +	/* Number of added chunks of balloon pages */
> +	unsigned int chunk_num;
> +	/* Bitmap used to record ballooned pages. */
> +	unsigned long *page_bmap[VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM];
> +};
> +
>  struct virtio_balloon {
>  	struct virtio_device *vdev;
>  	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> @@ -79,6 +109,8 @@ struct virtio_balloon {
>  	/* Synchronize access/update to this struct virtio_balloon elements */
>  	struct mutex balloon_lock;
>  
> +	struct virtio_balloon_page_chunk balloon_page_chunk;
> +
>  	/* The array of pfns we tell the Host about. */
>  	unsigned int num_pfns;
>  	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
> @@ -111,6 +143,133 @@ static void balloon_ack(struct virtqueue *vq)
>  	wake_up(&vb->acked);
>  }
>  
> +/* Update pfn_max and pfn_min according to the pfn of page */
> +static inline void update_pfn_range(struct virtio_balloon *vb,
> +				    struct page *page,
> +				    unsigned long *pfn_min,
> +				    unsigned long *pfn_max)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +
> +	*pfn_min = min(pfn, *pfn_min);
> +	*pfn_max = max(pfn, *pfn_max);
> +}
> +
> +static unsigned int extend_page_bmap_size(struct virtio_balloon *vb,
> +					  unsigned long pfn_num)

what's this API doing?  Pls add comments. this seems to assume
it will only be called once. it would be better to avoid making
this assumption, just look at what has been allocated
and extend it.

> +{
> +	unsigned int i, bmap_num, allocated_bmap_num;
> +	unsigned long bmap_len;
> +
> +	allocated_bmap_num = VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM;

how come? Pls init vars where they are declared.

> +	bmap_len = ALIGN(pfn_num, BITS_PER_LONG) / BITS_PER_BYTE;
> +	bmap_len = roundup(bmap_len, VIRTIO_BALLOON_PAGE_BMAP_SIZE);
> +	/*
> +	 * VIRTIO_BALLOON_PAGE_BMAP_SIZE is the size of one page_bmap, so
> +	 * divide it to calculate how many page_bmap that we need.
> +	 */
> +	bmap_num = (unsigned int)(bmap_len / VIRTIO_BALLOON_PAGE_BMAP_SIZE);
> +	/* The number of page_bmap to allocate should not exceed the max */
> +	bmap_num = min_t(unsigned int, VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM,
> +			 bmap_num);

two comments above don't really help just drop them.

> +
> +	for (i = VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM; i < bmap_num; i++) {
> +		vb->balloon_page_chunk.page_bmap[i] =
> +			    kmalloc(VIRTIO_BALLOON_PAGE_BMAP_SIZE, GFP_KERNEL);
> +		if (vb->balloon_page_chunk.page_bmap[i])
> +			allocated_bmap_num++;
> +		else
> +			break;
> +	}
> +
> +	return allocated_bmap_num;
> +}
> +
> +static void free_extended_page_bmap(struct virtio_balloon *vb,
> +				    unsigned int page_bmap_num)
> +{
> +	unsigned int i;
> +
> +	for (i = VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM; i < page_bmap_num;
> +	     i++) {
> +		kfree(vb->balloon_page_chunk.page_bmap[i]);
> +		vb->balloon_page_chunk.page_bmap[i] = NULL;
> +		page_bmap_num--;
> +	}
> +}
> +
> +static void clear_page_bmap(struct virtio_balloon *vb,
> +			    unsigned int page_bmap_num)
> +{
> +	int i;
> +
> +	for (i = 0; i < page_bmap_num; i++)
> +		memset(vb->balloon_page_chunk.page_bmap[i], 0,
> +		       VIRTIO_BALLOON_PAGE_BMAP_SIZE);
> +}
> +
> +static void send_page_chunks(struct virtio_balloon *vb, struct virtqueue *vq)
> +{
> +	unsigned int len, num;
> +	struct vring_desc *desc = vb->balloon_page_chunk.desc_table;
> +
> +	num = vb->balloon_page_chunk.chunk_num;
> +	if (!virtqueue_indirect_desc_table_add(vq, desc, num)) {
> +		virtqueue_kick(vq);
> +		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> +		vb->balloon_page_chunk.chunk_num = 0;
> +	}
> +}
> +
> +/* Add a chunk to the buffer. */
> +static void add_one_chunk(struct virtio_balloon *vb, struct virtqueue *vq,
> +			  u64 base_addr, u32 size)
> +{
> +	unsigned int *num = &vb->balloon_page_chunk.chunk_num;
> +	struct vring_desc *desc = &vb->balloon_page_chunk.desc_table[*num];
> +
> +	desc->addr = cpu_to_virtio64(vb->vdev, base_addr);
> +	desc->len = cpu_to_virtio32(vb->vdev, size);
> +	*num += 1;
> +	if (*num == VIRTIO_BALLOON_MAX_PAGE_CHUNKS)
> +		send_page_chunks(vb, vq);
> +}
> +

Poking at virtio internals like this is not nice. Pls move to virtio
code.  Also, pages must be read descriptors as host might modify them.

This also lacks viommu support but this is not mandatory as
that is borken atm anyway. I'll send a patch to at least fail cleanly.

> +static void convert_bmap_to_chunks(struct virtio_balloon *vb,
> +				   struct virtqueue *vq,
> +				   unsigned long *bmap,
> +				   unsigned long pfn_start,
> +				   unsigned long size)
> +{
> +	unsigned long next_one, next_zero, pos = 0;
> +	u64 chunk_base_addr;
> +	u32 chunk_size;
> +
> +	while (pos < size) {
> +		next_one = find_next_bit(bmap, size, pos);
> +		/*
> +		 * No "1" bit found, which means that there is no pfn
> +		 * recorded in the rest of this bmap.
> +		 */
> +		if (next_one == size)
> +			break;
> +		next_zero = find_next_zero_bit(bmap, size, next_one + 1);
> +		/*
> +		 * A bit in page_bmap corresponds to a page of PAGE_SIZE.
> +		 * Convert it to be pages of 4KB balloon page size when
> +		 * adding it to a chunk.

This looks wrong. add_one_chunk assumes size in bytes. So should be just
PAGE_SIZE.

> +		 */
> +		chunk_size = (next_zero - next_one) *
> +			     VIRTIO_BALLOON_PAGES_PER_PAGE;

How do you know this won't overflow a 32 bit integer? Needs a comment.

> +		chunk_base_addr = (pfn_start + next_one) <<
> +				  VIRTIO_BALLOON_PFN_SHIFT;

Same here I think we've left pfns behind, we are using standard s/g now.

> +		if (chunk_size) {
> +			add_one_chunk(vb, vq, chunk_base_addr, chunk_size);
> +			pos += next_zero + 1;
> +		}
> +	}
> +}
> +
>  static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>  {
>  	struct scatterlist sg;
> @@ -124,7 +283,35 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>  
>  	/* When host has read buffer, this completes via balloon_ack */
>  	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> +}
> +
> +static void tell_host_from_page_bmap(struct virtio_balloon *vb,
> +				     struct virtqueue *vq,
> +				     unsigned long pfn_start,
> +				     unsigned long pfn_end,
> +				     unsigned int page_bmap_num)
> +{
> +	unsigned long i, pfn_num;
>  
> +	for (i = 0; i < page_bmap_num; i++) {
> +		/*
> +		 * For the last page_bmap, only the remaining number of pfns
> +		 * need to be searched rather than the entire page_bmap.
> +		 */
> +		if (i + 1 == page_bmap_num)
> +			pfn_num = (pfn_end - pfn_start) %
> +				  VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP;
> +		else
> +			pfn_num = VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP;
> +
> +		convert_bmap_to_chunks(vb, vq,
> +				       vb->balloon_page_chunk.page_bmap[i],
> +				       pfn_start +
> +				       i * VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP,
> +				       pfn_num);
> +	}
> +	if (vb->balloon_page_chunk.chunk_num > 0)
> +		send_page_chunks(vb, vq);
>  }
>  
>  static void set_page_pfns(struct virtio_balloon *vb,
> @@ -141,13 +328,89 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  					  page_to_balloon_pfn(page) + i);
>  }
>  
> +/*
> + * Send ballooned pages in chunks to host.
> + * The ballooned pages are recorded in page bitmaps. Each bit in a bitmap
> + * corresponds to a page of PAGE_SIZE. The page bitmaps are searched for
> + * continuous "1" bits, which correspond to continuous pages, to chunk.
> + * When packing those continuous pages into chunks, pages are converted into
> + * 4KB balloon pages.
> + *
> + * pfn_max and pfn_min form the range of pfns that need to use page bitmaps to
> + * record. If the range is too large to be recorded into the allocated page
> + * bitmaps, the page bitmaps are used multiple times to record the entire
> + * range of pfns.
> + */
> +static void tell_host_page_chunks(struct virtio_balloon *vb,
> +				  struct list_head *pages,
> +				  struct virtqueue *vq,
> +				  unsigned long pfn_max,
> +				  unsigned long pfn_min)
> +{
> +	/*
> +	 * The pfn_start and pfn_end form the range of pfns that the allocated
> +	 * page_bmap can record in each round.
> +	 */
> +	unsigned long pfn_start, pfn_end;
> +	/* Total number of allocated page_bmap */
> +	unsigned int page_bmap_num;
> +	struct page *page;
> +	bool found;
> +
> +	/*
> +	 * In the case that one page_bmap is not sufficient to record the pfn
> +	 * range, page_bmap will be extended by allocating more numbers of
> +	 * page_bmap.
> +	 */
> +	page_bmap_num = extend_page_bmap_size(vb, pfn_max - pfn_min + 1);
> +
> +	/* Start from the beginning of the whole pfn range */
> +	pfn_start = pfn_min;
> +	while (pfn_start < pfn_max) {
> +		pfn_end = pfn_start +
> +			  VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP * page_bmap_num;
> +		pfn_end = pfn_end < pfn_max ? pfn_end : pfn_max;
> +		clear_page_bmap(vb, page_bmap_num);
> +		found = false;
> +
> +		list_for_each_entry(page, pages, lru) {
> +			unsigned long bmap_idx, bmap_pos, this_pfn;
> +
> +			this_pfn = page_to_pfn(page);
> +			if (this_pfn < pfn_start || this_pfn > pfn_end)
> +				continue;
> +			bmap_idx = (this_pfn - pfn_start) /
> +				   VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP;
> +			bmap_pos = (this_pfn - pfn_start) %
> +				   VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP;
> +			set_bit(bmap_pos,
> +				vb->balloon_page_chunk.page_bmap[bmap_idx]);
> +
> +			found = true;
> +		}
> +		if (found)
> +			tell_host_from_page_bmap(vb, vq, pfn_start, pfn_end,
> +						 page_bmap_num);
> +		/*
> +		 * Start the next round when pfn_start and pfn_end couldn't
> +		 * cover the whole pfn range given by pfn_max and pfn_min.
> +		 */
> +		pfn_start = pfn_end;
> +	}
> +	free_extended_page_bmap(vb, page_bmap_num);
> +}
> +
>  static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  	unsigned num_allocated_pages;
> +	bool chunking = virtio_has_feature(vb->vdev,
> +					   VIRTIO_BALLOON_F_PAGE_CHUNKS);
> +	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
>  
>  	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	if (!chunking)
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	mutex_lock(&vb->balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
> @@ -162,7 +425,10 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  			msleep(200);
>  			break;
>  		}
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (chunking)
> +			update_pfn_range(vb, page, &pfn_min, &pfn_max);
> +		else
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		if (!virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> @@ -171,8 +437,14 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  
>  	num_allocated_pages = vb->num_pfns;
>  	/* Did we get any? */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->inflate_vq);
> +	if (vb->num_pfns != 0) {
> +		if (chunking)
> +			tell_host_page_chunks(vb, &vb_dev_info->pages,
> +					      vb->inflate_vq,
> +					      pfn_max, pfn_min);
> +		else
> +			tell_host(vb, vb->inflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	return num_allocated_pages;
> @@ -198,9 +470,13 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	struct page *page;
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  	LIST_HEAD(pages);
> +	bool chunking = virtio_has_feature(vb->vdev,
> +					   VIRTIO_BALLOON_F_PAGE_CHUNKS);
> +	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
>  
> -	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	/* Traditionally, we can only do one array worth at a time. */
> +	if (!chunking)
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	mutex_lock(&vb->balloon_lock);
>  	/* We can't release more pages than taken */
> @@ -210,7 +486,10 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  		page = balloon_page_dequeue(vb_dev_info);
>  		if (!page)
>  			break;
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (chunking)
> +			update_pfn_range(vb, page, &pfn_min, &pfn_max);
> +		else
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>  		list_add(&page->lru, &pages);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
> @@ -221,8 +500,13 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
>  	 * is true, we *have* to do it in this order
>  	 */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->deflate_vq);
> +	if (vb->num_pfns != 0) {
> +		if (chunking)
> +			tell_host_page_chunks(vb, &pages, vb->deflate_vq,
> +					      pfn_max, pfn_min);
> +		else
> +			tell_host(vb, vb->deflate_vq);
> +	}
>  	release_pages_balloon(vb, &pages);
>  	mutex_unlock(&vb->balloon_lock);
>  	return num_freed_pages;
> @@ -442,6 +726,14 @@ static int init_vqs(struct virtio_balloon *vb)
>  }
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
> +
> +static void tell_host_one_page(struct virtio_balloon *vb,
> +			       struct virtqueue *vq, struct page *page)
> +{
> +	add_one_chunk(vb, vq, page_to_pfn(page) << VIRTIO_BALLOON_PFN_SHIFT,
> +		      VIRTIO_BALLOON_PAGES_PER_PAGE);
> +}
> +
>  /*
>   * virtballoon_migratepage - perform the balloon page migration on behalf of
>   *			     a compation thread.     (called under page lock)
> @@ -465,6 +757,8 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  {
>  	struct virtio_balloon *vb = container_of(vb_dev_info,
>  			struct virtio_balloon, vb_dev_info);
> +	bool chunking = virtio_has_feature(vb->vdev,
> +					   VIRTIO_BALLOON_F_PAGE_CHUNKS);
>  	unsigned long flags;
>  
>  	/*
> @@ -486,16 +780,22 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  	vb_dev_info->isolated_pages--;
>  	__count_vm_event(BALLOON_MIGRATE);
>  	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
> -	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> -	set_page_pfns(vb, vb->pfns, newpage);
> -	tell_host(vb, vb->inflate_vq);
> -
> +	if (chunking) {
> +		tell_host_one_page(vb, vb->inflate_vq, newpage);
> +	} else {
> +		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		set_page_pfns(vb, vb->pfns, newpage);
> +		tell_host(vb, vb->inflate_vq);
> +	}
>  	/* balloon's page migration 2nd step -- deflate "page" */
>  	balloon_page_delete(page);
> -	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> -	set_page_pfns(vb, vb->pfns, page);
> -	tell_host(vb, vb->deflate_vq);
> -
> +	if (chunking) {
> +		tell_host_one_page(vb, vb->deflate_vq, page);
> +	} else {
> +		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		set_page_pfns(vb, vb->pfns, page);
> +		tell_host(vb, vb->deflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	put_page(page); /* balloon reference */
> @@ -522,9 +822,78 @@ static struct file_system_type balloon_fs = {
>  
>  #endif /* CONFIG_BALLOON_COMPACTION */
>  
> +static void free_page_bmap(struct virtio_balloon *vb)
> +{
> +	int i;
> +
> +	for (i = 0; i < VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM; i++) {
> +		kfree(vb->balloon_page_chunk.page_bmap[i]);
> +		vb->balloon_page_chunk.page_bmap[i] = NULL;
> +	}
> +}
> +
> +static int balloon_page_chunk_init(struct virtio_balloon *vb)
> +{
> +	int i;
> +
> +	vb->balloon_page_chunk.desc_table = alloc_indirect(vb->vdev,
> +						VIRTIO_BALLOON_MAX_PAGE_CHUNKS,
> +						GFP_KERNEL);

This one's problematic, you aren't supposed to use APIs when device
is not inited yet. Seems to work by luck here. I suggest moving
this to probe, that's where we do a bunch of inits.
And then you can move private init back to allocate too.

> +	if (!vb->balloon_page_chunk.desc_table)
> +		goto err_page_chunk;
> +	vb->balloon_page_chunk.chunk_num = 0;
> +
> +	/*
> +	 * The default number of page_bmaps are allocated. More may be
> +	 * allocated on demand.
> +	 */
> +	for (i = 0; i < VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM; i++) {
> +		vb->balloon_page_chunk.page_bmap[i] =
> +			    kmalloc(VIRTIO_BALLOON_PAGE_BMAP_SIZE, GFP_KERNEL);
> +		if (!vb->balloon_page_chunk.page_bmap[i])
> +			goto err_page_bmap;
> +	}
> +
> +	return 0;
> +err_page_bmap:
> +	free_page_bmap(vb);
> +	kfree(vb->balloon_page_chunk.desc_table);
> +	vb->balloon_page_chunk.desc_table = NULL;
> +err_page_chunk:
> +	__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_PAGE_CHUNKS);
> +	dev_warn(&vb->vdev->dev, "%s: failed\n", __func__);
> +	return -ENOMEM;
> +}
> +
> +static int virtballoon_validate(struct virtio_device *vdev)
> +{
> +	struct virtio_balloon *vb = NULL;
> +	int err;
> +
> +	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
> +	if (!vb) {
> +		err = -ENOMEM;
> +		goto err_vb;
> +	}
> +	vb->vdev = vdev;
> +
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_CHUNKS)) {
> +		err = balloon_page_chunk_init(vb);
> +		if (err < 0)
> +			goto err_page_chunk;
> +	}
> +
> +	return 0;
> +
> +err_page_chunk:
> +	kfree(vb);
> +err_vb:
> +	return err;
> +}
> +

So here you are supposed to validate features, not handle OOM
conditions.  BTW we need a fix for vIOMMU - I noticed balloon does not
support that yes.

>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
> -	struct virtio_balloon *vb;
> +	struct virtio_balloon *vb = vdev->priv;
>  	int err;
>  
>  	if (!vdev->config->get) {
> @@ -533,20 +902,14 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		return -EINVAL;
>  	}
>  
> -	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
> -	if (!vb) {
> -		err = -ENOMEM;
> -		goto out;
> -	}
> -
>  	INIT_WORK(&vb->update_balloon_stats_work, update_balloon_stats_func);
>  	INIT_WORK(&vb->update_balloon_size_work, update_balloon_size_func);
>  	spin_lock_init(&vb->stop_update_lock);
>  	vb->stop_update = false;
>  	vb->num_pages = 0;
> +
>  	mutex_init(&vb->balloon_lock);
>  	init_waitqueue_head(&vb->acked);
> -	vb->vdev = vdev;
>  
>  	balloon_devinfo_init(&vb->vb_dev_info);
>  
> @@ -590,7 +953,6 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	vdev->config->del_vqs(vdev);
>  out_free_vb:
>  	kfree(vb);
> -out:
>  	return err;
>  }
>  
> @@ -620,6 +982,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	cancel_work_sync(&vb->update_balloon_stats_work);
>  
>  	remove_common(vb);
> +	free_page_bmap(vb);
> +	kfree(vb->balloon_page_chunk.desc_table);
>  #ifdef CONFIG_BALLOON_COMPACTION
>  	if (vb->vb_dev_info.inode)
>  		iput(vb->vb_dev_info.inode);
> @@ -664,6 +1028,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_PAGE_CHUNKS,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> @@ -674,6 +1039,7 @@ static struct virtio_driver virtio_balloon_driver = {
>  	.id_table =	id_table,
>  	.probe =	virtballoon_probe,
>  	.remove =	virtballoon_remove,
> +	.validate =	virtballoon_validate,
>  	.config_changed = virtballoon_changed,
>  #ifdef CONFIG_PM_SLEEP
>  	.freeze	=	virtballoon_freeze,
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index 409aeaa..0ea2512 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -235,8 +235,17 @@ static int vring_mapping_error(const struct vring_virtqueue *vq,
>  	return dma_mapping_error(vring_dma_dev(vq), addr);
>  }
>  
> -static struct vring_desc *alloc_indirect(struct virtqueue *_vq,
> -					 unsigned int total_sg, gfp_t gfp)
> +/**
> + * alloc_indirect - allocate an indirect desc table
> + * @vdev: the virtio_device that owns the indirect desc table.
> + * @num: the number of entries that the table will have.
> + * @gfp: how to do memory allocations (if necessary).
> + *
> + * Return NULL if the table allocation failed. Otherwise, return the address
> + * of the table.
> + */
> +struct vring_desc *alloc_indirect(struct virtio_device *vdev, unsigned int num,
> +				  gfp_t gfp)
>  {
>  	struct vring_desc *desc;
>  	unsigned int i;
> @@ -248,14 +257,15 @@ static struct vring_desc *alloc_indirect(struct virtqueue *_vq,
>  	 */
>  	gfp &= ~__GFP_HIGHMEM;
>  
> -	desc = kmalloc(total_sg * sizeof(struct vring_desc), gfp);
> +	desc = kmalloc_array(num, sizeof(struct vring_desc), gfp);
>  	if (!desc)
>  		return NULL;
>  
> -	for (i = 0; i < total_sg; i++)
> -		desc[i].next = cpu_to_virtio16(_vq->vdev, i + 1);
> +	for (i = 0; i < num; i++)
> +		desc[i].next = cpu_to_virtio16(vdev, i + 1);
>  	return desc;
>  }
> +EXPORT_SYMBOL_GPL(alloc_indirect);
>  
>  static inline int virtqueue_add(struct virtqueue *_vq,
>  				struct scatterlist *sgs[],
> @@ -302,7 +312,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
>  	/* If the host supports indirect descriptor tables, and we have multiple
>  	 * buffers, then go indirect. FIXME: tune this threshold */
>  	if (vq->indirect && total_sg > 1 && vq->vq.num_free)
> -		desc = alloc_indirect(_vq, total_sg, gfp);
> +		desc = alloc_indirect(_vq->vdev, total_sg, gfp);
>  	else
>  		desc = NULL;
>  
> @@ -433,6 +443,104 @@ static inline int virtqueue_add(struct virtqueue *_vq,
>  }
>  
>  /**
> + * virtqueue_indirect_desc_table_add - add an indirect desc table to the vq
> + * @_vq: the struct virtqueue we're talking about.
> + * @desc: the desc table we're talking about.
> + * @num: the number of entries that the desc table has.
> + *
> + * Returns zero or a negative error (ie. ENOSPC, EIO).
> + */
> +int virtqueue_indirect_desc_table_add(struct virtqueue *_vq,
> +				      struct vring_desc *desc,
> +				      unsigned int num)
> +{
> +	struct vring_virtqueue *vq = to_vvq(_vq);
> +	dma_addr_t desc_addr;
> +	unsigned int i, avail;
> +	int head;
> +
> +	/* Sanity check */
> +	if (!desc) {
> +		pr_debug("%s: empty desc table\n", __func__);
> +		return -EINVAL;
> +	}
> +
> +	START_USE(vq);
> +
> +	if (unlikely(vq->broken)) {
> +		END_USE(vq);
> +		return -EIO;
> +	}
> +
> +	if (!vq->vq.num_free) {
> +		pr_debug("%s: the virtioqueue is full\n", __func__);
> +		END_USE(vq);
> +		return -ENOSPC;
> +	}
> +
> +	/* Map and fill in the indirect table */
> +	desc_addr = vring_map_single(vq, desc, num * sizeof(struct vring_desc),
> +				     DMA_TO_DEVICE);
> +	if (vring_mapping_error(vq, desc_addr)) {
> +		pr_debug("%s: map desc failed\n", __func__);
> +		END_USE(vq);
> +		return -EIO;
> +	}
> +
> +	/* Mark the flag of the table entries */
> +	for (i = 0; i < num; i++)
> +		desc[i].flags = cpu_to_virtio16(_vq->vdev, VRING_DESC_F_NEXT);
> +	/* The last one doesn't continue. */
> +	desc[num - 1].flags &= cpu_to_virtio16(_vq->vdev, ~VRING_DESC_F_NEXT);
> +
> +	/* Get a ring entry to point to the indirect table */
> +	head = vq->free_head;
> +	vq->vring.desc[head].flags = cpu_to_virtio16(_vq->vdev,
> +						     VRING_DESC_F_INDIRECT);
> +	vq->vring.desc[head].addr = cpu_to_virtio64(_vq->vdev, desc_addr);
> +	vq->vring.desc[head].len = cpu_to_virtio32(_vq->vdev, num *
> +						   sizeof(struct vring_desc));
> +	/* We're using 1 buffers from the free list. */
> +	vq->vq.num_free--;
> +	/* Update free pointer */
> +	vq->free_head = virtio16_to_cpu(_vq->vdev, vq->vring.desc[head].next);
> +
> +	/* Store token and indirect buffer state. */
> +	vq->desc_state[head].data = desc;
> +	/* Don't free the caller allocated indirect table when detach_buf. */
> +	vq->desc_state[head].indir_desc = NULL;
> +
> +	/*
> +	 * Put entry in available array (but don't update avail->idx until they
> +	 * do sync).
> +	 */
> +	avail = vq->avail_idx_shadow & (vq->vring.num - 1);
> +	vq->vring.avail->ring[avail] = cpu_to_virtio16(_vq->vdev, head);
> +
> +	/*
> +	 * Descriptors and available array need to be set before we expose the
> +	 * new available array entries.
> +	 */
> +	virtio_wmb(vq->weak_barriers);
> +	vq->avail_idx_shadow++;
> +	vq->vring.avail->idx = cpu_to_virtio16(_vq->vdev, vq->avail_idx_shadow);
> +	vq->num_added++;
> +
> +	pr_debug("%s: added buffer head %i to %p\n", __func__, head, vq);
> +	END_USE(vq);
> +
> +	/*
> +	 * This is very unlikely, but theoretically possible.  Kick
> +	 * just in case.
> +	 */
> +	if (unlikely(vq->num_added == (1 << 16) - 1))
> +		virtqueue_kick(_vq);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(virtqueue_indirect_desc_table_add);
> +

I'm not really happy with the fact we are duplicating so much code. Most
of this is duplicated from virtqueue_add, isn't it? I imagine you just
need to factor out the code from the following place down:

        /* If the host supports indirect descriptor tables, and we have multiple
         * buffers, then go indirect. FIXME: tune this threshold */
        if (vq->indirect && total_sg > 1 && vq->vq.num_free)
                desc = alloc_indirect(_vq, total_sg, gfp);
        else
                desc = NULL;

then reuse that.

> +/**
>   * virtqueue_add_sgs - expose buffers to other end
>   * @vq: the struct virtqueue we're talking about.
>   * @sgs: array of terminated scatterlists.
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 7edfbdb..01dad22 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -34,6 +34,13 @@ struct virtqueue {
>  	void *priv;
>  };
>  
> +struct vring_desc *alloc_indirect(struct virtio_device *vdev,
> +				  unsigned int num, gfp_t gfp);
> +

Please prefix with virtqueue or virtio (depending on 1st parameter).
You also want a free API to pair with this (even though it's just kfree
right now).

> +int virtqueue_indirect_desc_table_add(struct virtqueue *_vq,
> +				      struct vring_desc *desc,
> +				      unsigned int num);
> +
>  int virtqueue_add_outbuf(struct virtqueue *vq,
>  			 struct scatterlist sg[], unsigned int num,
>  			 void *data,
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 343d7dd..5ed3c7b 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,6 +34,7 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_PAGE_CHUNKS	3 /* Inflate/Deflate pages in chunks */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> diff --git a/include/uapi/linux/virtio_ring.h b/include/uapi/linux/virtio_ring.h
> index c072959..0499fb8 100644
> --- a/include/uapi/linux/virtio_ring.h
> +++ b/include/uapi/linux/virtio_ring.h
> @@ -111,6 +111,9 @@ struct vring {
>  #define VRING_USED_ALIGN_SIZE 4
>  #define VRING_DESC_ALIGN_SIZE 16
>  
> +/* The supported max queue size */
> +#define VIRTQUEUE_MAX_SIZE 1024
> +
>  /* The standard layout for the ring is a continuous chunk of memory which looks
>   * like this.  We assume num is a power of 2.
>   *

Please do not add this to UAPI.

> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
