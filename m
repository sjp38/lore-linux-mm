Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 907646B0080
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 03:03:07 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so173992obc.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 00:03:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350629202-9664-5-git-send-email-wency@cn.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com> <1350629202-9664-5-git-send-email-wency@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 03:02:46 -0400
Message-ID: <CAHGf_=qrSuA7LP8im7s4Qf+F+hpD=LVsmZgg4WJQh8B_3B+-=A@mail.gmail.com>
Subject: Re: [PATCH v3 4/9] clear the memory to store struct page
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com

On Fri, Oct 19, 2012 at 2:46 AM,  <wency@cn.fujitsu.com> wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> If sparse memory vmemmap is enabled, we can't free the memory to store
> struct page when a memory device is hotremoved, because we may store
> struct page in the memory to manage the memory which doesn't belong
> to this memory device. When we hotadded this memory device again, we
> will reuse this memory to store struct page, and struct page may
> contain some obsolete information, and we will get bad-page state:
>
> [   59.611278] init_memory_mapping: [mem 0x80000000-0x9fffffff]
> [   59.637836] Built 2 zonelists in Node order, mobility grouping on.  To=
tal pages: 547617
> [   59.638739] Policy zone: Normal
> [   59.650840] BUG: Bad page state in process bash  pfn:9b6dc
> [   59.651124] page:ffffea0002200020 count:0 mapcount:0 mapping:         =
 (null) index:0xfdfdfdfdfdfdfdfd
> [   59.651494] page flags: 0x2fdfdfdfd5df9fd(locked|referenced|uptodate|d=
irty|lru|active|slab|owner_priv_1|private|private_2|writeback|head|tail|swa=
pcache|reclaim|swapbacked|unevictable|uncached|compound_lock)
> [   59.653604] Modules linked in: netconsole acpiphp pci_hotplug acpi_mem=
hotplug loop kvm_amd kvm microcode tpm_tis tpm tpm_bios evdev psmouse serio=
_raw i2c_piix4 i2c_core parport_pc parport processor button thermal_sys ext=
3 jbd mbcache sg sr_mod cdrom ata_generic virtio_net ata_piix virtio_blk li=
bata virtio_pci virtio_ring virtio scsi_mod
> [   59.656998] Pid: 988, comm: bash Not tainted 3.6.0-rc7-guest #12
> [   59.657172] Call Trace:
> [   59.657275]  [<ffffffff810e9b30>] ? bad_page+0xb0/0x100
> [   59.657434]  [<ffffffff810ea4c3>] ? free_pages_prepare+0xb3/0x100
> [   59.657610]  [<ffffffff810ea668>] ? free_hot_cold_page+0x48/0x1a0
> [   59.657787]  [<ffffffff8112cc08>] ? online_pages_range+0x68/0xa0
> [   59.657961]  [<ffffffff8112cba0>] ? __online_page_increment_counters+0=
x10/0x10
> [   59.658162]  [<ffffffff81045561>] ? walk_system_ram_range+0x101/0x110
> [   59.658346]  [<ffffffff814c4f95>] ? online_pages+0x1a5/0x2b0
> [   59.658515]  [<ffffffff8135663d>] ? __memory_block_change_state+0x20d/=
0x270
> [   59.658710]  [<ffffffff81356756>] ? store_mem_state+0xb6/0xf0
> [   59.658878]  [<ffffffff8119e482>] ? sysfs_write_file+0xd2/0x160
> [   59.659052]  [<ffffffff8113769a>] ? vfs_write+0xaa/0x160
> [   59.659212]  [<ffffffff81137977>] ? sys_write+0x47/0x90
> [   59.659371]  [<ffffffff814e2f25>] ? async_page_fault+0x25/0x30
> [   59.659543]  [<ffffffff814ea239>] ? system_call_fastpath+0x16/0x1b
> [   59.659720] Disabling lock debugging due to kernel taint
>
> This patch clears the memory to store struct page to avoid unexpected err=
or.
>
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Reported-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
