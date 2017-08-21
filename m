Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0611E6B04CA
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 01:18:49 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k10so53222385pgs.11
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 22:18:48 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s4si6868061pfk.619.2017.08.20.22.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Aug 2017 22:18:47 -0700 (PDT)
Message-ID: <599A6DE2.3040309@intel.com>
Date: Mon, 21 Aug 2017 13:21:38 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v14 5/5] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com> <1502940416-42944-6-git-send-email-wei.w.wang@intel.com> <20170818045519-mutt-send-email-mst@kernel.org> <5996A845.4010405@intel.com> <20170818211119-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170818211119-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 08/19/2017 02:26 AM, Michael S. Tsirkin wrote:
> On Fri, Aug 18, 2017 at 04:41:41PM +0800, Wei Wang wrote:
>> On 08/18/2017 10:13 AM, Michael S. Tsirkin wrote:
>>> On Thu, Aug 17, 2017 at 11:26:56AM +0800, Wei Wang wrote:
>>>> Add a new vq to report hints of guest free pages to the host.
>>> Please add some text here explaining the report_free_page_signal
>>> thing.
>>>
>>>
>>> I also really think we need some kind of ID in the
>>> buffer to do a handshake. whenever id changes you
>>> add another outbuf.
>> Please let me introduce the current design first:
>> 1) device put the signal buf to the vq and notify the driver (we need
>> a buffer because currently the device can't notify when the vq is empty);
>>
>> 2) the driver starts the report of free page blocks via inbuf;
>>
>> 3) the driver adds an the signal buf via outbuf to tell the device all are
>> reported.
>>
>>
>> Could you please elaborate more on the usage of ID?
> While driver is free to maintain at most one buffer in flight
> the design must work with pipelined requests as that
> is important for performance.

How would the pipeline be designed?

Currently, once the report starts,
- the driver work: add_inbuf(free_pages) & kick;

- the device work:
     record the pages into a free page bitmap;
     virtqueue_push(elem);
     virtio_notify();

For the driver, as long as the vq has available entries, it keeps doing 
its work;
For the device, as long as there are free pages in the vq, it also keeps 
doing its work.


>
> So host might be able to request the reporting twice.
> How does it know what is the report in response to?

The request to start is sent when live migration starts, where would be
the second chance to send the request to start?



>
> If we put an id in request and in response, then that fixes it.
>
>
> So there's a vq used for requesting free page reports.
> driver does add_inbuf( &device->id).
>
> Then when it starts reporting it does
>
>
> add_outbuf(&device->id)
>
> followed by pages.
>
>
> Also if device->id changes it knows it should restart
> reporting from beginning.
>
>
>
>
>
>
>>>> +retry:
>>>> +	ret = virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
>>>> +	virtqueue_kick(vq);
>>>> +	if (unlikely(ret == -ENOSPC)) {
>>> what if there's another error?
>> Another error is -EIO, how about disabling the free page report feature?
>> (I also saw it isn't handled in many other virtio devices e.g. virtio-net)
>>
>>>> +		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>>>> +		goto retry;
>>>> +	}
>>> what is this trickery doing? needs more comments or
>>> a simplification.
>> Just this:
>> if the vq is full, blocking wait till an entry gets released, then retry.
>> This is the
>> final one, which puts the signal buf to the vq to signify the end of the
>> report and
>> the mm lock is not held here, so it is fine to block.
>>
> But why do you kick here on failure? I would understand it if you
> did not kick when adding pages, as it is I don't understand.
>
>
> Also pls rewrite this with a for or while loop for clarity.

OK, I will rewrite this part.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
