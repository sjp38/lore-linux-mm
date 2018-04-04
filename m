Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8F846B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 22:04:40 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 91-v6so12179920pla.18
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 19:04:40 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 185si2869907pgd.561.2018.04.03.19.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 19:04:39 -0700 (PDT)
Message-ID: <5AC43377.2070607@intel.com>
Date: Wed, 04 Apr 2018 10:07:51 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v30 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1522771805-78927-1-git-send-email-wei.w.wang@intel.com> <1522771805-78927-3-git-send-email-wei.w.wang@intel.com> <20180403214147-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180403214147-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On 04/04/2018 02:47 AM, Michael S. Tsirkin wrote:
> On Wed, Apr 04, 2018 at 12:10:03AM +0800, Wei Wang wrote:
>> +static int add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t len)
>> +{
>> +	struct scatterlist sg;
>> +	unsigned int unused;
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
>> +	 * pages to report isn't important. We simply return without adding
>> +	 * the page hint if the vq is full.
> why not stop scanning of following pages though?

Because continuing to send hints is a way to deliver the maximum 
possible hints to host. For example, host may have a delay in taking 
hints at some point, and then it resumes to take hints soon. If the 
driver does not stop when the vq is full, it will be able to put more 
hints to the vq once the vq has available entries to add.


>
>> +	 * We are adding one entry each time, which essentially results in no
>> +	 * memory allocation, so the GFP_KERNEL flag below can be ignored.
>> +	 * Host works by polling the free page vq for hints after sending the
>> +	 * starting cmd id, so the driver doesn't need to kick after filling
>> +	 * the vq.
>> +	 * Lastly, there is always one entry reserved for the cmd id to use.
>> +	 */
>> +	if (vq->num_free > 1)
>> +		return virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
>> +
>> +	return 0;
>> +}
>> +
>> +static int virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
>> +					   unsigned long nr_pages)
>> +{
>> +	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
>> +	uint32_t len = nr_pages << PAGE_SHIFT;
>> +
>> +	/*
>> +	 * If a stop id or a new cmd id was just received from host, stop
>> +	 * the reporting, and return 1 to indicate an active stop.
>> +	 */
>> +	if (virtio32_to_cpu(vb->vdev, vb->cmd_id_use) != vb->cmd_id_received)
>> +		return 1;
>> +
> this access to cmd_id_use and cmd_id_received without locks
> bothers me. Pls document why it's safe.

OK. Probably we could add below to the above comments:

cmd_id_use and cmd_id_received don't need to be accessed under locks 
because the reporting does not have to stop immediately before 
cmd_id_received is changed (i.e. when host requests to stop). That is, 
reporting more hints after host requests to stop isn't an issue for this 
optimization feature, because host will simply drop the stale hints next 
time when it needs a new reporting.




>
>> +	return add_one_sg(vb->free_page_vq, pfn, len);
>> +}
>> +
>> +static int send_start_cmd_id(struct virtio_balloon *vb, uint32_t cmd_id)
>> +{
>> +	struct scatterlist sg;
>> +	struct virtqueue *vq = vb->free_page_vq;
>> +
>> +	vb->cmd_id_use = cpu_to_virtio32(vb->vdev, cmd_id);
>> +	sg_init_one(&sg, &vb->cmd_id_use, sizeof(vb->cmd_id_use));
>> +	return virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
>> +}
>> +
>> +static int send_stop_cmd_id(struct virtio_balloon *vb)
>> +{
>> +	struct scatterlist sg;
>> +	struct virtqueue *vq = vb->free_page_vq;
>> +
>> +	sg_init_one(&sg, &vb->stop_cmd_id, sizeof(vb->cmd_id_use));
> why the inconsistency?

Thanks, will make it consistent.

Best,
Wei
