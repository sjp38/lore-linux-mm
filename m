Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE6AB6B0388
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 23:01:53 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id j127so49880279qke.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 20:01:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a44si1918909qtc.322.2017.03.07.20.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 20:01:29 -0800 (PST)
Date: Wed, 8 Mar 2017 06:01:25 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 kernel 3/5] virtio-balloon: implementation of
 VIRTIO_BALLOON_F_CHUNK_TRANSFER
Message-ID: <20170308054813-mutt-send-email-mst@kernel.org>
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
 <1488519630-89058-4-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488519630-89058-4-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, Liang Li <liang.z.li@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

On Fri, Mar 03, 2017 at 01:40:28PM +0800, Wei Wang wrote:
> From: Liang Li <liang.z.li@intel.com>
> 
> The implementation of the current virtio-balloon is not very
> efficient, because the pages are transferred to the host one by one.
> Here is the breakdown of the time in percentage spent on each
> step of the balloon inflating process (inflating 7GB of an 8GB
> idle guest).
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
> This patch optimizes step 2) by transfering pages to the host in
> chunks. A chunk consists of guest physically continuous pages, and
> it is offered to the host via a base PFN (i.e. the start PFN of
> those physically continuous pages) and the size (i.e. the total
> number of the pages). A normal chunk is formated as below:
> -----------------------------------------------
> |  Base (52 bit)               | Size (12 bit)|
> -----------------------------------------------
> For large size chunks, an extended chunk format is used:
> -----------------------------------------------
> |                 Base (64 bit)               |
> -----------------------------------------------
> -----------------------------------------------
> |                 Size (64 bit)               |
> -----------------------------------------------
> 
> By doing so, step 4) can also be optimized by doing address
> translation and madvise() in chunks rather than page by page.
> 
> This optimization requires the negotation of a new feature bit,
> VIRTIO_BALLOON_F_CHUNK_TRANSFER.
> 
> With this new feature, the above ballooning process takes ~590ms
> resulting in an improvement of ~85%.
> 
> TODO: optimize stage 1) by allocating/freeing a chunk of pages
> instead of a single page each time.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Cc: Amit Shah <amit.shah@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Liang Li <liliang324@gmail.com>
> Cc: Wei Wang <wei.w.wang@intel.com>

Does this pass sparse? I see some endian-ness issues here.

