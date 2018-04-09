Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 837A56B0008
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 07:43:37 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 61-v6so6875960plz.20
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 04:43:37 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i75si109983pgd.399.2018.04.09.04.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 04:43:36 -0700 (PDT)
Message-ID: <5ACB52AB.5020200@intel.com>
Date: Mon, 09 Apr 2018 19:46:51 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v31 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1523017045-18315-1-git-send-email-wei.w.wang@intel.com> <1523017045-18315-3-git-send-email-wei.w.wang@intel.com> <20180409085457-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180409085457-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On 04/09/2018 02:03 PM, Michael S. Tsirkin wrote:
> On Fri, Apr 06, 2018 at 08:17:23PM +0800, Wei Wang wrote:
>> Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature indicates the
>> support of reporting hints of guest free pages to host via virtio-balloon.
>>
>> Host requests the guest to report free page hints by sending a new cmd
>> id to the guest via the free_page_report_cmd_id configuration register.
>>
>> When the guest starts to report, the first element added to the free page
>> vq is the cmd id given by host. When the guest finishes the reporting
>> of all the free pages, VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID is added
>> to the vq to tell host that the reporting is done. Host polls the free
>> page vq after sending the starting cmd id, so the guest doesn't need to
>> kick after filling an element to the vq.
>>
>> Host may also requests the guest to stop the reporting in advance by
>> sending the stop cmd id to the guest via the configuration register.
>>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Signed-off-by: Liang Li <liang.z.li@intel.com>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>
> Pretty good by now, Minor comments below.

Thanks for the comments.

>
>> ---
>>   drivers/virtio/virtio_balloon.c     | 272 +++++++++++++++++++++++++++++++-----
>>   include/uapi/linux/virtio_balloon.h |   4 +
>>   2 files changed, 240 insertions(+), 36 deletions(-)
>>
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>> index dfe5684..aef73ee 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -51,9 +51,22 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>>   static struct vfsmount *balloon_mnt;
>>   #endif
>>   
>> +enum virtio_balloon_vq {
>> +	VIRTIO_BALLOON_VQ_INFLATE,
>> +	VIRTIO_BALLOON_VQ_DEFLATE,
>> +	VIRTIO_BALLOON_VQ_STATS,
>> +	VIRTIO_BALLOON_VQ_FREE_PAGE,
>> +	VIRTIO_BALLOON_VQ_MAX
>> +};
>> +
>>   struct virtio_balloon {
>>   	struct virtio_device *vdev;
>> -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
>> +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
>> +
>> +	/* Balloon's own wq for cpu-intensive work items */
>> +	struct workqueue_struct *balloon_wq;
>> +	/* The free page reporting work item submitted to the balloon wq */
>> +	struct work_struct report_free_page_work;
>>   
>>   	/* The balloon servicing is delegated to a freezable workqueue. */
>>   	struct work_struct update_balloon_stats_work;
>> @@ -63,6 +76,13 @@ struct virtio_balloon {
>>   	spinlock_t stop_update_lock;
>>   	bool stop_update;
>>   
>> +	/* The new cmd id received from host */
>> +	uint32_t cmd_id_received;
>> +	/* The cmd id that is in use */
>> +	__virtio32 cmd_id_use;
> I'd prefer cmd_id_active but it's not critical.

OK, will change.

>
> +
> +static void report_free_page_func(struct work_struct *work)
> +{
> +	struct virtio_balloon *vb;
> +	struct virtqueue *vq;
> +	unsigned int unused;
> +	int ret;
> +
> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
> +	vq = vb->free_page_vq;
> +
> +	/* Start by sending the received cmd id to host with an outbuf. */
> +	ret = send_start_cmd_id(vb, vb->cmd_id_received);
> +	if (unlikely(ret))
> +		goto err;
> +
> +	ret = walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> +	if (unlikely(ret == -EIO))
> +		goto err;
> why is EIO special? I think you should special-case EINTR maybe.

Actually EINTR isn't an error which needs to bail out. That's just the 
case that the vq is full, that hint isn't added. Maybe it is not 
necessary to treat the "vq full" case as an error.
How about just returning "0" when the vq is full, instead of returning 
"EINTR"? (The next hint will continue to be added)



>
>> +
>> +	/* End by sending a stop id to host with an outbuf. */
>> +	ret = send_stop_cmd_id(vb);
>> +	if (likely(!ret)) {
> What happens on failure? Don't we need to detach anyway?

Yes. Please see below, we could make some more change.
>
>> +		/* Ending: detach all the used buffers from the vq. */
>> +		while (vq->num_free != virtqueue_get_vring_size(vq))
>> +			virtqueue_get_buf(vq, &unused);
> This isn't all that happens here. It also waits for buffers to
> be consumed. Is this by design? And why is it good idea to
> busy poll while doing it?

Because host and guest operations happen asynchronously. When the guest 
reaches here, host may have not put anything to the vq yet. How about 
doing this via the free page vq handler?
Host will send a free page vq interrupt before exiting the optimization. 
I think this would be nicer.


Best,
Wei
