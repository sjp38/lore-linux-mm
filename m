Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 193F02808AC
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 08:58:13 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c143so3594554wmd.1
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 05:58:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h63si2934856wme.168.2017.03.10.05.58.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 05:58:11 -0800 (PST)
Date: Fri, 10 Mar 2017 14:58:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: WTH is going on with memory hotplug sysf interface (was: Re: [RFC
 PATCH] mm, hotplug: get rid of auto_online_blocks)
Message-ID: <20170310135807.GI3753@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
 <1488462828-174523-1-git-send-email-imammedo@redhat.com>
 <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170309125400.GI11592@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

Let's CC people touching this logic. A short summary is that onlining
memory via udev is currently unusable for online_movable because blocks
are added from lower addresses while movable blocks are allowed from
last blocks. More below.

On Thu 09-03-17 13:54:00, Michal Hocko wrote:
> On Tue 07-03-17 13:40:04, Igor Mammedov wrote:
> > On Mon, 6 Mar 2017 15:54:17 +0100
> > Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > On Fri 03-03-17 18:34:22, Igor Mammedov wrote:
> [...]
> > > > in current mainline kernel it triggers following code path:
> > > > 
> > > > online_pages()
> > > >   ...
> > > >        if (online_type == MMOP_ONLINE_KERNEL) {                                 
> > > >                 if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))    
> > > >                         return -EINVAL;  
> > > 
> > > Are you sure? I would expect MMOP_ONLINE_MOVABLE here
> > pretty much, reproducer is above so try and see for yourself
> 
> I will play with this...

OK so I did with -m 2G,slots=4,maxmem=4G -numa node,mem=1G -numa node,mem=1G which generated
[...]
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00100000-0x3fffffff]
[    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x40000000-0x7fffffff]
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x27fffffff] hotplug
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0x3fffffff] -> [mem 0x00000000-0x3fffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x3fffc000-0x3fffffff]
[    0.000000] NODE_DATA(1) allocated [mem 0x7ffdc000-0x7ffdffff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007ffdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000003fffffff]
[    0.000000]   node   1: [mem 0x0000000040000000-0x000000007ffdffff]

so there is neither any normal zone nor movable one at the boot time.
Then I hotplugged 1G slot
(qemu) object_add memory-backend-ram,id=mem1,size=1G
(qemu) device_add pc-dimm,id=dimm1,memdev=mem1

unfortunatelly the memory didn't show up automatically and I got
[  116.375781] acpi PNP0C80:00: Enumeration failure

so I had to probe it manually (prbably the BIOS my qemu uses doesn't
support auto probing - I haven't really dug further). Anyway the SRAT
table printed during the boot told that we should start at 0x100000000

# echo 0x100000000 > /sys/devices/system/memory/probe
# grep . /sys/devices/system/memory/memory32/valid_zones
Normal Movable

which looks reasonably right? Both Normal and Movable zones are allowed

# echo $((0x100000000+(128<<20))) > /sys/devices/system/memory/probe
# grep . /sys/devices/system/memory/memory3?/valid_zones
/sys/devices/system/memory/memory32/valid_zones:Normal
/sys/devices/system/memory/memory33/valid_zones:Normal Movable

Huh, so our valid_zones have changed under our feet...

# echo $((0x100000000+2*(128<<20))) > /sys/devices/system/memory/probe
# grep . /sys/devices/system/memory/memory3?/valid_zones
/sys/devices/system/memory/memory32/valid_zones:Normal
/sys/devices/system/memory/memory33/valid_zones:Normal
/sys/devices/system/memory/memory34/valid_zones:Normal Movable

and again. So only the last memblock is considered movable. Let's try to
online them now.

# echo online_movable > /sys/devices/system/memory/memory34/state
# grep . /sys/devices/system/memory/memory3?/valid_zones
/sys/devices/system/memory/memory32/valid_zones:Normal
/sys/devices/system/memory/memory33/valid_zones:Normal Movable
/sys/devices/system/memory/memory34/valid_zones:Movable Normal

This would explain why onlining from the last block actually works but
to me this sounds like a completely crappy behavior. All we need to
guarantee AFAICS is that Normal and Movable zones do not overlap. I
believe there is even no real requirement about ordering of the physical
memory in Normal vs. Movable zones as long as they do not overlap. But
let's keep it simple for the start and always enforce the current status
quo that Normal zone is physically preceeding Movable zone.
Can somebody explain why we cannot have a simple rule for Normal vs.
Movable which would be:
	- block [pfn, pfn+block_size] can be Normal if
	  !zone_populated(MOVABLE) || pfn+block_size < ZONE_MOVABLE->zone_start_pfn
	- block [pfn, pfn+block_size] can be Movable if
	  !zone_populated(NORMAL) || ZONE_NORMAL->zone_end_pfn < pfn

I haven't fully grokked all the restrictions on the movable zone size
based on the kernel parameters (find_zone_movable_pfns_for_nodes) but
this shouldn't really make the situation really much more complicated I
believe because those parameters should be mostly about static
initialization rather than hotplug but I might be easily missing
something.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
