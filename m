Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1544C28038C
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 21:14:20 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id b2so3091660iof.5
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 18:14:20 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id u37si1478057iou.242.2017.09.04.18.14.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Sep 2017 18:14:19 -0700 (PDT)
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-20-jglisse@redhat.com>
 <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com>
 <20170904155123.GA3161@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com>
Date: Tue, 5 Sep 2017 09:13:24 +0800
MIME-Version: 1.0
In-Reply-To: <20170904155123.GA3161@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>, ross.zwisler@linux.intel.com

On 2017/9/4 23:51, Jerome Glisse wrote:
> On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
>> On 2017/8/17 8:05, Jerome Glisse wrote:
>>> Unlike unaddressable memory, coherent device memory has a real
>>> resource associated with it on the system (as CPU can address
>>> it). Add a new helper to hotplug such memory within the HMM
>>> framework.
>>>
>>
>> Got an new question, coherent device( e.g CCIX) memory are likely reported to OS 
>> through ACPI and recognized as NUMA memory node.
>> Then how can their memory be captured and managed by HMM framework?
>>
> 
> Only platform that has such memory today is powerpc and it is not reported
> as regular memory by the firmware hence why they need this helper.
> 
> I don't think anyone has defined anything yet for x86 and acpi. As this is

Not yet, but now the ACPI spec has Heterogeneous Memory Attribute
Table (HMAT) table defined in ACPI 6.2.
The HMAT can cover CPU-addressable memory types(though not non-cache coherent on-device memory).

Ross from Intel already done some work on this, see:
https://lwn.net/Articles/724562/

arm64 supports APCI also, there is likely more this kind of device when CCIX is out
(should be very soon if on schedule).

> memory on PCIE like interface then i don't expect it to be reported as NUMA
> memory node but as io range like any regular PCIE resources. Device driver
> through capabilities flags would then figure out if the link between the
> device and CPU is CCIX capable if so it can use this helper to hotplug it
> as device memory.
> 

>From my point of view,  Cache coherent device memory will popular soon and reported through ACPI/UEFI.
Extending NUMA policy still sounds more reasonable to me.

--
Thanks,
Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
