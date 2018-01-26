Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAA736B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 20:38:15 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id h5so5818247pgv.21
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 17:38:15 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x8-v6si2897955plo.616.2018.01.25.17.38.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 17:38:14 -0800 (PST)
Message-ID: <5A6A871C.6040408@intel.com>
Date: Fri, 26 Jan 2018 09:40:44 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v25 2/2] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1516871646-22741-1-git-send-email-wei.w.wang@intel.com> <1516871646-22741-3-git-send-email-wei.w.wang@intel.com> <20180125154708-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180125154708-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 01/25/2018 09:49 PM, Michael S. Tsirkin wrote:
> On Thu, Jan 25, 2018 at 05:14:06PM +0800, Wei Wang wrote:
>> +
>> +static void report_free_page_func(struct work_struct *work)
>> +{
>> +	struct virtio_balloon *vb;
>> +	int ret;
>> +
>> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
>> +
>> +	/* Start by sending the received cmd id to host with an outbuf */
>> +	ret = send_cmd_id(vb, vb->cmd_id_received);
>> +	if (unlikely(ret))
>> +		goto err;
>> +
>> +	ret = walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
>> +	if (unlikely(ret < 0))
>> +		goto err;
>> +
>> +	/* End by sending a stop id to host with an outbuf */
>> +	ret = send_cmd_id(vb, VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
>> +	if (likely(!ret))
>> +		return;
>> +err:
>> +	dev_err(&vb->vdev->dev, "%s failure: free page vq is broken\n",
>> +		__func__);
>> +}
>> +
> So that's very simple, but it only works well if the whole
> free list fits in the queue or host processes the queue faster
> than the guest. What if it doesn't?

This is the case that the virtqueue gets full, and I think we've agreed 
that this is an optimization feature and losing some hints to report 
isn't important, right?

Actually, in the tests, there is no chance to see the ring is full. If 
we check the host patches that were shared before, the device side 
operation is quite simple, it just clears the related bits from the 
bitmap, and then continues to take entries from the virtqueue till the 
virtqueue gets empty.


> If we had restartability you could just drop the lock
> and wait for a vq interrupt to make more progress, which
> would be better I think.
>

Restartability means that caller needs to record the state where it was 
when it stopped last time. The controversy is that the free list is not 
static once the lock is dropped, so everything is dynamically changing, 
including the state that was recorded. The method we are using is more 
prudent, IMHO. How about taking the fundamental solution, and seek to 
improve incrementally in the future?


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
