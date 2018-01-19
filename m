Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19CD26B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:21:48 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 199so892751pfy.18
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 22:21:48 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id r5si7446074pgt.92.2018.01.18.22.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 22:21:46 -0800 (PST)
Message-ID: <5A618F0B.4090805@intel.com>
Date: Fri, 19 Jan 2018 14:24:11 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v22 2/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com> <1516165812-3995-3-git-send-email-wei.w.wang@intel.com> <20180117180337-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180117180337-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 01/18/2018 12:44 AM, Michael S. Tsirkin wrote:
> On Wed, Jan 17, 2018 at 01:10:11PM +0800, Wei Wang wrote:
>>   
>> +static void virtballoon_changed(struct virtio_device *vdev)
>> +{
>> +	struct virtio_balloon *vb = vdev->priv;
>> +	unsigned long flags;
>> +	__u32 cmd_id;
>> +	s64 diff = towards_target(vb);
>> +
>> +	if (diff) {
>> +		spin_lock_irqsave(&vb->stop_update_lock, flags);
>> +		if (!vb->stop_update)
> Why do you ignore stop_update for freeze?
> This means new wq entries can be added during remove
> causing use after free issues.

I think stop_update isn't needed, because the lock has already been 
handled internally by the APIs. Similar examples like 
mem_cgroup_css_free() in "mm/memcontrol.c", there is no such locks used 
for cancel_work_sync(&memcg->high_work).

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
