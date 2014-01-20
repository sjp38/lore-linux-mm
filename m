Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6906B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 10:14:18 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id cc10so3273033wib.17
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 07:14:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ib3si946589wjb.48.2014.01.20.07.14.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 07:14:17 -0800 (PST)
Date: Mon, 20 Jan 2014 15:14:09 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH RESEND part2 v2 1/8] x86: get pg_data_t's memory from
 other node
Message-ID: <20140120151409.GU4963@suse.de>
References: <529D3FC0.6000403@cn.fujitsu.com>
 <529D4048.9070000@cn.fujitsu.com>
 <20140116171112.GB24740@suse.de>
 <52DCD065.7040408@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52DCD065.7040408@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On Mon, Jan 20, 2014 at 03:29:41PM +0800, Tang Chen wrote:
> Hi Mel,
> 
> On 01/17/2014 01:11 AM, Mel Gorman wrote:
> >On Tue, Dec 03, 2013 at 10:22:00AM +0800, Zhang Yanfei wrote:
> >>From: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
> >>
> >>If system can create movable node which all memory of the node is allocated
> >>as ZONE_MOVABLE, setup_node_data() cannot allocate memory for the node's
> >>pg_data_t. So, invoke memblock_alloc_nid(...MAX_NUMNODES) again to retry when
> >>the first allocation fails. Otherwise, the system could failed to boot.
> >>(We don't use memblock_alloc_try_nid() to retry because in this function,
> >>if the allocation fails, it will panic the system.)
> >>
> >
> >This implies that it is possible to ahve a configuration with a big ratio
> >difference between Normal:Movable memory. In such configurations there
> >would be a risk that the system will reclaim heavily or go OOM because
> >the kernrel cannot allocate memory due to a relatively small Normal
> >zone. What protects against that? Is the user ever warned if the ratio
> >between Normal:Movable very high?
> 
> For now, there is no way protecting against this. But on a modern
> server, it won't be
> that easy running out of memory when booting, I think.
> 


Booting is a basic functional requirement and I'm more concerned about the
behaviour of the kernel when the machine is running.  If the kernel trashes
heavily or goes OOM when a workload starts then the fact the machine booted
is not much comfort.

> The current implementation will set any node the kernel resides in
> as unhotpluggable,
> which means normal zone here. And for nowadays server, especially
> memory hotplug server,
> each node would have at least 16GB memory, which is enough for the
> kernel to boot.
> 

Again, booting is fine but least say it's an 8-node machine then that
implies the Normal:Movable ratio will be 1:8. All page table pages, inode,
dentries etc will have to fit in that 1/8th of memory with all the associated
costs including remote access penalties.  In extreme cases it may not be
possible to use all of memory because the management structures cannot be
allocated. Users may want the option of adjusting what this ratio is so
they can unplug some memory while not completely sacrificing performance.

Minimally, the kernel should print a big fat warning if the ratio is equal
or more than 1:3 Normal:Movable. That ratio selection is arbitrary. I do not
recall ever seeing any major Normal:Highmem bugs on 4G 32-bit machines so it
is a conservative choice. The last Normal:Highmem bug I remember was related
to a 16G 32-bit machine (https://bugzilla.kernel.org/show_bug.cgi?id=42578)
a 1:15 ratio feels very optimistic for a very large machine.

> We can add a patch to make it return to the original path if we run
> out of memory,
> which means turn off the functionality and warn users in log.
> 
> How do you think ?
> 

I think that will allow the machine to boot but that there still will be a
large number of bugs filed with these machines due to high Normal:Movable
ratios. The shape of the bug reports will be similar to the Normal:Highmem
ratio bugs that existed years ago.

> > The movable_node boot parameter still
> >turns the feature on and off, there appears to be no way of controlling
> >the ratio of memory other than booting with the minimum amount of memory
> >and manually hot-adding the sections to set the appropriate ratio.
> 
> For now, yes. We expect firmware and hardware to give the basic
> ratio (how much memory
> is hotpluggable), and the user decides how to arrange the memory
> (decide the size of
> normal zone and movable zone).
> 

There seems to be big gaps in the configuration options here. The user
can either ask it to be automatically assigned and have no control of
the ratio or manually hot-add the memory which is a relatively heavy
administrative burden.

I think they should be warned if the ratio is high and have an option of
specifying a ratio manually even if that means that additional nodes
will not be hot-removable.

This is all still a kludge around the fact that node memory hot-remove
did not try and cope with full migration by breaking some of the 1:1
virt:phys mapping assumptions when hot-remove was enabled.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