> ---
>  drivers/virtio/virtio_balloon.c | 351 ++++++++++++++++++++++++++++++++++++----
>  1 file changed, 323 insertions(+), 28 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index f59cb4f..4416370 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -42,6 +42,10 @@
>  #define OOM_VBALLOON_DEFAULT_PAGES 256
>  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
>  
> +#define PAGE_BMAP_SIZE	(8 * PAGE_SIZE)
> +#define PFNS_PER_PAGE_BMAP	(PAGE_BMAP_SIZE * BITS_PER_BYTE)
> +#define PAGE_BMAP_COUNT_MAX	32
> +
>  static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
>  module_param(oom_pages, int, S_IRUSR | S_IWUSR);
>  MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
> @@ -50,6 +54,16 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>  static struct vfsmount *balloon_mnt;
>  #endif
>  
> +struct balloon_page_chunk {
> +	__le64 base : 52;
> +	__le64 size : 12;
> +};
> +
> +struct balloon_page_chunk_ext {
> +	__le64 base;
> +	__le64 size;
> +};
> +
>  struct virtio_balloon {
>  	struct virtio_device *vdev;
>  	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> @@ -67,6 +81,20 @@ struct virtio_balloon {
>  
>  	/* Number of balloon pages we've told the Host we're not using. */
>  	unsigned int num_pages;
> +	/* Pointer to the response header. */
> +	struct virtio_balloon_resp_hdr resp_hdr;
> +	/* Pointer to the start address of response data. */
> +	__le64 *resp_data;
> +	/* Size of response data buffer. */
> +	unsigned int resp_buf_size;
> +	/* Pointer offset of the response data. */
> +	unsigned int resp_pos;
> +	/* Bitmap used to save the pfns info */
> +	unsigned long *page_bitmap[PAGE_BMAP_COUNT_MAX];
> +	/* Number of split page bitmaps */
> +	unsigned int nr_page_bmap;
> +	/* Used to record the processed pfn range */
> +	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
>  	/*
>  	 * The pages we've told the Host we're not using are enqueued
>  	 * at vb_dev_info->pages list.
> @@ -110,20 +138,180 @@ static void balloon_ack(struct virtqueue *vq)
>  	wake_up(&vb->acked);
>  }
>  
> -static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> +static inline void init_bmap_pfn_range(struct virtio_balloon *vb)
>  {
> -	struct scatterlist sg;
> +	vb->min_pfn = ULONG_MAX;
> +	vb->max_pfn = 0;
> +}
> +
> +static inline void update_bmap_pfn_range(struct virtio_balloon *vb,
> +				 struct page *page)
> +{
> +	unsigned long balloon_pfn = page_to_balloon_pfn(page);
> +
> +	vb->min_pfn = min(balloon_pfn, vb->min_pfn);
> +	vb->max_pfn = max(balloon_pfn, vb->max_pfn);
> +}
> +
> +static void extend_page_bitmap(struct virtio_balloon *vb,
> +				unsigned long nr_pfn)


what exactly does this do?

> +{
> +	int i, bmap_count;
> +	unsigned long bmap_len;
> +
> +	bmap_len = ALIGN(nr_pfn, BITS_PER_LONG) / BITS_PER_BYTE;
> +	bmap_len = ALIGN(bmap_len, PAGE_BMAP_SIZE);
> +	bmap_count = min((int)(bmap_len / PAGE_BMAP_SIZE),
> +				 PAGE_BMAP_COUNT_MAX);
> +
> +	for (i = 1; i < bmap_count; i++) {
> +		vb->page_bitmap[i] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
> +		if (vb->page_bitmap[i])
> +			vb->nr_page_bmap++;
> +		else
> +			break;

seems to fail silently ...

> +	}
> +}
> +
> +static void free_extended_page_bitmap(struct virtio_balloon *vb)
> +{
> +	int i, bmap_count = vb->nr_page_bmap;
> +
> +	for (i = 1; i < bmap_count; i++) {
> +		kfree(vb->page_bitmap[i]);
> +		vb->page_bitmap[i] = NULL;
> +		vb->nr_page_bmap--;
> +	}
> +}
> +
> +static void kfree_page_bitmap(struct virtio_balloon *vb)
> +{
> +	int i;
> +
> +	for (i = 0; i < vb->nr_page_bmap; i++)
> +		kfree(vb->page_bitmap[i]);
> +}
> +

A very confusing name. pls don't start with kfree.

> +static void clear_page_bitmap(struct virtio_balloon *vb)
> +{
> +	int i;
> +
> +	for (i = 0; i < vb->nr_page_bmap; i++)
> +		memset(vb->page_bitmap[i], 0, PAGE_BMAP_SIZE);
> +}
> +
> +static void send_resp_data(struct virtio_balloon *vb, struct virtqueue *vq,
> +			bool busy_wait)
> +{
> +	struct scatterlist sg[2];
> +	struct virtio_balloon_resp_hdr *hdr = &vb->resp_hdr;
>  	unsigned int len;
>  
> -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> +	len = hdr->data_len = vb->resp_pos * sizeof(__le64);
> +	sg_init_table(sg, 2);
> +	sg_set_buf(&sg[0], hdr, sizeof(struct virtio_balloon_resp_hdr));
> +	sg_set_buf(&sg[1], vb->resp_data, len);
> +
> +	if (virtqueue_add_outbuf(vq, sg, 2, vb, GFP_KERNEL) == 0) {

!virtqueue_add_outbuf

Also how about making this header linear with pfns?
This way you can use 1 s/g and avoid mallocs.

> +		virtqueue_kick(vq);
> +		if (busy_wait)
> +			while (!virtqueue_get_buf(vq, &len)
> +				&& !virtqueue_is_broken(vq))
> +				cpu_relax();
> +		else
> +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> +		vb->resp_pos = 0;
> +		free_extended_page_bitmap(vb);
> +	}
> +}
>  
> -	/* We should always be able to add one buffer to an empty queue. */
> -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> -	virtqueue_kick(vq);
> +static void do_set_resp_bitmap(struct virtio_balloon *vb, unsigned long base,
> +			       int size)
> +{
> +	/* Use the extented chunk format if the size is too large */
> +	if (size > (1 << VIRTIO_BALLOON_CHUNK_SIZE_SHIFT)) {
> +		struct balloon_page_chunk_ext *chunk_ext =
> +			(struct balloon_page_chunk_ext *)(vb->resp_data + vb->resp_pos);
> +		chunk_ext->base = cpu_to_le64(base);
> +		chunk_ext->size = cpu_to_le64(size);
> +		vb->resp_pos += sizeof(vb->resp_pos) / sizeof(*chunk_ext);
> +	} else {
> +		struct balloon_page_chunk *chunk =
> +			(struct balloon_page_chunk *)(vb->resp_data + vb->resp_pos);
> +		chunk->base = cpu_to_le64(base);
> +		chunk->size = cpu_to_le16(size);
> +		vb->resp_pos += sizeof(vb->resp_pos) / sizeof(*chunk);
> +	}
> +}
>  
> -	/* When host has read buffer, this completes via balloon_ack */
> -	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> +static void chunking_pages_from_bmap(struct virtio_balloon *vb,
> +				     struct virtqueue *vq,
> +				     unsigned long start_pfn, unsigned long *bitmap,
> +				     unsigned long len, bool busy_wait)
> +{
> +	unsigned long pos = 0, end = len * BITS_PER_BYTE;
> +
> +	while (pos < end) {
> +		unsigned long one = find_next_bit(bitmap, end, pos);
> +
> +		if (one < end) {
> +			unsigned long chunk_size, zero;
> +
> +			zero = find_next_zero_bit(bitmap, end, one + 1);
> +			if (zero >= end)
> +				chunk_size = end - one;
> +			else
> +				chunk_size = zero - one;
> +			if (chunk_size) {
> +				if ((vb->resp_pos + 2) * sizeof(__le64) >
> +						vb->resp_buf_size)

why + 2? where does sizeof come from?
Any chance this can be cleaned up using structs sizeof etc?
or at least commented?
How am I supposed to figure out all this convoluted pointer math?

> +					send_resp_data(vb, vq, busy_wait);
> +				do_set_resp_bitmap(vb, start_pfn + one,	chunk_size);
> +			}
> +			pos = one + chunk_size;
> +		} else
> +			break;
> +	}
> +}
>  
> +static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> +{
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CHUNK_TRANSFER)) {
> +		int nr_pfn, nr_used_bmap, i;
> +		unsigned long start_pfn, bmap_len;
> +
> +		start_pfn = vb->start_pfn;
> +		nr_pfn = vb->end_pfn - start_pfn + 1;
> +		nr_pfn = roundup(nr_pfn, BITS_PER_LONG);
> +		nr_used_bmap = nr_pfn / PFNS_PER_PAGE_BMAP;

better name here including "page"?
And bmaps instead of bmap?

> +		if (nr_pfn % PFNS_PER_PAGE_BMAP)
> +			nr_used_bmap++;

Pls just use macros like ALIGN or roundup?

> +		bmap_len = nr_pfn / BITS_PER_BYTE;

I guess we need to round up.

> +
> +		for (i = 0; i < nr_used_bmap; i++) {
> +			unsigned int bmap_size = PAGE_BMAP_SIZE;
> +
> +			if (i + 1 == nr_used_bmap)
> +				bmap_size = bmap_len - PAGE_BMAP_SIZE * i;

So last one is treated speacially? why?

> +			chunking_pages_from_bmap(vb, vq, start_pfn + i * PFNS_PER_PAGE_BMAP,
> +				 vb->page_bitmap[i], bmap_size, false);
> +		}
> +		if (vb->resp_pos > 0)
> +			send_resp_data(vb, vq, false);
> +	} else {
> +		struct scatterlist sg;
> +		unsigned int len;
> +
> +		sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> +
> +		/* We should always be able to add one buffer to an
> +		 * empty queue
> +		 */

/*
 * Multi-line comments
 * like this.
 */

> +		virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> +		virtqueue_kick(vq);
> +		/* When host has read buffer, this completes via balloon_ack */
> +		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> +	}
>  }
>  
>  static void set_page_pfns(struct virtio_balloon *vb,
> @@ -138,13 +326,58 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  					  page_to_balloon_pfn(page) + i);
>  }
>  
> -static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> +static void set_page_bitmap(struct virtio_balloon *vb,
> +			 struct list_head *pages, struct virtqueue *vq)

