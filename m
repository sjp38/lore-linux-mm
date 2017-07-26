Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 155C76B02F4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:41:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g69so4277023pfe.5
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:41:48 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v66si9384445pfb.416.2017.07.26.04.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 04:41:46 -0700 (PDT)
Message-ID: <59788097.6010402@intel.com>
Date: Wed, 26 Jul 2017 19:44:23 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
References: <20170719081311.GC26779@dhcp22.suse.cz> <596F4A0E.4010507@intel.com> <20170724090042.GF25221@dhcp22.suse.cz> <59771010.6080108@intel.com> <20170725112513.GD26723@dhcp22.suse.cz> <597731E8.9040803@intel.com> <20170725124141.GF26723@dhcp22.suse.cz> <286AC319A985734F985F78AFA26841F739283F62@shsmsx102.ccr.corp.intel.com> <20170725145333.GK26723@dhcp22.suse.cz> <5977FCDF.7040606@intel.com> <20170726102458.GH2981@dhcp22.suse.cz>
In-Reply-To: <20170726102458.GH2981@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On 07/26/2017 06:24 PM, Michal Hocko wrote:
> On Wed 26-07-17 10:22:23, Wei Wang wrote:
>> On 07/25/2017 10:53 PM, Michal Hocko wrote:
>>> On Tue 25-07-17 14:47:16, Wang, Wei W wrote:
>>>> On Tuesday, July 25, 2017 8:42 PM, hal Hocko wrote:
>>>>> On Tue 25-07-17 19:56:24, Wei Wang wrote:
>>>>>> On 07/25/2017 07:25 PM, Michal Hocko wrote:
>>>>>>> On Tue 25-07-17 17:32:00, Wei Wang wrote:
>>>>>>>> On 07/24/2017 05:00 PM, Michal Hocko wrote:
>>>>>>>>> On Wed 19-07-17 20:01:18, Wei Wang wrote:
>>>>>>>>>> On 07/19/2017 04:13 PM, Michal Hocko wrote:
>>>>>>>>> [...
>>>>>> We don't need to do the pfn walk in the guest kernel. When the API
>>>>>> reports, for example, a 2MB free page block, the API caller offers to
>>>>>> the hypervisor the base address of the page block, and size=2MB, to
>>>>>> the hypervisor.
>>>>> So you want to skip pfn walks by regularly calling into the page allocator to
>>>>> update your bitmap. If that is the case then would an API that would allow you
>>>>> to update your bitmap via a callback be s sufficient? Something like
>>>>> 	void walk_free_mem(int node, int min_order,
>>>>> 			void (*visit)(unsigned long pfn, unsigned long nr_pages))
>>>>>
>>>>> The function will call the given callback for each free memory block on the given
>>>>> node starting from the given min_order. The callback will be strictly an atomic
>>>>> and very light context. You can update your bitmap from there.
>>>> I would need to introduce more about the background here:
>>>> The hypervisor and the guest live in their own address space. The hypervisor's bitmap
>>>> isn't seen by the guest. I think we also wouldn't be able to give a callback function
>>> >from the hypervisor to the guest in this case.
>>> How did you plan to use your original API which export struct page array
>>> then?
>>
>> That's where the virtio-balloon driver comes in. It uses a shared ring
>> mechanism to
>> send the guest memory info to the hypervisor.
>>
>> We didn't expose the struct page array from the guest to the hypervisor. For
>> example, when
>> a 2MB free page block is reported from the free page list, the info put on
>> the ring is just
>> (base address of the 2MB continuous memory, size=2M).
> So what exactly prevents virtio-balloon from using the above proposed
> callback mechanism and export what is needed to the hypervisor?

I thought about it more. Probably we can use the callback function with 
a little change like this:

void walk_free_mem(void *opaque1, void (*visit)(void *opaque2, unsigned 
long pfn,
            unsigned long nr_pages))
{
     ...
     for_each_populated_zone(zone) {
                    for_each_migratetype_order(order, type) {
                         report_unused_page_block(zone, order, type, 
&page); // from patch 6
                         pfn = page_to_pfn(page);
                         visit(opaque1, pfn, 1 << order);
                     }
     }
}

The above function scans all the free list and directly sends each free 
page block to the
hypervisor via the virtio_balloon callback below. No need to implement a 
bitmap.

In virtio-balloon, we have the callback:
void *virtio_balloon_report_unused_pages(void *opaque,  unsigned long pfn,
unsigned long nr_pages)
{
     struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
     ...put the free page block to the the ring of vb;
}


What do you think?


Best,
Wei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
