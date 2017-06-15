Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A445A6B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:08:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h21so5520115pfk.13
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:08:03 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v62si1776433pfb.42.2017.06.15.01.08.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 01:08:02 -0700 (PDT)
Message-ID: <594240E9.2070705@intel.com>
Date: Thu, 15 Jun 2017 16:10:17 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v11 3/6] virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com> <1497004901-30593-4-git-send-email-wei.w.wang@intel.com> <20170613200049-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170613200049-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, Matthew Wilcox <willy@infradead.org>

On 06/14/2017 01:56 AM, Michael S. Tsirkin wrote:
> On Fri, Jun 09, 2017 at 06:41:38PM +0800, Wei Wang wrote:
>> Add a new feature, VIRTIO_BALLOON_F_PAGE_CHUNKS, which enables
>> the transfer of the ballooned (i.e. inflated/deflated) pages in
>> chunks to the host.
> so now these chunks are just s/g list entry.
> So let's rename this VIRTIO_BALLOON_F_SG with a comment:
> * Use standard virtio s/g instead of PFN lists *

Actually, it's not using the standard s/g list in the implementation,
because:
using the standard s/g will need kmalloc() the indirect table on
demand (i.e. when virtqueue_add() converts s/g to indirect table);

The implementation directly pre-allocates an indirect desc table,
and uses a entry (i.e. vring_desc) to describe a chunk. This
avoids the overhead of kmalloc() the indirect table.


>> +/*
>> + * Callulates how many pfns can a page_bmap record. A bit corresponds to a
>> + * page of PAGE_SIZE.
>> + */
>> +#define VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP \
>> +	(VIRTIO_BALLOON_PAGE_BMAP_SIZE * BITS_PER_BYTE)
>> +
>> +/* The number of page_bmap to allocate by default. */
>> +#define VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM	1
> It's not by default, it's at probe time, right?
It is the number of page bitmap being kept throughout the whole
lifecycle of the driver. The page bmap will be temporarily extended
due to insufficiency during a ballooning process, but when that
ballooning finishes, the extended part will be freed.
>> +/* The maximum number of page_bmap that can be allocated. */
> Not really, this is the size of the array we use to keep them.

This is the max number of the page bmap that can be
extended temporarily.

>> +#define VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM	32
>> +
> So you still have a home-grown bitmap. I'd like to know why
> isn't xbitmap suggested for this purpose by Matthew Wilcox
> appropriate. Please add a comment explaining the requirements
> from the data structure.

I didn't find his xbitmap being upstreamed, did you?

>> +/*
>> + * QEMU virtio implementation requires the desc table size less than
>> + * VIRTQUEUE_MAX_SIZE, so minus 1 here.
> I think it doesn't, the issue is probably that you add a header
> as a separate s/g. In any case see below.
>
>> + */
>> +#define VIRTIO_BALLOON_MAX_PAGE_CHUNKS (VIRTQUEUE_MAX_SIZE - 1)
> This is wrong, virtio spec says s/g size should not exceed VQ size.
> If you want to support huge VQ sizes, you can add a fallback to
> smaller sizes until it fits in 1 page.

Probably no need for huge VQ size, 1024 queue size should be
enough. And we can have 1024 descriptors in the indirect
table, so the above size doesn't exceed the vq size, right?


> +static unsigned int extend_page_bmap_size(struct virtio_balloon *vb,
> +					  unsigned long pfn_num)
> what's this API doing?  Pls add comments. this seems to assume
> it will only be called once.
OK, I will add some comments here. This is the function to extend
the number of page bitmap when the original 1 page bmap is
not sufficient during a ballooning process. As mentioned above,
at the end of this ballooning process, the extended part will be freed.

> it would be better to avoid making
> this assumption, just look at what has been allocated
> and extend it.
Actually it's not an assumption. The rule here is that we always keep
"1" page bmap. "1" is defined by the
VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM. So when freeing, it also
references VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM (not assuming
any number)

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
> Poking at virtio internals like this is not nice. Pls move to virtio
> code.  Also, pages must be read descriptors as host might modify them.
>
> This also lacks viommu support but this is not mandatory as
> that is borken atm anyway. I'll send a patch to at least fail cleanly.
OK, thanks.

>> +static void convert_bmap_to_chunks(struct virtio_balloon *vb,
>> +				   struct virtqueue *vq,
>> +				   unsigned long *bmap,
>> +				   unsigned long pfn_start,
>> +				   unsigned long size)
>> +{
>> +	unsigned long next_one, next_zero, pos = 0;
>> +	u64 chunk_base_addr;
>> +	u32 chunk_size;
>> +
>> +	while (pos < size) {
>> +		next_one = find_next_bit(bmap, size, pos);
>> +		/*
>> +		 * No "1" bit found, which means that there is no pfn
>> +		 * recorded in the rest of this bmap.
>> +		 */
>> +		if (next_one == size)
>> +			break;
>> +		next_zero = find_next_zero_bit(bmap, size, next_one + 1);
>> +		/*
>> +		 * A bit in page_bmap corresponds to a page of PAGE_SIZE.
>> +		 * Convert it to be pages of 4KB balloon page size when
>> +		 * adding it to a chunk.
> This looks wrong. add_one_chunk assumes size in bytes. So should be just
> PAGE_SIZE.

It's intended to be "chunk size", which is the number of pfns. The 
benefit is
that the 32-bit desc->len won't be overflow, as you mentioned below.


>
>> +		 */
>> +		chunk_size = (next_zero - next_one) *
>> +			     VIRTIO_BALLOON_PAGES_PER_PAGE;
> How do you know this won't overflow a 32 bit integer? Needs a comment.

If it stores size in bytes, it has the possibility to overflow.
If storing number of pfns, the 32-bit value can support 2^32*4KB=8TB
memory, unlikely to overflow.
> +
> +static int balloon_page_chunk_init(struct virtio_balloon *vb)
> +{
> +	int i;
> +
> +	vb->balloon_page_chunk.desc_table = alloc_indirect(vb->vdev,
> +						VIRTIO_BALLOON_MAX_PAGE_CHUNKS,
> +						GFP_KERNEL);
> This one's problematic, you aren't supposed to use APIs when device
> is not inited yet. Seems to work by luck here. I suggest moving
> this to probe, that's where we do a bunch of inits.
> And then you can move private init back to allocate too.

This is just to allocate an indirect desc table. If allocation fails, we 
need to clear
the related feature bit in ->validate(), right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
