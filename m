Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 36F856B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 22:44:52 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k1so10427579pgq.2
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 19:44:52 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u73si9485186pfi.245.2017.12.03.19.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Dec 2017 19:44:50 -0800 (PST)
Message-ID: <5A24C526.2060400@intel.com>
Date: Mon, 04 Dec 2017 11:46:46 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v18 07/10] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com> <1511963726-34070-8-git-send-email-wei.w.wang@intel.com> <20171201171746-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171201171746-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On 12/01/2017 11:38 PM, Michael S. Tsirkin wrote:
> On Wed, Nov 29, 2017 at 09:55:23PM +0800, Wei Wang wrote:
>> +static void send_one_desc(struct virtio_balloon *vb,
>> +			  struct virtqueue *vq,
>> +			  uint64_t addr,
>> +			  uint32_t len,
>> +			  bool inbuf,
>> +			  bool batch)
>> +{
>> +	int err;
>> +	unsigned int size;
>> +
>> +	/* Detach all the used buffers from the vq */
>> +	while (virtqueue_get_buf(vq, &size))
>> +		;
>> +
>> +	err = virtqueue_add_one_desc(vq, addr, len, inbuf, vq);
>> +	/*
>> +	 * This is expected to never fail: there is always at least 1 entry
>> +	 * available on the vq, because when the vq is full the worker thread
>> +	 * that adds the desc will be put into sleep until at least 1 entry is
>> +	 * available to use.
>> +	 */
>> +	BUG_ON(err);
>> +
>> +	/* If batching is requested, we batch till the vq is full */
>> +	if (!batch || !vq->num_free)
>> +		kick_and_wait(vq, vb->acked);
>> +}
>> +
> This internal kick complicates callers. I suggest that instead,
> you move this to callers, just return a "kick required" boolean.
> This way callers do not need to play with num_free at all.

Then in what situation would the function return true of "kick required"?

I think this wouldn't make a difference fundamentally. For example, we 
have 257 sgs (batching size=256) to send to host:

while (i < 257) {
     kick_required = send_sgs();
     if (kick_required)
         kick(); // After the 256 sgs have been added, the caller 
performs a kick().
}

Do we still need a kick here for the 257th sg as before? Only the caller 
knows if the last added sgs need a kick (when the send_sgs receives one 
sg, it doesn't know if there are more to come).

There is another approach to checking if the last added sgs haven't been 
sync-ed to the host: expose "vring_virtqueue->num_added" to the caller 
via a virtio_ring API:

     unsigned int virtqueue_num_added(struct virtqueue *_vq)
    {
         struct vring_virtqueue *vq = to_vvq(_vq);

         return vq->num_added;
   }



>> +/*
>> + * Send balloon pages in sgs to host. The balloon pages are recorded in the
>> + * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
>> + * The page xbitmap is searched for continuous "1" bits, which correspond
>> + * to continuous pages, to chunk into sgs.
>> + *
>> + * @page_xb_start and @page_xb_end form the range of bits in the xbitmap that
>> + * need to be searched.
>> + */
>> +static void tell_host_sgs(struct virtio_balloon *vb,
>> +			  struct virtqueue *vq,
>> +			  unsigned long page_xb_start,
>> +			  unsigned long page_xb_end)
>> +{
>> +	unsigned long pfn_start, pfn_end;
>> +	uint64_t addr;
>> +	uint32_t len, max_len = round_down(UINT_MAX, PAGE_SIZE);
>> +
>> +	pfn_start = page_xb_start;
>> +	while (pfn_start < page_xb_end) {
>> +		pfn_start = xb_find_next_set_bit(&vb->page_xb, pfn_start,
>> +						 page_xb_end);
>> +		if (pfn_start == page_xb_end + 1)
>> +			break;
>> +		pfn_end = xb_find_next_zero_bit(&vb->page_xb,
>> +						pfn_start + 1,
>> +						page_xb_end);
>> +		addr = pfn_start << PAGE_SHIFT;
>> +		len = (pfn_end - pfn_start) << PAGE_SHIFT;
> This assugnment can overflow. Next line compares with UINT_MAX but by
> that time it is too late.  I think you should do all math in 64 bit to
> avoid surprises, then truncate to max_len and then it's safe to assign
> to sg.

Sounds reasonable, thanks.


>> +
>> +	xb_clear_bit_range(&vb->page_xb, page_xb_start, page_xb_end);
>> +}
>> +
>> +static inline int xb_set_page(struct virtio_balloon *vb,
>> +			       struct page *page,
>> +			       unsigned long *pfn_min,
>> +			       unsigned long *pfn_max)
>> +{
>> +	unsigned long pfn = page_to_pfn(page);
>> +	int ret;
>> +
>> +	*pfn_min = min(pfn, *pfn_min);
>> +	*pfn_max = max(pfn, *pfn_max);
>> +
>> +	do {
>> +		ret = xb_preload_and_set_bit(&vb->page_xb, pfn,
>> +					     GFP_NOWAIT | __GFP_NOWARN);
>> +	} while (unlikely(ret == -EAGAIN));
> what exactly does this loop do? Does this wait
> forever until there is some free memory? why GFP_NOWAIT?

Basically, "-EAGAIN" is returned from xb_set_bit() in the case when the 
pre-allocated per-cpu ida_bitmap is NULL. In that case, the caller 
re-invokes xb_preload_and_set_bit(), which re-invokes xb_preload to 
allocate ida_bitmap. So "-EAGAIN" actually does not indicate a status 
about memory allocation. "-ENOMEM" is the one to indicate the failure of 
memory allocation, but the loop doesn't re-try on "-ENOMEM".

GFP_NOWAIT is used to avoid memory reclaiming, which could cause the 
deadlock issue we discussed before.




>   	return num_freed_pages;
>   }
>   
> +/*
> + * The regular leak_balloon() with VIRTIO_BALLOON_F_SG needs memory allocation
> + * for xbitmap, which is not suitable for the oom case. This function does not
> + * use xbitmap to chunk pages, so it can be used by oom notifier to deflate
> + * pages when VIRTIO_BALLOON_F_SG is negotiated.
> + */
> I guess we can live with this for now.

Agree, the patchset has been big. We can get the basic implementation in 
first, and leave the following as future work. I can add it in the 
commit log.

> Two things to consider
> - adding support for pre-allocating indirect buffers
> - sorting the internal page queue (how?)


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
