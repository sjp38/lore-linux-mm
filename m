Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 0B0FA6B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 04:48:17 -0400 (EDT)
Message-ID: <50641427.3040103@cn.fujitsu.com>
Date: Thu, 27 Sep 2012 16:53:59 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v9 PATCH 00/21] memory-hotplug: hot-remove physical memory
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com> <20120926165820.GB7559@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20120926165820.GB7559@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

At 09/27/2012 12:58 AM, Vasilis Liaskovitis Wrote:
> Testing 3.6.0-rc7 with this v9 patchset plus more recent fixes [1],[2],[3]
> Running in a guest (qemu+seabios from [4]). 
> CONFIG_SLAB=y
> CONFIG_DEBUG_SLAB=y
> 
> - succesfull hot-add and online
> - succesfull hot-remove with SCI (qemu) eject
> - attempt to hot-readd same memory
> 
> When the pages are re-onlined on hot-readd, I get a bad_page state for many
> pages e.g.

I have reproduced this problem, and I investigate it now.

Thanks
Wen Congyang

> 
> [   59.611278] init_memory_mapping: [mem 0x80000000-0x9fffffff]
> [   59.637836] Built 2 zonelists in Node order, mobility grouping on.  Total pages: 547617
> [   59.638739] Policy zone: Normal
> [   59.650840] BUG: Bad page state in process bash  pfn:9b6dc
> [   59.651124] page:ffffea0002200020 count:0 mapcount:0 mapping:          (null) index:0xfdfdfdfdfdfdfdfd
> [   59.651494] page flags: 0x2fdfdfdfd5df9fd(locked|referenced|uptodate|dirty|lru|active|slab|owner_priv_1|private|private_2|writeback|head|tail|swapcache|reclaim|swapbacked|unevictable|uncached|compound_lock)
> [   59.653604] Modules linked in: netconsole acpiphp pci_hotplug acpi_memhotplug loop kvm_amd kvm microcode tpm_tis tpm tpm_bios evdev psmouse serio_raw i2c_piix4 i2c_core parport_pc parport processor button thermal_sys ext3 jbd mbcache sg sr_mod cdrom ata_generic virtio_net ata_piix virtio_blk libata virtio_pci virtio_ring virtio scsi_mod
> [   59.656998] Pid: 988, comm: bash Not tainted 3.6.0-rc7-guest #12
> [   59.657172] Call Trace:
> [   59.657275]  [<ffffffff810e9b30>] ? bad_page+0xb0/0x100
> [   59.657434]  [<ffffffff810ea4c3>] ? free_pages_prepare+0xb3/0x100
> [   59.657610]  [<ffffffff810ea668>] ? free_hot_cold_page+0x48/0x1a0
> [   59.657787]  [<ffffffff8112cc08>] ? online_pages_range+0x68/0xa0
> [   59.657961]  [<ffffffff8112cba0>] ? __online_page_increment_counters+0x10/0x10
> [   59.658162]  [<ffffffff81045561>] ? walk_system_ram_range+0x101/0x110
> [   59.658346]  [<ffffffff814c4f95>] ? online_pages+0x1a5/0x2b0
> [   59.658515]  [<ffffffff8135663d>] ? __memory_block_change_state+0x20d/0x270
> [   59.658710]  [<ffffffff81356756>] ? store_mem_state+0xb6/0xf0
> [   59.658878]  [<ffffffff8119e482>] ? sysfs_write_file+0xd2/0x160
> [   59.659052]  [<ffffffff8113769a>] ? vfs_write+0xaa/0x160
> [   59.659212]  [<ffffffff81137977>] ? sys_write+0x47/0x90
> [   59.659371]  [<ffffffff814e2f25>] ? async_page_fault+0x25/0x30
> [   59.659543]  [<ffffffff814ea239>] ? system_call_fastpath+0x16/0x1b
> [   59.659720] Disabling lock debugging due to kernel taint
> 
> Patch 20/21 deals with a similar scenario, but only for __PG_HWPOISON flag.
> Did i miss any other patch for this?
> 
> thanks,
> 
> - Vasilis
> 
> [1] https://lkml.org/lkml/2012/9/6/635
> [2] https://lkml.org/lkml/2012/9/11/542
> [3] https://lkml.org/lkml/2012/9/20/37
> [4] http://permalink.gmane.org/gmane.comp.emulators.kvm.devel/98691
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
