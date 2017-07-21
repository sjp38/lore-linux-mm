Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 971FE6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 22:11:33 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p13so52971124pgf.14
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 19:11:33 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id u1si2340008plk.370.2017.07.20.19.11.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 19:11:32 -0700 (PDT)
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
References: <20170713211532.970-1-jglisse@redhat.com>
 <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
 <20170718153816.GA3135@redhat.com>
 <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
 <20170719022537.GA6911@redhat.com>
 <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
 <20170720150305.GA2767@redhat.com>
 <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
 <20170721014106.GB25991@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <052b3b89-6382-a1b8-270f-3a4e44158964@huawei.com>
Date: Fri, 21 Jul 2017 10:10:11 +0800
MIME-Version: 1.0
In-Reply-To: <20170721014106.GB25991@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal
 Hocko <mhocko@kernel.org>

On 2017/7/21 9:41, Jerome Glisse wrote:
> On Fri, Jul 21, 2017 at 09:15:29AM +0800, Bob Liu wrote:
>> On 2017/7/20 23:03, Jerome Glisse wrote:
>>> On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
>>>> On 2017/7/19 10:25, Jerome Glisse wrote:
>>>>> On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
>>>>>> On 2017/7/18 23:38, Jerome Glisse wrote:
>>>>>>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
>>>>>>>> On 2017/7/14 5:15, Jerome Glisse wrote:
> 
> [...]
> 
>>>> Then it's more like replace the numa node solution(CDM) with ZONE_DEVICE
>>>> (type MEMORY_DEVICE_PUBLIC). But the problem is the same, e.g how to make
>>>> sure the device memory say HBM won't be occupied by normal CPU allocation.
>>>> Things will be more complex if there are multi GPU connected by nvlink
>>>> (also cache coherent) in a system, each GPU has their own HBM.
>>>>
>>>> How to decide allocate physical memory from local HBM/DDR or remote HBM/
>>>> DDR? 
>>>>
>>>> If using numa(CDM) approach there are NUMA mempolicy and autonuma mechanism
>>>> at least.
>>>
>>> NUMA is not as easy as you think. First like i said we want the device
>>> memory to be isolated from most existing mm mechanism. Because memory
>>> is unreliable and also because device might need to be able to evict
>>> memory to make contiguous physical memory allocation for graphics.
>>>
>>
>> Right, but we need isolation any way.
>> For hmm-cdm, the isolation is not adding device memory to lru list, and many
>> if (is_device_public_page(page)) ...
>>
>> But how to evict device memory?
> 
> What you mean by evict ? Device driver can evict whenever they see the need
> to do so. CPU page fault will evict too. Process exit or munmap() will free
> the device memory.
> 
> Are you refering to evict in the sense of memory reclaim under pressure ?
> 
> So the way it flows for memory pressure is that if device driver want to
> make room it can evict stuff to system memory and if there is not enough

Yes, I mean this. 
So every driver have to maintain their own LRU-similar list instead of reuse what already in linux kernel.

> system memory than thing get reclaim as usual before device driver can
> make progress on device memory reclaim.
> 
> 
>>> Second device driver are not integrated that closely within mm and the
>>> scheduler kernel code to allow to efficiently plug in device access
>>> notification to page (ie to update struct page so that numa worker
>>> thread can migrate memory base on accurate informations).
>>>
>>> Third it can be hard to decide who win between CPU and device access
>>> when it comes to updating thing like last CPU id.
>>>
>>> Fourth there is no such thing like device id ie equivalent of CPU id.
>>> If we were to add something the CPU id field in flags of struct page
>>> would not be big enough so this can have repercusion on struct page
>>> size. This is not an easy sell.
>>>
>>> They are other issues i can't think of right now. I think for now it
>>
>> My opinion is most of the issues are the same no matter use CDM or HMM-CDM.
>> I just care about a more complete solution no matter CDM,HMM-CDM or other ways.
>> HMM or HMM-CDM depends on device driver, but haven't see a public/full driver to 
>> demonstrate the whole solution works fine.
> 
> I am working with NVidia close source driver team to make sure that it works
> well for them. I am also working on nouveau open source driver for same NVidia
> hardware thought it will be of less use as what is missing there is a solid
> open source userspace to leverage this. Nonetheless open source driver are in
> the work.
> 

Looking forward to see these drivers be public.

> The way i see it is start with HMM-CDM which isolate most of the changes in
> hmm code. Once we get more experience with real workload and not with device
> driver test suite then we can start revisiting NUMA and deeper integration
> with the linux kernel. I rather grow organicaly toward that than trying to
> design something that would make major changes all over the kernel without
> knowing for sure that we are going in the right direction. I hope that this
> make sense to others too.
> 

Make sense.

Thanks,
Bob Liu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
