Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3F1A6B0325
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 22:02:41 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id r20so1919739oie.0
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 19:02:41 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id 124si482617oig.274.2017.09.07.19.02.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Sep 2017 19:02:40 -0700 (PDT)
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170904155123.GA3161@redhat.com>
 <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com>
 <20170905023826.GA4836@redhat.com> <20170905185414.GB24073@linux.intel.com>
 <0bc5047d-d27c-65b6-acab-921263e715c8@huawei.com>
 <20170906021216.GA23436@redhat.com>
 <4f4a2196-228d-5d54-5386-72c3ffb1481b@huawei.com>
 <1726639990.10465990.1504805251676.JavaMail.zimbra@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <863afc77-ed84-fed5-ebb8-d88e636816a3@huawei.com>
Date: Fri, 8 Sep 2017 09:59:15 +0800
MIME-Version: 1.0
In-Reply-To: <1726639990.10465990.1504805251676.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>

On 2017/9/8 1:27, Jerome Glisse wrote:
>> On 2017/9/6 10:12, Jerome Glisse wrote:
>>> On Wed, Sep 06, 2017 at 09:25:36AM +0800, Bob Liu wrote:
>>>> On 2017/9/6 2:54, Ross Zwisler wrote:
>>>>> On Mon, Sep 04, 2017 at 10:38:27PM -0400, Jerome Glisse wrote:
>>>>>> On Tue, Sep 05, 2017 at 09:13:24AM +0800, Bob Liu wrote:
>>>>>>> On 2017/9/4 23:51, Jerome Glisse wrote:
>>>>>>>> On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
>>>>>>>>> On 2017/8/17 8:05, JA(C)rA'me Glisse wrote:
> 
> [...]
> 
>>> For HMM each process give hint (somewhat similar to mbind) for range of
>>> virtual address to the device kernel driver (through some API like OpenCL
>>> or CUDA for GPU for instance). All this being device driver specific ioctl.
>>>
>>> The kernel device driver have an overall view of all the process that use
>>> the device and each of the memory advise they gave. From that informations
>>> the kernel device driver decide what part of each process address space to
>>> migrate to device memory.
>>
>> Oh, I mean CDM-HMM.  I'm fine with HMM.
> 
> They are one and the same really. In both cases HMM is just a set of helpers
> for device driver.
> 
>>> This obviously dynamic and likely to change over the process lifetime.
>>>
>>> My understanding is that HMAT want similar API to allow process to give
>>> direction on
>>> where each range of virtual address should be allocated. It is expected
>>> that most
>>
>> Right, but not clear who should manage the physical memory allocation and
>> setup the pagetable mapping. An new driver or the kernel?
> 
> Physical device memory is manage by the kernel device driver as it is today
> and has it will be tomorrow. HMM does not change that, nor does it requires
> any change to that.
> 

Can someone from Intel give more information about the plan of managing HMAT reported memory?

> Migrating process memory to or from device is done by the kernel through
> the regular page migration. HMM provides new helper for device driver to
> initiate such migration. There is no mechanisms like auto numa migration
> for the reasons i explain previously.
> 
> Kernel device driver use all knowledge it has to decide what to migrate to
> device memory. Nothing new here either, it is what happens today for special
> allocated device object and it will just happen all the same for regular
> mmap memory (private anonymous or mmap of a regular file of a filesystem).
> 
> 
> So every low level thing happen in the kernel. Userspace only provides
> directive to the kernel device driver through device specific API. But the
> kernel device driver can ignore or override those directive.
> 
> 
>>> software can easily infer what part of its address will need more
>>> bandwidth, smaller
>>> latency versus what part is sparsely accessed ...
>>>
>>> For HMAT i think first target is HBM and persistent memory and device
>>> memory might
>>> be added latter if that make sense.
>>>
>>
>> Okay, so there are two potential ways for CPU-addressable cache-coherent
>> device memory
>> (or cpu-less numa memory or "target domain" memory in ACPI spec )?
>> 1. CDM-HMM
>> 2. HMAT
> 
> No this are 2 orthogonal thing, they do not conflict with each others quite
> the contrary. HMM (the CDM part is no different) is a set of helpers, see
> it as a toolbox, for device driver.
> 
> HMAT is a way for firmware to report memory resources with more informations
> that just range of physical address. HMAT is specific to platform that rely
> on ACPI. HMAT does not provide any helpers to manage these memory.
> 
> So a device driver can get informations about device memory from HMAT and then
> use HMM to help in managing and using this memory.
> 

Yes, but as Balbir mentioned requires :
1. Don't online the memory as a NUMA node
2. Use the HMM-CDM API's to map the memory to ZONE DEVICE via the driver

And I'm not sure whether Intel going to use this HMM-CDM based method for their "target domain" memory ? 
Or they prefer to NUMA approach?   Rossi 1/4 ? Dan?

--
Thanks,
Bob Liu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
