Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 9A31E6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 13:10:41 -0400 (EDT)
Received: by mail-bk0-f43.google.com with SMTP id jm2so1905073bkc.30
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 10:10:40 -0700 (PDT)
Date: Tue, 18 Jun 2013 19:10:36 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
Message-ID: <20130618171036.GD4553@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Thu, Jun 13, 2013 at 09:02:47PM +0800, Tang Chen wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> 
> No offence, just rebase and resend the patches from Yinghai to help
> to push this functionality faster.
> Also improve the comments in the patches' log.
> 
> 
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
> 
> could be found at:
>         git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git for-x86-mm
> 
> and it is based on today's Linus tree.
>

Has this patchset been tested on various numa configs?
I am using linux-next next-20130607 + part1 with qemu/kvm/seabios VMs. The kernel
boots successfully in many numa configs but while trying different memory sizes
for a 2 numa node VM, I noticed that booting does not complete in all cases
(bootup screen appears to hang but there is no output indicating an early panic)

node0   node1	 boots
1G 	1G	 yes
1G 	2G	 yes
1G 	0.5G	 yes
3G 	2.5G	 yes
3G 	3G 	 yes
4G 	0G	 yes
4G 	4G	 yes
1.5G	1G	 no
2G 	1G	 no
2G 	2G	 no
2.5G 	2G	 no
2.5G 	2.5G	 no

linux-next next-20130607 boots al of these configs fine.

Looks odd, perhaps I have something wrong in my setup or maybe there is a
seabios/qemu interaction with this patchset. I will update if I find something.

thanks,

- Vasilis


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
