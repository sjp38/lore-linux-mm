Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9868E800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 06:26:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id x16so2841529pfe.20
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 03:26:17 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n24si24143pgd.735.2018.01.24.03.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 03:26:16 -0800 (PST)
Message-ID: <5A686DEE.4050008@intel.com>
Date: Wed, 24 Jan 2018 19:28:46 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v22 2/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com> <1516165812-3995-3-git-send-email-wei.w.wang@intel.com> <20180117180337-mutt-send-email-mst@kernel.org> <5A616995.4050702@intel.com> <20180119143517-mutt-send-email-mst@kernel.org> <5A65CA39.2070906@intel.com> <20180124062723-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180124062723-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 01/24/2018 12:29 PM, Michael S. Tsirkin wrote:
> On Mon, Jan 22, 2018 at 07:25:45PM +0800, Wei Wang wrote:
>> On 01/19/2018 08:39 PM, Michael S. Tsirkin wrote:
>>> On Fri, Jan 19, 2018 at 11:44:21AM +0800, Wei Wang wrote:
>>>> On 01/18/2018 12:44 AM, Michael S. Tsirkin wrote:
>>>>> On Wed, Jan 17, 2018 at 01:10:11PM +0800, Wei Wang wrote:
>>>>>
>>>>>> +		vb->start_cmd_id = cmd_id;
>>>>>> +		queue_work(vb->balloon_wq, &vb->report_free_page_work);
>>>>> It seems that if a command was already queued (with a different id),
>>>>> this will result in new command id being sent to host twice, which will
>>>>> likely confuse the host.
>>>> I think that case won't happen, because
>>>> - the host sends a cmd id to the guest via the config, while the guest acks
>>>> back the received cmd id via the virtqueue;
>>>> - the guest ack back a cmd id only when a new cmd id is received from the
>>>> host, that is the above check:
>>>>
>>>>       if (cmd_id != vb->start_cmd_id) { --> the driver only queues the
>>>> reporting work only when a new cmd id is received
>>>>                           /*
>>>>                            * Host requests to start the reporting by sending a
>>>>                            * new cmd id.
>>>>                            */
>>>>                           WRITE_ONCE(vb->report_free_page, true);
>>>>                           vb->start_cmd_id = cmd_id;
>>>>                           queue_work(vb->balloon_wq,
>>>> &vb->report_free_page_work);
>>>>       }
>>>>
>>>> So the same cmd id wouldn't queue the reporting work twice.
>>>>
>>> Like this:
>>>
>>> 		vb->start_cmd_id = cmd_id;
>>> 		queue_work(vb->balloon_wq, &vb->report_free_page_work);
>>>
>>> command id changes
>>>
>>> 		vb->start_cmd_id = cmd_id;
>>>
>>> work executes
>>>
>>> 		queue_work(vb->balloon_wq, &vb->report_free_page_work);
>>>
>>> work executes again
>>>
>> If we think about the whole working flow, I think this case couldn't happen:
>>
>> 1) device send cmd_id=1 to driver;
>> 2) driver receives cmd_id=1 in the config and acks cmd_id=1 to the device
>> via the vq;
>> 3) device revives cmd_id=1;
>> 4) device wants to stop the reporting by sending cmd_id=STOP;
>> 5) driver receives cmd_id=STOP from the config, and acks cmd_id=STOP to the
>> device via the vq;
>> 6) device sends cmd_id=2 to driver;
>> ...
>>
>> cmd_id=2 won't come after cmd_id=1, there will be a STOP cmd in between them
>> (STOP won't queue the work).
>>
>> How about defining the correct device behavior in the spec:
>> The device Should NOT send a second cmd id to the driver until a STOP cmd
>> ack for the previous cmd id has been received from the guest.
>>
>>
>> Best,
>> Wei
> I think we should just fix races in the driver rather than introduce
> random restrictions in the device.
>
> If device wants to start a new sequence, it should be able to
> do just that without a complicated back and forth with several
> roundtrips through the driver.
>

OK, I've fixed it in the new version, v24. Please have a check there. 
Thanks.
(Other changes based on the comments on v23 have also been included)

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
