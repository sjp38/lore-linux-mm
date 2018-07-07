Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 925FB6B0003
	for <linux-mm@kvack.org>; Sat,  7 Jul 2018 13:36:18 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w204-v6so17398151oib.9
        for <linux-mm@kvack.org>; Sat, 07 Jul 2018 10:36:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i3-v6sor7483505oia.184.2018.07.07.10.36.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Jul 2018 10:36:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOSf1CFuxga8BAbnvPdZvutgpAxmzgjiqxzHFuVTVLOkMwKO+A@mail.gmail.com>
References: <20180706082911.13405-1-aneesh.kumar@linux.ibm.com>
 <20180706082911.13405-2-aneesh.kumar@linux.ibm.com> <CAPcyv4gjrsswcakSog7jxT+agH7NrBEvwxe9jT0ycU3RZV5sWA@mail.gmail.com>
 <CAOSf1CFuxga8BAbnvPdZvutgpAxmzgjiqxzHFuVTVLOkMwKO+A@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 7 Jul 2018 10:36:16 -0700
Message-ID: <CAPcyv4ihixEN9LV6TMqax3Qa2huiPnR-kFyhtO0H51GvGu2C2Q@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm/pmem: Add memblock based e820 platform driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver <oohall@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Jul 7, 2018 at 12:15 AM, Oliver <oohall@gmail.com> wrote:
> On Sat, Jul 7, 2018 at 5:38 AM, Dan Williams <dan.j.williams@intel.com> wrote:
>> On Fri, Jul 6, 2018 at 1:29 AM, Aneesh Kumar K.V
>> <aneesh.kumar@linux.ibm.com> wrote:
>>> This patch steal system RAM and use that to emulate pmem device using the
>>> e820 platform driver.
>>>
>>> This adds a new kernel command line 'pmemmap' which takes the format <size[KMG]>
>>> to allocate memory early in the boot. This memory is later registered as
>>> persistent memory range.
>>>
>>> Based on original patch from Oliver OHalloran <oliveroh@au1.ibm.com>
>>>
>>> Not-Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>>> ---
>>>  drivers/nvdimm/Kconfig        |  13 ++++
>>>  drivers/nvdimm/Makefile       |   1 +
>>>  drivers/nvdimm/memblockpmem.c | 115 ++++++++++++++++++++++++++++++++++
>>>  3 files changed, 129 insertions(+)
>>>  create mode 100644 drivers/nvdimm/memblockpmem.c
>>>
>> [..]
>>> +/*
>>> + * pmemmap=ss[KMG]
>>> + *
>>> + * This is similar to the memremap=offset[KMG]!size[KMG] paramater
>>> + * for adding a legacy pmem range to the e820 map on x86, but it's
>>> + * platform agnostic.
>
>> The current memmap=ss!nn option is a non-stop source of bugs and
>> fragility. The fact that this lets the kernel specify the base address
>> helps, but then this is purely just a debug facility because
>> memmap=ss!nn is there to cover platform firmware implementations that
>> fail to mark a given address range as persistent.
>
>> If this is just for debug, why not use qemu?
>
> To make a long story short, we have two virtualisation stacks and only one of
> them is based on qemu. An unfortunately large chunk of our customers (and
> our internal test systems) run the other one so we need to accommodate them
> somehow.
>
>> If this is not for debug what are these systems that don't have proper firmware
>> support?
>
> I wrote the original version (for RHEL 7.something) for a customer who wanted
> to do some testing which needed to be run on real hardware for some reason.
> We couldn't install a FW update on their system so this ended up being the least
> painful way to get them going. That's not a strong argument for
> merging this, but
> the point is that it's sometimes useful to have the capability in the kernel.

Ok, correct me if I'm wrong, but it seems to be purely about debug and
emulation? If that's the case would it be acceptable to just add more
capabilities to tools/testing/nvdimm/ for what you want to do? That
has been our primary vehicle for testing libnvdimm.
