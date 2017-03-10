Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC662808F6
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 05:01:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so156136227pgc.6
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 02:01:21 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g14si9174235plk.150.2017.03.10.02.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 02:01:14 -0800 (PST)
Message-ID: <58C279B7.2060106@intel.com>
Date: Fri, 10 Mar 2017 18:02:31 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v7 kernel 3/5] virtio-balloon: implementation
 of VIRTIO_BALLOON_F_CHUNK_TRANSFER
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com> <1488519630-89058-4-git-send-email-wei.w.wang@intel.com> <20170308054813-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170308054813-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Liang Li <liang.z.li@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

On 03/08/2017 12:01 PM, Michael S. Tsirkin wrote:
> On Fri, Mar 03, 2017 at 01:40:28PM +0800, Wei Wang wrote:
>> From: Liang Li <liang.z.li@intel.com>
>>
>> The implementation of the current virtio-balloon is not very
>> efficient, because the pages are transferred to the host one by one.
>> Here is the breakdown of the time in percentage spent on each
>> step of the balloon inflating process (inflating 7GB of an 8GB
>> idle guest).
>>
>> 1) allocating pages (6.5%)
>> 2) sending PFNs to host (68.3%)
>> 3) address translation (6.1%)
>> 4) madvise (19%)
>>
>> It takes about 4126ms for the inflating process to complete.
>> The above profiling shows that the bottlenecks are stage 2)
>> and stage 4).
>>
>> This patch optimizes step 2) by transfering pages to the host in
>> chunks. A chunk consists of guest physically continuous pages, and
>> it is offered to the host via a base PFN (i.e. the start PFN of
>> those physically continuous pages) and the size (i.e. the total
>> number of the pages). A normal chunk is formated as below:
>> -----------------------------------------------
>> |  Base (52 bit)               | Size (12 bit)|
>> -----------------------------------------------
>> For large size chunks, an extended chunk format is used:
>> -----------------------------------------------
>> |                 Base (64 bit)               |
>> -----------------------------------------------
>> -----------------------------------------------
>> |                 Size (64 bit)               |
>> -----------------------------------------------
>>
>> By doing so, step 4) can also be optimized by doing address
>> translation and madvise() in chunks rather than page by page.
>>
>> This optimization requires the negotation of a new feature bit,
>> VIRTIO_BALLOON_F_CHUNK_TRANSFER.
>>
>> With this new feature, the above ballooning process takes ~590ms
>> resulting in an improvement of ~85%.
>>
>> TODO: optimize stage 1) by allocating/freeing a chunk of pages
>> instead of a single page each time.
>>
>> Signed-off-by: Liang Li <liang.z.li@intel.com>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Cc: Paolo Bonzini <pbonzini@redhat.com>
>> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
>> Cc: Amit Shah <amit.shah@redhat.com>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: Liang Li <liliang324@gmail.com>
>> Cc: Wei Wang <wei.w.wang@intel.com>
> Does this pass sparse? I see some endian-ness issues here.

"pass sparse"- what does that mean?
I didn't see any complaints from "make" on my machine.

