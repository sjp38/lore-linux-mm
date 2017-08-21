Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2616B04CD
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 01:25:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r133so263188471pgr.6
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 22:25:36 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m10si6736908pge.298.2017.08.20.22.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Aug 2017 22:25:34 -0700 (PDT)
Message-ID: <599A6F78.4070705@intel.com>
Date: Mon, 21 Aug 2017 13:28:24 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v14 5/5] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com> <1502940416-42944-6-git-send-email-wei.w.wang@intel.com> <20170818052301-mutt-send-email-mst@kernel.org> <5996A6F6.2050405@intel.com> <20170818202337-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170818202337-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 08/19/2017 02:10 AM, Michael S. Tsirkin wrote:
> On Fri, Aug 18, 2017 at 04:36:06PM +0800, Wei Wang wrote:
>> On 08/18/2017 10:28 AM, Michael S. Tsirkin wrote:
>>> On Thu, Aug 17, 2017 at 11:26:56AM +0800, Wei Wang wrote:
>>>> Add a new vq to report hints of guest free pages to the host.
>>>>
>>>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>>>> Signed-off-by: Liang Li <liang.z.li@intel.com>
>>>> ---
>>>>    drivers/virtio/virtio_balloon.c     | 167 +++++++++++++++++++++++++++++++-----
>>>>    include/uapi/linux/virtio_balloon.h |   1 +
>>>>    2 files changed, 147 insertions(+), 21 deletions(-)
>>>>
>>>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>>>> index 72041b4..e6755bc 100644
>>>> --- a/drivers/virtio/virtio_balloon.c
>>>> +++ b/drivers/virtio/virtio_balloon.c
>>>> @@ -54,11 +54,12 @@ static struct vfsmount *balloon_mnt;
>>>>    struct virtio_balloon {
>>>>    	struct virtio_device *vdev;
>>>> -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
>>>> +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
>>>>    	/* The balloon servicing is delegated to a freezable workqueue. */
>>>>    	struct work_struct update_balloon_stats_work;
>>>>    	struct work_struct update_balloon_size_work;
>>>> +	struct work_struct report_free_page_work;
>>>>    	/* Prevent updating balloon when it is being canceled. */
>>>>    	spinlock_t stop_update_lock;
>>>> @@ -90,6 +91,13 @@ struct virtio_balloon {
>>>>    	/* Memory statistics */
>>>>    	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
>>>> +	/*
>>>> +	 * Used by the device and driver to signal each other.
>>>> +	 * device->driver: start the free page report.
>>>> +	 * driver->device: end the free page report.
>>>> +	 */
>>>> +	__virtio32 report_free_page_signal;
>>>> +
>>>>    	/* To register callback in oom notifier call chain */
>>>>    	struct notifier_block nb;
>>>>    };
>>>> @@ -174,6 +182,17 @@ static void send_balloon_page_sg(struct virtio_balloon *vb,
>>>>    	} while (unlikely(ret == -ENOSPC));
>>>>    }
>>>> +static void send_free_page_sg(struct virtqueue *vq, void *addr, uint32_t size)
>>>> +{
>>>> +	unsigned int len;
>>>> +
>>>> +	add_one_sg(vq, addr, size);
>>>> +	virtqueue_kick(vq);
>>>> +	/* Release entries if there are */
>>>> +	while (virtqueue_get_buf(vq, &len))
>>>> +		;
>>>> +}
>>>> +
>>>>    /*
>>>>     * Send balloon pages in sgs to host. The balloon pages are recorded in the
>>>>     * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
>>>> @@ -511,42 +530,143 @@ static void update_balloon_size_func(struct work_struct *work)
>>>>    		queue_work(system_freezable_wq, work);
>>>>    }
>>>> +static void virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
>>>> +					   unsigned long nr_pages)
>>>> +{
>>>> +	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
>>>> +	void *addr = (void *)pfn_to_kaddr(pfn);
>>>> +	uint32_t len = nr_pages << PAGE_SHIFT;
>>>> +
>>>> +	send_free_page_sg(vb->free_page_vq, addr, len);
>>>> +}
>>>> +
>>>> +static void report_free_page_completion(struct virtio_balloon *vb)
>>>> +{
>>>> +	struct virtqueue *vq = vb->free_page_vq;
>>>> +	struct scatterlist sg;
>>>> +	unsigned int len;
>>>> +	int ret;
>>>> +
>>>> +	sg_init_one(&sg, &vb->report_free_page_signal, sizeof(__virtio32));
>>>> +retry:
>>>> +	ret = virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
>>>> +	virtqueue_kick(vq);
>>>> +	if (unlikely(ret == -ENOSPC)) {
>>>> +		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>>>> +		goto retry;
>>>> +	}
>>>> +}
>>> So the annoying thing here is that once this starts going,
>>> it will keep sending free pages from the list even if
>>> host is no longer interested. There should be a way
>>> for host to tell guest "stop" or "start from the beginning".
>> This can be achieved via two output signal buf here:
>> signal_buf_start: filled with VIRTIO_BALLOON_F_FREE_PAGE_REPORT_START
>> signal_buf_end: filled with VIRTIO_BALLOON_F_FREE_PAGE_REPORT_END
>>
>> The device holds both, and can put one of them to the vq and notify.
> Do you mean device writes start and end in the buf? then it's an inbuf
> not an outbuf.
>

Not really. I meant that the driver fills two signal buffer,_START and _STOP
and send them as outbuf to the device. Then the device holds two read-only
signal buffer:
When request to start: add the _START elem to the vq
When request  to stop: add the _STOP elem to the vq


>>
>>> It's the result of using same vq for guest to host and
>>> host to guest communication, and I think it's not a great idea.
>>> I'd reuse stats vq for host to guest requests maybe.
>>>
>>
>> As we discussed before, we can't have a vq interleave the report of stats
>> and free pages.
>> The vq will be locked when one command is in use. So, when live migration
>> starts, the
>> periodically reported stats will be delayed.
>
>
>
>
>
>> Would this be OK? Or would you
>> like to have
>> one host to guest vq, and multiple host to guest vqs? That is,
>>
>> - host to guest:
>> CMD_VQ
>>
>> - guest to host:
>> STATS_REPORT_VQ
>> FREE_PAGE_VQ
>>
>>
>> Best,
>> Wei
>>
> Point is stats report vq is also host to guest.
> So I think it can be combined with CMD VQ.
> If it's too hard a separate vq isn't too bad though.
>

IMHO, this kind of categorization - using stat_vq for

host-to-guest stats request,
guest-to-host stats report,
host-to-guest free page request,

seems a little tricky and unclear. I would think it is better to have 
unrelated
features decoupled. For example, both stats report and free page report
are optional features. With the above implementation, using the free page
feature will depend on the stats report feature (in fact we can implement
it to have the free page feature work independently)

That being said, if you don't mind the above, we can go with that option
in the next version.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
