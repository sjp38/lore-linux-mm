Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66B246B0038
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:06:03 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f191so245449576qka.7
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:06:03 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id n51si3302930qtb.182.2017.03.14.09.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 09:06:02 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id n37so10526115qtb.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:06:01 -0700 (PDT)
Subject: Re: WTH is going on with memory hotplug sysf interface
References: <1488462828-174523-1-git-send-email-imammedo@redhat.com>
 <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
 <20170310135807.GI3753@dhcp22.suse.cz>
 <75ee9d3f-7027-782a-9cde-5192396a4a8c@gmail.com>
 <20170313091907.GF31518@dhcp22.suse.cz>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <99f14975-f89f-4484-6ae1-296b242d4bf9@gmail.com>
Date: Tue, 14 Mar 2017 12:05:59 -0400
MIME-Version: 1.0
In-Reply-To: <20170313091907.GF31518@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Reza Arbab <arbab@linux.vnet.ibm.com>, yasu.isimatu@gmail.com



On 03/13/2017 05:19 AM, Michal Hocko wrote:
> On Fri 10-03-17 12:39:27, Yasuaki Ishimatsu wrote:
>> On 03/10/2017 08:58 AM, Michal Hocko wrote:
> [...]
>>> OK so I did with -m 2G,slots=4,maxmem=4G -numa node,mem=1G -numa node,mem=1G which generated
>>> [...]
>>> [    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
>>> [    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00100000-0x3fffffff]
>>> [    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x40000000-0x7fffffff]
>>> [    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x27fffffff] hotplug
>>> [    0.000000] NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0x3fffffff] -> [mem 0x00000000-0x3fffffff]
>>> [    0.000000] NODE_DATA(0) allocated [mem 0x3fffc000-0x3fffffff]
>>> [    0.000000] NODE_DATA(1) allocated [mem 0x7ffdc000-0x7ffdffff]
>>> [    0.000000] Zone ranges:
>>> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
>>> [    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007ffdffff]
>>> [    0.000000]   Normal   empty
>>> [    0.000000] Movable zone start for each node
>>> [    0.000000] Early memory node ranges
>>> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
>>> [    0.000000]   node   0: [mem 0x0000000000100000-0x000000003fffffff]
>>> [    0.000000]   node   1: [mem 0x0000000040000000-0x000000007ffdffff]
>>>
>>> so there is neither any normal zone nor movable one at the boot time.
>>> Then I hotplugged 1G slot
>>> (qemu) object_add memory-backend-ram,id=mem1,size=1G
>>> (qemu) device_add pc-dimm,id=dimm1,memdev=mem1
>>>
>>> unfortunatelly the memory didn't show up automatically and I got
>>> [  116.375781] acpi PNP0C80:00: Enumeration failure
>>>
>>> so I had to probe it manually (prbably the BIOS my qemu uses doesn't
>>> support auto probing - I haven't really dug further). Anyway the SRAT
>>> table printed during the boot told that we should start at 0x100000000
>>>
>>> # echo 0x100000000 > /sys/devices/system/memory/probe
>>> # grep . /sys/devices/system/memory/memory32/valid_zones
>>> Normal Movable
>>>
>>> which looks reasonably right? Both Normal and Movable zones are allowed
>>>
>>> # echo $((0x100000000+(128<<20))) > /sys/devices/system/memory/probe
>>> # grep . /sys/devices/system/memory/memory3?/valid_zones
>>> /sys/devices/system/memory/memory32/valid_zones:Normal
>>> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
>>>
>>> Huh, so our valid_zones have changed under our feet...
>>>
>>> # echo $((0x100000000+2*(128<<20))) > /sys/devices/system/memory/probe
>>> # grep . /sys/devices/system/memory/memory3?/valid_zones
>>> /sys/devices/system/memory/memory32/valid_zones:Normal
>>> /sys/devices/system/memory/memory33/valid_zones:Normal
>>> /sys/devices/system/memory/memory34/valid_zones:Normal Movable
>>>
>>> and again. So only the last memblock is considered movable. Let's try to
>>> online them now.
>>>
>>> # echo online_movable > /sys/devices/system/memory/memory34/state
>>> # grep . /sys/devices/system/memory/memory3?/valid_zones
>>> /sys/devices/system/memory/memory32/valid_zones:Normal
>>> /sys/devices/system/memory/memory33/valid_zones:Normal Movable
>>> /sys/devices/system/memory/memory34/valid_zones:Movable Normal
>>>
>>
>> I think there is no strong reason which kernel has the restriction.
>> By setting the restrictions, it seems to have made management of
>> these zone structs simple.
>
> Could you be more specific please? How could this make management any
> easier when udev is basically racing with the physical hotplug and the
> result is basically undefined?
>

When changing zone from NORMAL(N) to MOVALBE(M), we must resize both zones,
zone->zone_start_pfn and zone->spanned_pages. Currently there is the
restriction.

So we just simply change:
   zone(N)->spanned_pages -= nr_pages
   zone(M)->zone_start_pfn -= nr_pages

But if every memory can change zone with no restriction, we must recalculate
these zones spanned_pages and zone_start_pfn follows:

   memory section #
    1 2 3 4 5 6 7
   |N|M|N|N|N|M|M|
      |
   |N|N|N|N|N|M|M|
  * change memory section #2 from MOVABLE to NORMAL.
    then we must find next movable memory section (#6) and resize these zones.

I think when implementing movable memory, there is no requirement of this.
So kernel has the current restriction.

Thanks,
Yasuaki Ishimatsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