>> ---
>>   drivers/virtio/virtio_balloon.c | 351 ++++++++++++++++++++++++++++++++++++----
>>   1 file changed, 323 insertions(+), 28 deletions(-)
>>
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>> index f59cb4f..4416370 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -42,6 +42,10 @@
>>   #define OOM_VBALLOON_DEFAULT_PAGES 256
>>   #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
>>   
>> +#define PAGE_BMAP_SIZE	(8 * PAGE_SIZE)
>> +#define PFNS_PER_PAGE_BMAP	(PAGE_BMAP_SIZE * BITS_PER_BYTE)
>> +#define PAGE_BMAP_COUNT_MAX	32
>> +
>>   static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
>>   module_param(oom_pages, int, S_IRUSR | S_IWUSR);
>>   MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>> @@ -50,6 +54,16 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>>   static struct vfsmount *balloon_mnt;
>>   #endif
>>   
>> +struct balloon_page_chunk {
>> +	__le64 base : 52;
>> +	__le64 size : 12;
>> +};
>> +
>> +struct balloon_page_chunk_ext {
>> +	__le64 base;
>> +	__le64 size;
>> +};
>> +
>>   struct virtio_balloon {
>>   	struct virtio_device *vdev;
>>   	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
>> @@ -67,6 +81,20 @@ struct virtio_balloon {
>>   
>>   	/* Number of balloon pages we've told the Host we're not using. */
>>   	unsigned int num_pages;
>> +	/* Pointer to the response header. */
>> +	struct virtio_balloon_resp_hdr resp_hdr;
>> +	/* Pointer to the start address of response data. */
>> +	__le64 *resp_data;
>> +	/* Size of response data buffer. */
>> +	unsigned int resp_buf_size;
>> +	/* Pointer offset of the response data. */
>> +	unsigned int resp_pos;
>> +	/* Bitmap used to save the pfns info */
>> +	unsigned long *page_bitmap[PAGE_BMAP_COUNT_MAX];
>> +	/* Number of split page bitmaps */
>> +	unsigned int nr_page_bmap;
>> +	/* Used to record the processed pfn range */
>> +	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
>>   	/*
>>   	 * The pages we've told the Host we're not using are enqueued
>>   	 * at vb_dev_info->pages list.
>> @@ -110,20 +138,180 @@ static void balloon_ack(struct virtqueue *vq)
>>   	wake_up(&vb->acked);
>>   }
>>   
>> -static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>> +static inline void init_bmap_pfn_range(struct virtio_balloon *vb)
>>   {
>> -	struct scatterlist sg;
>> +	vb->min_pfn = ULONG_MAX;
>> +	vb->max_pfn = 0;
>> +}
>> +
>> +static inline void update_bmap_pfn_range(struct virtio_balloon *vb,
>> +				 struct page *page)
>> +{
>> +	unsigned long balloon_pfn = page_to_balloon_pfn(page);
>> +
>> +	vb->min_pfn = min(balloon_pfn, vb->min_pfn);
>> +	vb->max_pfn = max(balloon_pfn, vb->max_pfn);
>> +}
>> +
>> +static void extend_page_bitmap(struct virtio_balloon *vb,
>> +				unsigned long nr_pfn)
>
> what exactly does this do?

By default, only one page_bmap is allocated.
When there are too many pfns to fit into one page_bmap,
it tries to allocate more page_bmap using this extend_page_bmap() function.

>
>> +{
>> +	int i, bmap_count;
>> +	unsigned long bmap_len;
>> +
>> +	bmap_len = ALIGN(nr_pfn, BITS_PER_LONG) / BITS_PER_BYTE;
>> +	bmap_len = ALIGN(bmap_len, PAGE_BMAP_SIZE);
>> +	bmap_count = min((int)(bmap_len / PAGE_BMAP_SIZE),
>> +				 PAGE_BMAP_COUNT_MAX);
>> +
>> +	for (i = 1; i < bmap_count; i++) {
>> +		vb->page_bitmap[i] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
>> +		if (vb->page_bitmap[i])
>> +			vb->nr_page_bmap++;
>> +		else
>> +			break;
> seems to fail silently ...

I think here it is fine whether the page_bmap extension succeeds or 
silently fails.
It doesn't affect the correctness of the implementation - the page_bmap 
is always
used through vb->nr_page_bmap. Maybe the code logic is still a little 
fuzzy. I plan
to re-write most of the implementation to make it clearer.

>> +	}
>> +}
>> +
>> +static void free_extended_page_bitmap(struct virtio_balloon *vb)
>> +{
>> +	int i, bmap_count = vb->nr_page_bmap;
>> +
>> +	for (i = 1; i < bmap_count; i++) {
>> +		kfree(vb->page_bitmap[i]);
>> +		vb->page_bitmap[i] = NULL;
>> +		vb->nr_page_bmap--;
>> +	}
>> +}
>> +
>> +static void kfree_page_bitmap(struct virtio_balloon *vb)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < vb->nr_page_bmap; i++)
>> +		kfree(vb->page_bitmap[i]);
>> +}
>> +
> A very confusing name. pls don't start with kfree.

Ok. I'll simply call it free_page_bmap()

>
>> +static void clear_page_bitmap(struct virtio_balloon *vb)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < vb->nr_page_bmap; i++)
>> +		memset(vb->page_bitmap[i], 0, PAGE_BMAP_SIZE);
>> +}
>> +
>> +static void send_resp_data(struct virtio_balloon *vb, struct virtqueue *vq,
>> +			bool busy_wait)
>> +{
>> +	struct scatterlist sg[2];
>> +	struct virtio_balloon_resp_hdr *hdr = &vb->resp_hdr;
>>   	unsigned int len;
>>   
>> -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
>> +	len = hdr->data_len = vb->resp_pos * sizeof(__le64);
>> +	sg_init_table(sg, 2);
>> +	sg_set_buf(&sg[0], hdr, sizeof(struct virtio_balloon_resp_hdr));
>> +	sg_set_buf(&sg[1], vb->resp_data, len);
>> +
>> +	if (virtqueue_add_outbuf(vq, sg, 2, vb, GFP_KERNEL) == 0) {
> !virtqueue_add_outbuf
>
> Also how about making this header linear with pfns?
> This way you can use 1 s/g and avoid mallocs.

Yes, I think it'll be better, thanks.


>> +		virtqueue_kick(vq);
>> +		if (busy_wait)
>> +			while (!virtqueue_get_buf(vq, &len)
>> +				&& !virtqueue_is_broken(vq))
>> +				cpu_relax();
>> +		else
>> +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>> +		vb->resp_pos = 0;
>> +		free_extended_page_bitmap(vb);
>> +	}
>> +}
>>   
>> -	/* We should always be able to add one buffer to an empty queue. */
>> -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
>> -	virtqueue_kick(vq);
>> +static void do_set_resp_bitmap(struct virtio_balloon *vb, unsigned long base,
>> +			       int size)
>> +{
>> +	/* Use the extented chunk format if the size is too large */
>> +	if (size > (1 << VIRTIO_BALLOON_CHUNK_SIZE_SHIFT)) {
>> +		struct balloon_page_chunk_ext *chunk_ext =
>> +			(struct balloon_page_chunk_ext *)(vb->resp_data + vb->resp_pos);
>> +		chunk_ext->base = cpu_to_le64(base);
>> +		chunk_ext->size = cpu_to_le64(size);
>> +		vb->resp_pos += sizeof(vb->resp_pos) / sizeof(*chunk_ext);
>> +	} else {
>> +		struct balloon_page_chunk *chunk =
>> +			(struct balloon_page_chunk *)(vb->resp_data + vb->resp_pos);
>> +		chunk->base = cpu_to_le64(base);
>> +		chunk->size = cpu_to_le16(size);
>> +		vb->resp_pos += sizeof(vb->resp_pos) / sizeof(*chunk);
>> +	}
>> +}
>>   
>> -	/* When host has read buffer, this completes via balloon_ack */
>> -	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>> +static void chunking_pages_from_bmap(struct virtio_balloon *vb,
>> +				     struct virtqueue *vq,
>> +				     unsigned long start_pfn, unsigned long *bitmap,
>> +				     unsigned long len, bool busy_wait)
>> +{
>> +	unsigned long pos = 0, end = len * BITS_PER_BYTE;
>> +
>> +	while (pos < end) {
>> +		unsigned long one = find_next_bit(bitmap, end, pos);
>> +
>> +		if (one < end) {
>> +			unsigned long chunk_size, zero;
>> +
>> +			zero = find_next_zero_bit(bitmap, end, one + 1);
>> +			if (zero >= end)
>> +				chunk_size = end - one;
>> +			else
>> +				chunk_size = zero - one;
>> +			if (chunk_size) {
>> +				if ((vb->resp_pos + 2) * sizeof(__le64) >
>> +						vb->resp_buf_size)
> why + 2? where does sizeof come from?
> Any chance this can be cleaned up using structs sizeof etc?
> or at least commented?
> How am I supposed to figure out all this convoluted pointer math?

Right. I'll take of it in the new version.


>> +					send_resp_data(vb, vq, busy_wait);
>> +				do_set_resp_bitmap(vb, start_pfn + one,	chunk_size);
>> +			}
>> +			pos = one + chunk_size;
>> +		} else
>> +			break;
>> +	}
>> +}
>>   
>> +static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>> +{
>> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CHUNK_TRANSFER)) {
>> +		int nr_pfn, nr_used_bmap, i;
>> +		unsigned long start_pfn, bmap_len;
>> +
>> +		start_pfn = vb->start_pfn;
>> +		nr_pfn = vb->end_pfn - start_pfn + 1;
>> +		nr_pfn = roundup(nr_pfn, BITS_PER_LONG);
>> +		nr_used_bmap = nr_pfn / PFNS_PER_PAGE_BMAP;
> better name here including "page"?
> And bmaps instead of bmap?
Agree. I'll call it page_bmaps.


>> +		if (nr_pfn % PFNS_PER_PAGE_BMAP)
>> +			nr_used_bmap++;
> Pls just use macros like ALIGN or roundup?
>
>> +		bmap_len = nr_pfn / BITS_PER_BYTE;
> I guess we need to round up.
>
>> +
>> +		for (i = 0; i < nr_used_bmap; i++) {
>> +			unsigned int bmap_size = PAGE_BMAP_SIZE;
>> +
>> +			if (i + 1 == nr_used_bmap)
>> +				bmap_size = bmap_len - PAGE_BMAP_SIZE * i;
> So last one is treated speacially? why?

The last one takes the leftover only, so that chunking_pages_from_bmap()
only searches the necessary part of (rather than the entire) the page_bmap.

>> +			chunking_pages_from_bmap(vb, vq, start_pfn + i * PFNS_PER_PAGE_BMAP,
>> +				 vb->page_bitmap[i], bmap_size, false);
>> +		}
>> +		if (vb->resp_pos > 0)
>> +			send_resp_data(vb, vq, false);
>> +	} else {
>> +		struct scatterlist sg;
>> +		unsigned int len;
>> +
>> +		sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
>> +
>> +		/* We should always be able to add one buffer to an
>> +		 * empty queue
>> +		 */
> /*
>   * Multi-line comments
>   * like this.
>   */

OK.

>> +		virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
>> +		virtqueue_kick(vq);
>> +		/* When host has read buffer, this completes via balloon_ack */
>> +		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>> +	}
>>   }
>>   
>>   static void set_page_pfns(struct virtio_balloon *vb,
>> @@ -138,13 +326,58 @@ static void set_page_pfns(struct virtio_balloon *vb,
>>   					  page_to_balloon_pfn(page) + i);
>>   }
>>   
>> -static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>> +static void set_page_bitmap(struct virtio_balloon *vb,
>> +			 struct list_head *pages, struct virtqueue *vq)
> align on ( pls.
>
>> +{
>> +	unsigned long pfn, pfn_limit;
>> +	struct page *page;
>> +	bool found;
>> +
>> +	vb->min_pfn = rounddown(vb->min_pfn, BITS_PER_LONG);
>> +	vb->max_pfn = roundup(vb->max_pfn, BITS_PER_LONG);
>> +	pfn_limit = PFNS_PER_PAGE_BMAP * vb->nr_page_bmap;
>> +
>> +	if (vb->nr_page_bmap == 1)
>> +		extend_page_bitmap(vb, vb->max_pfn - vb->min_pfn + 1);
> how is 1 special?

Thanks. I think "if (vb->nr_page_bmap == 1)" should be removed.
Whenever the current amount of page_bmap is not enough to hold
the amount of pfns, it should try to entend page_bmap.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
