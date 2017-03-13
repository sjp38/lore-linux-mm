Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A50746B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 06:43:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d66so13233094wmi.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 03:43:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n26si10350915wmi.51.2017.03.13.03.43.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 03:43:07 -0700 (PDT)
Date: Mon, 13 Mar 2017 11:43:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WTH is going on with memory hotplug sysf interface (was: Re:
 [RFC PATCH] mm, hotplug: get rid of auto_online_blocks)
Message-ID: <20170313104302.GK31518@dhcp22.suse.cz>
References: <1488462828-174523-1-git-send-email-imammedo@redhat.com>
 <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
 <20170310135807.GI3753@dhcp22.suse.cz>
 <20170313113110.6a9636a1@nial.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313113110.6a9636a1@nial.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Mon 13-03-17 11:31:10, Igor Mammedov wrote:
> On Fri, 10 Mar 2017 14:58:07 +0100
[...]
> > [    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
> > [    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00100000-0x3fffffff]
> > [    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x40000000-0x7fffffff]
> > [    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x27fffffff] hotplug
> > [    0.000000] NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0x3fffffff] -> [mem 0x00000000-0x3fffffff]
> > [    0.000000] NODE_DATA(0) allocated [mem 0x3fffc000-0x3fffffff]
> > [    0.000000] NODE_DATA(1) allocated [mem 0x7ffdc000-0x7ffdffff]
> > [    0.000000] Zone ranges:
> > [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> > [    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007ffdffff]
> > [    0.000000]   Normal   empty
> > [    0.000000] Movable zone start for each node
> > [    0.000000] Early memory node ranges
> > [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> > [    0.000000]   node   0: [mem 0x0000000000100000-0x000000003fffffff]
> > [    0.000000]   node   1: [mem 0x0000000040000000-0x000000007ffdffff]
> > 
> > so there is neither any normal zone nor movable one at the boot time.
> it could be if hotpluggable memory were present at boot time in E802 table
> (if I remember right when running on hyperv there is movable zone at boot time),
> 
> but in qemu hotpluggable memory isn't put into E820,
> so zone is allocated later when memory is enumerated
> by ACPI subsystem and onlined.
> It causes less issues wrt movable zone and works for
> different versions of linux/windows as well.
> 
> That's where in kernel auto-onlining could be also useful,
> since user would be able to start-up with with small
> non removable memory plus several removable DIMMs
> and have all the memory onlined/available by the time
> initrd is loaded. (missing piece here is onling
> removable memory as movable by default).

Why we should even care to online that memory that early rather than
making it available via e820?
 
> > Then I hotplugged 1G slot
> > (qemu) object_add memory-backend-ram,id=mem1,size=1G
> > (qemu) device_add pc-dimm,id=dimm1,memdev=mem1
> You can also specify node a pc-dimm goes to with 'node' property
> if it should go to other then node 0.
> 
> device_add pc-dimm,id=dimm1,memdev=mem1,node=1

thanks for the tip

> > unfortunatelly the memory didn't show up automatically and I got
> > [  116.375781] acpi PNP0C80:00: Enumeration failure
> it should work,
> do you have CONFIG_ACPI_HOTPLUG_MEMORY enabled?

No I didn't. Thanks, good to know!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
