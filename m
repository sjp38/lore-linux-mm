Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B39996B0292
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 22:38:33 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o77so2797708qke.1
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 19:38:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e32si8482911qtd.469.2017.09.04.19.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 19:38:32 -0700 (PDT)
Date: Mon, 4 Sep 2017 22:38:27 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
Message-ID: <20170905023826.GA4836@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-20-jglisse@redhat.com>
 <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com>
 <20170904155123.GA3161@redhat.com>
 <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>, ross.zwisler@linux.intel.com

On Tue, Sep 05, 2017 at 09:13:24AM +0800, Bob Liu wrote:
> On 2017/9/4 23:51, Jerome Glisse wrote:
> > On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
> >> On 2017/8/17 8:05, Jerome Glisse wrote:
> >>> Unlike unaddressable memory, coherent device memory has a real
> >>> resource associated with it on the system (as CPU can address
> >>> it). Add a new helper to hotplug such memory within the HMM
> >>> framework.
> >>>
> >>
> >> Got an new question, coherent device( e.g CCIX) memory are likely reported to OS 
> >> through ACPI and recognized as NUMA memory node.
> >> Then how can their memory be captured and managed by HMM framework?
> >>
> > 
> > Only platform that has such memory today is powerpc and it is not reported
> > as regular memory by the firmware hence why they need this helper.
> > 
> > I don't think anyone has defined anything yet for x86 and acpi. As this is
> 
> Not yet, but now the ACPI spec has Heterogeneous Memory Attribute
> Table (HMAT) table defined in ACPI 6.2.
> The HMAT can cover CPU-addressable memory types(though not non-cache
> coherent on-device memory).
> 
> Ross from Intel already done some work on this, see:
> https://lwn.net/Articles/724562/
> 
> arm64 supports APCI also, there is likely more this kind of device when CCIX
> is out (should be very soon if on schedule).

HMAT is not for the same thing, AFAIK HMAT is for deep "hierarchy" memory ie
when you have several kind of memory each with different characteristics:
  - HBM very fast (latency) and high bandwidth, non persistent, somewhat
    small (ie few giga bytes)
  - Persistent memory, slower (both latency and bandwidth) big (tera bytes)
  - DDR (good old memory) well characteristics are between HBM and persistent

So AFAICT this has nothing to do with what HMM is for, ie device memory. Note
that device memory can have a hierarchy of memory themself (HBM, GDDR and in
maybe even persistent memory).

> > memory on PCIE like interface then i don't expect it to be reported as NUMA
> > memory node but as io range like any regular PCIE resources. Device driver
> > through capabilities flags would then figure out if the link between the
> > device and CPU is CCIX capable if so it can use this helper to hotplug it
> > as device memory.
> > 
> 
> From my point of view,  Cache coherent device memory will popular soon and
> reported through ACPI/UEFI. Extending NUMA policy still sounds more reasonable
> to me.

Cache coherent device will be reported through standard mecanisms defined by
the bus standard they are using. To my knowledge all the standard are either
on top of PCIE or are similar to PCIE.

It is true that on many platform PCIE resource is manage/initialize by the
bios (UEFI) but it is platform specific. In some case we reprogram what the
bios pick.

So like i was saying i don't expect the BIOS/UEFI to report device memory as
regular memory. It will be reported as a regular PCIE resources and then the
device driver will be able to determine through some flags if the link between
the CPU(s) and the device is cache coherent or not. At that point the device
driver can use register it with HMM helper.


The whole NUMA discussion happen several time in the past i suggest looking
on mm list archive for them. But it was rule out for several reasons. Top of
my head:
  - people hate CPU less node and device memory is inherently CPU less
  - device driver want total control over memory and thus to be isolated from
    mm mecanism and doing all those special cases was not welcome
  - existing NUMA migration mecanism are ill suited for this memory as
    access by the device to the memory is unknown to core mm and there
    is no easy way to report it or track it (this kind of depends on the
    platform and hardware)

I am likely missing other big points.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
