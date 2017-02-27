Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 814926B0389
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 20:56:39 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 1so155374353pgz.5
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 17:56:39 -0800 (PST)
Received: from dggrg01-dlp.huawei.com ([45.249.212.187])
        by mx.google.com with ESMTPS id a96si13835812pli.151.2017.02.26.17.56.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 26 Feb 2017 17:56:38 -0800 (PST)
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170221111107.GJ15595@dhcp22.suse.cz>
 <890fb824-d1f0-3711-4fe6-d6ddf29a0d80@linux.vnet.ibm.com>
 <60b3dd35-a802-ba93-c2c5-d6b2b3dd72ea@huawei.com>
 <20170224045311.GA15343@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <fc486de7-81ce-6953-3e56-90f45a2e5527@huawei.com>
Date: Mon, 27 Feb 2017 09:56:13 +0800
MIME-Version: 1.0
In-Reply-To: <20170224045311.GA15343@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dave.hansen@intel.com, "dan.j.williams@intel.com; jhubbard"@nvidia.com

On 2017/2/24 12:53, Jerome Glisse wrote:
> On Fri, Feb 24, 2017 at 09:06:19AM +0800, Bob Liu wrote:
>> On 2017/2/21 21:39, Anshuman Khandual wrote:
>>> On 02/21/2017 04:41 PM, Michal Hocko wrote:
>>>> On Fri 17-02-17 17:11:57, Anshuman Khandual wrote:
>>>> [...]
>>>>> * User space using mbind() to get CDM memory is an additional benefit
>>>>>   we get by making the CDM plug in as a node and be part of the buddy
>>>>>   allocator. But the over all idea from the user space point of view
>>>>>   is that the application can allocate any generic buffer and try to
>>>>>   use the buffer either from the CPU side or from the device without
>>>>>   knowing about where the buffer is really mapped physically. That
>>>>>   gives a seamless and transparent view to the user space where CPU
>>>>>   compute and possible device based compute can work together. This
>>>>>   is not possible through a driver allocated buffer.
>>>>
>>>> But how are you going to define any policy around that. Who is allowed
>>>
>>> The user space VMA can define the policy with a mbind(MPOL_BIND) call
>>> with CDM/CDMs in the nodemask.
>>>
>>>> to allocate and how much of this "special memory". Is it possible that
>>>
>>> Any user space application with mbind(MPOL_BIND) call with CDM/CDMs in
>>> the nodemask can allocate from the CDM memory. "How much" gets controlled
>>> by how we fault from CPU and the default behavior of the buddy allocator.
>>>
>>>> we will eventually need some access control mechanism? If yes then mbind
>>>
>>> No access control mechanism is needed. If an application wants to use
>>> CDM memory by specifying in the mbind() it can. Nothing prevents it
>>> from using the CDM memory.
>>>
>>>> is really not suitable interface to (ab)use. Also what should happen if
>>>> the mbind mentions only CDM memory and that is depleted?
>>>
>>> IIUC *only CDM* cannot be requested from user space as there are no user
>>> visible interface which can translate to __GFP_THISNODE. MPOL_BIND with
>>> CDM in the nodemask will eventually pick a FALLBACK zonelist which will
>>> have zones of the system including CDM ones. If the resultant CDM zones
>>> run out of memory, we fail the allocation request as usual.
>>>
>>>>
>>>> Could you also explain why the transparent view is really better than
>>>> using a device specific mmap (aka CDM awareness)?
>>>
>>> Okay with a transparent view, we can achieve a control flow of application
>>> like the following.
>>>
>>> (1) Allocate a buffer:		alloc_buffer(buf, size)
>>> (2) CPU compute on buffer:	cpu_compute(buf, size)
>>> (3) Device compute on buffer:	device_compute(buf, size)
>>> (4) CPU compute on buffer:	cpu_compute(buf, size)
>>> (5) Release the buffer:		release_buffer(buf, size)
>>>
>>> With assistance from a device specific driver, the actual page mapping of
>>> the buffer can change between system RAM and device memory depending on
>>> which side is accessing at a given point. This will be achieved through
>>> driver initiated migrations.
>>>
>>
>> Sorry, I'm a bit confused here.
>> What's the difference with the Heterogeneous memory management?
>> Which also "allows to use device memory transparently inside any process
>> without any modifications to process program code."
> 
> HMM is first and foremost for platform (like Intel) where CPU can not
> access device memory in cache coherent way or at all. CDM is for more
> advance platform with a system bus that allow the CPU to access device
> memory in cache coherent way.
> 
> Hence CDM was design to integrate more closely in existing concept like
> NUMA. From my point of view it is like another level in the memory
> hierarchy. Nowaday you have local node memory and other node memory.
> In not too distant future you will have fast CPU on die memory, local
> memory (you beloved DDR3/DDR4), slightly slower but gigantic persistant
> memory and also device memory (all those local to a node).
> 
> On top of that you will still have the regular NUMA hierarchy between
> nodes. But each node will have its own local hierarchy of memory.
> 
> CDM wants to integrate with existing memory hinting API and i believe
> this is needed to get some experience with how end user might want to
> use this to fine tune their application.
> 
> Some bit of HMM are generic and will be reuse by CDM, for instance the
> DMA capable memory migration helpers. Wether they can also share HMM
> approach of using ZONE_DEVICE is yet to be proven but it comes with
> limitations (can't be on lru or have device lru) that might hinder a
> closer integration of CDM memory with many aspect of kernel mm.
> 
> 
> This is my own view and it likely differ in some way from the view of
> the people behind CDM :)
> 

Got it, thank you for the kindly explanation.
And also thank you, John.

Regards,
Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
