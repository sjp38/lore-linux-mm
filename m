Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE86A6B0007
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 01:17:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f8-v6so982758eds.6
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 22:17:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n49-v6si562076edd.82.2018.07.08.22.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jul 2018 22:17:37 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w695E9RC022301
	for <linux-mm@kvack.org>; Mon, 9 Jul 2018 01:17:36 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k3y1x65ve-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:17:35 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 9 Jul 2018 01:17:35 -0400
Subject: Re: [RFC PATCH 2/2] mm/pmem: Add memblock based e820 platform driver
References: <20180706082911.13405-1-aneesh.kumar@linux.ibm.com>
 <20180706082911.13405-2-aneesh.kumar@linux.ibm.com>
 <CAPcyv4gjrsswcakSog7jxT+agH7NrBEvwxe9jT0ycU3RZV5sWA@mail.gmail.com>
 <CAOSf1CFuxga8BAbnvPdZvutgpAxmzgjiqxzHFuVTVLOkMwKO+A@mail.gmail.com>
 <CAPcyv4ihixEN9LV6TMqax3Qa2huiPnR-kFyhtO0H51GvGu2C2Q@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Mon, 9 Jul 2018 10:47:28 +0530
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ihixEN9LV6TMqax3Qa2huiPnR-kFyhtO0H51GvGu2C2Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <2581eec7-ad1e-578b-d0cd-7076a4f88776@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Oliver <oohall@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 07/07/2018 11:06 PM, Dan Williams wrote:
> On Sat, Jul 7, 2018 at 12:15 AM, Oliver <oohall@gmail.com> wrote:
>> On Sat, Jul 7, 2018 at 5:38 AM, Dan Williams <dan.j.williams@intel.com> wrote:
>>> On Fri, Jul 6, 2018 at 1:29 AM, Aneesh Kumar K.V
>>> <aneesh.kumar@linux.ibm.com> wrote:
>>>> This patch steal system RAM and use that to emulate pmem device using the
>>>> e820 platform driver.
>>>>
>>>> This adds a new kernel command line 'pmemmap' which takes the format <size[KMG]>
>>>> to allocate memory early in the boot. This memory is later registered as
>>>> persistent memory range.
>>>>
>>>> Based on original patch from Oliver OHalloran <oliveroh@au1.ibm.com>
>>>>
>>>> Not-Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>>>> ---
>>>>   drivers/nvdimm/Kconfig        |  13 ++++
>>>>   drivers/nvdimm/Makefile       |   1 +
>>>>   drivers/nvdimm/memblockpmem.c | 115 ++++++++++++++++++++++++++++++++++
>>>>   3 files changed, 129 insertions(+)
>>>>   create mode 100644 drivers/nvdimm/memblockpmem.c
>>>>
>>> [..]
>>>> +/*
>>>> + * pmemmap=ss[KMG]
>>>> + *
>>>> + * This is similar to the memremap=offset[KMG]!size[KMG] paramater
>>>> + * for adding a legacy pmem range to the e820 map on x86, but it's
>>>> + * platform agnostic.
>>
>>> The current memmap=ss!nn option is a non-stop source of bugs and
>>> fragility. The fact that this lets the kernel specify the base address
>>> helps, but then this is purely just a debug facility because
>>> memmap=ss!nn is there to cover platform firmware implementations that
>>> fail to mark a given address range as persistent.
>>
>>> If this is just for debug, why not use qemu?
>>
>> To make a long story short, we have two virtualisation stacks and only one of
>> them is based on qemu. An unfortunately large chunk of our customers (and
>> our internal test systems) run the other one so we need to accommodate them
>> somehow.
>>
>>> If this is not for debug what are these systems that don't have proper firmware
>>> support?
>>
>> I wrote the original version (for RHEL 7.something) for a customer who wanted
>> to do some testing which needed to be run on real hardware for some reason.
>> We couldn't install a FW update on their system so this ended up being the least
>> painful way to get them going. That's not a strong argument for
>> merging this, but
>> the point is that it's sometimes useful to have the capability in the kernel.
> 
> Ok, correct me if I'm wrong, but it seems to be purely about debug and
> emulation? If that's the case would it be acceptable to just add more
> capabilities to tools/testing/nvdimm/ for what you want to do? That
> has been our primary vehicle for testing libnvdimm.
> 

What we need is the ability to run with fsdax on hypervisor other than KVM.

-aneesh
