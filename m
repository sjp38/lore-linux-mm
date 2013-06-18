Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 847A16B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 22:04:05 -0400 (EDT)
Received: by mail-yh0-f46.google.com with SMTP id i57so1324730yha.5
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:04:04 -0700 (PDT)
Date: Mon, 17 Jun 2013 19:03:57 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
Message-ID: <20130618020357.GZ32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Thu, Jun 13, 2013 at 09:02:47PM +0800, Tang Chen wrote:
> One commit that tried to parse SRAT early get reverted before v3.9-rc1.
> 
> | commit e8d1955258091e4c92d5a975ebd7fd8a98f5d30f
> | Author: Tang Chen <tangchen@cn.fujitsu.com>
> | Date:   Fri Feb 22 16:33:44 2013 -0800
> |
> |    acpi, memory-hotplug: parse SRAT before memblock is ready
> 
> It broke several things, like acpi override and fall back path etc.
> 
> This patchset is clean implementation that will parse numa info early.
> 1. keep the acpi table initrd override working by split finding with copying.
>    finding is done at head_32.S and head64.c stage,
>         in head_32.S, initrd is accessed in 32bit flat mode with phys addr.
>         in head64.c, initrd is accessed via kernel low mapping address
>         with help of #PF set page table.
>    copying is done with early_ioremap just after memblock is setup.
> 2. keep fallback path working. numaq and ACPI and amd_nmua and dummy.
>    seperate initmem_init to two stages.
>    early_initmem_init will only extract numa info early into numa_meminfo.
>    initmem_init will keep slit and emulation handling.
> 3. keep other old code flow untouched like relocate_initrd and initmem_init.
>    early_initmem_init will take old init_mem_mapping position.
>    it call early_x86_numa_init and init_mem_mapping for every nodes.
>    For 64bit, we avoid having size limit on initrd, as relocate_initrd
>    is still after init_mem_mapping for all memory.
> 4. last patch will try to put page table on local node, so that memory
>    hotplug will be happy.
> 
> In short, early_initmem_init will parse numa info early and call
> init_mem_mapping to set page table for every nodes's mem.

So, can you please explain why you're doing the above?  What are you
trying to achieve in the end and why is this the best approach?  This
is all for memory hotplug, right?

I can understand the part where you're move NUMA discovery before
initializations which will get allocated permanent addresses in the
wrong nodes, but trying to do the same with memblock itself is making
the code extremely fragile.  It's nasty because there's nothing
apparent which seems to necessitate such ordering.  The ordering looks
rather arbitrary but changing the orders will subtly break memory
hotplug support, which is a really bad way to structure the code.

Can't you just move memblock arrays after NUMA init is complete?
That'd be a lot simpler and way more robust than the proposed changes,
no?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
