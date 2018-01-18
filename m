Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38C2F6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 08:30:40 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id r12so14662846otr.11
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 05:30:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e185si2746831oif.280.2018.01.18.05.30.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 05:30:38 -0800 (PST)
Subject: Re: [PATCH v22 2/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com>
 <1516165812-3995-3-git-send-email-wei.w.wang@intel.com>
 <20180117180337-mutt-send-email-mst@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <2bb0e3d9-1679-9ad3-b402-f0781f6cf094@I-love.SAKURA.ne.jp>
Date: Thu, 18 Jan 2018 22:30:18 +0900
MIME-Version: 1.0
In-Reply-To: <20180117180337-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 2018/01/18 1:44, Michael S. Tsirkin wrote:
>> +static void add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t len)
>> +{
>> +	struct scatterlist sg;
>> +	unsigned int unused;
>> +	int err;
>> +
>> +	sg_init_table(&sg, 1);
>> +	sg_set_page(&sg, pfn_to_page(pfn), len, 0);
>> +
>> +	/* Detach all the used buffers from the vq */
>> +	while (virtqueue_get_buf(vq, &unused))
>> +		;
>> +
>> +	/*
>> +	 * Since this is an optimization feature, losing a couple of free
>> +	 * pages to report isn't important.
>> We simply resturn
> 
> return
> 
>> without adding
>> +	 * the page if the vq is full. We are adding one entry each time,
>> +	 * which essentially results in no memory allocation, so the
>> +	 * GFP_KERNEL flag below can be ignored.
>> +	 */
>> +	if (vq->num_free) {
>> +		err = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> 
> Should we kick here? At least when ring is close to
> being full. Kick at half way full?
> Otherwise it's unlikely ring will
> ever be cleaned until we finish the scan.

Since this add_one_sg() is called between spin_lock_irqsave(&zone->lock, flags)
and spin_unlock_irqrestore(&zone->lock, flags), it is not permitted to sleep.
And walk_free_mem_block() is not ready to handle resume.

By the way, specifying GFP_KERNEL here is confusing even though it is never used.
walk_free_mem_block() says:

  * The callback itself must not sleep or perform any operations which would
  * require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
  * or via any lock dependency. 

> 
>> +		/*
>> +		 * This is expected to never fail, because there is always an
>> +		 * entry available on the vq.
>> +		 */
>> +		BUG_ON(err);
>> +	}
>> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
