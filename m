Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC73F280449
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 22:12:28 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v140so11965160oif.7
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 19:12:28 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id z1si919952oig.408.2017.09.06.19.12.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 19:12:27 -0700 (PDT)
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-20-jglisse@redhat.com>
 <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com>
 <20170904155123.GA3161@redhat.com>
 <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com>
 <20170905023826.GA4836@redhat.com> <20170905185414.GB24073@linux.intel.com>
 <0bc5047d-d27c-65b6-acab-921263e715c8@huawei.com>
 <20170906021216.GA23436@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <4f4a2196-228d-5d54-5386-72c3ffb1481b@huawei.com>
Date: Thu, 7 Sep 2017 10:06:41 +0800
MIME-Version: 1.0
In-Reply-To: <20170906021216.GA23436@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>

On 2017/9/6 10:12, Jerome Glisse wrote:
> On Wed, Sep 06, 2017 at 09:25:36AM +0800, Bob Liu wrote:
>> On 2017/9/6 2:54, Ross Zwisler wrote:
>>> On Mon, Sep 04, 2017 at 10:38:27PM -0400, Jerome Glisse wrote:
>>>> On Tue, Sep 05, 2017 at 09:13:24AM +0800, Bob Liu wrote:
>>>>> On 2017/9/4 23:51, Jerome Glisse wrote:
>>>>>> On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
>>>>>>> On 2017/8/17 8:05, Jerome Glisse wrote:
>>>>>>>> Unlike unaddressable memory, coherent device memory has a real
>>>>>>>> resource associated with it on the system (as CPU can address
>>>>>>>> it). Add a new helper to hotplug such memory within the HMM
>>>>>>>> framework.
>>>>>>>>
>>>>>>>
>>>>>>> Got an new question, coherent device( e.g CCIX) memory are likely reported to OS 
>>>>>>> through ACPI and recognized as NUMA memory node.
>>>>>>> Then how can their memory be captured and managed by HMM framework?
>>>>>>>
>>>>>>
>>>>>> Only platform that has such memory today is powerpc and it is not reported
>>>>>> as regular memory by the firmware hence why they need this helper.
>>>>>>
>>>>>> I don't think anyone has defined anything yet for x86 and acpi. As this is
>>>>>
>>>>> Not yet, but now the ACPI spec has Heterogeneous Memory Attribute
>>>>> Table (HMAT) table defined in ACPI 6.2.
>>>>> The HMAT can cover CPU-addressable memory types(though not non-cache
>>>>> coherent on-device memory).
>>>>>
>>>>> Ross from Intel already done some work on this, see:
>>>>> https://lwn.net/Articles/724562/
>>>>>
>>>>> arm64 supports APCI also, there is likely more this kind of device when CCIX
>>>>> is out (should be very soon if on schedule).
>>>>
>>>> HMAT is not for the same thing, AFAIK HMAT is for deep "hierarchy" memory ie
>>>> when you have several kind of memory each with different characteristics:
>>>>   - HBM very fast (latency) and high bandwidth, non persistent, somewhat
>>>>     small (ie few giga bytes)
>>>>   - Persistent memory, slower (both latency and bandwidth) big (tera bytes)
>>>>   - DDR (good old memory) well characteristics are between HBM and persistent
>>>>
>>>> So AFAICT this has nothing to do with what HMM is for, ie device memory. Note
>>>> that device memory can have a hierarchy of memory themself (HBM, GDDR and in
>>>> maybe even persistent memory).
>>>>
>>>>>> memory on PCIE like interface then i don't expect it to be reported as NUMA
>>>>>> memory node but as io range like any regular PCIE resources. Device driver
>>>>>> through capabilities flags would then figure out if the link between the
>>>>>> device and CPU is CCIX capable if so it can use this helper to hotplug it
>>>>>> as device memory.
>>>>>>
>>>>>
>>>>> From my point of view,  Cache coherent device memory will popular soon and
>>>>> reported through ACPI/UEFI. Extending NUMA policy still sounds more reasonable
>>>>> to me.
>>>>
>>>> Cache coherent device will be reported through standard mecanisms defined by
>>>> the bus standard they are using. To my knowledge all the standard are either
>>>> on top of PCIE or are similar to PCIE.
>>>>
>>>> It is true that on many platform PCIE resource is manage/initialize by the
>>>> bios (UEFI) but it is platform specific. In some case we reprogram what the
>>>> bios pick.
>>>>
>>>> So like i was saying i don't expect the BIOS/UEFI to report device memory as
>>>> regular memory. It will be reported as a regular PCIE resources and then the
>>>> device driver will be able to determine through some flags if the link between
>>>> the CPU(s) and the device is cache coherent or not. At that point the device
>>>> driver can use register it with HMM helper.
>>>>
>>>>
>>>> The whole NUMA discussion happen several time in the past i suggest looking
>>>> on mm list archive for them. But it was rule out for several reasons. Top of
>>>> my head:
>>>>   - people hate CPU less node and device memory is inherently CPU less
>>>
>>> With the introduction of the HMAT in ACPI 6.2 one of the things that was added
>>> was the ability to have an ACPI proximity domain that isn't associated with a
>>> CPU.  This can be seen in the changes in the text of the "Proximity Domain"
>>> field in table 5-73 which describes the "Memory Affinity Structure".  One of
>>> the major features of the HMAT was the separation of "Initiator" proximity
>>> domains (CPUs, devices that initiate memory transfers), and "target" proximity
>>> domains (memory regions, be they attached to a CPU or some other device).
>>>
>>> ACPI proximity domains map directly to Linux NUMA nodes, so I think we're
>>> already in a place where we have to support CPU-less NUMA nodes.
>>>
>>>>   - device driver want total control over memory and thus to be isolated from
>>>>     mm mecanism and doing all those special cases was not welcome
>>>
>>> I agree that the kernel doesn't have enough information to be able to
>>> accurately handle all the use cases for the various types of heterogeneous
>>> memory.   The goal of my HMAT enabling is to allow that memory to be reserved
>>> from kernel use via the "Reservation Hint" in the HMAT's Memory Subsystem
>>> Address Range Structure, then provide userspace with enough information to be
>>> able to distinguish between the various types of memory in the system so it
>>> can allocate & utilize it appropriately.
>>>
>>
>> Does this mean require an user space memory management library to deal with all
>> alloc/free/defragment.. But how to do with virtual <-> physical address mapping
>> from userspace?
> 
> For HMM each process give hint (somewhat similar to mbind) for range of virtual
> address to the device kernel driver (through some API like OpenCL or CUDA for GPU
> for instance). All this being device driver specific ioctl.
> 
> The kernel device driver have an overall view of all the process that use the device
> and each of the memory advise they gave. From that informations the kernel device
> driver decide what part of each process address space to migrate to device memory.

Oh, I mean CDM-HMM.  I'm fine with HMM.

> This obviously dynamic and likely to change over the process lifetime.
> 
> 
> My understanding is that HMAT want similar API to allow process to give direction on
> where each range of virtual address should be allocated. It is expected that most

Right, but not clear who should manage the physical memory allocation and setup the 
pagetable mapping. An new driver or the kernel?

> software can easily infer what part of its address will need more bandwidth, smaller
> latency versus what part is sparsely accessed ...
> 
> For HMAT i think first target is HBM and persistent memory and device memory might
> be added latter if that make sense.
> 

Okay, so there are two potential ways for CPU-addressable cache-coherent device memory
(or cpu-less numa memory or "target domain" memory in ACPI spec )?
1. CDM-HMM
2. HMAT

--
Regards,
Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
