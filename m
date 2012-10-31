Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id B52686B0070
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 07:48:23 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 6/8] clear the memory to store struct page
Date: Wed, 31 Oct 2012 19:23:12 +0800
Message-Id: <1351682594-17347-7-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com>
References: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rjw@sisk.pl, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>

If sparse memory vmemmap is enabled, we can't free the memory to store
struct page when a memory device is hotremoved, because we may store
struct page in the memory to manage the memory which doesn't belong
to this memory device. When we hotadded this memory device again, we
will reuse this memory to store struct page, and struct page may
contain some obsolete information, and we will get bad-page state:

[   59.611278] init_memory_mapping: [mem 0x80000000-0x9fffffff]
[   59.637836] Built 2 zonelists in Node order, mobility grouping on.  Total pages: 547617
[   59.638739] Policy zone: Normal
[   59.650840] BUG: Bad page state in process bash  pfn:9b6dc
[   59.651124] page:ffffea0002200020 count:0 mapcount:0 mapping:          (null) index:0xfdfdfdfdfdfdfdfd
[   59.651494] page flags: 0x2fdfdfdfd5df9fd(locked|referenced|uptodate|dirty|lru|active|slab|owner_priv_1|private|private_2|writeback|head|tail|swapcache|reclaim|swapbacked|unevictable|uncached|compound_lock)
[   59.653604] Modules linked in: netconsole acpiphp pci_hotplug acpi_memhotplug loop kvm_amd kvm microcode tpm_tis tpm tpm_bios evdev psmouse serio_raw i2c_piix4 i2c_core parport_pc parport processor button thermal_sys ext3 jbd mbcache sg sr_mod cdrom ata_generic virtio_net ata_piix virtio_blk libata virtio_pci virtio_ring virtio scsi_mod
[   59.656998] Pid: 988, comm: bash Not tainted 3.6.0-rc7-guest #12
[   59.657172] Call Trace:
[   59.657275]  [<ffffffff810e9b30>] ? bad_page+0xb0/0x100
[   59.657434]  [<ffffffff810ea4c3>] ? free_pages_prepare+0xb3/0x100
[   59.657610]  [<ffffffff810ea668>] ? free_hot_cold_page+0x48/0x1a0
[   59.657787]  [<ffffffff8112cc08>] ? online_pages_range+0x68/0xa0
[   59.657961]  [<ffffffff8112cba0>] ? __online_page_increment_counters+0x10/0x10
[   59.658162]  [<ffffffff81045561>] ? walk_system_ram_range+0x101/0x110
[   59.658346]  [<ffffffff814c4f95>] ? online_pages+0x1a5/0x2b0
[   59.658515]  [<ffffffff8135663d>] ? __memory_block_change_state+0x20d/0x270
[   59.658710]  [<ffffffff81356756>] ? store_mem_state+0xb6/0xf0
[   59.658878]  [<ffffffff8119e482>] ? sysfs_write_file+0xd2/0x160
[   59.659052]  [<ffffffff8113769a>] ? vfs_write+0xaa/0x160
[   59.659212]  [<ffffffff81137977>] ? sys_write+0x47/0x90
[   59.659371]  [<ffffffff814e2f25>] ? async_page_fault+0x25/0x30
[   59.659543]  [<ffffffff814ea239>] ? system_call_fastpath+0x16/0x1b
[   59.659720] Disabling lock debugging due to kernel taint

This patch clears the memory to store struct page to avoid unexpected error.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Reported-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/sparse.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index fac95f2..0021265 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -638,7 +638,6 @@ static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 got_map_page:
 	ret = (struct page *)pfn_to_kaddr(page_to_pfn(page));
 got_map_ptr:
-	memset(ret, 0, memmap_size);
 
 	return ret;
 }
@@ -760,6 +759,8 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 		goto out;
 	}
 
+	memset(memmap, 0, sizeof(struct page) * nr_pages);
+
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
 	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
