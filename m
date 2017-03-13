Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5E386B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:19:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c143so12929529wmd.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 02:19:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f72si10111307wmh.18.2017.03.13.02.19.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 02:19:12 -0700 (PDT)
Date: Mon, 13 Mar 2017 10:19:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WTH is going on with memory hotplug sysf interface
Message-ID: <20170313091907.GF31518@dhcp22.suse.cz>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <75ee9d3f-7027-782a-9cde-5192396a4a8c@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Fri 10-03-17 12:39:27, Yasuaki Ishimatsu wrote:
> On 03/10/2017 08:58 AM, Michal Hocko wrote:
[...]
> >OK so I did with -m 2G,slots=4,maxmem=4G -numa node,mem=1G -numa node,mem=1G which generated
> >[...]
> >[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
> >[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00100000-0x3fffffff]
> >[    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x40000000-0x7fffffff]
> >[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x27fffffff] hotplug
> >[    0.000000] NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0x3fffffff] -> [mem 0x00000000-0x3fffffff]
> >[    0.000000] NODE_DATA(0) allocated [mem 0x3fffc000-0x3fffffff]
> >[    0.000000] NODE_DATA(1) allocated [mem 0x7ffdc000-0x7ffdffff]
> >[    0.000000] Zone ranges:
> >[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> >[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007ffdffff]
> >[    0.000000]   Normal   empty
> >[    0.000000] Movable zone start for each node
> >[    0.000000] Early memory node ranges
> >[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> >[    0.000000]   node   0: [mem 0x0000000000100000-0x000000003fffffff]
> >[    0.000000]   node   1: [mem 0x0000000040000000-0x000000007ffdffff]
> >
> >so there is neither any normal zone nor movable one at the boot time.
> >Then I hotplugged 1G slot
> >(qemu) object_add memory-backend-ram,id=mem1,size=1G
> >(qemu) device_add pc-dimm,id=dimm1,memdev=mem1
> >
> >unfortunatelly the memory didn't show up automatically and I got
> >[  116.375781] acpi PNP0C80:00: Enumeration failure
> >
> >so I had to probe it manually (prbably the BIOS my qemu uses doesn't
> >support auto probing - I haven't really dug further). Anyway the SRAT
> >table printed during the boot told that we should start at 0x100000000
> >
> ># echo 0x100000000 > /sys/devices/system/memory/probe
> ># grep . /sys/devices/system/memory/memory32/valid_zones
> >Normal Movable
> >
> >which looks reasonably right? Both Normal and Movable zones are allowed
> >
> ># echo $((0x100000000+(128<<20))) > /sys/devices/system/memory/probe
> ># grep . /sys/devices/system/memory/memory3?/valid_zones
> >/sys/devices/system/memory/memory32/valid_zones:Normal
> >/sys/devices/system/memory/memory33/valid_zones:Normal Movable
> >
> >Huh, so our valid_zones have changed under our feet...
> >
> ># echo $((0x100000000+2*(128<<20))) > /sys/devices/system/memory/probe
> ># grep . /sys/devices/system/memory/memory3?/valid_zones
> >/sys/devices/system/memory/memory32/valid_zones:Normal
> >/sys/devices/system/memory/memory33/valid_zones:Normal
> >/sys/devices/system/memory/memory34/valid_zones:Normal Movable
> >
> >and again. So only the last memblock is considered movable. Let's try to
> >online them now.
> >
> ># echo online_movable > /sys/devices/system/memory/memory34/state
> ># grep . /sys/devices/system/memory/memory3?/valid_zones
> >/sys/devices/system/memory/memory32/valid_zones:Normal
> >/sys/devices/system/memory/memory33/valid_zones:Normal Movable
> >/sys/devices/system/memory/memory34/valid_zones:Movable Normal
> >
> 
> I think there is no strong reason which kernel has the restriction.
> By setting the restrictions, it seems to have made management of
> these zone structs simple.

Could you be more specific please? How could this make management any
easier when udev is basically racing with the physical hotplug and the
result is basically undefined?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
