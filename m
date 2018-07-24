Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A68A16B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 21:45:09 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id y8-v6so1643497plp.17
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 18:45:09 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y9-v6si8766605pgv.290.2018.07.23.18.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 18:45:08 -0700 (PDT)
Message-ID: <5B5685A0.9040005@intel.com>
Date: Tue, 24 Jul 2018 09:49:20 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v36 2/5] virtio_balloon: replace oom notifier with shrinker
References: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com> <1532075585-39067-3-git-send-email-wei.w.wang@intel.com> <20180722174125-mutt-send-email-mst@kernel.org> <5B55AE56.5030404@intel.com> <20180723170826-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180723170826-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On 07/23/2018 10:13 PM, Michael S. Tsirkin wrote:
>>>    	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
>>>    #endif
>>> +	err = virtio_balloon_register_shrinker(vb);
>>> +	if (err)
>>> +		goto out_del_vqs;
>>> So we can get scans before device is ready. Leak will fail
>>> then. Why not register later after device is ready?
>> Probably no.
>>
>> - it would be better not to set device ready when register_shrinker failed.
> That's very rare so I won't be too worried.

Just a little confused with the point here. "very rare" means it still 
could happen (even it's a corner case), and if that happens, we got 
something wrong functionally. So it will be a bug if we change like 
that, right?

Still couldn't understand the reason of changing shrinker_register after 
device_ready (the original oom notifier was registered before setting 
device ready too)?
(I think the driver won't get shrinker_scan called if device isn't ready 
because of the reasons below)

>> - When the device isn't ready, ballooning won't happen, that is,
>> vb->num_pages will be 0, which results in shrinker_count=0 and shrinker_scan
>> won't be called.

Best,
Wei