align on ( pls.

> +{
> +	unsigned long pfn, pfn_limit;
> +	struct page *page;
> +	bool found;
> +
> +	vb->min_pfn = rounddown(vb->min_pfn, BITS_PER_LONG);
> +	vb->max_pfn = roundup(vb->max_pfn, BITS_PER_LONG);
> +	pfn_limit = PFNS_PER_PAGE_BMAP * vb->nr_page_bmap;
> +
> +	if (vb->nr_page_bmap == 1)
> +		extend_page_bitmap(vb, vb->max_pfn - vb->min_pfn + 1);

how is 1 special?

> +	for (pfn = vb->min_pfn; pfn < vb->max_pfn; pfn += pfn_limit) {
> +		unsigned long end_pfn;
> +
> +		clear_page_bitmap(vb);
> +		vb->start_pfn = pfn;
> +		end_pfn = pfn;
> +		found = false;
> +		list_for_each_entry(page, pages, lru) {
> +			unsigned long bmap_idx, bmap_pos, balloon_pfn;
> +
> +			balloon_pfn = page_to_balloon_pfn(page);
> +			if (balloon_pfn < pfn || balloon_pfn >= pfn + pfn_limit)
> +				continue;
> +			bmap_idx = (balloon_pfn - pfn) / PFNS_PER_PAGE_BMAP;
> +			bmap_pos = (balloon_pfn - pfn) % PFNS_PER_PAGE_BMAP;
> +			set_bit(bmap_pos, vb->page_bitmap[bmap_idx]);
> +			if (balloon_pfn > end_pfn)
> +				end_pfn = balloon_pfn;
> +			found = true;
> +		}
> +		if (found) {
> +			vb->end_pfn = end_pfn;
> +			tell_host(vb, vq);
> +		}
> +	}
> +}
> +
> +static unsigned int fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
> -	unsigned num_allocated_pages;
> +	unsigned int num_allocated_pages;
> +	bool chunking = virtio_has_feature(vb->vdev,
> +				 VIRTIO_BALLOON_F_CHUNK_TRANSFER);
>  
> -	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	if (chunking)
> +		init_bmap_pfn_range(vb);
> +	else
> +		/* We can only do one array worth at a time. */
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	mutex_lock(&vb->balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
> @@ -159,7 +392,10 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  			msleep(200);
>  			break;
>  		}
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (chunking)
> +			update_bmap_pfn_range(vb, page);
> +		else
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		if (!virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> @@ -168,8 +404,13 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  
>  	num_allocated_pages = vb->num_pfns;
>  	/* Did we get any? */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->inflate_vq);
> +	if (vb->num_pfns != 0) {
> +		if (chunking)
> +			set_page_bitmap(vb, &vb_dev_info->pages,
> +					vb->inflate_vq);
> +		else
> +			tell_host(vb, vb->inflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	return num_allocated_pages;
> @@ -189,15 +430,20 @@ static void release_pages_balloon(struct virtio_balloon *vb,
>  	}
>  }
>  
> -static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
> +static unsigned int leak_balloon(struct virtio_balloon *vb, size_t num)
>  {
> -	unsigned num_freed_pages;
> +	unsigned int num_freed_pages;
>  	struct page *page;
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  	LIST_HEAD(pages);
> +	bool chunking = virtio_has_feature(vb->vdev,
> +			 VIRTIO_BALLOON_F_CHUNK_TRANSFER);

Align on ( pls.

>  
> -	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	if (chunking)
> +		init_bmap_pfn_range(vb);
> +	else
> +		/* We can only do one array worth at a time. */
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	mutex_lock(&vb->balloon_lock);
>  	/* We can't release more pages than taken */
> @@ -207,7 +453,10 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  		page = balloon_page_dequeue(vb_dev_info);
>  		if (!page)
>  			break;
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (chunking)
> +			update_bmap_pfn_range(vb, page);
> +		else
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>  		list_add(&page->lru, &pages);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
> @@ -218,8 +467,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
>  	 * is true, we *have* to do it in this order
>  	 */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->deflate_vq);
> +	if (vb->num_pfns != 0) {
> +		if (chunking)
> +			set_page_bitmap(vb, &pages, vb->deflate_vq);
> +		else
> +			tell_host(vb, vb->deflate_vq);
> +	}
>  	release_pages_balloon(vb, &pages);
>  	mutex_unlock(&vb->balloon_lock);
>  	return num_freed_pages;
> @@ -431,6 +684,18 @@ static int init_vqs(struct virtio_balloon *vb)
>  }
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
> +static void tell_host_one_page(struct virtio_balloon *vb,
> +	struct virtqueue *vq, struct page *page)
> +{
> +	__le64 *chunk;
> +
> +	chunk = vb->resp_data + vb->resp_pos;
> +	*chunk = cpu_to_le64((page_to_pfn(page) <<
> +				VIRTIO_BALLOON_CHUNK_SIZE_SHIFT) | 1);
> +	vb->resp_pos++;
> +	send_resp_data(vb, vq, false);
> +}
> +
>  /*
>   * virtballoon_migratepage - perform the balloon page migration on behalf of
>   *			     a compation thread.     (called under page lock)
> @@ -455,6 +720,8 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  	struct virtio_balloon *vb = container_of(vb_dev_info,
>  			struct virtio_balloon, vb_dev_info);
>  	unsigned long flags;
> +	bool chunking = virtio_has_feature(vb->vdev,
> +				 VIRTIO_BALLOON_F_CHUNK_TRANSFER);
>  
>  	/*
>  	 * In order to avoid lock contention while migrating pages concurrently
> @@ -475,15 +742,23 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  	vb_dev_info->isolated_pages--;
>  	__count_vm_event(BALLOON_MIGRATE);
>  	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
> -	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> -	set_page_pfns(vb, vb->pfns, newpage);
> -	tell_host(vb, vb->inflate_vq);
> +	if (chunking)
> +		tell_host_one_page(vb, vb->inflate_vq, newpage);
> +	else {

Ad {} around 1st block too pls.

> +		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		set_page_pfns(vb, vb->pfns, newpage);
> +		tell_host(vb, vb->inflate_vq);
> +	}
>  
>  	/* balloon's page migration 2nd step -- deflate "page" */
>  	balloon_page_delete(page);
> -	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> -	set_page_pfns(vb, vb->pfns, page);
> -	tell_host(vb, vb->deflate_vq);
> +	if (chunking)
> +		tell_host_one_page(vb, vb->deflate_vq, page);


and here

> +	else {
> +		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		set_page_pfns(vb, vb->pfns, page);
> +		tell_host(vb, vb->deflate_vq);
> +	}
>  
>  	mutex_unlock(&vb->balloon_lock);
>  
> @@ -533,6 +808,21 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	spin_lock_init(&vb->stop_update_lock);
>  	vb->stop_update = false;
>  	vb->num_pages = 0;
> +
> +	vb->page_bitmap[0] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
> +	if (!vb->page_bitmap[0]) {
> +		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_CHUNK_TRANSFER);
> +	} else {
> +		vb->nr_page_bmap = 1;
> +		vb->resp_data = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
> +		if (!vb->resp_data) {
> +			__virtio_clear_bit(vdev,
> +					VIRTIO_BALLOON_F_CHUNK_TRANSFER);

align on ( pls

> +			kfree(vb->page_bitmap[0]);
> +		}
> +	}
> +	vb->resp_pos = 0;
> +	vb->resp_buf_size = PAGE_BMAP_SIZE;
>  	mutex_init(&vb->balloon_lock);
>  	init_waitqueue_head(&vb->acked);
>  	vb->vdev = vdev;
> @@ -578,6 +868,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  out_del_vqs:
>  	vdev->config->del_vqs(vdev);
>  out_free_vb:
> +	kfree(vb->resp_data);
> +	kfree_page_bitmap(vb);
>  	kfree(vb);
>  out:
>  	return err;
> @@ -611,6 +903,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	remove_common(vb);
>  	if (vb->vb_dev_info.inode)
>  		iput(vb->vb_dev_info.inode);
> +	kfree_page_bitmap(vb);
> +	kfree(vb->resp_data);
>  	kfree(vb);
>  }
>  
> @@ -649,6 +943,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_CHUNK_TRANSFER,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
