Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7BCAA6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 06:08:50 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id cc10so4032544wib.4
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 03:08:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k18si8482289wie.2.2014.02.11.03.08.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 03:08:48 -0800 (PST)
Date: Tue, 11 Feb 2014 11:08:42 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH RESEND part2 v2 1/8] x86: get pg_data_t's memory from
 other node
Message-ID: <20140211110842.GI6732@suse.de>
References: <529D3FC0.6000403@cn.fujitsu.com>
 <529D4048.9070000@cn.fujitsu.com>
 <20140116171112.GB24740@suse.de>
 <52DCD065.7040408@cn.fujitsu.com>
 <20140120151409.GU4963@suse.de>
 <20140206101230.GA21345@suse.de>
 <52F86745.2060204@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52F86745.2060204@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On Mon, Feb 10, 2014 at 01:44:37PM +0800, Tang Chen wrote:
> Hi Mel,
> 
> On 02/06/2014 06:12 PM, Mel Gorman wrote:
> >Any comment on this or are the issues just going to be waved away?
> 
> Sorry for the delay.
> 
> >
> ......
> >>Again, booting is fine but least say it's an 8-node machine then that
> >>implies the Normal:Movable ratio will be 1:8. All page table pages, inode,
> >>dentries etc will have to fit in that 1/8th of memory with all the associated
> >>costs including remote access penalties.  In extreme cases it may not be
> >>possible to use all of memory because the management structures cannot be
> >>allocated. Users may want the option of adjusting what this ratio is so
> >>they can unplug some memory while not completely sacrificing performance.
> >>
> >>Minimally, the kernel should print a big fat warning if the ratio is equal
> >>or more than 1:3 Normal:Movable. That ratio selection is arbitrary. I do not
> >>recall ever seeing any major Normal:Highmem bugs on 4G 32-bit machines so it
> >>is a conservative choice. The last Normal:Highmem bug I remember was related
> >>to a 16G 32-bit machine (https://bugzilla.kernel.org/show_bug.cgi?id=42578)
> >>a 1:15 ratio feels very optimistic for a very large machine.
> ......
> >>>
> >>>For now, yes. We expect firmware and hardware to give the basic
> >>>ratio (how much memory
> >>>is hotpluggable), and the user decides how to arrange the memory
> >>>(decide the size of
> >>>normal zone and movable zone).
> >>>
> >>
> >>There seems to be big gaps in the configuration options here. The user
> >>can either ask it to be automatically assigned and have no control of
> >>the ratio or manually hot-add the memory which is a relatively heavy
> >>administrative burden.
> 
> Yes.
> 
> 1. Automatically assigning is done by movable_node boot option,
> which is the
>    main work of this patch-set. It depends on SRAT (firmware).
> 

I know but I'm concerned that this means that the firmware can request a
setup with an insane Normal:Movable ratio.

> 2. Manually assigning has been done since 2012, by the following patch-set.
> 
>    https://lkml.org/lkml/2012/8/6//113
> 
>    This patch-set allowed users to online memory as normal or
> movable. But it
>    is not that easy to use. So, I also think an user space tool is needed.
>    And I'm planing to do this recently.
> 

Ok.

> >>
> >>I think they should be warned if the ratio is high and have an option of
> >>specifying a ratio manually even if that means that additional nodes
> >>will not be hot-removable.
> 
> I think this is easy to do, provide an option for users to specify a
> Normal:Movable ratio. This is not phys addr, and it is easy to use.
> 

Yes. It would even be some help if the parameter forced some NUMA nodes
to be Normal instead of Movable regardless of what SRAT says. There
still would be an administrative burden in discovering what nodes are
now pluggable but they must have been dealing with this already.

> >>
> >>This is all still a kludge around the fact that node memory hot-remove
> >>did not try and cope with full migration by breaking some of the 1:1
> >>virt:phys mapping assumptions when hot-remove was enabled.
> 
> I also said before, the implementation now can only be a temporary
> solution for memory hotplug since it would take us a lot of time to
> deal with 1:1 mapping thing.
> 
> But about "breaking some of the 1:1 mapping", would you please give me
> any hint of it ?  I want to do it too, but I cannot see where to start.
> 

Some hints on how it might be tackled were given back in November 2012
https://lkml.org/lkml/2012/11/29/190 but I never researched it in
detail.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
