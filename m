Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2243E6B038B
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:11:07 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y51so45830653wry.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:11:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u16si981566wrc.200.2017.03.13.08.11.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 08:11:05 -0700 (PDT)
Date: Mon, 13 Mar 2017 16:11:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WTH is going on with memory hotplug sysf interface (was: Re:
 [RFC PATCH] mm, hotplug: get rid of auto_online_blocks)
Message-ID: <20170313151100.GS31518@dhcp22.suse.cz>
References: <1488462828-174523-1-git-send-email-imammedo@redhat.com>
 <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
 <20170310135807.GI3753@dhcp22.suse.cz>
 <20170310155333.GN3753@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170310155333.GN3753@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Andi Kleen <ak@linux.intel.com>

Let's add Andi

On Fri 10-03-17 16:53:33, Michal Hocko wrote:
> On Fri 10-03-17 14:58:07, Michal Hocko wrote:
> [...]
> > This would explain why onlining from the last block actually works but
> > to me this sounds like a completely crappy behavior. All we need to
> > guarantee AFAICS is that Normal and Movable zones do not overlap. I
> > believe there is even no real requirement about ordering of the physical
> > memory in Normal vs. Movable zones as long as they do not overlap. But
> > let's keep it simple for the start and always enforce the current status
> > quo that Normal zone is physically preceeding Movable zone.
> > Can somebody explain why we cannot have a simple rule for Normal vs.
> > Movable which would be:
> > 	- block [pfn, pfn+block_size] can be Normal if
> > 	  !zone_populated(MOVABLE) || pfn+block_size < ZONE_MOVABLE->zone_start_pfn
> > 	- block [pfn, pfn+block_size] can be Movable if
> > 	  !zone_populated(NORMAL) || ZONE_NORMAL->zone_end_pfn < pfn
> 
> OK, so while I was playing with this setup some more I probably got why
> this is done this way. All new memblocks are added to the zone Normal
> where they are accounted as spanned but not present. When we do
> online_movable we just cut from the end of the Normal zone and move it
> to Movable zone. This sounds really awkward. What was the reason to go
> this way? Why cannot we simply add those pages to the zone at the online
> time?

Answering to myself. So the reason seems to be 9d99aaa31f59 ("[PATCH]
x86_64: Support memory hotadd without sparsemem") which is no longer
true because 
config MEMORY_HOTPLUG
        bool "Allow for memory hot-add"
        depends on SPARSEMEM || X86_64_ACPI_NUMA
        depends on ARCH_ENABLE_MEMORY_HOTPLUG
        depends on COMPILE_TEST || !KASAN

so it is either SPARSEMEM or X86_64_ACPI_NUMA that would have to be enabled.
config X86_64_ACPI_NUMA
        def_bool y
        prompt "ACPI NUMA detection"
        depends on X86_64 && NUMA && ACPI && PCI
        select ACPI_NUMA

But I do not see any way how to enable anything but SPARSEMEM for x86_64
choice
        prompt "Memory model"
        depends on SELECT_MEMORY_MODEL
        default DISCONTIGMEM_MANUAL if ARCH_DISCONTIGMEM_DEFAULT
        default SPARSEMEM_MANUAL if ARCH_SPARSEMEM_DEFAULT
        default FLATMEM_MANUAL

ARCH_SPARSEMEM_DEFAULT is 32b only
config ARCH_DISCONTIGMEM_DEFAULT
        def_bool y
        depends on NUMA && X86_32

and ARCH_SPARSEMEM_DEFAULT is enabeld on 64b. So I guess whatever was
the reason to add this code back in 2006 is not true anymore. So I am
really wondering. Do we absolutely need to assign pages which are not
onlined yet to the ZONE_NORMAL unconditionally? Why cannot we put them
out of any zone and wait for memory online operation to put them where
requested?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
