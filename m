Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8CB6B04B6
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 23:52:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q76so4419566pfq.5
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 20:52:46 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id f15si6415033pln.287.2017.09.04.20.52.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Sep 2017 20:52:45 -0700 (PDT)
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-20-jglisse@redhat.com>
 <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com>
 <20170904155123.GA3161@redhat.com>
 <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com>
 <20170905023826.GA4836@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <c7997016-7932-649d-cf27-17caa33cd856@huawei.com>
Date: Tue, 5 Sep 2017 11:50:57 +0800
MIME-Version: 1.0
In-Reply-To: <20170905023826.GA4836@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>, ross.zwisler@linux.intel.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>

On 2017/9/5 10:38, Jerome Glisse wrote:
> On Tue, Sep 05, 2017 at 09:13:24AM +0800, Bob Liu wrote:
>> On 2017/9/4 23:51, Jerome Glisse wrote:
>>> On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
>>>> On 2017/8/17 8:05, Jerome Glisse wrote:
>>>>> Unlike unaddressable memory, coherent device memory has a real
>>>>> resource associated with it on the system (as CPU can address
>>>>> it). Add a new helper to hotplug such memory within the HMM
>>>>> framework.
>>>>>
>>>>
>>>> Got an new question, coherent device( e.g CCIX) memory are likely reported to OS 
>>>> through ACPI and recognized as NUMA memory node.
>>>> Then how can their memory be captured and managed by HMM framework?
>>>>
>>>
>>> Only platform that has such memory today is powerpc and it is not reported
>>> as regular memory by the firmware hence why they need this helper.
>>>
>>> I don't think anyone has defined anything yet for x86 and acpi. As this is
>>
>> Not yet, but now the ACPI spec has Heterogeneous Memory Attribute
>> Table (HMAT) table defined in ACPI 6.2.
>> The HMAT can cover CPU-addressable memory types(though not non-cache
>> coherent on-device memory).
>>
>> Ross from Intel already done some work on this, see:
>> https://lwn.net/Articles/724562/
>>
>> arm64 supports APCI also, there is likely more this kind of device when CCIX
>> is out (should be very soon if on schedule).
> 
> HMAT is not for the same thing, AFAIK HMAT is for deep "hierarchy" memory ie
> when you have several kind of memory each with different characteristics:
>   - HBM very fast (latency) and high bandwidth, non persistent, somewhat
>     small (ie few giga bytes)
>   - Persistent memory, slower (both latency and bandwidth) big (tera bytes)
>   - DDR (good old memory) well characteristics are between HBM and persistent
> 

Okay, then how the kernel handle the situation of "kind of memory each with different characteristics"?
Does someone have any suggestion?  I thought HMM can do this.
Numa policy/node distance is good but perhaps require a few extending, e.g a HBM node can't be
swap, can't accept DDR fallback allocation.

> So AFAICT this has nothing to do with what HMM is for, ie device memory. Note
> that device memory can have a hierarchy of memory themself (HBM, GDDR and in
> maybe even persistent memory).
> 

This looks like a subset of HMAT when CPU can address device memory directly in cache-coherent way.


>>> memory on PCIE like interface then i don't expect it to be reported as NUMA
>>> memory node but as io range like any regular PCIE resources. Device driver
>>> through capabilities flags would then figure out if the link between the
>>> device and CPU is CCIX capable if so it can use this helper to hotplug it
>>> as device memory.
>>>
>>
>> From my point of view,  Cache coherent device memory will popular soon and
>> reported through ACPI/UEFI. Extending NUMA policy still sounds more reasonable
>> to me.
> 
> Cache coherent device will be reported through standard mecanisms defined by
> the bus standard they are using. To my knowledge all the standard are either
> on top of PCIE or are similar to PCIE.
> 
> It is true that on many platform PCIE resource is manage/initialize by the
> bios (UEFI) but it is platform specific. In some case we reprogram what the
> bios pick.
> 
> So like i was saying i don't expect the BIOS/UEFI to report device memory as

But it's happening.
In my understanding, that's why HMAT was introduced.
For reporting device memory as regular memory(with different characteristics).

--
Regards,
Bob Liu

> regular memory. It will be reported as a regular PCIE resources and then the
> device driver will be able to determine through some flags if the link between
> the CPU(s) and the device is cache coherent or not. At that point the device
> driver can use register it with HMM helper.
> 
> 
> The whole NUMA discussion happen several time in the past i suggest looking
> on mm list archive for them. But it was rule out for several reasons. Top of
> my head:
>   - people hate CPU less node and device memory is inherently CPU less
>   - device driver want total control over memory and thus to be isolated from
>     mm mecanism and doing all those special cases was not welcome
>   - existing NUMA migration mecanism are ill suited for this memory as
>     access by the device to the memory is unknown to core mm and there
>     is no easy way to report it or track it (this kind of depends on the
>     platform and hardware)
> 
> I am likely missing other big points.
> 
> Cheers,
> Jerome
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
