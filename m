Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id BB45E6B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 04:40:21 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so5969525wgh.3
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 01:40:21 -0700 (PDT)
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
        by mx.google.com with ESMTPS id ud8si10058502wib.66.2014.08.19.01.40.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 Aug 2014 01:40:20 -0700 (PDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so6030969wgh.35
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 01:40:19 -0700 (PDT)
Message-ID: <53F30D71.9010107@plexistor.com>
Date: Tue, 19 Aug 2014 11:40:17 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 9/9] prd: Add support for page struct mapping
References: <53EB5536.8020702@gmail.com> <53EB5960.50200@plexistor.com>	 <1408134524.26567.38.camel@misato.fc.hp.com> <53F07342.30006@gmail.com> <1408391280.26567.79.camel@misato.fc.hp.com>
In-Reply-To: <1408391280.26567.79.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Boaz Harrosh <openosd@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Yigal Korman <yigal@plexistor.com>

On 08/18/2014 10:48 PM, Toshi Kani wrote:
> On Sun, 2014-08-17 at 12:17 +0300, Boaz Harrosh wrote:
<>
>> "System RAM" it is not. 
> 
> I think add_memory() can be easily extended (or modified to provide a
> separate interface) for persistent memory, and avoid creating the sysfs
> interface and change the handling with firmware_map.  But I can also see
> your point that persistent memory should not be added to zone at all.
> 

Right

> Anyway, I am a bit concerned with the way to create direct mappings with
> map_vm_area() within the prd driver.  Can we use init_memory_mapping()
> as it's used by add_memory() and supports large page size?  The size of
> persistent memory will grow up quickly.

A bit about large page size. The principal reason of my effort here is
that at some stage I need to send pmem blocks to block-layer or network.

The PAGE == 4K is pasted all over the block stack. Do you know how those
can work together? will we need some kind of page_split thing how does
that work?

> Also, I'd prefer to have an mm
> interface that takes care of page allocations and mappings, and avoid a
> driver to deal with them.
> 

This is a great idea you mean that I define:
+	int mm_add_page_mapping(phys_addr_t phys_addr, size_t total_size,
+				void **o_virt_addr)

At the mm level. OK It needs a much better name.

I know of 2 more drivers that will need the use of the same interface
actually, so you are absolutely right. I didn't dare ask ;-)

>> And also I think that for DDR4 NvDIMMs we will fail with:
>> 	ret = check_hotplug_memory_range(start, size);
>>
> 
> Can you elaborate why DDR4 will fail with the function above?
> 

I'm not at all familiar with the details, perhaps the Intel
guys that knows better can chip in, but from the little I
understood: Today with DDR3 these chips come up at the e820
controller, as type 12 memory and, each vendor has a driver
to drive proprietary enablement and persistence.
With DDR4 it will all be standardized, but it will not come
up through the e820 manager, but as a separate device on the
SMBus/ACPI.
So it is not clear to me that we want to plug this back into
the ARCH's memory controllers. check_hotplug_memory_range is
it per ARCH?

> Thanks,
> -Toshi
> 
> 

I will produce a new Patchset that introduces a new API
for drivers. And I will try to see about the use of
init_memory_mapping(), as long as it is not using
zones.

Do you think that the new code should sit in?
	mm/memory_hotplug.c

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
