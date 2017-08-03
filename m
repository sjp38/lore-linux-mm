Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC976B06BB
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 09:18:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r187so12765410pfr.8
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 06:18:43 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p129si21105681pfp.193.2017.08.03.06.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 06:18:42 -0700 (PDT)
Message-ID: <59832353.1020600@intel.com>
Date: Thu, 03 Aug 2017 21:21:23 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v13 5/5] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com> <1501742299-4369-6-git-send-email-wei.w.wang@intel.com> <147332060.38438527.1501748021126.JavaMail.zimbra@redhat.com> <598316DB.4050308@intel.com> <900253471.38532197.1501765506419.JavaMail.zimbra@redhat.com>
In-Reply-To: <900253471.38532197.1501765506419.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia huck <cornelia.huck@de.ibm.com>, mgorman@techsingularity.net, aarcange@redhat.com, amit shah <amit.shah@redhat.com>, pbonzini@redhat.com, liliang opensource <liliang.opensource@gmail.com>, yang zhang wz <yang.zhang.wz@gmail.com>, quan xu <quan.xu@aliyun.com>

On 08/03/2017 09:05 PM, Pankaj Gupta wrote:
>> On 08/03/2017 04:13 PM, Pankaj Gupta wrote:
>>>> +        /* Allocate space for find_vqs parameters */
>>>> +        vqs = kcalloc(nvqs, sizeof(*vqs), GFP_KERNEL);
>>>> +        if (!vqs)
>>>> +                goto err_vq;
>>>> +        callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
>>>> +        if (!callbacks)
>>>> +                goto err_callback;
>>>> +        names = kmalloc_array(nvqs, sizeof(*names), GFP_KERNEL);
>>>                       
>>>          is size here (integer) intentional?
>>
>> Sorry, I didn't get it. Could you please elaborate more?
> This is okay
>
>>
>>>> +        if (!names)
>>>> +                goto err_names;
>>>> +
>>>> +        callbacks[0] = balloon_ack;
>>>> +        names[0] = "inflate";
>>>> +        callbacks[1] = balloon_ack;
>>>> +        names[1] = "deflate";
>>>> +
>>>> +        i = 2;
>>>> +        if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>>>> +                callbacks[i] = stats_request;
>>> just thinking if memory for callbacks[3] & names[3] is allocated?
>>
>> Yes, the above kmalloc_array allocated them.
> I mean we have created callbacks array for two entries 0,1?
>
> callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
>
> But we are trying to access location '2' which is third:
>
>           i = 2;
> +        if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> +                callbacks[i] = stats_request;      <---- callbacks[2]
> +                names[i] = "stats";                <----- names[2]
> +                i++;
> +        }
>
> I am missing anything obvious here?


Yes.
if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) is true
nvqs will be 3, that is, callbacks[2] is allocated.

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
