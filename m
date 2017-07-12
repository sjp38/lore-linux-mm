Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4916B6B053F
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 08:55:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s4so23870816pgr.3
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 05:55:08 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d6si1967910pln.369.2017.07.12.05.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 05:55:07 -0700 (PDT)
Message-ID: <59661CA6.5040903@intel.com>
Date: Wed, 12 Jul 2017 20:57:10 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v11 6/6] virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com> <1497004901-30593-7-git-send-email-wei.w.wang@intel.com> <20170620190343-mutt-send-email-mst@kernel.org> <5949E7C0.3050106@intel.com> <20170621151922-mutt-send-email-mst@kernel.org> <594B8287.6000706@intel.com> <20170628175956-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170628175956-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "riel@redhat.com" <riel@redhat.com>, "nilal@redhat.com" <nilal@redhat.com>

On 06/28/2017 11:01 PM, Michael S. Tsirkin wrote:
> On Thu, Jun 22, 2017 at 04:40:39PM +0800, Wei Wang wrote:
>> On 06/21/2017 08:28 PM, Michael S. Tsirkin wrote:
>>> On Wed, Jun 21, 2017 at 11:28:00AM +0800, Wei Wang wrote:
>>>> On 06/21/2017 12:18 AM, Michael S. Tsirkin wrote:
>>>>> On Fri, Jun 09, 2017 at 06:41:41PM +0800, Wei Wang wrote:
>>>>>> -	if (!virtqueue_indirect_desc_table_add(vq, desc, num)) {
>>>>>> +	if (!virtqueue_indirect_desc_table_add(vq, desc, *num)) {
>>>>>>     		virtqueue_kick(vq);
>>>>>> -		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>>>>>> -		vb->balloon_page_chunk.chunk_num = 0;
>>>>>> +		if (busy_wait)
>>>>>> +			while (!virtqueue_get_buf(vq, &len) &&
>>>>>> +			       !virtqueue_is_broken(vq))
>>>>>> +				cpu_relax();
>>>>>> +		else
>>>>>> +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>>>>> This is something I didn't previously notice.
>>>>> As you always keep a single buffer in flight, you do not
>>>>> really need indirect at all. Just add all descriptors
>>>>> in the ring directly, then kick.
>>>>>
>>>>> E.g.
>>>>> 	virtqueue_add_first
>>>>> 	virtqueue_add_next
>>>>> 	virtqueue_add_last
>>>>>
>>>>> ?
>>>>>
>>>>> You also want a flag to avoid allocations but there's no need to do it
>>>>> per descriptor, set it on vq.
>>>>>
>>>> Without using the indirect table, I'm thinking about changing to use
>>>> the standard sg (i.e. struct scatterlist), instead of vring_desc, so that
>>>> we don't need to modify or add any new functions of virtqueue_add().
>>>>
>>>> In this case, we will kmalloc an array of sgs in probe(), and we can add
>>>> the sgs one by one to the vq, which won't trigger the allocation of an
>>>> indirect table inside virtqueue_add(), and then kick when all are added.
>>>>
>>>> Best,
>>>> Wei
>>> And allocate headers too? This can work. API extensions aren't
>>> necessarily a bad idea though. The API I suggest above is preferable
>>> for the simple reason that it can work without INDIRECT flag
>>> support in hypervisor.
>> OK, probably we don't need to add a desc to the vq - we can just use
>> the vq's desc, like this:
>>
>> int virtqueue_add_first(struct virtqueue *_vq,
>>                                       uint64_t addr,
>>                                       uint32_t len,
>>                                       bool in,
>>                                       unsigned int *idx) {
>>
>>      ...
>>     uint16_t desc_flags = in ? VRING_DESC_F_NEXT | VRING_DESC_F_WRITE :
>>                                               VRING_DESC_F_NEXT;
>>
>>      vq->vring.desc[vq->free_head].addr = addr;
>>      vq->vring.desc[vq->free_head].len = len;
>>      vq->vring.desc[vq->free_head].flags = cpu_to_virtio16(_vq->vdev, flags);
>>      /* return to the caller the desc id */
>>      *idx = vq->free_head;
>>      ...
>> }
>>
>> int virtqueue_add_next(struct virtqueue *_vq,
>>                                       uint64_t addr,
>>                                       uint32_t len,
>>                                       bool in,
>>                                       bool end,
>>                                       unsigned int *idx) {
>>      ...
>>      vq->vring.desc[*idx].next = vq->free_head;
>>      vq->vring.desc[vq->free_head].addr = addr;
>>      ...
>>      if (end)
>>          remove the VRING_DESC_F_NEXT flag
>> }
>>
> Add I would say add-last.
>
>> What do you think? We can also combine the two functions into one.
>>
>>
>>
>> Best,
>> Wei
> With an enum? Yes that's also an option.
>

Thanks for the suggestion. I shifted it a little bit, please have a check
the latest v12 patches that I just sent out.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
