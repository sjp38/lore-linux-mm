Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52A386B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 06:31:20 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g57so34940230qta.5
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 03:31:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g9si84526qte.112.2017.03.13.03.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 03:31:19 -0700 (PDT)
Date: Mon, 13 Mar 2017 11:31:10 +0100
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: WTH is going on with memory hotplug sysf interface (was: Re:
 [RFC PATCH] mm, hotplug: get rid of auto_online_blocks)
Message-ID: <20170313113110.6a9636a1@nial.brq.redhat.com>
In-Reply-To: <20170310135807.GI3753@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
	<1488462828-174523-1-git-send-email-imammedo@redhat.com>
	<20170302142816.GK1404@dhcp22.suse.cz>
	<20170302180315.78975d4b@nial.brq.redhat.com>
	<20170303082723.GB31499@dhcp22.suse.cz>
	<20170303183422.6358ee8f@nial.brq.redhat.com>
	<20170306145417.GG27953@dhcp22.suse.cz>
	<20170307134004.58343e14@nial.brq.redhat.com>
	<20170309125400.GI11592@dhcp22.suse.cz>
	<20170310135807.GI3753@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y.
 Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Fri, 10 Mar 2017 14:58:07 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> Let's CC people touching this logic. A short summary is that onlining
> memory via udev is currently unusable for online_movable because blocks
> are added from lower addresses while movable blocks are allowed from
> last blocks. More below.
> 
> On Thu 09-03-17 13:54:00, Michal Hocko wrote:
> > On Tue 07-03-17 13:40:04, Igor Mammedov wrote:  
> > > On Mon, 6 Mar 2017 15:54:17 +0100
> > > Michal Hocko <mhocko@kernel.org> wrote:
> > >   
> > > > On Fri 03-03-17 18:34:22, Igor Mammedov wrote:  
> > [...]  
> > > > > in current mainline kernel it triggers following code path:
> > > > > 
> > > > > online_pages()
> > > > >   ...
> > > > >        if (online_type == MMOP_ONLINE_KERNEL) {                                 
> > > > >                 if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))    
> > > > >                         return -EINVAL;    
> > > > 
> > > > Are you sure? I would expect MMOP_ONLINE_MOVABLE here  
> > > pretty much, reproducer is above so try and see for yourself  
> > 
> > I will play with this...  
> 
> OK so I did with -m 2G,slots=4,maxmem=4G -numa node,mem=1G -numa node,mem=1G which generated
'mem' here distributes boot memory specified by "-m 2G" and does not
include memory specified by -device pc-dimm.

> [...]
> [    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
> [    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00100000-0x3fffffff]
> [    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x40000000-0x7fffffff]
> [    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x27fffffff] hotplug
> [    0.000000] NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0x3fffffff] -> [mem 0x00000000-0x3fffffff]
> [    0.000000] NODE_DATA(0) allocated [mem 0x3fffc000-0x3fffffff]
> [    0.000000] NODE_DATA(1) allocated [mem 0x7ffdc000-0x7ffdffff]
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007ffdffff]
> [    0.000000]   Normal   empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x000000003fffffff]
> [    0.000000]   node   1: [mem 0x0000000040000000-0x000000007ffdffff]
> 
> so there is neither any normal zone nor movable one at the boot time.
it could be if hotpluggable memory were present at boot time in E802 table
(if I remember right when running on hyperv there is movable zone at boot time),

but in qemu hotpluggable memory isn't put into E820,
so zone is allocated later when memory is enumerated
by ACPI subsystem and onlined.
It causes less issues wrt movable zone and works for
different versions of linux/windows as well.

That's where in kernel auto-onlining could be also useful,
since user would be able to start-up with with small
non removable memory plus several removable DIMMs
and have all the memory onlined/available by the time
initrd is loaded. (missing piece here is onling
removable memory as movable by default).


> Then I hotplugged 1G slot
> (qemu) object_add memory-backend-ram,id=mem1,size=1G
> (qemu) device_add pc-dimm,id=dimm1,memdev=mem1
You can also specify node a pc-dimm goes to with 'node' property
if it should go to other then node 0.

device_add pc-dimm,id=dimm1,memdev=mem1,node=1


> unfortunatelly the memory didn't show up automatically and I got
> [  116.375781] acpi PNP0C80:00: Enumeration failure
it should work,
do you have CONFIG_ACPI_HOTPLUG_MEMORY enabled?
 
> so I had to probe it manually (prbably the BIOS my qemu uses doesn't
> support auto probing - I haven't really dug further). Anyway the SRAT
> table printed during the boot told that we should start at 0x100000000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
