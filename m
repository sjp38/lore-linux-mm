Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E38F26B058D
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 08:44:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r187so115111571pfr.8
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 05:44:30 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s10si14404646plj.27.2017.07.29.05.44.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 05:44:29 -0700 (PDT)
Message-ID: <597C83CC.7060702@intel.com>
Date: Sat, 29 Jul 2017 20:47:08 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <20170712160129-mutt-send-email-mst@kernel.org> <5966241C.9060503@intel.com> <20170712163746-mutt-send-email-mst@kernel.org> <5967246B.9030804@intel.com> <20170713210819-mutt-send-email-mst@kernel.org> <59686EEB.8080805@intel.com> <20170723044036-mutt-send-email-mst@kernel.org> <59781119.8010200@intel.com> <20170726155856-mutt-send-email-mst@kernel.org> <597954E3.2070801@intel.com> <20170729020231-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170729020231-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 07/29/2017 07:08 AM, Michael S. Tsirkin wrote:
> On Thu, Jul 27, 2017 at 10:50:11AM +0800, Wei Wang wrote:
>>>>> OK I thought this over. While we might need these new APIs in
>>>>> the future, I think that at the moment, there's a way to implement
>>>>> this feature that is significantly simpler. Just add each s/g
>>>>> as a separate input buffer.
>>>> Should it be an output buffer?
>>> Hypervisor overwrites these pages with zeroes. Therefore it is
>>> writeable by device: DMA_FROM_DEVICE.
>> Why would the hypervisor need to zero the buffer?
> The page is supplied to hypervisor and can lose the value that
> is there.  That is the definition of writeable by device.

I think for the free pages, it should be clear that they will be added as
output buffer to the device, because (as we discussed) they are just hints,
and some of them may be used by the guest after the report_ API is invoked.
The device/hypervisor should not use or discard them.

For the balloon pages, I kind of agree with the existing implementation
(e.g. inside tell_host()), which uses virtqueue_add_outbuf (instead of 
_add_inbuf()).
I think inbuf should be a buffer which will be written by the device and 
read by the
driver. The cmd buffer put on the vq for the device to send commands can 
be an
inbuf, I think.


>
>> I think it may only
>> need to read out the info(base,size).
> And then do what?


For the free pages, the info will be used to clear the corresponding "1" 
in the dirty bitmap.
For balloon pages, they will be made DONTNEED and given to other host 
processes to
use (the device won't write them, so no need to set "write" when 
virtqueue_map_desc() in
the device).


>
>> I think it should be like this:
>> the cmd hdr buffer: input, because the hypervisor would write it to
>> send a cmd to the guest
>> the payload buffer: output, for the hypervisor to read the info
> These should be split.
>
> We have:
>
> 1. request that hypervisor sends to guest, includes ID: input
> 2. synchronisation header with ID sent by guest: output
> 3. list of pages: input
>
> 2 and 3 must be on the same VQ. 1 can come on any VQ - reusing stats VQ
> might make sense.

I would prefer to make the above item 1 come on the the free page vq,
because the existing stat_vq doesn't support the cmd hdr.
Now, I think it is also not necessary to move the existing stat_vq 
implementation to
a new implementation under the cmd hdr, because
that new support doesn't make a difference for stats, it will still use 
its stat_vq (the free
page vq will be used for reporting free pages only)

What do you think?


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
